# 🧩 PageInstead App Groups Specification

**Version:** 2.0 (MVP)
**Last Updated:** 31 Oct 2025
**Author:** Joakim Achrén
**Purpose:** Defines the architecture, data model, and user experience for configurable *App Groups* that control how PageInstead interacts with user-selected apps via the iOS Screen Time API.

---

## 1. Overview

App Groups are user-defined collections of apps that share the same usage and blocking rules inside PageInstead.

Each group controls:
- **Which apps are included** (via FamilyActivityPicker)
- **Pause duration** before app access is granted (0-300 seconds)
- **Daily open limit** (optional maximum opens per day)
- **Hard block behavior** when limits are exceeded
- **Schedule** (days of week + time range when group is active)

These rules combine **behavioral nudges** (pause & reflection) and **strict controls** (blocking) to help users build better digital habits.

### MVP Scope

This specification focuses on **achievable features** given iOS ScreenTime API limitations:

✅ **Included in MVP:**
- Multiple app groups with distinct rules
- Pause timer (timestamp-based, not live UI)
- Daily open limit tracking (per-app counter)
- Hard block toggle (block entirely vs continue nudging)
- Scheduling (days of week + time range)
- Streak tracking (consecutive days of staying within limits)

❌ **Deferred to Future Versions:**
- Per-session duration tracking (API doesn't provide this)
- Total daily time limits (no reliable tracking available)
- Live countdown timers in Shield UI (Shield is stateless)
- Quick Setup templates
- Icon/color customization
- Empty state onboarding

---

## 2. Core Components

| Component | Description | Responsibilities |
|------------|-------------|------------------|
| **FamilyActivityPicker** | System UI for selecting apps and categories | App selection only (iOS provides this) |
| **AppGroupManager** | Main app service for CRUD operations | Create, read, update, delete groups; conflict detection |
| **Shield Configuration Extension** | Displays PageInstead quote screens | Check schedule, pause timer, daily counter, show quote + buttons |
| **DeviceActivityMonitor Extension** | Daily reconciliation | Reset counters at midnight, update streaks, sync with health score |
| **App Group Container** | Shared storage (`group.com.pageinstead`) | UserDefaults for group definitions + daily counters |

---

## 3. Data Model

### AppGroup Structure

```swift
struct AppGroup: Identifiable, Codable {
    var id: UUID
    var name: String  // Auto-generated ("Group #1"), user can rename

    // Apps (stored as tokens, NOT FamilyActivitySelection - it's not Codable)
    var applicationTokens: Set<ApplicationToken>
    var webDomainTokens: Set<WebDomainToken>

    // Behavioral nudge
    var pauseForSeconds: Int  // 0, 5, 10, 20, 30, 60, 120, 180, 300

    // Daily limit (nil = unlimited)
    var dailyOpenLimit: Int?  // Number of times each app can be opened per day
    var blockAfterMaxUse: Bool  // If true, hard block when limit reached

    // Scheduling
    var schedule: AppGroupSchedule

    // Metadata
    var createdAt: Date
    var lastUsedDate: Date?  // Last day any app in group was blocked
    var streakDays: Int  // Consecutive days of staying within limits
}

struct AppGroupSchedule: Codable {
    var alwaysActive: Bool  // If true, ignore schedule settings
    var startTime: DateComponents  // Store as [.hour, .minute]
    var endTime: DateComponents
    var activeDays: Set<Int>  // 1=Sunday, 2=Monday, ..., 7=Saturday (Calendar.current.weekday)
}
```

### Helper Extensions

```swift
extension AppGroup {
    // Computed property for UI binding (FamilyActivityPicker requires FamilyActivitySelection)
    var selection: FamilyActivitySelection {
        get {
            var sel = FamilyActivitySelection()
            sel.applicationTokens = applicationTokens
            sel.webDomainTokens = webDomainTokens
            return sel
        }
        set {
            applicationTokens = newValue.applicationTokens
            webDomainTokens = newValue.webDomainTokens
        }
    }

    // Count of apps in group
    var appCount: Int {
        applicationTokens.count + webDomainTokens.count
    }
}
```

### Default Values

When creating a new App Group:
```swift
AppGroup(
    id: UUID(),
    name: "Group #\(nextGroupNumber)",  // Auto-increment
    applicationTokens: [],
    webDomainTokens: [],
    pauseForSeconds: 10,
    dailyOpenLimit: nil,  // Unlimited
    blockAfterMaxUse: false,
    schedule: AppGroupSchedule(
        alwaysActive: true,
        startTime: DateComponents(hour: 0, minute: 0),
        endTime: DateComponents(hour: 23, minute: 59),
        activeDays: [1, 2, 3, 4, 5, 6, 7]  // All days
    ),
    createdAt: Date(),
    lastUsedDate: nil,
    streakDays: 0
)
```

---

## 4. User Flow

### Adding a New App Group

1. **Main Screen:** User taps "Add App Group" button
2. **FamilyActivityPicker:** System picker appears → user selects apps → saves
3. **Rules Screen:** Opens automatically with default settings
4. **Configuration:** User adjusts:
   - Group name (tap to rename)
   - Pause duration (dropdown)
   - Daily open limit (optional, number picker)
   - Hard block toggle
   - Schedule settings (toggle + time/day pickers)
5. **Save:** User taps "Save" button at bottom
6. **Validation:** System checks for conflicts (same app in multiple groups)
   - If conflict: Show alert "Instagram is already in 'Social Detox'. An app can only be in one group."
   - If valid: Save and return to main screen
7. **Main Screen:** New group card appears with app icons and streak

### Editing an Existing Group

1. **Main Screen:** User taps on group card
2. **Rules Screen:** Opens with current settings
3. **Edit:** User can:
   - Rename group (tap name field)
   - Change app selection (tap app count → opens FamilyActivityPicker)
   - Adjust all rules
   - Delete group (destructive button at bottom)
4. **Save:** User taps "Save" button
5. **Validation:** Check for conflicts (excluding current group)
6. **Return:** Back to main screen with updated group card

### Group Card Display

```
┌─────────────────────────────────────┐
│  Social Media                       │
│                                     │
│  [📱] [📱] [📱]      Streak: 3 days │
│  (App icons)                        │
└─────────────────────────────────────┘
```

**Design Notes:**
- No icon displayed next to group name (cleaner look)
- Group name is prominent at top of card
- App icons shown as visual preview (actual app icons from iOS)
- Streak displayed on right side

If no apps selected:
```
┌─────────────────────────────────────┐
│  Work Focus                         │
│                                     │
│  No Apps Selected    Streak: 0 days │
└─────────────────────────────────────┘
```

---

## 5. Rules Screen Sections

### Header Design
```
‹ Back

Group Rules        ← Large, left-aligned title (34pt font)
```

**Design Notes:**
- Back button at top left
- "Group Rules" title is large (34px) and left-aligned
- Matches main screen header style
- No centered navigation bar

### Section 1: Group Name
```
GROUP NAME

Group #1  ✏️        ← Name with pencil icon, tappable
```

**Interaction:**
- Tap anywhere on the row to edit
- Opens system alert dialog with text input field
- User enters new name → Save → Returns to rules screen
- More iOS-native than inline editing

### Section 2: App Selection
```
APPS

Selected Apps                    3 apps  ›
```

**Interaction:**
- Tap row to open iOS FamilyActivityPicker
- System picker handles app/website selection
- On return, count updates automatically
- Helper text shows selected app names (e.g., "Instagram, Twitter, LinkedIn")

### Section 3: Pause For
```
PAUSE FOR

Wait before opening          10 seconds  ›
```

**Available options (system list picker):**
- 0 seconds (instant access)
- 5 seconds
- 10 seconds (default)
- 20 seconds
- 30 seconds
- 60 seconds
- 120 seconds
- 180 seconds
- 300 seconds

**Interaction:**
- Tap row to open system list picker
- User selects duration from list
- Selected value shows checkmark
- Returns to rules screen with updated value

### Section 4: Daily Open Limit
```
Daily Open Limit

[Toggle: OFF]     ← When OFF, fields below are hidden

Open each app up to [20] times per day

[Toggle: Block after max use]
```

**Behavior:**
- Toggle ON: Show number picker and hard block toggle
- Number picker: 1-100 (default: 20)
- Hard block toggle:
  - ON: Show hard block message when limit reached (no button)
  - OFF: Continue showing quotes with pause timer (motivational mode)

### Section 5: Schedule
```
Schedule

[Toggle: Always Active]  ← When ON, fields below are hidden

Start time:   [0:00]
End time:     [23:59]

[Su] [M] [T] [W] [Th] [F] [Sa]  ← Tappable pills
(Selected days are filled with blue, unselected are outlined)
```

**Behavior:**
- Always Active ON: Group applies 24/7
- Always Active OFF: Group only applies during:
  - Selected days of week
  - Between start time and end time
- Time pickers use native iOS time picker
- Days toggle on/off with tap (must select at least 1)

### Section 6: Actions
```
[Save]  ← Primary button (Liquid Glass style)

[Delete Group]  ← Destructive button (red, bottom of screen)
```

---

## 6. Shield Extension Behavior

### Shield Configuration Logic

**When a user tries to open a blocked app:**

```swift
// 1. Look up which group this app belongs to
guard let group = AppGroupManager.shared.getGroup(for: appToken) else {
    // App not in any group - allow access
    return nil
}

// 2. Check if group is currently active (schedule)
guard isGroupActive(group) else {
    // Outside scheduled hours - allow access
    return nil
}

// 3. Get today's usage data
let defaults = UserDefaults(suiteName: "group.com.pageinstead")!
let usageKey = "usage_\(group.id)_\(appToken)_\(todayString)"
var opensToday = defaults.integer(forKey: usageKey)

// 4. Check if daily limit exceeded
if let limit = group.dailyOpenLimit, opensToday >= limit {
    if group.blockAfterMaxUse {
        // HARD BLOCK - no button
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: .black.opacity(0.8),
            icon: .init(systemName: "hourglass.circle.fill"),
            title: .init(text: "Daily Limit Reached", color: .white),
            subtitle: .init(text: "You've opened this app \(opensToday) times today. Try again tomorrow.", color: .white.opacity(0.7))
        )
    } else {
        // SOFT BLOCK - continue with pause timer
        // (Motivational mode - still show quotes)
    }
}

// 5. Check pause timer
let pauseKey = "pause_\(group.id)_\(appToken)"
let pauseStart = defaults.object(forKey: pauseKey) as? Date

if pauseStart == nil {
    // First time showing shield today for this app - record timestamp
    defaults.set(Date(), forKey: pauseKey)
    defaults.synchronize()
}

let elapsed = Date().timeIntervalSince(pauseStart ?? Date())
let showButton = elapsed >= Double(group.pauseForSeconds)

// 6. Increment counter (only once per shield display)
let incrementKey = "incremented_\(group.id)_\(appToken)_\(Date().timeIntervalSince1970)"
if defaults.object(forKey: incrementKey) == nil {
    opensToday += 1
    defaults.set(opensToday, forKey: usageKey)
    defaults.set(true, forKey: incrementKey)
    defaults.synchronize()

    // Also increment global health score counter
    HealthScoreService.incrementBlockedAttempts()
}

// 7. Get current quote
let quote = QuoteScheduler.shared.getCurrentQuote()

// 8. Return shield configuration
return ShieldConfiguration(
    backgroundBlurStyle: .systemMaterial,
    backgroundColor: .black.opacity(0.95),
    icon: .init(systemName: "book.fill"),
    title: .init(text: quote.text, color: .white),
    subtitle: .init(text: "— \(quote.author), \(quote.book)", color: .white.opacity(0.7)),
    primaryButtonLabel: showButton ?
        .init(text: "Open App", color: .blue) :
        .init(text: "Wait \(Int(Double(group.pauseForSeconds) - elapsed))s...", color: .gray)
)
```

### Schedule Checking

```swift
func isGroupActive(_ group: AppGroup) -> Bool {
    guard !group.schedule.alwaysActive else { return true }

    let now = Date()
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: now)

    // Check if today is selected
    guard group.schedule.activeDays.contains(weekday) else {
        return false
    }

    // Get current time components
    let currentTime = calendar.dateComponents([.hour, .minute], from: now)

    // Handle overnight schedules (e.g., 22:00 - 06:00)
    if isOvernightSchedule(group.schedule) {
        return isCurrentTimeInOvernightRange(currentTime, schedule: group.schedule)
    } else {
        return isCurrentTimeInRange(currentTime, schedule: group.schedule)
    }
}

func isOvernightSchedule(_ schedule: AppGroupSchedule) -> Bool {
    let startHour = schedule.startTime.hour ?? 0
    let endHour = schedule.endTime.hour ?? 0
    return startHour > endHour
}
```

### Important Limitations

**Shield Extension is stateless:**
- ❌ No live countdown timers
- ❌ No persistent UI state
- ❌ iOS may cache shield for hours
- ✅ Use timestamps and check elapsed time
- ✅ User must close/reopen app to see button appear

**DeviceActivityMonitor is limited:**
- ❌ No per-launch callbacks
- ❌ No foreground/background events
- ❌ No per-session duration tracking
- ✅ Can run daily reconciliation at midnight
- ✅ Can handle threshold events (once per interval)

---

## 7. Daily Reset & Streak Logic

### Reset at Midnight

**Handled in Shield Extension:**
```swift
// Check if date changed
let lastResetKey = "last_reset_\(group.id)"
let lastReset = defaults.object(forKey: lastResetKey) as? String ?? ""
let todayString = dateFormatter.string(from: Date())

if lastReset != todayString {
    // New day - reset counters
    resetDailyCounters(for: group)
    defaults.set(todayString, forKey: lastResetKey)
}
```

**Also in DeviceActivityMonitor:**
```swift
func intervalDidEnd(for activity: DeviceActivityName) {
    // Daily reconciliation (runs at midnight)
    let groups = AppGroupManager.shared.getAllGroups()

    for group in groups {
        // Reset daily counters
        resetDailyCounters(for: group)

        // Update streak
        updateStreak(for: group)

        // Sync with health score
        reconcileHealthScore()
    }
}
```

### Streak Calculation

```swift
func updateStreak(for group: AppGroup) {
    guard let lastUsed = group.lastUsedDate else {
        // Never used - streak stays at 0
        return
    }

    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

    if calendar.isDate(lastUsed, inSameDayAs: yesterday) {
        // Used yesterday - increment streak
        group.streakDays += 1
        group.lastUsedDate = Date()
    } else if calendar.isDate(lastUsed, inSameDayAs: Date()) {
        // Used today - no change
    } else {
        // Missed a day - reset streak
        group.streakDays = 0
        group.lastUsedDate = nil
    }

    AppGroupManager.shared.save(group)
}
```

**Streak Definition:**
- Counts consecutive days where user encountered blocks from this group
- Resets to 0 if a day is skipped without any blocked attempts
- Displayed on group card: "Streak: X days"

---

## 8. Conflict Detection

### Rule: One App, One Group

An app can only belong to **one** App Group at a time.

**Validation on Save:**
```swift
func validateGroup(_ group: AppGroup, excluding: UUID? = nil) -> ValidationResult {
    let allGroups = AppGroupManager.shared.getAllGroups()
        .filter { $0.id != excluding }  // Exclude current group when editing

    for existingGroup in allGroups {
        // Check for token conflicts
        let conflictingApps = group.applicationTokens.intersection(existingGroup.applicationTokens)
        let conflictingDomains = group.webDomainTokens.intersection(existingGroup.webDomainTokens)

        if !conflictingApps.isEmpty || !conflictingDomains.isEmpty {
            // Get app name for error message (if possible)
            let appName = getAppName(for: conflictingApps.first) ?? "This app"

            return .failure(
                title: "Conflict Detected",
                message: "\(appName) is already in '\(existingGroup.name)'. An app can only be in one group at a time."
            )
        }
    }

    return .success
}
```

**User Experience:**
1. User tries to save group with conflicting app
2. Alert appears with group name containing the conflict
3. User must remove app from new group or delete it from existing group first
4. Save only succeeds when no conflicts exist

---

## 9. Storage & Persistence

### Storage Location

All data stored in **App Group Container:**
```
group.com.pageinstead
```

### UserDefaults Keys

**Group Definitions:**
```swift
"app_groups"  // JSON array of AppGroup structs
```

**Daily Usage Counters:**
```swift
"usage_{groupID}_{appToken}_{YYYY-MM-DD}"  // Int: opens today
"pause_{groupID}_{appToken}"  // Date: timestamp of first shield display
"incremented_{groupID}_{appToken}_{timestamp}"  // Bool: prevent double-counting
"last_reset_{groupID}"  // String: last date counters were reset
```

**Migration from Existing System:**
```swift
// On first launch of new App Groups system:
// 1. Check if old "selectedApps" exists in ScreenTimeService
// 2. If yes, create default "Group #1" with those apps
// 3. Use default settings (10s pause, no limit)
// 4. Mark migration as complete
```

### Example Data

**Stored App Group:**
```json
{
  "id": "E8F5F1C0-3F7B-44A5-8C45-4230E37A6A95",
  "name": "Social Media Detox",
  "applicationTokens": ["com.instagram.ios", "com.twitter.twitter"],
  "webDomainTokens": [],
  "pauseForSeconds": 20,
  "dailyOpenLimit": 10,
  "blockAfterMaxUse": true,
  "schedule": {
    "alwaysActive": false,
    "startTime": {"hour": 9, "minute": 0},
    "endTime": {"hour": 17, "minute": 0},
    "activeDays": [2, 3, 4, 5, 6]
  },
  "createdAt": "2025-10-31T08:00:00Z",
  "lastUsedDate": "2025-10-31T08:00:00Z",
  "streakDays": 3
}
```

---

## 10. UI Mockups

### HTML Prototypes

Interactive HTML mockups are available in `/mockups/`:

1. **index.html** - Navigation hub with feature overview
2. **app-groups-empty-state.html** - First-time user onboarding
3. **app-groups-main-screen.html** - Dashboard with group cards
4. **app-groups-rules-screen.html** - Configuration screen (default state)
5. **app-groups-rules-expanded.html** - Configuration screen (fully configured)

**To view:**
```bash
open mockups/index.html
```

**Key Design Decisions:**
- Removed decorative icons next to group names (cleaner, more iOS-like)
- Simplified empty state to prevent scrolling (40% reduction)
- Large left-aligned headers matching main app style
- System dialogs for name editing (native iOS pattern)
- System pickers for app selection and duration (FamilyActivityPicker, List)
- All interactive elements functional with JavaScript

---

## 11. UI Design Patterns

### Liquid Glass Styling

All UI components follow PageInstead's Liquid Glass design system:

**Group Card:**
```swift
.liquidGlassCard()  // White 0.08 opacity + ultraThinMaterial + border
```

**Primary Button (Save):**
```swift
.liquidGlassPrimaryButton()  // Blue tint, capsule shape
```

**Destructive Button (Delete):**
```swift
.liquidGlassDestructiveButton()  // Red tint
```

**Day Pills:**
```swift
// Selected
.background(Color.blue)
.foregroundColor(.white)

// Unselected
.background(Color.blue.opacity(0.2))
.foregroundColor(.blue)
```

### Critical Design Rules

- ✅ Add `.allowsHitTesting(false)` to overlay layers
- ✅ Use blue text on glass buttons (white is invisible)
- ✅ Only glass navigation/control layers (never content)
- ❌ Never stack glass layers (causes visual clutter)

---

## 12. Behavioral Summary

| User Action | System Reaction | Notes |
|------------|------------------|-------|
| Opens blocked app (within schedule) | Show quote + pause timer | Normal soft block |
| Opens app before pause expires | Show "Wait Xs..." message | User must close/reopen to check again |
| Opens app after pause expires | Show "Open App" button | Tapping proceeds to app |
| Reaches daily limit (hard block OFF) | Continue normal pause behavior | Motivational mode |
| Reaches daily limit (hard block ON) | Show "Daily Limit Reached" message (no button) | Enforced mode |
| Opens app outside schedule | Allow access immediately | Schedule not active |
| New day starts | Reset counters, update streak | Behavior returns to soft mode |
| Taps group card | Opens Rules screen | Edit mode |
| Saves group with conflict | Show alert, prevent save | Must resolve first |

---

## 13. Integration with Existing Features

### Health Score Service

**App Groups tracking feeds into health score:**
- Each shield display increments global `blocked_attempts_today` counter
- HealthScoreService uses this for score calculation (100 - (attempts / baseline * 100))
- Daily reconciliation in DeviceActivityMonitor syncs both systems

### Quote System

**Time-based quotes continue to work:**
- Shield Extension calls `QuoteScheduler.shared.getCurrentQuote()`
- 2-hour window algorithm remains unchanged
- Both Shield and main app calculate independently (no IPC)

### Self-Restriction Features

**Lock settings timer/passcode still apply:**
- Users can still lock settings behind timer or passcode
- App Groups screen is part of "Blocked Apps" tab (tab 1)
- Subject to same restrictions as other settings

---

## 14. Future Enhancements (Post-MVP)

| Feature | Description | Complexity |
|---------|-------------|-----------|
| Quick Setup Templates | Pre-configured groups ("Social Media", "Work Apps", etc.) | Low |
| Icon/Color Customization | Let users pick icon and accent color per group | Low |
| Empty State Onboarding | Tutorial on first launch explaining App Groups | Medium |
| Category-Based Rules | Apply limits by app category (Social, Games, etc.) | Medium |
| Per-App Different Rules | Different pause/limits for apps within same group | High |
| Total Time Tracking | Track total minutes per day (requires workaround) | High |
| Quote Personalization | Pick quote collections per group | Medium |
| Weekly Goals | Aggregate stats across 7 days | Medium |
| Export Data | CSV export of usage history | Low |

---

## 15. Testing Checklist

### Unit Tests
- [ ] AppGroup model encoding/decoding
- [ ] Schedule validation (overnight ranges, edge cases)
- [ ] Conflict detection algorithm
- [ ] Streak calculation logic
- [ ] Daily reset timing

### Integration Tests
- [ ] FamilyActivityPicker selection → storage
- [ ] Shield Extension lookups (app → group)
- [ ] DeviceActivityMonitor daily reconciliation
- [ ] Migration from old blocking system
- [ ] Health score synchronization

### Manual Testing
- [ ] Create group → select apps → save → appears on main screen
- [ ] Edit group → change rules → save → updates reflected
- [ ] Delete group → apps become unblocked
- [ ] Pause timer: open app, wait, reopen, button appears
- [ ] Daily limit: open 20 times, 21st shows hard block
- [ ] Schedule: set to weekdays only, verify works on Monday, not Saturday
- [ ] Overnight schedule: set 22:00-06:00, test at 23:00 and 05:00
- [ ] Conflict detection: try adding same app to two groups
- [ ] Streak: block app 3 days in a row, verify streak = 3
- [ ] Migration: existing blocked apps appear in "Group #1"

### Edge Cases
- [ ] Empty group (no apps selected)
- [ ] Pause = 0 seconds (instant access)
- [ ] No daily limit (unlimited opens)
- [ ] Schedule all days, 00:00-23:59 (effectively always active)
- [ ] Delete group while app is being blocked
- [ ] Timezone changes
- [ ] Date rolls over at midnight while app is open

---

---

## 17. Implementation Resources

### Task Lists

**Comprehensive Task Breakdown:**
- `APP_GROUPS_IMPLEMENTATION_TASKS.md` - Detailed 8-phase implementation plan with 80+ specific tasks, file locations, acceptance criteria, and dependencies

**Quick Reference Checklist:**
- `APP_GROUPS_CHECKLIST.md` - Condensed checklist for tracking progress across 14 major phases

**Visual Mockups:**
- `mockups/` - Interactive HTML prototypes of all screens
- `mockups/index.html` - Navigation hub

### Implementation Timeline

**Phase 1-2:** Week 1 (Data layer + Rules UI)
**Phase 3-4:** Week 2 (Main screen + Shield Extension)
**Phase 5-6:** Week 3 (Monitor + ScreenTime integration)
**Phase 7-8:** Week 3-4 (Testing + Documentation)

**Total Estimated Effort:** 3-4 weeks

### Key Decisions

- Use UserDefaults in App Group suite (not Core Data)
- System dialogs for name editing (not inline)
- Timestamp-based pause timer (not live countdown)
- FamilyActivityPicker for app selection (iOS provided)
- No decorative icons on group cards (cleaner design)
- Simplified empty state (no scrolling required)

---

## 18. Summary

**App Groups MVP** provides users with structured, flexible control over their digital habits:

✅ **Multiple groups** for different contexts (work, social, etc.)
✅ **Behavioral nudges** via pause timers (0-300s)
✅ **Daily limits** with optional hard blocking
✅ **Scheduling** for time-of-day and day-of-week control
✅ **Streak tracking** for motivation
✅ **Conflict prevention** (one app, one group)
✅ **Seamless migration** from existing blocking system

**Technical Constraints Respected:**
- Shield Extension is stateless (timestamp-based timers)
- No per-session tracking (API limitation)
- No live UI updates (user must reopen)
- Daily reconciliation via DeviceActivityMonitor

**Design Principles:**
- Progressive disclosure (main screen → rules screen)
- Liquid Glass visual language
- Simple, intuitive controls
- Graceful degradation (works even if some features disabled)

This specification serves as the complete blueprint for implementing App Groups in PageInstead.
