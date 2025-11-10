# How to Source Quotes for PageInstead

## Legal & Ethical Quote Sourcing Guide

### ⚖️ Copyright Considerations

**Short quotes (1-3 sentences) generally qualify as fair use when:**
- Used for inspirational/educational purposes
- Properly attributed to author and book
- Not substituting for the original work
- Transformative in nature (motivating users to read)

**Best practices:**
- Always attribute author and book title
- Keep quotes brief (under 200 words)
- Use quotes that inspire action, not reproduce core content
- Consider public domain works when possible

---

## 📚 Where to Find Popular Quotes

### 1. Goodreads Quotes Section
**Best source for popular quotes**

For each book:
1. Go to book page on Goodreads
2. Click "Quotes" tab
3. Sort by "Most Liked"
4. Top 5-10 quotes show what resonates with readers

Example: https://www.goodreads.com/work/quotes/[BOOK_ID]

### 2. Amazon "Look Inside" Feature
**Direct from source**

- Search book on Amazon
- Use "Look Inside" feature
- Look for highlighted passages
- Check "Popular Highlights" section (Kindle books)

### 3. Quote Aggregator Sites
**Community-curated quotes**

- **BrainyQuote.com** - Organized by author
- **AZQuotes.com** - Includes vote counts
- **QuotesCosmos** - Book-specific collections
- **PassItOn.com** - Inspirational focus

### 4. Book Reviews & Highlights
**Reader-selected passages**

- Medium articles reviewing the book
- BookTube/BookTok quotes
- Instagram book accounts (@bookstagram)
- Blinkist summaries (key insights)

### 5. Author's Official Channels
**Pre-approved sharing**

- Author's website quote pages
- Official social media graphics
- Press kit materials
- Author interviews where they share favorite passages

---

## 🎯 Quote Selection Criteria

### Quality Checklist
- [ ] **Standalone impact** - Makes sense without context
- [ ] **Actionable wisdom** - Inspires thought or behavior change
- [ ] **Universal appeal** - Not overly niche or inside-baseball
- [ ] **Brevity** - Ideally 1-2 sentences (150-250 chars)
- [ ] **Memorable** - Quotable, shareable quality
- [ ] **Diverse perspectives** - Mix of styles across categories

### What to Avoid
- ❌ Plot spoilers or key reveals
- ❌ Inside jokes requiring book context
- ❌ Overly academic or jargon-heavy
- ❌ Depressing/negative without redemption
- ❌ Controversial for controversy's sake

---

## 📝 Recommended Workflow

### For Each Book (15-20 min per book)

**Step 1: Research (10 min)**
1. Open Goodreads quotes page
2. Open Amazon "Look Inside"
3. Scan top 10-20 most-liked quotes
4. Note 3-5 candidates

**Step 2: Select (3 min)**
1. Choose 2 quotes that:
   - Work for app blocking context (motivational)
   - Are from different parts of book (variety)
   - Represent book's core message

**Step 3: Format (2 min)**
1. Copy exact text (preserve punctuation)
2. Verify author name spelling
3. Check book title capitalization
4. Get ASIN from Amazon URL

**Step 4: Document (5 min)**
```json
{
  "id": 296,
  "text": "Quote text here",
  "author": "Author Name",
  "bookTitle": "Book Title",
  "bookId": "author_lastname_uniqueid",
  "asin": "B00EXAMPLE",
  "coverImageURL": "https://m.media-amazon.com/images/P/B00EXAMPLE.jpg",
  "bookDescription": "Book about [topic]",
  "isActive": true,
  "tags": ["wisdom"],
  "dateAdded": "2025-11-10",
  "categories": ["Category Name"]
}
```

---

## 🚀 Bulk Processing Tips

### Create a Spreadsheet
Track your progress with columns:
- Book Title
- Author
- ASIN
- Quote 1
- Quote 2
- Category
- Status (pending/done)
- Notes

### Batch by Category
Process all books in one category together:
- Opens 10-15 Goodreads tabs
- Consistent mental context
- Easier to ensure variety

### Use AI Assistance (Carefully)
You can ask me to:
- ✅ Check if a quote you found is formatted correctly
- ✅ Suggest tags based on quote content
- ✅ Write book descriptions
- ✅ Verify ASIN and cover URLs
- ❌ Don't ask me to reproduce copyrighted quotes

---

## 📖 Priority Books (Start Here)

### Tier 1: Public Domain (No Copyright Issues)
These books are freely quotable:

**Classics & Literature:**
- Pride and Prejudice (1813)
- Moby-Dick (1851)
- Jane Eyre (1847)
- Frankenstein (1818)
- The Odyssey (~8th century BC)
- Crime and Punishment (1866)

**Spirituality:**
- Siddhartha (1922 - US public domain 2018)
- The Prophet (1923 - public domain 2019)
- Tao Te Ching (ancient)

**Philosophy:**
- Meditations by Marcus Aurelius
- Thus Spoke Zarathustra (1883)

### Tier 2: Widely-Quoted Modern Classics
These have robust Goodreads quote collections:
- Man's Search for Meaning
- The Alchemist
- Atomic Habits
- Sapiens
- Becoming

### Tier 3: Recent Releases
May have fewer quotes online, might need book access:
- The Light Eaters (2024)
- Our Moon (2024)
- Alien Earths (2024)

---

## 🔍 Example: Finding Quotes for "Atomic Habits"

**Step-by-step demonstration:**

1. **Goodreads**: https://www.goodreads.com/work/quotes/55711913-atomic-habits
   - 500+ quotes submitted
   - Top quote has 5,000+ likes
   - Clear reader favorites

2. **Amazon**: Search "Atomic Habits Kindle"
   - "Look Inside" shows first chapter
   - Popular Highlights visible to Kindle users
   - Can preview key concepts

3. **Author's Site**: jamesclear.com
   - Shares quotes regularly
   - 3-2-1 newsletter excerpts
   - Pre-approved for sharing

4. **Select 2 quotes** that:
   - Represent different aspects (identity vs systems)
   - Are actionable
   - Work in app-blocking context

---

## ✅ Quality Control

Before adding to quotes.json:

1. **Verify attribution**: Google the quote to ensure it's actually from that book
2. **Check formatting**: Match existing quote style in quotes.json
3. **Test in app**: Does it work on shield screen? Inspire action?
4. **Avoid duplicates**: Search quotes.json for similar themes

---

## 📚 Resources

### Quote Sources
- [Goodreads Quotes](https://www.goodreads.com/quotes)
- [BrainyQuote](https://www.brainyquote.com)
- [AZQuotes](https://www.azquotes.com)

### Copyright Guidance
- [Stanford Fair Use Overview](https://fairuse.stanford.edu)
- [Copyright and Fair Use (Columbia)](https://copyright.columbia.edu/basics/fair-use.html)

### Book Metadata
- [Amazon Product Advertising API](https://webservices.amazon.com/paapi5/documentation/)
- [Google Books API](https://developers.google.com/books)

---

**Remember:** You're not reproducing the books - you're sharing brief inspirational moments that encourage users to read the full work. Proper attribution is key!
