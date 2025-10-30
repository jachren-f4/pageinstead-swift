#!/usr/bin/env python3
"""
Curate Kindle highlights from Readwise CSV export
Multi-stage filtering to select best 2 quotes per book
"""
import csv
import json
import re
from collections import defaultdict
from datetime import datetime
import sys

class QuoteCurator:
    def __init__(self, csv_path):
        self.csv_path = csv_path
        self.books = defaultdict(list)
        self.filtered_quotes = defaultdict(list)

    def load_csv(self, books_only=True, min_highlights=5):
        """Load and parse the Readwise CSV"""
        print("📖 Loading Readwise CSV...")

        all_items = defaultdict(list)
        stats = {
            'books': 0,
            'articles': 0,
            'tweets': 0,
            'other': 0,
            'total_highlights': 0
        }

        with open(self.csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            self.headers = reader.fieldnames

            for row in reader:
                # Extract key fields (handle different CSV formats)
                book_title = self._get_field(row, ['Book Title', 'Title', 'book_title'])
                author = self._get_field(row, ['Author', 'author', 'Book Author'])
                highlight = self._get_field(row, ['Highlight', 'Text', 'highlight', 'text'])
                note = self._get_field(row, ['Note', 'note', 'Notes'])
                location = self._get_field(row, ['Location', 'location'])
                asin = self._get_field(row, ['ASIN', 'asin', 'Book ID', 'Amazon Book ID'])

                if not book_title or not highlight:
                    continue

                stats['total_highlights'] += 1

                # Detect source type
                source_type = self._detect_source_type(book_title, author, asin)

                all_items[book_title].append({
                    'author': author,
                    'highlight': highlight,
                    'note': note,
                    'location': location,
                    'asin': asin,
                    'length': len(highlight),
                    'source_type': source_type
                })

        # Count source types
        for title, highlights in all_items.items():
            source_type = highlights[0]['source_type']
            stats[source_type] += 1

        # Filter to books only if requested
        if books_only:
            print("\n🔍 Filtering to Kindle books only...")
            for title, highlights in all_items.items():
                source_type = highlights[0]['source_type']
                if source_type == 'books' and len(highlights) >= min_highlights:
                    self.books[title] = highlights

            print(f"\n📊 SOURCE BREAKDOWN:")
            print(f"  📚 Kindle Books: {stats['books']} ({sum(len(h) for t, h in all_items.items() if h[0]['source_type'] == 'books')} highlights)")
            print(f"  📰 Articles: {stats['articles']} ({sum(len(h) for t, h in all_items.items() if h[0]['source_type'] == 'articles')} highlights)")
            print(f"  🐦 Tweets: {stats['tweets']} ({sum(len(h) for t, h in all_items.items() if h[0]['source_type'] == 'tweets')} highlights)")
            print(f"  ❓ Other: {stats['other']} ({sum(len(h) for t, h in all_items.items() if h[0]['source_type'] == 'other')} highlights)")
            print(f"\n✅ Using: {len(self.books)} books with {min_highlights}+ highlights")
        else:
            self.books = all_items
            print(f"✅ Loaded all {len(self.books)} items")

        total_kept = sum(len(h) for h in self.books.values())
        print(f"📊 Total highlights to process: {total_kept:,}")

    def _detect_source_type(self, title, author, asin):
        """Detect if this is a book, article, tweet, etc."""
        title_lower = title.lower() if title else ''

        # Tweets
        if 'tweets from' in title_lower or 'tweet from' in title_lower:
            return 'tweets'

        # Books (has ASIN)
        if asin and len(asin) == 10:
            return 'books'

        # Articles (no ASIN, has author, reasonable title)
        if not asin and author and len(title) > 10:
            return 'articles'

        return 'other'

    def _get_field(self, row, possible_names):
        """Get field from row with multiple possible column names"""
        for name in possible_names:
            if name in row and row[name]:
                return row[name].strip()
        return None

    def stage1_automatic_filter(self):
        """Stage 1: Automatic filtering to reduce 40k → ~1000"""
        print("\n🔍 Stage 1: Automatic Filtering")
        print("-" * 60)

        for book_title, highlights in self.books.items():
            candidates = []

            for h in highlights:
                text = h['highlight']

                # Length filter (50-200 chars is sweet spot)
                if len(text) < 40 or len(text) > 500:
                    continue

                # Remove non-quotes
                if self._is_likely_not_quote(text):
                    continue

                # Calculate score
                score = self._calculate_quote_score(h)
                h['score'] = score

                candidates.append(h)

            # Sort by score and take top 10 per book
            candidates.sort(key=lambda x: x['score'], reverse=True)
            self.filtered_quotes[book_title] = candidates[:10]

        total_filtered = sum(len(h) for h in self.filtered_quotes.values())
        print(f"✅ Filtered to {total_filtered} candidate quotes (~{total_filtered / len(self.books):.1f} per book)")

    def _is_likely_not_quote(self, text):
        """Detect if text is likely not a good quote"""
        # Too many numbers (probably a fact/statistic)
        if len(re.findall(r'\d+', text)) > 3:
            return True

        # Starts with common non-quote patterns
        non_quote_starts = [
            'chapter ', 'figure ', 'table ', 'see page',
            'according to', 'in the year', 'references:',
            'http://', 'https://', 'www.'
        ]
        text_lower = text.lower()
        if any(text_lower.startswith(pattern) for pattern in non_quote_starts):
            return True

        # Too many bullet points or lists
        if text.count('•') > 2 or text.count('\n') > 3:
            return True

        return False

    def _calculate_quote_score(self, highlight):
        """Score a quote based on various factors"""
        text = highlight['highlight']
        score = 100  # Base score

        # Length scoring (prefer 80-150 chars)
        length = len(text)
        if 80 <= length <= 150:
            score += 30
        elif 50 <= length <= 200:
            score += 15

        # Has user note (indicates importance)
        if highlight['note']:
            score += 50

        # Quote markers (actual dialogue/quote)
        if '"' in text or '"' in text or '"' in text:
            score += 10

        # Inspirational/philosophical keywords
        inspirational_words = [
            'life', 'love', 'truth', 'beauty', 'wisdom', 'freedom',
            'happiness', 'meaning', 'purpose', 'soul', 'heart',
            'believe', 'hope', 'dream', 'courage', 'strength'
        ]
        text_lower = text.lower()
        score += sum(10 for word in inspirational_words if word in text_lower)

        # Reading/book related (perfect for PageInstead)
        reading_words = ['read', 'book', 'story', 'write', 'word', 'page', 'library']
        score += sum(20 for word in reading_words if word in text_lower)

        # Sentence completeness (starts with capital, ends with punctuation)
        if text and text[0].isupper() and text[-1] in '.!?"':
            score += 15

        # Avoid questions (usually not good standalone quotes)
        if '?' in text:
            score -= 10

        return score

    def stage2_export_for_review(self, output_path):
        """Stage 2: Export to JSON for manual review"""
        print("\n📝 Stage 2: Exporting for Review")
        print("-" * 60)

        review_data = []

        for book_title, highlights in sorted(self.filtered_quotes.items()):
            if not highlights:
                continue

            # Get book metadata from first highlight
            first = highlights[0]

            book_entry = {
                'book_title': book_title,
                'author': first['author'],
                'asin': first['asin'],
                'highlight_count': len(self.books[book_title]),
                'candidates': []
            }

            for h in highlights[:10]:  # Max 10 candidates per book
                book_entry['candidates'].append({
                    'text': h['highlight'],
                    'score': h['score'],
                    'length': h['length'],
                    'note': h['note'],
                    'selected': False  # User will mark true for final 2
                })

            review_data.append(book_entry)

        # Save to JSON
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(review_data, f, indent=2, ensure_ascii=False)

        print(f"✅ Exported {len(review_data)} books to {output_path}")
        print(f"📊 Total candidate quotes: {sum(len(b['candidates']) for b in review_data)}")

    def stage3_auto_select_top2(self):
        """Stage 3: Automatically select top 2 per book (for quick start)"""
        print("\n🎯 Stage 3: Auto-selecting top 2 per book")
        print("-" * 60)

        final_quotes = []

        for book_title, highlights in sorted(self.filtered_quotes.items()):
            if not highlights:
                continue

            # Take top 2 by score
            top2 = highlights[:2]

            for h in top2:
                final_quotes.append({
                    'book_title': book_title,
                    'author': h['author'],
                    'highlight': h['highlight'],
                    'asin': h['asin'],
                    'score': h['score']
                })

        print(f"✅ Selected {len(final_quotes)} final quotes (2 per book)")
        return final_quotes

    def export_to_pageinstead_format(self, quotes, output_path):
        """Convert to PageInstead quotes.json format"""
        print("\n📤 Exporting to PageInstead Format")
        print("-" * 60)

        page_instead_quotes = []

        for idx, q in enumerate(quotes, start=1):
            # Generate book ID
            author_slug = q['author'].lower().replace(' ', '_').replace('.', '') if q['author'] else 'unknown'
            book_id = f"{author_slug}_{hash(q['book_title']) % 10000:04d}"

            # Generate cover URL
            cover_url = None
            if q['asin']:
                cover_url = f"https://m.media-amazon.com/images/P/{q['asin']}.jpg"

            # Extract tags
            tags = self._extract_tags(q['highlight'])

            page_instead_quotes.append({
                'id': idx,
                'text': q['highlight'],
                'author': q['author'] or 'Unknown',
                'bookTitle': q['book_title'],
                'bookId': book_id,
                'asin': q['asin'],
                'coverImageURL': cover_url,
                'isActive': True,
                'tags': tags,
                'dateAdded': datetime.now().strftime('%Y-%m-%d')
            })

        # Create final JSON structure
        output_data = {
            'version': 1,
            'lastUpdated': datetime.now().strftime('%Y-%m-%d'),
            'quotes': page_instead_quotes
        }

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)

        print(f"✅ Exported {len(page_instead_quotes)} quotes to {output_path}")
        print(f"📝 Ready to use in PageInstead!")

    def _extract_tags(self, text):
        """Extract tags from quote text"""
        tags = set()
        text_lower = text.lower()

        tag_keywords = {
            'reading': ['read', 'reading', 'book', 'books'],
            'life': ['life', 'living', 'alive'],
            'wisdom': ['wisdom', 'wise', 'knowledge', 'truth'],
            'love': ['love', 'heart', 'soul'],
            'freedom': ['free', 'freedom', 'liberty'],
            'courage': ['courage', 'brave', 'strength'],
            'learning': ['learn', 'education', 'teach'],
            'imagination': ['imagine', 'imagination', 'dream'],
            'happiness': ['happy', 'happiness', 'joy'],
            'inspiration': ['inspire', 'inspiration', 'hope']
        }

        for tag, keywords in tag_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                tags.add(tag)

        # Default to reading if no tags
        if not tags:
            tags.add('reading')

        return sorted(list(tags))[:3]  # Max 3 tags

def main():
    if len(sys.argv) < 2:
        print("Usage: python curate_kindle_quotes.py <readwise_csv> [options]")
        print("\nOptions:")
        print("  --auto              Automatically select top 2 per book (quick mode)")
        print("  --review            Export for manual review (default)")
        print("  --all-sources       Include articles/tweets (not just books)")
        print("  --min-highlights N  Minimum highlights per book (default: 5)")
        print("\nExamples:")
        print("  python curate_kindle_quotes.py readwise.csv")
        print("  python curate_kindle_quotes.py readwise.csv --auto")
        print("  python curate_kindle_quotes.py readwise.csv --min-highlights 10")
        sys.exit(1)

    csv_path = sys.argv[1]
    auto_mode = '--auto' in sys.argv
    all_sources = '--all-sources' in sys.argv

    # Parse min-highlights argument
    min_highlights = 5
    for i, arg in enumerate(sys.argv):
        if arg == '--min-highlights' and i + 1 < len(sys.argv):
            try:
                min_highlights = int(sys.argv[i + 1])
            except ValueError:
                print("Error: --min-highlights must be followed by a number")
                sys.exit(1)

    curator = QuoteCurator(csv_path)
    curator.load_csv(books_only=not all_sources, min_highlights=min_highlights)
    curator.stage1_automatic_filter()

    if auto_mode:
        # Quick mode: auto-select top 2
        final_quotes = curator.stage3_auto_select_top2()
        curator.export_to_pageinstead_format(
            final_quotes,
            'kindle_highlights_curated.json'
        )
        print("\n✅ Complete! Import 'kindle_highlights_curated.json' into PageInstead")
    else:
        # Review mode: export candidates for manual selection
        curator.stage2_export_for_review('kindle_highlights_review.json')
        print("\n📋 Next steps:")
        print("1. Review 'kindle_highlights_review.json'")
        print("2. Mark your favorite 2 quotes per book (set 'selected': true)")
        print("3. Run: python finalize_selection.py kindle_highlights_review.json")

if __name__ == "__main__":
    main()
