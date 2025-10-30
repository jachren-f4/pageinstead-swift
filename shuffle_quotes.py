#!/usr/bin/env python3
"""
Shuffle quotes to ensure quotes from the same book are spread out
Uses intelligent shuffling to maximize distance between same-book quotes
"""
import json
import random
from collections import defaultdict

def shuffle_quotes_intelligently(quotes):
    """Shuffle quotes ensuring same-book quotes are maximally separated"""

    # Group quotes by book
    by_book = defaultdict(list)
    for q in quotes:
        by_book[q['bookTitle']].append(q)

    print(f"📚 {len(by_book)} unique books")
    print(f"📝 {len(quotes)} total quotes")

    # Check distribution
    books_with_2 = sum(1 for book_quotes in by_book.values() if len(book_quotes) == 2)
    print(f"✅ {books_with_2} books have exactly 2 quotes")

    # Strategy: Interleave quotes from different books
    # Create multiple passes through all books
    shuffled = []

    # Get all book titles shuffled
    book_titles = list(by_book.keys())
    random.shuffle(book_titles)

    # First pass: Take first quote from each book (shuffled order)
    for book_title in book_titles:
        if by_book[book_title]:
            shuffled.append(by_book[book_title].pop(0))

    # Second pass: Take remaining quotes (shuffled order)
    random.shuffle(book_titles)
    for book_title in book_titles:
        while by_book[book_title]:
            shuffled.append(by_book[book_title].pop(0))

    # Verify separation
    print(f"\n📊 SHUFFLE VERIFICATION:")

    # Check minimum distance between same-book quotes
    book_positions = defaultdict(list)
    for i, q in enumerate(shuffled):
        book_positions[q['bookTitle']].append(i)

    distances = []
    for book_title, positions in book_positions.items():
        if len(positions) > 1:
            dist = positions[1] - positions[0]
            distances.append(dist)

    if distances:
        print(f"  Min distance between same-book quotes: {min(distances)} positions")
        print(f"  Max distance: {max(distances)} positions")
        print(f"  Average distance: {sum(distances) / len(distances):.1f} positions")
        print(f"  → Same-book quotes separated by {min(distances) * 5} - {max(distances) * 5} minutes")

    # Re-assign IDs
    for i, q in enumerate(shuffled, start=1):
        q['id'] = i

    return shuffled

def main():
    import sys

    if len(sys.argv) < 2:
        input_file = 'PageInstead/Resources/quotes.json'
    else:
        input_file = sys.argv[1]

    print(f"📖 Loading {input_file}...")

    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    original_quotes = data['quotes']

    print(f"📊 BEFORE SHUFFLE:")
    print(f"  Total quotes: {len(original_quotes)}")

    # Check current clustering
    consecutive_same_book = 0
    for i in range(len(original_quotes) - 1):
        if original_quotes[i]['bookTitle'] == original_quotes[i + 1]['bookTitle']:
            consecutive_same_book += 1

    print(f"  Consecutive same-book pairs: {consecutive_same_book}")

    # Shuffle
    print(f"\n🔀 SHUFFLING...")
    shuffled_quotes = shuffle_quotes_intelligently(original_quotes)

    # Update data
    data['quotes'] = shuffled_quotes

    # Save
    output_file = input_file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Saved shuffled quotes to {output_file}")

    # Show examples
    print(f"\n📝 SAMPLE SHUFFLED ORDER (first 10):")
    for i, q in enumerate(shuffled_quotes[:10], 1):
        text = q['text'][:60] + '...' if len(q['text']) > 60 else q['text']
        print(f"  {i:3}. [{q['bookTitle'][:30]:30}] \"{text}\"")

    print(f"\n🎉 Done! Quotes from the same book are now spread out.")

if __name__ == '__main__':
    main()
