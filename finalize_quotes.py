#!/usr/bin/env python3
"""
Convert manually curated TXT file to PageInstead quotes.json format
"""
import sys
import json
import re
from datetime import datetime

def parse_curated_txt(filepath):
    """Parse the manually edited TXT file"""
    print(f"📖 Reading {filepath}...")

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by book sections
    book_sections = content.split('-' * 80)

    quotes = []
    current_book = None
    current_author = None
    current_asin = None

    for section in book_sections:
        lines = section.strip().split('\n')
        if not lines:
            continue

        # Parse book metadata
        for line in lines:
            if line.startswith('BOOK:'):
                current_book = line.replace('BOOK:', '').strip()
            elif line.startswith('AUTHOR:'):
                current_author = line.replace('AUTHOR:', '').strip()
            elif line.startswith('ASIN:'):
                current_asin = line.replace('ASIN:', '').strip()

        # Find quotes
        i = 0
        while i < len(lines):
            line = lines[i].strip()

            if line.startswith('QUOTE'):
                # Start of a quote block
                i += 1

                # Collect quote text (everything until LENGTH: or TAGS:)
                quote_lines = []
                while i < len(lines):
                    current_line = lines[i]
                    if current_line.startswith('LENGTH:') or current_line.startswith('TAGS:'):
                        break
                    if current_line.strip():
                        quote_lines.append(current_line)
                    i += 1

                quote_text = '\n'.join(quote_lines).strip()

                # Get tags
                tags = []
                while i < len(lines):
                    current_line = lines[i].strip()
                    if current_line.startswith('TAGS:'):
                        tags_str = current_line.replace('TAGS:', '').strip()
                        tags = [t.strip() for t in tags_str.split(',') if t.strip()]
                        break
                    i += 1

                # Only add if we have valid data
                if quote_text and current_book and current_author:
                    quotes.append({
                        'text': quote_text,
                        'author': current_author,
                        'book_title': current_book,
                        'asin': current_asin,
                        'tags': tags if tags else ['wisdom']
                    })

            i += 1

    print(f"✅ Parsed {len(quotes)} quotes")
    return quotes

def convert_to_pageinstead(quotes, output_path):
    """Convert to PageInstead format"""
    print("\n📤 Converting to PageInstead format...")

    page_instead_quotes = []

    for idx, q in enumerate(quotes, start=1):
        # Generate book ID
        author_slug = q['author'].lower().replace(' ', '_').replace('.', '').replace("'", '')
        book_id = f"{author_slug}_{hash(q['book_title']) % 10000:04d}"

        # Generate cover URL
        cover_url = None
        if q['asin']:
            cover_url = f"https://m.media-amazon.com/images/P/{q['asin']}.jpg"

        page_instead_quotes.append({
            'id': idx,
            'text': q['text'],
            'author': q['author'],
            'bookTitle': q['book_title'],
            'bookId': book_id,
            'asin': q['asin'],
            'coverImageURL': cover_url,
            'isActive': True,
            'tags': q['tags'][:3],  # Max 3 tags
            'dateAdded': datetime.now().strftime('%Y-%m-%d')
        })

    # Create final JSON structure
    output_data = {
        'version': 1,
        'lastUpdated': datetime.now().strftime('%Y-%m-%d'),
        'quotes': page_instead_quotes
    }

    # Save to file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"✅ Exported {len(page_instead_quotes)} quotes to {output_path}")

    # Statistics
    unique_books = len(set(q['bookTitle'] for q in page_instead_quotes))
    avg_length = sum(len(q['text']) for q in page_instead_quotes) / len(page_instead_quotes)

    print(f"\n📊 STATS:")
    print(f"  Total quotes: {len(page_instead_quotes)}")
    print(f"  Unique books: {unique_books}")
    print(f"  Average length: {avg_length:.0f} chars")
    print(f"  Quotes per book: {len(page_instead_quotes) / unique_books:.1f}")

    print(f"\n🎉 Ready to use in PageInstead!")
    print(f"\nNext: cp {output_path} PageInstead/Resources/quotes.json")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python finalize_quotes.py QUOTES_TO_CURATE.txt")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = 'kindle_quotes_final.json'

    quotes = parse_curated_txt(input_path)
    convert_to_pageinstead(quotes, output_path)
