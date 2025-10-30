#!/usr/bin/env python3
"""
Curate SHORT quotes from Readwise - prioritize brevity for shield UI
Select 6 shortest high-quality quotes per book for manual review
"""
import csv
import sys
from collections import defaultdict

class ShortQuoteCurator:
    def __init__(self, csv_path):
        self.csv_path = csv_path
        self.books = defaultdict(list)

    def load_csv(self, min_highlights=5):
        """Load and parse the Readwise CSV, books only"""
        print("📖 Loading Readwise CSV...")

        all_items = defaultdict(list)

        with open(self.csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for row in reader:
                book_title = self._get_field(row, ['Book Title', 'Title'])
                author = self._get_field(row, ['Book Author', 'Author'])
                highlight = self._get_field(row, ['Highlight', 'Text'])
                asin = self._get_field(row, ['Amazon Book ID', 'ASIN'])
                note = self._get_field(row, ['Note'])

                if not book_title or not highlight:
                    continue

                # Books only (has ASIN)
                if not asin or len(asin) != 10:
                    continue

                all_items[book_title].append({
                    'author': author,
                    'highlight': highlight,
                    'asin': asin,
                    'note': note,
                    'length': len(highlight),
                })

        # Filter to books with enough highlights
        for title, highlights in all_items.items():
            if len(highlights) >= min_highlights:
                self.books[title] = highlights

        print(f"✅ Loaded {len(self.books)} books with {min_highlights}+ highlights")

    def _get_field(self, row, possible_names):
        """Get field from row with multiple possible column names"""
        for name in possible_names:
            if name in row and row[name]:
                return row[name].strip()
        return None

    def select_short_quotes(self):
        """Select 6 shortest high-quality quotes per book"""
        print("\n🔍 Filtering and ranking by length...")

        curated = {}

        for book_title, highlights in self.books.items():
            candidates = []

            for h in highlights:
                text = h['highlight']

                # Quality filters
                if len(text) < 20:  # Too short, incomplete
                    continue
                if len(text) > 300:  # Too long for shield UI
                    continue
                if self._is_poor_quality(text):
                    continue

                # Calculate quality score (higher = better)
                score = self._calculate_quality_score(h)
                h['score'] = score

                candidates.append(h)

            # Sort by length (shortest first), then by score (highest first)
            candidates.sort(key=lambda x: (x['length'], -x['score']))

            # Take top 6 shortest
            curated[book_title] = candidates[:6]

        total = sum(len(quotes) for quotes in curated.values())
        avg_per_book = total / len(curated) if curated else 0
        print(f"✅ Selected {total} quotes (~{avg_per_book:.1f} per book)")

        return curated

    def _is_poor_quality(self, text):
        """Filter out poor quality quotes"""
        # Too many numbers (statistics/facts)
        if text.count('0') + text.count('1') + text.count('2') + text.count('3') > 5:
            return True

        # Starts with non-quote patterns
        bad_starts = ['chapter ', 'figure ', 'table ', 'http', 'www.']
        if any(text.lower().startswith(s) for s in bad_starts):
            return True

        # Too many line breaks (lists)
        if text.count('\n') > 2:
            return True

        return False

    def _calculate_quality_score(self, highlight):
        """Score quote quality (not used for ranking, just for tie-breaking)"""
        score = 100
        text = highlight['highlight']

        # Has user note = important
        if highlight['note']:
            score += 50

        # Complete sentence
        if text and text[0].isupper() and text[-1] in '.!?"':
            score += 20

        # Quote marks (actual dialogue)
        if '"' in text or '"' in text:
            score += 10

        # Inspirational keywords
        good_words = ['life', 'wisdom', 'success', 'lead', 'create', 'think']
        score += sum(10 for word in good_words if word in text.lower())

        return score

    def export_for_manual_curation(self, curated_quotes, output_path):
        """Export to editable TXT format"""
        print(f"\n📝 Exporting to {output_path}...")

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("=" * 80 + "\n")
            f.write("KINDLE QUOTES - MANUAL CURATION\n")
            f.write("=" * 80 + "\n")
            f.write("\n")
            f.write("INSTRUCTIONS:\n")
            f.write("1. Review the 6 quotes for each book (sorted shortest first)\n")
            f.write("2. Edit/approve the suggested TAGS for each quote\n")
            f.write("3. DELETE the 4 quotes you don't want (keep only 2 per book)\n")
            f.write("4. Save this file\n")
            f.write("5. Run: python3 finalize_quotes.py QUOTES_TO_CURATE.txt\n")
            f.write("\n")
            f.write("TAG OPTIONS:\n")
            f.write("business, leadership, strategy, creativity, success, wisdom, life,\n")
            f.write("learning, courage, discipline, inspiration, reading, thinking,\n")
            f.write("communication, power, decision, freedom, love, happiness\n")
            f.write("\n")
            f.write("=" * 80 + "\n")
            f.write("\n")

            # Sort books alphabetically
            for book_title in sorted(curated_quotes.keys()):
                quotes = curated_quotes[book_title]
                if not quotes:
                    continue

                author = quotes[0]['author']
                asin = quotes[0]['asin']

                f.write(f"BOOK: {book_title}\n")
                f.write(f"AUTHOR: {author}\n")
                f.write(f"ASIN: {asin}\n")
                f.write("\n")

                for i, q in enumerate(quotes, 1):
                    # Suggest tags
                    suggested_tags = self._suggest_tags(q['highlight'], book_title)

                    f.write(f"QUOTE {i}:\n")
                    f.write(f"{q['highlight']}\n")
                    f.write(f"\n")
                    f.write(f"LENGTH: {q['length']} chars\n")
                    f.write(f"TAGS: {', '.join(suggested_tags)}\n")
                    if q['note']:
                        f.write(f"YOUR NOTE: {q['note']}\n")
                    f.write("\n")

                f.write("-" * 80 + "\n")
                f.write("\n")

        print(f"✅ Exported {sum(len(q) for q in curated_quotes.values())} quotes")
        print(f"\n📋 Next steps:")
        print(f"1. Open: {output_path}")
        print(f"2. Keep 2 quotes per book, delete the rest")
        print(f"3. Edit tags as needed")
        print(f"4. Run: python3 finalize_quotes.py {output_path}")

    def _suggest_tags(self, text, book_title=''):
        """Suggest tags based on content"""
        tags = set()
        text_lower = text.lower()
        book_lower = book_title.lower()

        tag_keywords = {
            'business': ['business', 'company', 'startup', 'entrepreneur', 'customer', 'product'],
            'leadership': ['lead', 'leader', 'manage', 'team', 'ceo', 'executive'],
            'strategy': ['strategy', 'plan', 'goal', 'vision'],
            'creativity': ['creative', 'create', 'innovation', 'design', 'invent'],
            'success': ['success', 'achieve', 'accomplish', 'win'],
            'wisdom': ['wisdom', 'knowledge', 'truth', 'understand', 'principle'],
            'life': ['life', 'living', 'people', 'human'],
            'learning': ['learn', 'education', 'teach', 'skill'],
            'courage': ['courage', 'brave', 'strength', 'risk', 'fear'],
            'discipline': ['discipline', 'focus', 'habit', 'routine'],
            'inspiration': ['inspire', 'motivate', 'hope'],
            'reading': ['read', 'book', 'story', 'page'],
            'thinking': ['think', 'thought', 'mind', 'idea'],
            'communication': ['communicate', 'speak', 'talk', 'listen'],
            'power': ['power', 'influence', 'control'],
            'decision': ['decide', 'choice', 'choose'],
            'freedom': ['free', 'freedom', 'liberty', 'independent'],
            'love': ['love', 'heart', 'soul', 'passion'],
            'happiness': ['happy', 'joy', 'delight'],
        }

        for tag, keywords in tag_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                tags.add(tag)

        # Fallback based on book title
        if not tags:
            if 'business' in book_lower or 'company' in book_lower:
                tags.add('business')
            elif 'lead' in book_lower or 'power' in book_lower:
                tags.add('leadership')
            else:
                tags.add('wisdom')

        return sorted(list(tags))[:3]

def main():
    if len(sys.argv) < 2:
        print("Usage: python curate_short_quotes.py <readwise_csv>")
        sys.exit(1)

    csv_path = sys.argv[1]

    curator = ShortQuoteCurator(csv_path)
    curator.load_csv(min_highlights=5)
    curated = curator.select_short_quotes()
    curator.export_for_manual_curation(curated, 'QUOTES_TO_CURATE.txt')

if __name__ == "__main__":
    main()
