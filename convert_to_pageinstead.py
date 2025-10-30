#!/usr/bin/env python3
"""
Convert final selected Kindle highlights to PageInstead quotes.json format
"""
import json
import sys
from datetime import datetime

def convert_to_pageinstead(input_json_path, output_json_path):
    """Convert selected quotes to PageInstead format"""

    print("📖 Loading selected quotes...")
    with open(input_json_path, 'r', encoding='utf-8') as f:
        selected_quotes = json.load(f)

    print(f"✅ Found {len(selected_quotes)} selected quotes")

    page_instead_quotes = []

    for idx, quote in enumerate(selected_quotes, start=1):
        # Generate book ID
        author = quote.get('author', 'Unknown')
        book_title = quote.get('book_title', 'Unknown')

        author_slug = author.lower().replace(' ', '_').replace('.', '').replace("'", '')
        book_id = f"{author_slug}_{hash(book_title) % 10000:04d}"

        # Generate cover URL from ASIN
        asin = quote.get('asin')
        cover_url = None
        if asin:
            cover_url = f"https://m.media-amazon.com/images/P/{asin}.jpg"

        # Extract tags
        tags = extract_tags(quote['highlight'])

        page_instead_quotes.append({
            'id': idx,
            'text': quote['highlight'],
            'author': author,
            'bookTitle': book_title,
            'bookId': book_id,
            'asin': asin,
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

    # Save to file
    with open(output_json_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"\n✅ SUCCESS!")
    print(f"📝 Created: {output_json_path}")
    print(f"📊 Total quotes: {len(page_instead_quotes)}")
    print(f"📚 Unique books: {len(set(q['bookTitle'] for q in page_instead_quotes))}")
    print(f"\n🎉 Ready to use in PageInstead!")
    print(f"\nNext steps:")
    print(f"1. Copy to: PageInstead/Resources/quotes.json")
    print(f"2. Rebuild app in Xcode")

def extract_tags(text):
    """Extract tags from quote text"""
    tags = set()
    text_lower = text.lower()

    tag_keywords = {
        'reading': ['read', 'reading', 'book', 'books', 'library', 'story', 'page'],
        'life': ['life', 'living', 'alive', 'exist'],
        'wisdom': ['wisdom', 'wise', 'knowledge', 'truth', 'understand'],
        'love': ['love', 'heart', 'soul', 'compassion'],
        'freedom': ['free', 'freedom', 'liberty', 'independent'],
        'courage': ['courage', 'brave', 'strength', 'bold'],
        'learning': ['learn', 'education', 'teach', 'study'],
        'imagination': ['imagine', 'imagination', 'dream', 'creative'],
        'happiness': ['happy', 'happiness', 'joy', 'delight'],
        'inspiration': ['inspire', 'inspiration', 'hope', 'motivate']
    }

    for tag, keywords in tag_keywords.items():
        if any(keyword in text_lower for keyword in keywords):
            tags.add(tag)

    # Default to reading if no tags
    if not tags:
        tags.add('reading')

    return sorted(list(tags))[:3]  # Max 3 tags

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_to_pageinstead.py <input_json> <output_json>")
        print("\nExample:")
        print("  python convert_to_pageinstead.py kindle_highlights_final_selection.json quotes.json")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    convert_to_pageinstead(input_path, output_path)
