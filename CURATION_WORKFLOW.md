# Manual Quote Curation Workflow

## 📄 Files Created

| File | Purpose |
|------|---------|
| `QUOTES_TO_CURATE.txt` | 874 quotes (6 per book) for you to curate |
| `finalize_quotes.py` | Converts edited TXT → JSON |

## 🎯 Your Task

Review 148 books × 6 quotes each = 874 quotes
**Keep 2 per book** = ~296 final quotes

---

## ✏️ Step-by-Step Process

### 1. Open the File
```bash
open QUOTES_TO_CURATE.txt
```

### 2. For Each Book, Do This:

**Read all 6 quotes** (sorted shortest → longest)

**Example:**
```
BOOK: Build: An Unorthodox Guide to Making Things Worth Making
AUTHOR: Tony Fadell
ASIN: B08BKSJX1M

QUOTE 1:
First principle thinking.
LENGTH: 25 chars
TAGS: thinking

QUOTE 2:
Less can be more; the trick is building up the courage to embrace this.
LENGTH: 71 chars
TAGS: courage, life

QUOTE 3:
Watching Steve Jobs was like watching a master conductor direct an orchestra.
LENGTH: 77 chars
TAGS: leadership

QUOTE 4:
[... 3 more quotes ...]
```

**Pick your 2 favorites**
- Usually the **2 shortest** are best for shield UI
- But choose based on what resonates with you
- Consider: Which would YOU want to see when distracted?

**Edit the tags**
- My suggestions are there, but feel free to change
- Format: `TAGS: business, leadership, wisdom`
- Max 3 tags, comma-separated

**DELETE the 4 unwanted quotes**
- Select from `QUOTE X:` to the blank line after tags
- Delete the entire block
- Leave only 2 quotes per book

### 3. Save the File
Just save it with your edits (keep the same filename)

### 4. Convert to JSON
```bash
python3 finalize_quotes.py QUOTES_TO_CURATE.txt
```

Creates: `kindle_quotes_final.json`

### 5. Install in App
```bash
cp kindle_quotes_final.json PageInstead/Resources/quotes.json
```

---

## 📏 Length Guidelines

Based on the quotes I selected:

| Range | Count | Recommendation |
|-------|-------|----------------|
| 20-50 chars | 362 | ⭐ **Perfect** - instant impact |
| 51-100 chars | 265 | ✅ **Great** - easy to read |
| 101-150 chars | 146 | 👍 **Good** - still readable |
| 151-200 chars | 50 | ⚠️ **Long** - use sparingly |
| 200+ chars | 51 | ❌ **Too long** - avoid if possible |

**Average: 79 chars** (median: 64 chars)

---

## 🏷️ Tag Reference

Available tags (use 1-3 per quote):

**Business/Work:**
- `business` - company, startup, entrepreneurship
- `leadership` - managing, leading teams
- `strategy` - planning, goals, vision
- `success` - achievement, winning
- `power` - influence, control
- `decision` - making choices
- `communication` - speaking, listening

**Personal Growth:**
- `wisdom` - knowledge, understanding
- `life` - living, human experience
- `learning` - education, skills
- `courage` - bravery, overcoming fear
- `discipline` - focus, habits, routine
- `thinking` - mind, ideas, reflection

**Inspiration:**
- `inspiration` - motivation, hope
- `creativity` - innovation, design
- `imagination` - dreams, possibilities
- `happiness` - joy, delight
- `love` - heart, soul, passion
- `freedom` - independence, liberty

**Reading (PageInstead theme):**
- `reading` - books, stories, pages

---

## 💡 Tips for Choosing Quotes

**Prefer quotes that:**
- ✅ Are **short** (under 100 chars ideal)
- ✅ Work **out of context** (don't need to know the book)
- ✅ Are **inspirational** or thought-provoking
- ✅ You **personally** highlighted (they mattered to you!)
- ✅ Make you **think** when distracted

**Avoid quotes that:**
- ❌ Are too long (over 150 chars)
- ❌ Need context from the book
- ❌ Are just facts/statistics
- ❌ Are chapter headings (some slipped through)

---

## 🎯 Example Editing Session

**Before (6 quotes):**
```
BOOK: Principles: Life and Work
AUTHOR: Ray Dalio

QUOTE 1:
Principles are ways of successfully dealing with reality.
LENGTH: 56 chars
TAGS: wisdom

QUOTE 2:
Think for yourself while being radically open-minded.
LENGTH: 52 chars
TAGS: thinking, wisdom

QUOTE 3:
Pain + Reflection = Progress
LENGTH: 28 chars
TAGS: learning, wisdom

QUOTE 4:
[longer quote...]
LENGTH: 180 chars
TAGS: life

QUOTE 5:
[another quote...]
LENGTH: 145 chars
TAGS: business

QUOTE 6:
[another quote...]
LENGTH: 200 chars
TAGS: leadership
```

**After (keep 2, edit tags):**
```
BOOK: Principles: Life and Work
AUTHOR: Ray Dalio

QUOTE 1:
Pain + Reflection = Progress
LENGTH: 28 chars
TAGS: wisdom, learning

QUOTE 2:
Think for yourself while being radically open-minded.
LENGTH: 52 chars
TAGS: thinking, freedom
```

You deleted quotes 3-6 and kept the 2 shortest with best tags.

---

## ⏱️ Time Estimate

- **Fast mode:** 1-2 hours (pick shortest 2, accept tags)
- **Careful mode:** 3-4 hours (read all, curate tags)
- **Per book:** ~1-2 minutes average

---

## 🔄 If You Make a Mistake

**Backed up original:** `QUOTES_TO_CURATE.txt.backup` (if you want to restart)

**Re-generate anytime:**
```bash
python3 curate_short_quotes.py readwise-data.csv
```

---

## 📊 What You'll Get

**Final result:**
- ~296 quotes (2 per book, from your 148 most-read books)
- Average ~60-80 chars (super readable on shield)
- Perfectly tagged (by you!)
- From books YOU actually read and highlighted
- Meaningful quotes that resonated with you

---

## 🚀 Quick Start

```bash
# 1. Open file
open QUOTES_TO_CURATE.txt

# 2. Edit (keep 2 per book, fix tags)
# ... do your curation ...

# 3. Convert
python3 finalize_quotes.py QUOTES_TO_CURATE.txt

# 4. Install
cp kindle_quotes_final.json PageInstead/Resources/quotes.json

# 5. Rebuild app
open PageInstead.xcodeproj
```

---

## ❓ Questions?

**"Can I keep 3 quotes per book instead of 2?"**
Yes! Just leave 3 quotes in the file. The script will take whatever you leave.

**"What if I want different books?"**
Re-run with `--min-highlights` parameter to change which books are included.

**"Can I add quotes manually?"**
Yes! Just follow the format in the TXT file and the converter will pick them up.

**"Do I have to edit all 148 books?"**
Yes, to get 296 final quotes. But you can do it in batches - edit 50 books, convert, test, then do more.

Happy curating! 📚✨
