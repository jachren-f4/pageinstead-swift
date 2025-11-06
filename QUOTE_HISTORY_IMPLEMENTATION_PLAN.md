# Quote History - Last 10 Quotes Implementation Plan

## Overview
Track the last 10 quotes that the user has actually seen, stored in App Group UserDefaults so both main app and Shield Extension can access.

## Data Structure

### QuoteHistoryEntry Model
```swift
struct QuoteHistoryEntry: Codable {
    let quoteId: Int
    let timestamp: TimeInterval  // When user saw this quote
    let windowStart: Date        // Start of the 5-minute window
}
```

### Storage Location
- **Key**: `"quote_history_last_10"`
- **Location**: App Group UserDefaults (`group.com.pageinstead`)
- **Format**: JSON array of QuoteHistoryEntry
- **Max Size**: 10 entries (FIFO)

## Implementation Logic

### 1. When to Record a Quote View

**Trigger Point**: `CurrentQuoteView.onAppear()`
- Every time user opens the main Quote screen
- Record the current quote being displayed
- Use QuoteScheduler to get current quote

**Check Before Adding**:
- Don't add duplicate if it's the same quote as the most recent entry
- This prevents recording the same quote multiple times if user switches tabs quickly

### 2. FIFO Queue Management

```swift
class QuoteHistoryService {
    private let maxHistorySize = 10
    private let appGroupDefaults = UserDefaults(suiteName: "group.com.pageinstead")
    private let storageKey = "quote_history_last_10"

    func addQuoteView(_ quote: BookQuote) {
        // 1. Load existing history
        var history = loadHistory()

        // 2. Check if it's duplicate of most recent
        if let lastEntry = history.first,
           lastEntry.quoteId == quote.id,
           Date().timeIntervalSince1970 - lastEntry.timestamp < 300 { // Within 5 min
            return // Don't add duplicate
        }

        // 3. Create new entry
        let newEntry = QuoteHistoryEntry(
            quoteId: quote.id,
            timestamp: Date().timeIntervalSince1970,
            windowStart: QuoteScheduler.shared.getCurrentWindowInfo().currentWindowStart
        )

        // 4. Add to front (newest first)
        history.insert(newEntry, at: 0)

        // 5. Trim to max size (FIFO - oldest drops off)
        if history.count > maxHistorySize {
            history = Array(history.prefix(maxHistorySize))
        }

        // 6. Save back to UserDefaults
        saveHistory(history)
    }

    func loadHistory() -> [QuoteHistoryEntry] {
        // Load from App Group UserDefaults
    }

    func saveHistory(_ history: [QuoteHistoryEntry]) {
        // Save to App Group UserDefaults
    }
}
```

### 3. Display in QuoteHistoryView

**Title**: "Last 10 Quotes" (instead of "Today")

**Data Flow**:
1. Load history entries from UserDefaults
2. For each entry, fetch full BookQuote from QuoteService using quoteId
3. Display in list with relative time ("5 min ago", "1 hour ago")

**Relative Time Logic**:
```swift
func formatRelativeTime(_ timestamp: TimeInterval) -> String {
    let now = Date().timeIntervalSince1970
    let diff = now - timestamp

    if diff < 300 { // < 5 min
        return "Just now"
    } else if diff < 3600 { // < 1 hour
        let minutes = Int(diff / 60)
        return "\(minutes) min ago"
    } else if diff < 86400 { // < 24 hours
        let hours = Int(diff / 3600)
        return "\(hours)h ago"
    } else {
        let days = Int(diff / 86400)
        return "\(days)d ago"
    }
}
```

### 4. Stats Calculation

**Quotes Seen Today**:
```swift
func getQuotesSeenToday() -> Int {
    let history = loadHistory()
    let startOfDay = Calendar.current.startOfDay(for: Date())

    return history.filter { entry in
        Date(timeIntervalSince1970: entry.timestamp) >= startOfDay
    }.count
}
```

**Quote Streak** (Days where user saw at least 1 quote):
```swift
func calculateStreak() -> Int {
    let history = loadAllHistory() // Need separate full history for this
    let calendar = Calendar.current

    // Group by date
    let dateGroups = Dictionary(grouping: history) { entry in
        calendar.startOfDay(for: Date(timeIntervalSince1970: entry.timestamp))
    }

    let sortedDates = dateGroups.keys.sorted(by: >)

    // Count consecutive days from today
    var streak = 0
    let today = calendar.startOfDay(for: Date())

    for i in 0..<sortedDates.count {
        let expectedDate = calendar.date(byAdding: .day, value: -i, to: today)!
        if sortedDates[i] == expectedDate {
            streak += 1
        } else {
            break
        }
    }

    return streak
}
```

**Note**: For streak calculation, we need to track ALL quote views (not just last 10). This requires a separate storage:
- **Key**: `"quote_history_all_dates"` - stores just dates (compact)
- **Format**: Array of timestamps (just dates, no quote IDs needed)
- **Cleanup**: Keep last 90 days

## Implementation Steps

### Step 1: Create Models
- `QuoteHistoryEntry.swift`
- `QuoteHistoryService.swift`

### Step 2: Update CurrentQuoteView
- Add `.onAppear` hook
- Call `QuoteHistoryService.shared.addQuoteView(currentQuote)`

### Step 3: Update QuoteHistoryView
- Remove old windows-based loading
- Load from QuoteHistoryService
- Change title to "Last 10 Quotes"
- Update stats cards with new metrics

### Step 4: Update Stats Logic
- Implement "Quotes Seen Today" counter
- Implement "Streak" calculator
- Add to QuoteHistoryViewModel

### Step 5: Glass UI Consistency
- Update all cards to use:
  - Border: `Color.white.opacity(0.2), lineWidth: 1`
  - Background: `Color.white.opacity(0.08)`
  - Blur: `.blur(radius: 10)` or `UIBlurEffect.Style.systemUltraThinMaterial`
- Ensure consistent corner radius (20-24px)

## Edge Cases

1. **Empty History**: Show empty state "No quotes viewed yet"
2. **First Launch**: History is empty, streak is 0
3. **Same Quote Twice**: Only record if >5 minutes apart
4. **Midnight Boundary**: Ensure today count resets at midnight
5. **Streak Break**: If user misses a day, streak resets to current streak

## Migration
- Existing users have no history initially
- History builds up as they use the app going forward
- No migration needed from old system

## Benefits
- Shows actual user behavior (what they saw)
- Not tied to 5-minute windows
- Works even if user rarely opens app
- Streak encourages daily engagement
- Simple FIFO queue, easy to understand
