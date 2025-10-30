#!/usr/bin/env python3
"""
Automatically select top 2 quality-scored quotes per book
and clean up book titles (remove subtitles)
"""
import re
import json
from datetime import datetime

def clean_book_title(title):
    """Remove subtitle from book title"""
    # Pattern 1: Remove everything after colon (most common)
    if ':' in title:
        title = title.split(':')[0].strip()

    # Pattern 2: Remove everything after dash (if dash is near end)
    if ' - ' in title:
        parts = title.split(' - ')
        # Only remove if second part looks like subtitle (not author name)
        if len(parts) == 2 and len(parts[1]) > 10:
            title = parts[0].strip()

    # Pattern 3: Remove content in parentheses at the end
    title = re.sub(r'\s*\([^)]+\)\s*$', '', title)

    # Pattern 4: Remove "Enhanced Edition" type suffixes
    title = re.sub(r',?\s+(Enhanced|Expanded|Revised|Updated|Anniversary|Special) Edition.*$', '', title, flags=re.IGNORECASE)

    return title.strip()

def parse_curation_file(filepath):
    """Parse the QUOTES_TO_CURATE.txt file"""
    print(f"📖 Reading {filepath}...")

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by book sections
    book_sections = content.split('-' * 80)

    books_data = []

    for section in book_sections:
        if not section.strip() or 'INSTRUCTIONS:' in section:
            continue

        lines = section.strip().split('\n')
        if not lines:
            continue

        # Parse book metadata
        book_title = None
        author = None
        asin = None
        quotes = []

        i = 0
        while i < len(lines):
            line = lines[i].strip()

            if line.startswith('BOOK:'):
                book_title = line.replace('BOOK:', '').strip()
                book_title = clean_book_title(book_title)  # Clean the title
            elif line.startswith('AUTHOR:'):
                author = line.replace('AUTHOR:', '').strip()
            elif line.startswith('ASIN:'):
                asin = line.replace('ASIN:', '').strip()
            elif line.startswith('QUOTE'):
                # Parse quote
                i += 1
                quote_lines = []

                # Collect quote text
                while i < len(lines) and not lines[i].startswith('LENGTH:'):
                    if lines[i].strip():
                        quote_lines.append(lines[i])
                    i += 1

                quote_text = '\n'.join(quote_lines).strip()

                # Get quality score
                quality_score = 0
                tags = []

                while i < len(lines):
                    current_line = lines[i].strip()
                    if current_line.startswith('LENGTH:'):
                        # Extract quality score
                        if 'QUALITY SCORE:' in current_line:
                            score_match = re.search(r'QUALITY SCORE:\s*(\d+)', current_line)
                            if score_match:
                                quality_score = int(score_match.group(1))
                    elif current_line.startswith('TAGS:'):
                        tags_str = current_line.replace('TAGS:', '').strip()
                        tags = [t.strip() for t in tags_str.split(',') if t.strip()]
                        break
                    i += 1

                if quote_text:
                    quotes.append({
                        'text': quote_text,
                        'quality_score': quality_score,
                        'tags': tags if tags else ['wisdom']
                    })

            i += 1

        if book_title and author and quotes:
            # Sort by quality score (highest first)
            quotes.sort(key=lambda x: x['quality_score'], reverse=True)

            # Take top 2
            top2 = quotes[:2]

            books_data.append({
                'book_title': book_title,
                'author': author,
                'asin': asin,
                'quotes': top2
            })

    print(f"✅ Parsed {len(books_data)} books")
    total_quotes = sum(len(b['quotes']) for b in books_data)
    print(f"✅ Selected {total_quotes} quotes (top 2 per book)")

    return books_data

def convert_to_pageinstead(books_data, output_path):
    """Convert to PageInstead format"""
    print("\n📤 Converting to PageInstead format...")

    page_instead_quotes = []
    quote_id = 1

    for book in books_data:
        for quote_data in book['quotes']:
            # Generate book ID
            author_slug = book['author'].lower().replace(' ', '_').replace('.', '').replace("'", '')
            book_id = f"{author_slug}_{hash(book['book_title']) % 10000:04d}"

            # Generate cover URL
            cover_url = None
            if book['asin']:
                cover_url = f"https://m.media-amazon.com/images/P/{book['asin']}.jpg"

            page_instead_quotes.append({
                'id': quote_id,
                'text': quote_data['text'],
                'author': book['author'],
                'bookTitle': book['book_title'],
                'bookId': book_id,
                'asin': book['asin'],
                'coverImageURL': cover_url,
                'isActive': True,
                'tags': quote_data['tags'][:3],
                'dateAdded': datetime.now().strftime('%Y-%m-%d')
            })
            quote_id += 1

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

    print(f"\n📊 FINAL STATS:")
    print(f"  Total quotes: {len(page_instead_quotes)}")
    print(f"  Unique books: {unique_books}")
    print(f"  Average quote length: {avg_length:.0f} chars")
    print(f"  Quotes per book: {len(page_instead_quotes) / unique_books:.1f}")

    # Show sample cleaned titles
    print(f"\n📚 SAMPLE CLEANED BOOK TITLES:")
    for book in sorted(books_data, key=lambda x: x['book_title'])[:10]:
        print(f"  • {book['book_title']}")

    print(f"\n🎉 Ready to use in PageInstead!")
    print(f"\nNext: cp {output_path} PageInstead/Resources/quotes.json")

    return output_data

if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        input_file = 'QUOTES_TO_CURATE.txt'
    else:
        input_file = sys.argv[1]

    output_file = 'kindle_quotes_final.json'

    books_data = parse_curation_file(input_file)
    convert_to_pageinstead(books_data, output_file)
