#!/usr/bin/env python3
"""
Analyze Readwise CSV structure and provide statistics
"""
import csv
import sys
from collections import defaultdict, Counter

def detect_source_type(title, author, asin):
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

def analyze_csv(filepath):
    """Analyze the Readwise CSV to understand structure"""

    # Read first few rows to understand structure
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames

        print("=" * 60)
        print("READWISE CSV ANALYSIS")
        print("=" * 60)

        print("\n📋 COLUMN HEADERS:")
        for i, header in enumerate(headers, 1):
            print(f"  {i}. {header}")

        # Collect statistics
        books = defaultdict(list)
        total_rows = 0
        highlight_lengths = []
        source_stats = {'books': 0, 'articles': 0, 'tweets': 0, 'other': 0}

        print("\n📊 Analyzing highlights...")
        for row in reader:
            total_rows += 1

            # Get book identifier (try different possible column names)
            book_title = (row.get('Book Title') or
                         row.get('Title') or
                         row.get('book_title') or
                         row.get('title') or
                         'Unknown')

            # Get highlight text
            highlight = (row.get('Highlight') or
                        row.get('Text') or
                        row.get('highlight') or
                        row.get('text') or
                        '')

            # Get ASIN
            asin = (row.get('Amazon Book ID') or
                   row.get('ASIN') or
                   row.get('asin') or
                   row.get('Book ID') or
                   '')

            # Get author
            author = (row.get('Book Author') or
                     row.get('Author') or
                     row.get('author') or
                     '')

            # Detect source type
            source_type = detect_source_type(book_title, author, asin)

            books[book_title].append({
                'text': highlight,
                'length': len(highlight),
                'row': row,
                'asin': asin,
                'author': author,
                'source_type': source_type
            })

            if highlight:
                highlight_lengths.append(len(highlight))

        # Count source types
        for title, highlights in books.items():
            source_type = highlights[0]['source_type']
            source_stats[source_type] += 1

        # Statistics
        print(f"\n📈 STATISTICS:")
        print(f"  Total highlights: {total_rows:,}")
        print(f"  Unique items: {len(books)}")
        print(f"  Average highlights per item: {total_rows / len(books):.1f}")

        print(f"\n📚 SOURCE BREAKDOWN:")
        kindle_books = [t for t, h in books.items() if h[0]['source_type'] == 'books']
        articles = [t for t, h in books.items() if h[0]['source_type'] == 'articles']
        tweets = [t for t, h in books.items() if h[0]['source_type'] == 'tweets']
        other = [t for t, h in books.items() if h[0]['source_type'] == 'other']

        print(f"  📕 Kindle Books: {len(kindle_books)} ({sum(len(books[t]) for t in kindle_books)} highlights)")
        print(f"  📰 Articles: {len(articles)} ({sum(len(books[t]) for t in articles)} highlights)")
        print(f"  🐦 Tweets: {len(tweets)} ({sum(len(books[t]) for t in tweets)} highlights)")
        print(f"  ❓ Other: {len(other)} ({sum(len(books[t]) for t in other)} highlights)")

        # Books with enough highlights for curation
        substantial_books = [t for t in kindle_books if len(books[t]) >= 5]
        print(f"\n💡 RECOMMENDATION:")
        print(f"  Books with 5+ highlights: {len(substantial_books)}")
        print(f"  Books with 10+ highlights: {len([t for t in kindle_books if len(books[t]) >= 10])}")
        print(f"  → Suggested for PageInstead: {len(substantial_books)} books × 2 quotes = {len(substantial_books) * 2} total quotes")

        if highlight_lengths:
            print(f"\n📏 HIGHLIGHT LENGTHS:")
            print(f"  Shortest: {min(highlight_lengths)} chars")
            print(f"  Longest: {max(highlight_lengths)} chars")
            print(f"  Average: {sum(highlight_lengths) / len(highlight_lengths):.0f} chars")
            print(f"  Median: {sorted(highlight_lengths)[len(highlight_lengths)//2]} chars")

        # Books with most highlights (Kindle books only)
        print(f"\n📚 TOP 10 KINDLE BOOKS BY HIGHLIGHT COUNT:")
        book_counts = [(title, len(highlights)) for title, highlights in books.items() if highlights[0]['source_type'] == 'books']
        book_counts.sort(key=lambda x: x[1], reverse=True)

        for i, (title, count) in enumerate(book_counts[:10], 1):
            author = books[title][0].get('author', 'Unknown')
            print(f"  {i}. {title[:45]:<45} by {author[:20]:<20} ({count} highlights)")

        # Books with fewest highlights (but still substantial)
        print(f"\n📖 KINDLE BOOKS WITH 5-10 HIGHLIGHTS:")
        moderate_books = [(t, c) for t, c in book_counts if 5 <= c <= 10][:5]
        for i, (title, count) in enumerate(moderate_books, 1):
            author = books[title][0].get('author', 'Unknown')
            print(f"  {i}. {title[:45]:<45} by {author[:20]:<20} ({count} highlights)")

        # Sample highlights from first book
        if book_counts:
            first_book_title = book_counts[0][0]
            print(f"\n💡 SAMPLE HIGHLIGHTS FROM: {first_book_title}")
            for i, highlight in enumerate(books[first_book_title][:3], 1):
                text = highlight['text'][:100] + "..." if len(highlight['text']) > 100 else highlight['text']
                print(f"  {i}. [{highlight['length']} chars] {text}")

        print("\n" + "=" * 60)
        print(f"✅ Analysis complete!")
        print("=" * 60)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python analyze_readwise_csv.py <path_to_csv>")
        sys.exit(1)

    csv_path = sys.argv[1]
    analyze_csv(csv_path)
