# Readwise Source Filtering Guide

## The Problem

Your Readwise CSV contains highlights from **multiple sources**, not just Kindle books:

| Source | How to Identify | Example |
|--------|----------------|---------|
| **📕 Kindle Books** | Has 10-char ASIN in "Amazon Book ID" column | `0143127853` |
| **📰 Articles** | No ASIN, has author, reasonable title | "The Future of AI" |
| **🐦 Tweets** | Title starts with "Tweets from..." | "Tweets from Scott L" |
| **❓ Other** | PDFs, podcasts, etc. | Varies |

## The Solution

The updated curator **automatically detects and filters** sources:

```bash
# Books only (default, recommended for PageInstead)
python3 curate_kindle_quotes.py readwise.csv

# Include everything (books, articles, tweets)
python3 curate_kindle_quotes.py readwise.csv --all-sources
```

---

## Detection Logic

### Kindle Books
**Criteria:** Has valid 10-character ASIN
```
Column: "Amazon Book ID" = "0143127853"
→ Kindle Book ✅
```

### Tweets
**Criteria:** Title contains "tweets from" or "tweet from"
```
Column: "Book Title" = "Tweets from Scott L"
→ Tweet 🐦
```

### Articles
**Criteria:** No ASIN + Has author + Title length > 10
```
No ASIN + Author: "Tim Urban" + Title: "Wait But Why: AI Revolution"
→ Article 📰
```

### Other
Everything else (PDFs, podcasts, unknown sources)

---

## Filtering Options

### Minimum Highlights Per Book

Only include books you actually read (not just 1-2 highlights):

```bash
# Default: 5+ highlights
python3 curate_kindle_quotes.py readwise.csv

# Stricter: 10+ highlights only
python3 curate_kindle_quotes.py readwise.csv --min-highlights 10

# More lenient: 3+ highlights
python3 curate_kindle_quotes.py readwise.csv --min-highlights 3
```

**Recommendation:**
- `5+` = Read a decent chunk of the book
- `10+` = Actually finished or thoroughly read
- `3+` = Include books you sampled

---

## Expected Results (Based on Your Data)

Your Readwise export has:
- **Total:** 20,082 highlights from 1,680 items
- **Breakdown:** (will see after running analyzer)
  - ~300-400 Kindle books (estimated)
  - ~1,200 articles
  - ~100 tweets
  - ~80 other

**After filtering to books with 5+ highlights:**
- ~150-250 books (estimated)
- × 2 quotes each
- = **300-500 final quotes** for PageInstead

---

## Step-by-Step Workflow

### 1. Analyze Sources (Recommended First Step)

```bash
python3 analyze_readwise_csv.py readwise.csv
```

**Shows:**
- 📊 How many books vs articles vs tweets
- 📕 Top Kindle books by highlight count
- 💡 Recommendation for min-highlights threshold

### 2. Run Curator with Filters

**Conservative (quality over quantity):**
```bash
python3 curate_kindle_quotes.py readwise.csv --min-highlights 10 --auto
# Result: ~150-200 books, ~300-400 quotes
```

**Balanced (recommended):**
```bash
python3 curate_kindle_quotes.py readwise.csv --min-highlights 5
# Result: ~200-300 books, ~400-600 quotes
```

**Aggressive (maximum coverage):**
```bash
python3 curate_kindle_quotes.py readwise.csv --min-highlights 3 --all-sources
# Result: All books + articles, ~1000+ quotes
```

### 3. Review & Export

Use the interactive UI to pick your final 2 per book.

---

## Why Filter?

### Too Many Quotes = Bad UX

PageInstead rotates quotes every 5 minutes:
- 300 quotes = 25 hours to see them all
- 500 quotes = 42 hours (good balance)
- 1000 quotes = 83 hours (too many, won't see favorites often)

### Quality Over Quantity

Books with only 1-2 highlights:
- ❌ Probably didn't finish
- ❌ May not be meaningful
- ❌ Less context for good quotes

Books with 10+ highlights:
- ✅ Actually read and enjoyed
- ✅ Multiple good quotes to choose from
- ✅ More personal connection

---

## Command Reference

```bash
# Analyze first (always do this)
python3 analyze_readwise_csv.py readwise.csv

# Books only, 5+ highlights (default, recommended)
python3 curate_kindle_quotes.py readwise.csv

# Books only, 10+ highlights (stricter)
python3 curate_kindle_quotes.py readwise.csv --min-highlights 10

# Books only, auto-select (skip manual review)
python3 curate_kindle_quotes.py readwise.csv --auto

# Include articles and tweets too
python3 curate_kindle_quotes.py readwise.csv --all-sources

# Combined: strict + auto
python3 curate_kindle_quotes.py readwise.csv --min-highlights 10 --auto
```

---

## Output Files

| File | Contains | When Created |
|------|----------|--------------|
| `kindle_highlights_review.json` | Top 10 candidates per book | After stage 1 (manual mode) |
| `kindle_highlights_final_selection.json` | Your 2 picks per book | After manual review in UI |
| `kindle_highlights_curated.json` | Auto-selected quotes | After `--auto` mode |
| `kindle_quotes.json` | PageInstead format | After convert script |

---

## Troubleshooting

### "Why are tweets showing up?"
Your CSV mixes sources. Use default settings (books only).

### "Only getting 50 books, expected more"
Your `--min-highlights` threshold is too high. Try:
```bash
python3 analyze_readwise_csv.py readwise.csv
# See how many books have 5+ vs 10+ highlights
```

### "Want to include some articles too"
Articles don't have ASINs/cover images, but you can:
```bash
python3 curate_kindle_quotes.py readwise.csv --all-sources
# Manually add ASINs later if needed
```

### "Some books have wrong ASIN"
Readwise sometimes mismatches. You can:
1. Export the JSON
2. Manually fix ASINs
3. Re-run the converter

---

## Next Steps

1. **Run analyzer** to see your source breakdown
2. **Pick a filter level** (5, 10, or 3 min-highlights)
3. **Run curator** with chosen filters
4. **Review in UI** or use `--auto`
5. **Convert to PageInstead format**
6. **Import into app**

Questions? Check the main guide: `KINDLE_CURATION_GUIDE.md`
