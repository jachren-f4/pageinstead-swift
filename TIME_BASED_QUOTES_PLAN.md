# Implementation Plan: Time-Based Quote Synchronization

## Overview
Replace random quote selection with deterministic time-based scheduling. Both Shield Extension and main app independently calculate the same quote based on the current time, ensuring perfect synchronization without any IPC.

---

## Task 1: Design QuoteScheduler Logic

### Purpose
Define the algorithm for mapping time to quotes.

### Details
```swift
// Algorithm:
1. Get current date/time
2. Calculate minutes since midnight: (hour × 60) + minute
3. Calculate 5-minute window index: floor(minutesSinceMidnight / 5)
4. Map window to quote: windowIndex % totalQuotes
5. Return quote at that index

// Example:
Time: 14:23 (2:23 PM)
Minutes since midnight: 863
Window index: 172 (863 ÷ 5)
Total quotes: 50
Quote index: 172 % 50 = 22
Return: quotes[22]
```

### Decisions to Make
- **Window duration**: 5 minutes (288 windows per day)
- **Quote cycling**: Modulo operation ensures quotes repeat throughout day
- **Timezone**: Use device local time (both Shield and app use same clock)

### Output
- Document algorithm
- Validate math: 24 hours × 12 windows/hour = 288 windows

---

## Task 2: Create QuoteScheduler.swift

### Purpose
Shared utility class for time-based quote selection.

### Implementation
```swift
class QuoteScheduler {
    static let shared = QuoteScheduler()
    private let windowDurationMinutes = 5

    /// Get the current quote based on time
    func getCurrentQuote() -> BookQuote {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)

        let minutesSinceMidnight = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let windowIndex = minutesSinceMidnight / windowDurationMinutes

        let allQuotes = QuoteService.shared.getAllQuotes()
        let quoteIndex = windowIndex % allQuotes.count

        return allQuotes[quoteIndex]
    }

    /// Get the previous quote (for edge case handling)
    func getPreviousWindowQuote() -> BookQuote {
        // Calculate quote from 5 minutes ago
    }

    /// Get window info for debugging
    func getCurrentWindowInfo() -> (windowIndex: Int, nextWindowAt: Date) {
        // Return current window number and when next window starts
    }
}
```

### File Location
`PageInstead/Core/Services/QuoteScheduler.swift`

### Testing
- Test at boundary times (midnight, 11:59 PM)
- Test modulo wrapping (when windows > quotes)
- Verify same output across Shield and main app

---

## Task 3: Update Shield Extension

### Purpose
Replace random quote selection with QuoteScheduler.

### Changes to `ShieldConfigurationExtension.swift`

**Before:**
```swift
let quote: BookQuote
if let serviceQuote = QuoteService.shared.getRandomQuote() {
    quote = serviceQuote
} else {
    quote = BookQuote.fallbackQuotes.randomElement()!
}
```

**After:**
```swift
let quote = QuoteScheduler.shared.getCurrentQuote()
print("🛡️ Shield: Showing quote for window \(QuoteScheduler.shared.getCurrentWindowInfo().windowIndex)")
```

### Impact
- Remove `saveCurrentQuote()` call (no longer needed)
- Remove fallback logic (QuoteScheduler always returns a quote)
- Simpler code

---

## Task 4: Create CurrentQuoteView

### Purpose
Main app view that prominently displays the current time-based quote.

### UI Design
```
┌─────────────────────────────────────┐
│  Your Quote Right Now               │
│                                      │
│  [Book Icon]                         │
│                                      │
│  "The man who does not read has     │
│   no advantage over the man who     │
│   cannot read."                     │
│                                      │
│  — Mark Twain                        │
│  Collected Works                     │
│                                      │
│  [Get This Book →]                  │
│  (Affiliate link button)             │
│                                      │
│  This quote changes every 5 minutes  │
│  Next quote at: 14:30                │
└─────────────────────────────────────┘
```

### Features
- Large, readable quote display
- Prominent author and book name
- Call-to-action button with affiliate link
- Timer showing when next quote appears
- Auto-refresh when window changes

### File Location
`PageInstead/Features/Quotes/CurrentQuoteView.swift`

---

## Task 5: Update App Navigation

### Purpose
Make CurrentQuoteView the primary landing screen after blocking.

### Changes to Navigation Structure

**Option A: Replace History tab with Current Quote**
```
Tabs:
- Block Apps
- Current Quote (main feature)
- Books (browse/search)
```

**Option B: Add Current Quote as first tab**
```
Tabs:
- Current Quote (main feature)
- Block Apps
- Books
- History (optional, de-emphasized)
```

### Recommendation
Option B - Keep history but make Current Quote the hero feature.

### Deep Linking
When user taps "Open PageInstead" on shield:
- Open app directly to CurrentQuoteView
- Smooth transition from shield → app showing same quote

---

## Task 6: Add Affiliate Link Integration

### Purpose
Convert quote views into book purchases.

### Implementation
In `CurrentQuoteView.swift`:
```swift
Button(action: {
    let book = AffiliateService.shared.getBook(for: quote)
    AffiliateService.shared.openAffiliateLink(for: book)
}) {
    HStack {
        Text("Get This Book")
        Image(systemName: "arrow.right")
    }
    .font(.headline)
    .foregroundColor(.white)
    .padding()
    .background(Color.blue)
    .cornerRadius(12)
}
```

### Tracking
- Log when users tap "Get This Book"
- Track which quotes generate most conversions
- A/B test different CTAs

---

## Task 7: Update or Remove DeviceActivityMonitor

### Decision Point
Do we still need DeviceActivityMonitor for history tracking?

### Option A: Keep It (Minimal)
- Use for rough usage statistics only
- Track "you were blocked X times today"
- Don't worry about matching specific quotes

### Option B: Remove It
- History shows "Recent quotes you may have seen" (based on time windows)
- Calculate which windows user was likely active (rough estimate)
- Simpler implementation, no event tracking needed

### Recommendation
**Option B** - Remove DeviceActivityMonitor complexity. History can show:
```
Today's Quotes:
- 2:00 PM - 2:05 PM: Quote from Hemingway
- 2:05 PM - 2:10 PM: Quote from Maya Angelou
- 2:10 PM - 2:15 PM: Quote from Mark Twain
(User likely saw these if they were trying to access blocked apps)
```

### Files to Update/Remove
- Remove: `DeviceActivityMonitor/` folder
- Update: `ScreenTimeService.swift` (remove monitoring code)
- Update: Xcode project (remove DeviceActivityMonitor target)

---

## Task 8: Update History View (Optional)

### Purpose
Show user which quotes they may have encountered.

### New Approach
Instead of tracking events, show time-based quote schedule:

```swift
struct RecentQuotesView {
    // Get last 24 hours of 5-minute windows
    func getRecentWindows() -> [(time: Date, quote: BookQuote)] {
        var windows: [(Date, BookQuote)] = []
        let now = Date()

        // Go back 24 hours in 5-minute increments
        for i in 0..<288 {
            let windowTime = now.addingTimeInterval(TimeInterval(-i * 5 * 60))
            // Calculate quote for that window using QuoteScheduler logic
            windows.append((windowTime, quote))
        }

        return windows
    }
}
```

### UI Design
```
Recent Quotes (Last 24 Hours)

Today
2:30 PM  "A reader lives a thousand lives..."
         — George R.R. Martin

2:25 PM  "Books are a uniquely portable magic."
         — Stephen King

2:20 PM  "The man who does not read..."
         — Mark Twain
```

### Behavior
- Show last 50 windows (approximately 4 hours)
- Group by time period (Today, Yesterday)
- Tap quote → see book details + affiliate link

---

## Task 9: Edge Case Handling

### Problem
User sees quote at 14:04 (window 168), opens app at 14:06 (window 169).

### Solutions

**Solution A: Grace Period**
```swift
func getCurrentOrRecentQuote() -> BookQuote {
    let current = getCurrentQuote()
    let timeSinceWindowStart = getSecondsSinceWindowStart()

    // If we just transitioned to new window (< 30 seconds),
    // show previous quote with a note
    if timeSinceWindowStart < 30 {
        return getPreviousWindowQuote()
    }

    return current
}
```

**Solution B: Show Both**
```
You just saw:
"Quote from previous window"
— Author

Your current quote:
"Quote from current window"
— Author
```

**Solution C: Ignore It**
- Most users won't notice 5-minute misalignment
- Accept ~8% chance of mismatch (30 seconds / 5 minutes)

### Recommendation
**Solution A** with 30-second grace period.

---

## Task 10: Testing

### Test Cases

1. **Synchronization Test**
   - Open blocked app at specific time → note shield quote
   - Immediately open PageInstead → verify same quote
   - Repeat at different times throughout day

2. **Window Transition Test**
   - Open blocked app at XX:04:58
   - Open PageInstead at XX:05:02
   - Verify grace period shows previous quote

3. **Midnight Rollover Test**
   - Test at 23:59 and 00:00
   - Verify window calculation wraps correctly

4. **Quote Variety Test**
   - Track which quotes appear over 24 hours
   - Verify all quotes appear (eventually)
   - Check for modulo edge cases

5. **Cross-Extension Test**
   - Shield picks quote at time T
   - Main app picks quote at time T
   - Verify both use identical calculation

### Test Script
```bash
# Run at various times:
- 00:00 (midnight)
- 05:29 (window boundary)
- 14:23 (middle of day)
- 23:59 (end of day)
```

---

## Task 11: Update Documentation

### Files to Update

1. **CLAUDE.md**
   - Remove DeviceActivityMonitor architecture
   - Add QuoteScheduler explanation
   - Update data flow diagram

2. **IMPLEMENTATION_SUMMARY.md**
   - Document new time-based approach
   - Explain why it's better than event tracking
   - Remove DeviceActivityMonitor section

3. **README.md** (if exists)
   - Update feature description
   - Highlight "Quote of the moment" feature

### New Architecture Diagram
```
User opens blocked app at 14:23
    ↓
Shield Extension calls QuoteScheduler.getCurrentQuote()
    → Calculates window index: 172
    → Returns quotes[172]
    → Displays quote
    ↓
User taps "Open PageInstead"
    ↓
Main app opens at 14:23 (same window)
Main app calls QuoteScheduler.getCurrentQuote()
    → Calculates window index: 172
    → Returns quotes[172]
    → Shows same quote ✅
```

---

## Summary

### What We're Building
1. **QuoteScheduler** - Deterministic time-based quote selection
2. **CurrentQuoteView** - Hero feature showing current quote
3. **Simplified Shield** - Uses QuoteScheduler, no random/saving
4. **Optional History** - Shows recent time windows, not events
5. **Removed DeviceActivityMonitor** - No longer needed

### Key Benefits
✅ Perfect synchronization (no IPC needed)
✅ Simpler architecture (less code)
✅ Better UX (intentional quote delivery)
✅ Works around iOS limitations elegantly

### Estimated Time
- Core implementation: 2-3 hours
- Testing: 1 hour
- Documentation: 30 minutes
- **Total: ~4 hours**

### Risks
- Low risk - Much simpler than event tracking
- Edge cases are acceptable (30-second misalignment)
- Can always enhance later (better history, analytics)

---

## Next Steps

1. Review this plan
2. Approve or suggest modifications
3. Begin implementation (I'll work through tasks sequentially)
4. Test thoroughly
5. Deploy and gather user feedback

**Ready to proceed?** 🚀
