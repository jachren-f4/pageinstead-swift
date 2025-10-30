#!/usr/bin/env python3
"""
Re-tag quotes with improved keyword matching
"""
import json

def extract_better_tags(text, book_title=''):
    """Extract tags with improved keyword matching"""
    tags = set()
    text_lower = text.lower()
    book_lower = book_title.lower()

    # More comprehensive tag keywords
    tag_keywords = {
        'business': ['business', 'company', 'startup', 'entrepreneur', 'market', 'customer', 'product', 'revenue', 'profit'],
        'leadership': ['lead', 'leader', 'leadership', 'manage', 'manager', 'team', 'organization', 'ceo', 'executive'],
        'strategy': ['strategy', 'strategic', 'plan', 'goal', 'objective', 'vision', 'mission'],
        'creativity': ['creative', 'create', 'innovation', 'innovate', 'design', 'invent', 'original'],
        'success': ['success', 'achieve', 'accomplish', 'win', 'excel', 'performance'],
        'wisdom': ['wisdom', 'wise', 'knowledge', 'truth', 'understand', 'insight', 'principle'],
        'life': ['life', 'living', 'alive', 'exist', 'human', 'people'],
        'learning': ['learn', 'education', 'teach', 'study', 'skill', 'practice', 'training'],
        'courage': ['courage', 'brave', 'strength', 'bold', 'risk', 'fear'],
        'discipline': ['discipline', 'focus', 'habit', 'routine', 'consistent', 'commitment'],
        'inspiration': ['inspire', 'inspiration', 'motivate', 'hope', 'aspire'],
        'reading': ['read', 'reading', 'book', 'books', 'library', 'page', 'story', 'chapter'],
        'love': ['love', 'heart', 'soul', 'passion', 'care'],
        'freedom': ['free', 'freedom', 'liberty', 'independent', 'choice'],
        'imagination': ['imagine', 'imagination', 'dream', 'vision', 'possibility'],
        'happiness': ['happy', 'happiness', 'joy', 'delight', 'pleasure'],
        'power': ['power', 'powerful', 'influence', 'control', 'authority'],
        'thinking': ['think', 'thought', 'mind', 'idea', 'reflect', 'consider'],
        'communication': ['communicate', 'speak', 'talk', 'say', 'tell', 'listen', 'conversation'],
        'decision': ['decide', 'decision', 'choice', 'choose', 'judgment'],
    }

    # Check quote text
    for tag, keywords in tag_keywords.items():
        if any(keyword in text_lower for keyword in keywords):
            tags.add(tag)

    # Also check book title for context (but weight less)
    book_tags = set()
    for tag, keywords in tag_keywords.items():
        if any(keyword in book_lower for keyword in keywords):
            book_tags.add(tag)

    # Combine but prioritize quote content
    all_tags = list(tags) + [t for t in book_tags if t not in tags]

    # If still no tags, use book-based fallback
    if not all_tags:
        if any(word in book_lower for word in ['business', 'ceo', 'company', 'entrepreneur', 'startup']):
            all_tags = ['business']
        elif any(word in book_lower for word in ['lead', 'power', 'strategy']):
            all_tags = ['leadership']
        elif any(word in book_lower for word in ['think', 'mind', 'wisdom']):
            all_tags = ['wisdom']
        else:
            all_tags = ['inspiration']  # Better fallback than "reading"

    return sorted(list(set(all_tags)))[:3]  # Max 3 tags

def retag_all_quotes():
    """Re-tag all quotes in quotes.json"""

    # Load current quotes
    with open('PageInstead/Resources/quotes.json', 'r') as f:
        data = json.load(f)

    # Backup original
    with open('PageInstead/Resources/quotes.json.before-retag', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print("📋 Re-tagging quotes...")
    changes = 0

    for q in data['quotes']:
        old_tags = q['tags'].copy()
        new_tags = extract_better_tags(q['text'], q['bookTitle'])

        if old_tags != new_tags:
            q['tags'] = new_tags
            changes += 1

    # Save updated quotes
    with open('PageInstead/Resources/quotes.json', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Re-tagged {changes} quotes")
    print(f"📊 Backed up original to: quotes.json.before-retag")

    # Show statistics
    tag_counts = {}
    for q in data['quotes']:
        for tag in q['tags']:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1

    print("\n📊 TAG DISTRIBUTION:")
    for tag, count in sorted(tag_counts.items(), key=lambda x: x[1], reverse=True)[:15]:
        print(f"  {tag:15} {count:3} quotes")

if __name__ == '__main__':
    retag_all_quotes()
