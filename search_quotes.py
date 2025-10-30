#!/usr/bin/env python3
"""
Search your curated quotes
"""
import json
import sys

def search_quotes(query):
    with open('PageInstead/Resources/quotes.json', 'r') as f:
        data = json.load(f)

    query_lower = query.lower()
    matches = []

    for q in data['quotes']:
        if (query_lower in q['text'].lower() or
            query_lower in q['bookTitle'].lower() or
            query_lower in q['author'].lower()):
            matches.append(q)

    if not matches:
        print(f"No quotes found matching '{query}'")
        return

    print(f"Found {len(matches)} quotes matching '{query}':")
    print('=' * 80)
    print()

    for q in matches:
        print(f'📖 {q["bookTitle"]}')
        print(f'   by {q["author"]}')
        print()
        print(f'   "{q["text"]}"')
        print()
        print(f'   Tags: {", ".join(q["tags"])}')
        print('-' * 80)
        print()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python search_quotes.py <keyword>")
        print("\nExamples:")
        print("  python search_quotes.py 'Ray Dalio'")
        print("  python search_quotes.py 'leadership'")
        print("  python search_quotes.py 'read'")
        sys.exit(1)

    query = ' '.join(sys.argv[1:])
    search_quotes(query)
