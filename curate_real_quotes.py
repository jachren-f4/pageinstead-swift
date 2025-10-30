#!/usr/bin/env python3
"""
Curate REAL quotes - filter out chapter headings and section titles
Prefer short, meaningful quotes with complete thoughts
"""
import csv
import sys
import re
from collections import defaultdict

class RealQuoteCurator:
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

    def select_real_quotes(self):
        """Select real quotes - filter out chapter headings"""
        print("\n🔍 Analyzing quotes for quality...")

        curated = {}
        stats = {
            'total_highlights': 0,
            'filtered_chapter_headings': 0,
            'filtered_too_short': 0,
            'filtered_too_long': 0,
            'filtered_poor_quality': 0,
            'kept': 0
        }

        for book_title, highlights in self.books.items():
            candidates = []

            for h in highlights:
                text = h['highlight']
                stats['total_highlights'] += 1

                # Length filters
                if len(text) < 25:  # Too short
                    stats['filtered_too_short'] += 1
                    continue
                if len(text) > 250:  # Too long for shield
                    stats['filtered_too_long'] += 1
                    continue

                # Detect chapter headings/section titles
                if self._is_chapter_heading(text):
                    stats['filtered_chapter_headings'] += 1
                    continue

                # Quality check
                if self._is_poor_quality(text):
                    stats['filtered_poor_quality'] += 1
                    continue

                # Calculate "realness" score
                realness_score = self._calculate_realness_score(h)
                h['realness'] = realness_score
                h['score'] = realness_score

                candidates.append(h)
                stats['kept'] += 1

            # Sort by realness (highest first), then length (shortest first)
            candidates.sort(key=lambda x: (-x['realness'], x['length']))

            # Take top 6
            curated[book_title] = candidates[:6]

        print(f"\n📊 FILTERING STATS:")
        print(f"  Total highlights processed: {stats['total_highlights']}")
        print(f"  ❌ Filtered chapter headings: {stats['filtered_chapter_headings']}")
        print(f"  ❌ Filtered too short: {stats['filtered_too_short']}")
        print(f"  ❌ Filtered too long: {stats['filtered_too_long']}")
        print(f"  ❌ Filtered poor quality: {stats['filtered_poor_quality']}")
        print(f"  ✅ Kept high-quality quotes: {stats['kept']}")

        total = sum(len(quotes) for quotes in curated.values())
        avg_per_book = total / len(curated) if curated else 0
        print(f"\n✅ Selected {total} quotes (~{avg_per_book:.1f} per book)")

        return curated

    def _is_chapter_heading(self, text):
        """Detect if text is a chapter heading or section title"""
        text_stripped = text.strip()
        text_lower = text_stripped.lower()

        # Pattern 1: Starts with chapter/part/section keywords
        heading_keywords = [
            'chapter ', 'part ', 'section ', 'phase ', 'step ',
            'lesson ', 'appendix', 'introduction', 'conclusion',
            'preface', 'foreword', 'prologue', 'epilogue'
        ]
        if any(text_lower.startswith(kw) for kw in heading_keywords):
            return True

        # Pattern 2: Contains chapter/part mid-text with numbers
        if re.search(r'\b(chapter|part|section|phase|step)\s+\d+', text_lower):
            return True

        # Pattern 3: Starts with just a number and colon/period
        if re.match(r'^\d+[\.:]\s+[A-Z]', text_stripped):
            return True

        # Pattern 4: All caps or mostly caps (likely heading)
        if len(text_stripped) < 100:  # Only check short text
            uppercase_count = sum(1 for c in text_stripped if c.isupper())
            letter_count = sum(1 for c in text_stripped if c.isalpha())
            if letter_count > 0 and uppercase_count / letter_count > 0.7:
                return True

        # Pattern 5: Title Case with no ending punctuation (likely heading)
        words = text_stripped.split()
        if len(words) <= 8 and not text_stripped[-1] in '.!?"':
            # Check if Title Case (most words start with capital)
            capitalized = sum(1 for w in words if w and w[0].isupper())
            if capitalized >= len(words) * 0.7:
                return True

        # Pattern 6: Very short with no verbs (likely heading)
        if len(text_stripped) < 60:
            # Common verbs
            common_verbs = ['is', 'are', 'was', 'were', 'be', 'been', 'being',
                           'have', 'has', 'had', 'do', 'does', 'did',
                           'will', 'would', 'should', 'could', 'can', 'may',
                           'get', 'make', 'take', 'think', 'know', 'see',
                           'come', 'go', 'say', 'find', 'give', 'tell', 'feel']
            has_verb = any(verb in text_lower.split() for verb in common_verbs)
            if not has_verb:
                return True

        return False

    def _is_poor_quality(self, text):
        """Filter out poor quality quotes"""
        # Too many numbers (likely statistics/references)
        digit_count = sum(1 for c in text if c.isdigit())
        if digit_count > 10:
            return True

        # Starts with URLs or references
        bad_starts = ['http', 'www.', 'see page', 'figure ', 'table ']
        if any(text.lower().startswith(s) for s in bad_starts):
            return True

        # Too many line breaks (likely list/formatting)
        if text.count('\n') > 3:
            return True

        # Too many bullet points or dashes
        if text.count('•') > 2 or text.count('\n-') > 2:
            return True

        return False

    def _calculate_realness_score(self, highlight):
        """Score how 'real' a quote is (higher = better actual quote)"""
        score = 100
        text = highlight['highlight']
        text_lower = text.lower()

        # Bonus for complete sentences (ends with punctuation)
        if text and text[-1] in '.!?"':
            score += 30

        # Bonus for having verbs (indicates complete thought)
        common_verbs = ['is', 'are', 'was', 'were', 'be', 'been',
                       'have', 'has', 'had', 'do', 'does', 'did',
                       'will', 'would', 'should', 'could', 'can',
                       'make', 'take', 'get', 'think', 'know', 'need',
                       'want', 'become', 'learn', 'create', 'build']
        verb_count = sum(1 for verb in common_verbs if f' {verb} ' in f' {text_lower} ')
        score += verb_count * 15

        # Bonus for articles (a, an, the) - indicates natural language
        article_count = (text_lower.count(' a ') +
                        text_lower.count(' an ') +
                        text_lower.count(' the '))
        score += article_count * 10

        # Bonus for pronouns - indicates direct communication
        pronouns = ['you', 'your', 'i', 'we', 'our', 'they', 'them']
        pronoun_count = sum(1 for p in pronouns if f' {p} ' in f' {text_lower} ')
        score += pronoun_count * 12

        # Bonus for conjunctions - indicates complex thought
        conjunctions = ['and', 'but', 'or', 'because', 'if', 'when', 'while', 'although']
        conjunction_count = sum(1 for c in conjunctions if f' {c} ' in f' {text_lower} ')
        score += conjunction_count * 10

        # Bonus for user note (they found it meaningful)
        if highlight['note']:
            score += 50

        # Penalty for being too short (incomplete thought)
        if len(text) < 40:
            score -= 20

        # Bonus for optimal length (readable on shield)
        if 40 <= len(text) <= 120:
            score += 25
        elif 121 <= len(text) <= 180:
            score += 10

        # Bonus for starting with capital and ending with punctuation
        if text and text[0].isupper() and text[-1] in '.!?"':
            score += 15

        # Bonus for quote marks (dialogue or cited quote)
        if '"' in text or '"' in text or "'" in text:
            score += 10

        return score

    def export_for_manual_curation(self, curated_quotes, output_path):
        """Export to editable TXT format"""
        print(f"\n📝 Exporting to {output_path}...")

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("=" * 80 + "\n")
            f.write("KINDLE QUOTES - MANUAL CURATION (REAL QUOTES ONLY)\n")
            f.write("=" * 80 + "\n")
            f.write("\n")
            f.write("INSTRUCTIONS:\n")
            f.write("1. Review the 6 quotes for each book (sorted by quality)\n")
            f.write("2. Edit/approve the suggested TAGS for each quote\n")
            f.write("3. DELETE the 4 quotes you don't want (keep only 2 per book)\n")
            f.write("4. Save this file\n")
            f.write("5. Run: python3 finalize_quotes.py QUOTES_TO_CURATE.txt\n")
            f.write("\n")
            f.write("NOTE: Chapter headings and section titles have been filtered out.\n")
            f.write("These are real quotes that scored high on 'realness' metrics:\n")
            f.write("- Complete sentences with verbs\n")
            f.write("- Natural language (articles, pronouns, conjunctions)\n")
            f.write("- Optimal length (25-250 chars)\n")
            f.write("- Your highlights that meant something to you\n")
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
                    f.write(f"LENGTH: {q['length']} chars | QUALITY SCORE: {q['realness']}\n")
                    f.write(f"TAGS: {', '.join(suggested_tags)}\n")
                    if q['note']:
                        f.write(f"YOUR NOTE: {q['note']}\n")
                    f.write("\n")

                f.write("-" * 80 + "\n")
                f.write("\n")

        print(f"✅ Exported {sum(len(q) for q in curated_quotes.values())} high-quality quotes")
        print(f"\n📋 Next steps:")
        print(f"1. Open: {output_path}")
        print(f"2. Keep 2 quotes per book, delete the rest")
        print(f"3. Edit tags as needed")
        print(f"4. Run: python3 finalize_quotes.py {output_path}")

    def _suggest_tags(self, text, book_title=''):
        """Suggest tags based on content"""
        tags = set()
        text_lower = text.lower()

        tag_keywords = {
            'business': ['business', 'company', 'startup', 'entrepreneur', 'customer', 'product', 'market'],
            'leadership': ['lead', 'leader', 'manage', 'team', 'ceo', 'executive', 'organization'],
            'strategy': ['strategy', 'plan', 'goal', 'vision', 'mission'],
            'creativity': ['creative', 'create', 'innovation', 'design', 'invent', 'original'],
            'success': ['success', 'achieve', 'accomplish', 'win', 'excel'],
            'wisdom': ['wisdom', 'knowledge', 'truth', 'understand', 'principle', 'insight'],
            'life': ['life', 'living', 'people', 'human', 'world'],
            'learning': ['learn', 'education', 'teach', 'skill', 'practice'],
            'courage': ['courage', 'brave', 'strength', 'risk', 'fear', 'bold'],
            'discipline': ['discipline', 'focus', 'habit', 'routine', 'consistent'],
            'inspiration': ['inspire', 'motivate', 'hope', 'aspire'],
            'reading': ['read', 'book', 'story', 'page', 'write', 'author'],
            'thinking': ['think', 'thought', 'mind', 'idea', 'reflect', 'consider'],
            'communication': ['communicate', 'speak', 'talk', 'listen', 'say', 'tell'],
            'power': ['power', 'influence', 'control', 'authority'],
            'decision': ['decide', 'choice', 'choose', 'judgment'],
            'freedom': ['free', 'freedom', 'liberty', 'independent'],
            'love': ['love', 'heart', 'soul', 'passion', 'care'],
            'happiness': ['happy', 'joy', 'delight', 'pleasure'],
        }

        for tag, keywords in tag_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                tags.add(tag)

        # Fallback
        if not tags:
            tags.add('wisdom')

        return sorted(list(tags))[:3]

def main():
    if len(sys.argv) < 2:
        print("Usage: python curate_real_quotes.py <readwise_csv>")
        sys.exit(1)

    csv_path = sys.argv[1]

    curator = RealQuoteCurator(csv_path)
    curator.load_csv(min_highlights=5)
    curated = curator.select_real_quotes()
    curator.export_for_manual_curation(curated, 'QUOTES_TO_CURATE.txt')

if __name__ == "__main__":
    main()
