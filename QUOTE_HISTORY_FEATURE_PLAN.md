# Quote History Feature - Implementation Plan

## Overview

This document outlines the plan for implementing a quote history tracking system in PageInstead. When users are blocked from opening apps, they see book quotes via the Shield Extension. This feature will track all quotes shown and display them in the main app, ordered by most recent first.

## Architecture Overview

### Data Flow
1. **Shield Extension** displays quote → Saves to App Group shared storage
2. **User opens PageInstead** → Reads from App Group shared storage
3. **Main app** displays history → Shows quotes ordered by timestamp (newest first)

---

## 1. Data Models & Storage

### Enhanced Data Structures

**`ShieldEvent`** (already exists in `QuoteData.swift`)
```swift
struct ShieldEvent: Codable {
    let quote: BookQuote
    let timestamp: TimeInterval
    let blockedApp: String
    // Future additions:
    // let duration: TimeInterval?  // How long shield was displayed
    // let userTappedButton: Bool?  // Did user tap "Open PageInstead"
}
```

### Storage Strategy

**Current State:**
- `ShieldDataStore` uses UserDefaults with App Group
- Only stores single "lastShieldEvent"

**Needed Changes:**
- Store an array/list of all shield events
- Key: `"shieldEventHistory"` as JSON array

**Storage Considerations:**
- UserDefaults has ~4MB limit (sufficient for quote history)
- For larger scale: Could migrate to SQLite via App Group or CoreData with shared container
- Implement cleanup: Limit to last 500 events OR last 90 days

---

## 2. Shield Extension Updates

### File: `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Current Behavior:**
- Saves single event to `ShieldDataStore`

**Required Changes:**
- Change from saving single event to appending to history array
- Add method: `appendShieldEvent(_ event: ShieldEvent)`
- Ensure timestamp precision is consistent

**What to Track:**
- Quote text, author, book title
- App that was blocked (name + bundle ID if available)
- Timestamp when shield was displayed
- Optional: Track if user tapped "Open PageInstead" button

---

## 3. Data Access Layer

### File: `ShieldConfiguration/QuoteData.swift`

**ShieldDataStore Enhancements:**

```swift
class ShieldDataStore {
    static let shared = ShieldDataStore()
    private let suiteName = "group.com.pageinstead"
    private let historyKey = "shieldEventHistory"
    private let maxEvents = 500  // Limit storage

    // New Methods Needed:
    func saveShieldEvent(_ event: ShieldEvent)
    func getAllShieldEvents() -> [ShieldEvent]
    func getRecentShieldEvents(limit: Int) -> [ShieldEvent]
    func clearOldEvents(olderThan: TimeInterval)
    func getEventsForApp(_ appName: String) -> [ShieldEvent]
    func clearAllHistory()
}
```

**Storage Implementation:**
- Use JSON encoding/decoding for array of `ShieldEvent`
- Implement automatic cleanup when exceeding `maxEvents`
- Add thread safety with `NSLock` or `DispatchQueue`

---

## 4. Main App UI Components

### New View: `QuoteHistoryView`

**Location:** `PageInstead/Features/History/QuoteHistoryView.swift`

**Layout Structure:**
```
QuoteHistoryView
├── NavigationView
│   └── Header: "Your Quote History"
├── Stats Section (Optional - Phase 2)
│   ├── Total blocks today
│   ├── Most blocked app
│   └── Total quotes seen
└── List (or LazyVStack)
    └── ShieldEventRow (for each event)
        ├── Quote text with quotation marks
        ├── Author & Book title
        ├── App name + icon (if available)
        ├── Timestamp (relative: "2 hours ago", "Yesterday")
        └── Divider
```

**Features:**
- Pull to refresh
- Scroll to load more (pagination)
- Empty state when no history
- Search/filter options (Phase 2)

### Supporting View: `ShieldEventRow`

**Location:** `PageInstead/Features/History/ShieldEventRow.swift`

**Component Structure:**
```swift
struct ShieldEventRow: View {
    let event: ShieldEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quote text
            Text(""\(event.quote.text)"")
                .font(.body)
                .foregroundColor(.primary)

            // Author & Book
            Text("— \(event.quote.author), \(event.quote.bookTitle)")
                .font(.caption)
                .foregroundColor(.secondary)

            // Metadata
            HStack {
                Label(event.blockedApp, systemImage: "app.fill")
                Spacer()
                Text(event.timestamp.relativeTime())
            }
            .font(.caption2)
            .foregroundColor(.gray)
        }
        .padding()
    }
}
```

### ViewModel: `HistoryViewModel`

**Location:** `PageInstead/Features/History/HistoryViewModel.swift`

```swift
@available(iOS 16.0, *)
class HistoryViewModel: ObservableObject {
    @Published var events: [ShieldEvent] = []
    @Published var isLoading = false

    private let dataStore = ShieldDataStore.shared

    func loadHistory() {
        events = dataStore.getAllShieldEvents()
            .sorted { $0.timestamp > $1.timestamp }  // Newest first
    }

    func clearHistory() {
        dataStore.clearAllHistory()
        events = []
    }

    func filterByApp(_ appName: String) -> [ShieldEvent] {
        return events.filter { $0.blockedApp == appName }
    }
}
```

---

## 5. Tab Navigation Update

### File: `PageInstead/App/ContentView.swift`

**Current Tabs:**
1. Block Apps (`AppSelectionView`)
2. Books (`BooksPlaceholderView`)

**Add New Tab:**
3. **History** (`QuoteHistoryView`)
   - Icon: `"clock.arrow.circlepath"` or `"book.pages"`
   - Label: "History"

**Code Change:**
```swift
TabView {
    AppSelectionView()
        .tabItem {
            Label("Block Apps", systemImage: "shield")
        }

    BooksPlaceholderView()
        .tabItem {
            Label("Books", systemImage: "book")
        }

    QuoteHistoryView()  // NEW
        .tabItem {
            Label("History", systemImage: "clock.arrow.circlepath")
        }
}
```

---

## 6. Real-time Updates

### Challenge
When shield is shown, main app might not be running. Need to ensure history updates when user returns to app.

### Solutions

**Option 1: Simple (Recommended for Phase 1)**
- Reload history when view appears using `.onAppear`
```swift
.onAppear {
    viewModel.loadHistory()
}
```

**Option 2: Advanced (Phase 2)**
- Use Combine to observe UserDefaults changes
- React to changes in shared App Group storage

**Option 3: Notifications (Phase 3)**
- Shield Extension posts Darwin notification when event is saved
- Main app observes and reloads automatically

---

## 7. Data Synchronization

### App Group Configuration
- Already configured: `group.com.pageinstead`
- Both main app and extension have read/write access
- Shared UserDefaults instance

### Thread Safety
**Potential Issues:**
- Shield shown while user viewing history in app
- Multiple apps blocked simultaneously
- Concurrent reads/writes to UserDefaults

**Solution:**
```swift
private let lock = NSLock()

func saveShieldEvent(_ event: ShieldEvent) {
    lock.lock()
    defer { lock.unlock() }
    // ... save logic
}

func getAllShieldEvents() -> [ShieldEvent] {
    lock.lock()
    defer { lock.unlock() }
    // ... read logic
}
```

---

## 8. Performance Considerations

### Efficient Loading
- Don't load all events at once if list grows large
- Implement pagination: Load 50 events at a time
- Use `LazyVStack` in SwiftUI for efficient rendering

### Memory Management
```swift
// Cleanup strategy
func cleanupOldEvents() {
    let ninetyDaysAgo = Date().timeIntervalSince1970 - (90 * 24 * 60 * 60)
    clearOldEvents(olderThan: ninetyDaysAgo)

    // Or limit by count
    var events = getAllShieldEvents()
    if events.count > 500 {
        events = Array(events.suffix(500))
        // Save back to storage
    }
}
```

**When to Run Cleanup:**
- On app launch
- After saving new event (if count exceeds threshold)
- Weekly background task (future enhancement)

---

## 9. Additional Features (Nice-to-have)

### Analytics/Insights
- **Streak tracking:** "You've stayed focused for 5 days!"
- **Charts:** Blocks per day/week using Swift Charts
- **Top blocked apps:** Most frequently blocked
- **Favorite authors:** From quotes shown

### Quote Actions
- **Share quote:** Export as image or text
- **Mark as favorite:** Save special quotes
- **Find this book:** Link to book details or Apple Books

### Export
- Export full history as JSON/CSV
- Share quote collection
- Email weekly summary

---

## 10. Implementation Order

### Phase 1 - Core Functionality (MVP)
1. ✅ Update `ShieldDataStore` to handle array of events
2. ✅ Modify `ShieldConfigurationExtension` to append to history
3. ✅ Create basic `QuoteHistoryView` with list
4. ✅ Add History tab to main app
5. ✅ Implement basic empty state
6. ✅ Test end-to-end flow

**Estimated Time:** 2-3 hours

### Phase 2 - Polish
7. ⬜ Add filtering/sorting options
8. ⬜ Implement better empty state design
9. ⬜ Add relative timestamps ("2 hours ago")
10. ⬜ Handle storage cleanup automatically
11. ⬜ Add pull-to-refresh
12. ⬜ Implement search functionality

**Estimated Time:** 2-3 hours

### Phase 3 - Advanced Features
13. ⬜ Add statistics/insights dashboard
14. ⬜ Implement quote actions (share, favorite)
15. ⬜ Add export functionality
16. ⬜ Create charts for visualizations
17. ⬜ Add app icons in history

**Estimated Time:** 4-5 hours

---

## 11. Testing Plan

### Manual Testing Checklist

**Basic Flow:**
- [ ] Block an app → Open it → Verify quote appears in shield
- [ ] Open PageInstead → Navigate to History tab
- [ ] Verify quote appears in history list
- [ ] Verify timestamp is correct
- [ ] Block multiple apps → Verify all appear in history
- [ ] Restart app → Verify history persists

**Order & Sorting:**
- [ ] Block apps in sequence → Verify newest appears first
- [ ] Check timestamps are in descending order

**Edge Cases:**
- [ ] No history (empty state shows correctly)
- [ ] Very long quote text (proper truncation/wrapping)
- [ ] 100+ events (performance remains good)
- [ ] App Group access denied (graceful error handling)
- [ ] Corrupted data in UserDefaults (fallback to empty array)

**Data Integrity:**
- [ ] Same app blocked twice → Both events tracked separately
- [ ] Different quotes shown for same app → All recorded
- [ ] Clear history → All events removed
- [ ] Storage limit reached → Old events pruned correctly

---

## 12. Key Files to Create/Modify

### New Files to Create

```
PageInstead/Features/History/
├── QuoteHistoryView.swift       # Main history screen
├── ShieldEventRow.swift         # Individual event row component
└── HistoryViewModel.swift       # Data loading & business logic
```

### Files to Modify

1. **ShieldConfiguration/QuoteData.swift**
   - Enhance `ShieldDataStore` with history array methods
   - Add thread-safe read/write operations
   - Implement cleanup logic

2. **ShieldConfiguration/ShieldConfigurationExtension.swift**
   - Change from single event save to append to array
   - Call new `ShieldDataStore.saveShieldEvent()` method

3. **PageInstead/App/ContentView.swift**
   - Add History tab to TabView
   - Import new QuoteHistoryView

4. **PageInstead.xcodeproj** (via Ruby script)
   - Add new History folder to project
   - Add new Swift files to compile sources

---

## 13. Data Model Extensions

### TimeInterval Extension for Relative Dates

**Location:** `PageInstead/Core/Extensions/TimeInterval+Relative.swift`

```swift
extension TimeInterval {
    func relativeTime() -> String {
        let date = Date(timeIntervalSince1970: self)
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.minute, .hour, .day, .weekOfYear],
            from: date,
            to: now
        )

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}
```

---

## 14. Error Handling

### Potential Errors

1. **App Group not accessible**
   - Fallback to empty history
   - Show error message to user

2. **Corrupted JSON data**
   - Try to parse, catch errors
   - Clear corrupted data and start fresh

3. **Storage full**
   - Implement automatic cleanup
   - Notify user if cleanup needed

### Error Handling Strategy

```swift
func getAllShieldEvents() -> [ShieldEvent] {
    guard let userDefaults = UserDefaults(suiteName: suiteName) else {
        print("⚠️ Cannot access App Group")
        return []
    }

    guard let data = userDefaults.data(forKey: historyKey) else {
        return []  // No history yet
    }

    do {
        let events = try JSONDecoder().decode([ShieldEvent].self, from: data)
        return events
    } catch {
        print("⚠️ Failed to decode history: \(error)")
        // Clear corrupted data
        userDefaults.removeObject(forKey: historyKey)
        return []
    }
}
```

---

## 15. Future Enhancements

### Integration with Books Feature
- Link quotes to full book details
- Show "Find this book" button
- Track which books user is interested in

### Social Features
- Share quote collections with friends
- Compare focus streaks
- Quote of the day recommendations

### Gamification
- Achievements: "Viewed 50 quotes"
- Badges for focus streaks
- Level up system

### Advanced Analytics
- Screen Time integration statistics
- Productivity trends
- Best focus hours/days

---

## Summary

This plan provides a complete roadmap for implementing quote history tracking in PageInstead. The phased approach allows for incremental development and testing, with Phase 1 delivering core functionality and later phases adding polish and advanced features.

**Key Success Metrics:**
- ✅ Quotes are reliably saved when shield is displayed
- ✅ History accurately reflects chronological order
- ✅ App remains performant with large history
- ✅ Data persists across app restarts
- ✅ Users can easily view and understand their history

**Next Steps:**
1. Review and approve this plan
2. Begin Phase 1 implementation
3. Test on device after each phase
4. Gather feedback and iterate
