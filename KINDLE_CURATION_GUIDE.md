# Kindle Highlights Curation Guide

Complete workflow to convert your 40,000 Readwise Kindle highlights into 2 curated quotes per book for PageInstead.

## Overview

**Input:** Readwise CSV export (~40,000 highlights from 167 books)
**Output:** PageInstead `quotes.json` (~334 quotes, 2 per book)

**Process:** 3-stage filtering with smart scoring and manual review

---

## Step-by-Step Instructions

### Step 1: Analyze Your CSV (Optional, but recommended)

First, understand what you're working with:

```bash
python3 analyze_readwise_csv.py your_readwise_export.csv
```

**This shows:**
- Total highlights and books
- Average highlights per book
- Books with most/fewest highlights
- Sample highlights
- CSV column structure

---

### Step 2: Automatic Pre-Filtering

Run the curator to filter 40,000 → ~1,000 candidate quotes:

```bash
python3 curate_kindle_quotes.py your_readwise_export.csv
```

**This creates:** `kindle_highlights_review.json`

**Automatic filtering includes:**
- ✅ Length filter (40-500 chars, optimal 80-150)
- ✅ Remove non-quotes (facts, references, lists)
- ✅ Smart scoring (highlights with notes get +50 points)
- ✅ Prefer inspirational/philosophical content
- ✅ Boost reading-related quotes (+20 points)
- ✅ Top 10 candidates per book

**Score calculation:**
- Base: 100 points
- Has user note: +50
- Optimal length (80-150 chars): +30
- Reading/book keywords: +20 each
- Inspirational words: +10 each
- Complete sentences: +15
- Quote marks present: +10
- Questions: -10

---

### Step 3: Manual Review (Interactive UI)

Open the review interface:

```bash
open review_quotes.html
```

**Features:**
1. **Load** `kindle_highlights_review.json`
2. **Review** ~10 candidates per book (sorted by score)
3. **Select** your 2 favorites per book (click to toggle)
4. **Quick actions:**
   - "Auto-Select Top 2" - picks highest scores
   - "Show Only Incomplete" - filter incomplete books
   - "Clear All" - start over
5. **Progress tracking** - shows completion %
6. **Export** when done → `kindle_highlights_final_selection.json`

**Tips:**
- Quotes with your notes are marked
- Higher scores = better quotes (algorithm picked them)
- Click any quote to select/deselect
- Must pick exactly 2 per book before exporting

---

### Step 4: Convert to PageInstead Format

Convert selected quotes to `quotes.json`:

```bash
python3 convert_to_pageinstead.py \
  kindle_highlights_final_selection.json \
  kindle_quotes.json
```

**This creates:** `kindle_quotes.json` in PageInstead format

**Includes:**
- Sequential IDs (1-334)
- Author and book title
- ASINs for Amazon links
- Cover image URLs (auto-generated from ASIN)
- Smart tags (auto-extracted from text)
- Date added (today)

---

### Step 5: Import to PageInstead

Replace the existing quotes file:

```bash
cp kindle_quotes.json PageInstead/Resources/quotes.json
```

Or merge with existing quotes:

```bash
# TODO: Create merge script if needed
```

Then rebuild in Xcode:

```bash
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead build
```

---

## Quick Mode (Fully Automatic)

If you trust the algorithm to pick the top 2 per book:

```bash
python3 curate_kindle_quotes.py your_readwise_export.csv --auto
```

**This:**
1. Filters 40,000 → ~1,000
2. Auto-selects top 2 per book by score
3. Exports directly to `kindle_highlights_curated.json`
4. Skip manual review entirely

**Then:**
```bash
cp kindle_highlights_curated.json PageInstead/Resources/quotes.json
```

---

## Scoring Algorithm Details

### Length Scoring
| Length | Score Bonus |
|--------|-------------|
| 80-150 chars | +30 |
| 50-200 chars | +15 |
| < 40 or > 500 | Filtered out |

### Keyword Bonuses
| Type | Keywords | Bonus |
|------|----------|-------|
| Reading | read, book, story, page, library | +20 each |
| Inspirational | life, love, truth, wisdom, freedom, hope | +10 each |
| User note | Any note you added | +50 |

### Quality Filters (Auto-removed)
- ❌ >3 numbers (statistics/facts)
- ❌ Starts with "chapter", "figure", "table"
- ❌ URLs present
- ❌ >3 newlines (lists/formatting)
- ❌ Questions (usually not standalone quotes)

---

## Customization Options

### Adjust Quotes Per Book

Edit `curate_kindle_quotes.py` line 78:

```python
self.filtered_quotes[book_title] = candidates[:10]  # Change 10 to desired number
```

### Change Final Selection Count

Edit line 189:

```python
top2 = highlights[:2]  # Change to [:3] for 3 per book
```

### Modify Scoring Weights

Edit `_calculate_quote_score()` method (lines 91-138):

```python
# Example: Boost shorter quotes
if 50 <= length <= 100:
    score += 40  # Was 30
```

---

## Troubleshooting

### "No highlights loaded"
- Check CSV encoding (should be UTF-8)
- Verify column names match expected format
- Run `analyze_readwise_csv.py` first to see structure

### "ASIN not found"
- Some books may not have ASINs in Readwise
- Cover images will be `null` (okay, app handles this)
- Can manually add ASINs later

### "Too many/few candidates per book"
- Adjust filtering in stage 1 (line 78)
- Change score thresholds in `_calculate_quote_score()`

### "Review UI won't open"
- Make sure you're opening `review_quotes.html` in a browser
- Use Chrome/Firefox/Safari (modern browser needed)
- Check browser console for errors

---

## File Reference

| File | Purpose |
|------|---------|
| `analyze_readwise_csv.py` | Analyze CSV structure and stats |
| `curate_kindle_quotes.py` | Main curation tool (stage 1-3) |
| `review_quotes.html` | Interactive review UI |
| `convert_to_pageinstead.py` | Convert to PageInstead format |
| `kindle_highlights_review.json` | Candidates for review (intermediate) |
| `kindle_highlights_final_selection.json` | Your final selections |
| `kindle_quotes.json` | Final PageInstead format (ready to use) |

---

## Stats You'll See

After running the full pipeline:

```
✅ Original highlights: 40,000
✅ Unique books: 167
✅ After stage 1 filtering: ~1,000 candidates
✅ Final curated quotes: ~334 (2 per book)
✅ Average quote length: ~120 characters
✅ Books with ASINs: ~150+ (depends on Readwise data)
```

---

## Next Steps After Import

1. **Test in Simulator** (add bypass for Screen Time)
2. **Build to device** and verify quotes display
3. **Check quote rotation** (5-minute windows)
4. **Verify Amazon affiliate links** work
5. **Review cover images** (some may 404, that's okay)

---

## Tips for Best Results

1. **Trust high-scoring quotes** - algorithm is tuned for quality
2. **Look for your notes** - quotes you commented on are usually favorites
3. **Prefer shorter quotes** - better for shield UI (limited space)
4. **Mix genres** - variety keeps it interesting
5. **Review outliers** - some high-scoring quotes might not feel right to you

---

## Future Enhancements

Ideas for improving the curation process:

- [ ] **Duplicate detection** across books (same quote in multiple books)
- [ ] **Genre-based filtering** (prefer non-fiction quotes)
- [ ] **Sentiment analysis** (prefer positive/inspiring)
- [ ] **Readability scoring** (Flesch-Kincaid)
- [ ] **Personal reading timeline** (include when you read the book)
- [ ] **Merge tool** (combine with existing quotes.json without duplicates)
- [ ] **Batch ASIN lookup** (auto-find missing ASINs via Amazon API)

---

## Questions?

- Check existing PageInstead quotes: `PageInstead/Resources/quotes.json`
- Review quote structure: `ShieldConfiguration/QuoteData.swift`
- See scoring algorithm: `curate_kindle_quotes.py` lines 91-138

Happy curating! 📚✨
