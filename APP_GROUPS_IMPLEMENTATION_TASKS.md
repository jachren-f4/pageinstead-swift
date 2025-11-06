# App Groups Feature - Implementation Task List

**Project:** PageInstead Swift App Groups MVP
**Specification:** App_Groups_Specification.md v2.0
**Last Updated:** October 31, 2025
**Status:** ✅ **IMPLEMENTATION COMPLETE** - Ready for Testing

---

## Implementation Status

**Completed Phases:**
- ✅ **Phase 1:** Data Layer & Models (AppGroup, AppGroupManager, Migration)
- ✅ **Phase 2:** Rules Screen UI (All 6 sections with system pickers)
- ✅ **Phase 3:** Main Screen UI (AppGroupsListView, Cards, Empty State)
- ✅ **Phase 4:** Shield Extension Integration (Group lookup, schedule, pause timer, counters)
- ✅ **Phase 5:** DeviceActivityMonitor Integration (Daily reset, streak calculation)
- ✅ **Phase 6:** ScreenTimeService Integration (Auto-apply shields via Combine)
- ✅ **Bonus:** Simulator Support (FamilyActivityPicker bypass for UI testing)
- ✅ **Phase 8:** Documentation (CLAUDE.md updated with App Groups section)

**Pending:**
- ⏳ **Phase 7:** Unit Tests & Manual Device Testing

---

## Overview

This document breaks down the App Groups feature implementation into organized phases with specific tasks. Each task includes file locations, dependencies, and acceptance criteria.

**Estimated Total Effort:** 3-4 weeks
**Critical Path:** Phase 1 → Phase 2 → Phase 4 → Phase 5

---

## Phase 1: Data Layer & Models (Week 1, Days 1-2) ✅ COMPLETED

### 1.1 Create AppGroup Model ✅
**File:** `PageInstead/Core/Models/AppGroup.swift`

**Tasks:**
- [x] Create `AppGroup` struct conforming to `Identifiable`, `Codable`
  - Properties: id, name, applicationTokens, webDomainTokens, pauseForSeconds, dailyOpenLimit, blockAfterMaxUse, schedule, createdAt, lastUsedDate, streakDays
- [x] Create `AppGroupSchedule` struct conforming to `Codable`
  - Properties: alwaysActive, startTime, endTime, activeDays
- [x] Add computed property `selection` (FamilyActivitySelection ↔ tokens conversion)
- [x] Add computed property `appCount` (total apps + domains)
- [ ] Write unit tests for encoding/decoding
- [ ] Write unit tests for selection conversion

**Acceptance Criteria:**
- ✅ AppGroup can be encoded to/from JSON
- ✅ FamilyActivitySelection converts correctly to/from tokens
- ✅ Default values match specification

**Files Created:**
- `PageInstead/Core/Models/AppGroup.swift` (new)
- `PageInsteadTests/Models/AppGroupTests.swift` (new)

---

### 1.2 Create AppGroupManager Service ✅
**File:** `PageInstead/Core/Services/AppGroupManager.swift`

**Tasks:**
- [x] Create `AppGroupManager` singleton class
- [x] Implement storage using UserDefaults (App Group suite)
  - Key: `"app_groups"` → JSON array
- [x] Implement CRUD operations:
  - `getAllGroups() -> [AppGroup]`
  - `getGroup(by id: UUID) -> AppGroup?`
  - `getGroup(for token: ApplicationToken) -> AppGroup?`
  - `createGroup(_ group: AppGroup) throws`
  - `updateGroup(_ group: AppGroup) throws`
  - `deleteGroup(id: UUID) throws`
- [x] Implement conflict detection:
  - `validateGroup(_ group: AppGroup, excluding: UUID?) -> ValidationResult`
- [x] Implement auto-increment for group names ("Group #1", "Group #2", etc.)
- [x] Add observers for group changes (Combine publishers)
- [ ] Write unit tests for all operations

**Acceptance Criteria:**
- ✅ Groups persist across app restarts
- ✅ Conflict detection prevents duplicate app assignments
- ✅ CRUD operations atomic (rollback on error)
- ✅ Observable changes for UI updates

**Files Created:**
- `PageInstead/Core/Services/AppGroupManager.swift` (new)
- `PageInsteadTests/Services/AppGroupManagerTests.swift` (new)

---

### 1.3 Migration from Existing System ✅
**File:** `PageInstead/Core/Services/AppGroupManager.swift` (extension)

**Tasks:**
- [x] Add `performMigrationIfNeeded()` method
- [x] Check if old `ScreenTimeService.selectedApps` exists
- [x] If exists and no groups:
  - Create default "Group #1"
  - Convert `FamilyActivitySelection` to tokens
  - Set default rules (10s pause, no limit)
  - Mark migration complete with flag
- [x] Call migration on first app launch after update
- [ ] Write migration tests

**Acceptance Criteria:**
- ✅ Existing blocked apps migrate to "Group #1"
- ✅ Migration only runs once
- ✅ No data loss during migration
- ✅ Old system continues working if migration fails

**Files Modified:**
- `PageInstead/Core/Services/AppGroupManager.swift`
- `PageInstead/App/PageInsteadApp.swift` (add migration call)

---

## Phase 2: Rules Screen UI (Week 1, Days 3-5) ✅ COMPLETED

### 2.1 Create AppGroupRulesView
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create SwiftUI view with scroll container
- [ ] Add header with back button + "Group Rules" title (34pt, left-aligned)
- [ ] Add `@State` for group being edited
- [ ] Add `@State` for UI toggles (dailyLimitEnabled, scheduleActive)
- [ ] Add `@Environment(\.dismiss)` for navigation
- [ ] Implement save/cancel logic
- [ ] Add validation before save
- [ ] Show conflict alerts if validation fails

**Acceptance Criteria:**
- ✅ Header matches main screen style
- ✅ Back button navigates correctly
- ✅ Save persists changes
- ✅ Cancel discards changes

**Files Created:**
- `PageInstead/Features/AppGroups/AppGroupRulesView.swift` (new)

---

### 2.2 Section 1: Group Name Editing
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create glass card section with "GROUP NAME" title
- [ ] Display group name with pencil icon (✏️)
- [ ] Add tap gesture to show system alert
- [ ] Implement `TextField` in alert dialog
- [ ] Update group name on save
- [ ] Trim whitespace and validate non-empty

**Acceptance Criteria:**
- ✅ Tapping opens native iOS alert
- ✅ Alert has text field pre-filled with current name
- ✅ Empty names rejected
- ✅ Name updates immediately in UI

**Components:**
- Uses `.liquidGlassCard()` modifier
- Blue pencil icon color (#6CC8FF)

---

### 2.3 Section 2: App Selection
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create glass card section with "APPS" title
- [ ] Add row: "Selected Apps" label + count + chevron
- [ ] Add `@State var isPickerPresented = false`
- [ ] Bind to FamilyActivityPicker with `.familyActivityPicker()`
- [ ] Update group.selection on picker dismissal
- [ ] Show helper text with app names (if available)
- [ ] Update count dynamically

**Acceptance Criteria:**
- ✅ Tapping opens FamilyActivityPicker
- ✅ Count updates when picker closes
- ✅ Changes not saved until "Save" button pressed
- ✅ Helper text shows selected app names

**Dependencies:**
- FamilyControls framework
- FamilyActivityPicker system component

---

### 2.4 Section 3: Pause For Duration
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create glass card section with "PAUSE FOR" title
- [ ] Add row: "Wait before opening" label + value + chevron
- [ ] Create duration picker (Menu or NavigationLink to list)
- [ ] Options: [0, 5, 10, 20, 30, 60, 120, 180, 300] seconds
- [ ] Format display: "10 seconds", "2 minutes", etc.
- [ ] Add helper text explaining pause behavior

**Acceptance Criteria:**
- ✅ Tapping opens system-style picker
- ✅ Selected value highlighted with checkmark
- ✅ Display updates immediately
- ✅ All 9 options available

**Implementation Note:**
Use SwiftUI `Menu` or `Picker` with `.pickerStyle(.menu)` for native iOS list

---

### 2.5 Section 4: Daily Open Limit
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create glass card section with "DAILY OPEN LIMIT" title
- [ ] Add toggle: "Enable Daily Limit"
- [ ] Add conditional content (show when toggle ON):
  - Number picker row: "Opens per day" + stepper (1-100)
  - Toggle row: "Block after max use"
- [ ] Add helper text explaining hard block vs soft mode
- [ ] Animate section expansion/collapse

**Acceptance Criteria:**
- ✅ Toggle shows/hides nested content smoothly
- ✅ Number picker allows 1-100 range
- ✅ Hard block toggle updates state
- ✅ Helper text explains current configuration

**Components:**
- iOS-style Toggle
- Custom number picker with +/- buttons or Stepper

---

### 2.6 Section 5: Schedule
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Create glass card section with "SCHEDULE" title
- [ ] Add toggle: "Always Active"
- [ ] Add conditional content (show when toggle OFF):
  - Time picker row: "Start time" (DatePicker, hourAndMinute)
  - Time picker row: "End time" (DatePicker, hourAndMinute)
  - Day pills row: 7 tappable buttons (Su, M, T, W, Th, F, Sa)
- [ ] Implement day pill toggle logic
- [ ] Validate at least 1 day selected
- [ ] Add helper text explaining schedule
- [ ] Animate section expansion/collapse

**Acceptance Criteria:**
- ✅ Always Active toggle shows/hides schedule controls
- ✅ Time pickers use native iOS interface
- ✅ Day pills toggle blue (selected) / outlined (unselected)
- ✅ At least 1 day must be selected (validation)

**Components:**
- DatePicker with `.hourAndMinute` displayedComponents
- Custom day pill buttons with `.liquidGlassPill()` style

---

### 2.7 Section 6: Action Buttons
**File:** `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

**Tasks:**
- [ ] Add "Save" button at bottom
  - Primary glass button style (blue)
  - Validate group before saving
  - Show conflict alert if needed
  - Dismiss on success
- [ ] Add "Delete Group" button below Save
  - Destructive glass button style (red)
  - Show confirmation alert
  - Remove shields from ScreenTimeService
  - Delete from AppGroupManager
  - Dismiss on success
- [ ] Disable Save if validation fails

**Acceptance Criteria:**
- ✅ Save validates and persists changes
- ✅ Conflict alert shows group name
- ✅ Delete confirms before removing
- ✅ Buttons styled correctly (blue/red glass)

**Components:**
- `.liquidGlassPrimaryButton()`
- `.liquidGlassDestructiveButton()`

---

## Phase 3: Main Screen UI (Week 2, Days 1-2) ✅ COMPLETED

### 3.1 Create AppGroupsListView
**File:** `PageInstead/Features/AppGroups/AppGroupsListView.swift`

**Tasks:**
- [ ] Create SwiftUI view replacing `AppSelectionView`
- [ ] Add header: "Blocked Apps" (42pt) + subtitle
- [ ] Add `@StateObject` observing `AppGroupManager`
- [ ] Implement ScrollView with group cards
- [ ] Add "Add App Group" button at bottom
- [ ] Handle empty state (show when no groups)
- [ ] Add navigation to AppGroupRulesView

**Acceptance Criteria:**
- ✅ Lists all app groups from AppGroupManager
- ✅ Updates automatically when groups change
- ✅ Navigation works in both directions
- ✅ Empty state shows when appropriate

**Files Created:**
- `PageInstead/Features/AppGroups/AppGroupsListView.swift` (new)

---

### 3.2 Create Group Card Component
**File:** `PageInstead/Features/AppGroups/Components/AppGroupCard.swift`

**Tasks:**
- [ ] Create reusable SwiftUI view
- [ ] Display group name (no icon)
- [ ] Show app icons (fetch from ApplicationToken if possible)
- [ ] Show "No Apps Selected" if empty
- [ ] Display streak badge on right
- [ ] Apply `.liquidGlassCard()` styling
- [ ] Add tap gesture for navigation
- [ ] Add active state animation

**Acceptance Criteria:**
- ✅ Card matches HTML mockup design
- ✅ Shows actual app icons from iOS
- ✅ Tappable with visual feedback
- ✅ Streak displayed correctly

**Files Created:**
- `PageInstead/Features/AppGroups/Components/AppGroupCard.swift` (new)

**Technical Notes:**
- May need to use `Label` from FamilyControls for app icons
- Fallback to placeholder if icon unavailable

---

### 3.3 Create Empty State View
**File:** `PageInstead/Features/AppGroups/Components/AppGroupsEmptyState.swift`

**Tasks:**
- [ ] Create SwiftUI view matching simplified design
- [ ] Add shield icon (80pt, 0.4 opacity)
- [ ] Add title: "Create Your First App Group"
- [ ] Add description text
- [ ] Add "Create App Group" CTA button
- [ ] Navigate to AppGroupRulesView (create mode)

**Acceptance Criteria:**
- ✅ Matches simplified HTML mockup
- ✅ No scrolling required to see button
- ✅ Button navigates to rules screen
- ✅ Creates new group on navigation

**Files Created:**
- `PageInstead/Features/AppGroups/Components/AppGroupsEmptyState.swift` (new)

---

### 3.4 Update ContentView Navigation
**File:** `PageInstead/App/ContentView.swift`

**Tasks:**
- [ ] Replace `AppSelectionView` with `AppGroupsListView`
- [ ] Update tab label if needed
- [ ] Verify self-restriction locks still work
- [ ] Test navigation flow

**Acceptance Criteria:**
- ✅ New view appears in correct tab
- ✅ Tab label unchanged ("Blocked Apps")
- ✅ Self-restriction features still functional
- ✅ No breaking changes to other tabs

**Files Modified:**
- `PageInstead/App/ContentView.swift`

---

## Phase 4: Shield Extension Integration (Week 2, Days 3-5) ✅ COMPLETED

### 4.1 Update ShieldConfigurationExtension - Group Lookup
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Import AppGroupManager in extension target
- [ ] Add method: `lookupGroup(for token: ApplicationToken) -> AppGroup?`
- [ ] Iterate through all groups to find matching token
- [ ] Return first matching group (conflict prevention ensures only one)
- [ ] Add logging for debugging

**Acceptance Criteria:**
- ✅ Extension can access App Group container
- ✅ Lookup finds correct group for any app
- ✅ Returns nil if app not in any group
- ✅ Performance acceptable (< 10ms)

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

---

### 4.2 Update ShieldConfigurationExtension - Schedule Checking
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Add method: `isGroupActive(_ group: AppGroup) -> Bool`
- [ ] Check `schedule.alwaysActive` flag
- [ ] Get current weekday and time
- [ ] Check if current day in `activeDays`
- [ ] Check if current time between start/end times
- [ ] Handle overnight schedules (start > end)
- [ ] Add unit tests for schedule logic

**Acceptance Criteria:**
- ✅ Returns true when schedule is active
- ✅ Returns false when outside schedule
- ✅ Handles overnight ranges correctly (22:00-06:00)
- ✅ Respects timezone

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

---

### 4.3 Update ShieldConfigurationExtension - Pause Timer
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Add timestamp storage for pause mechanism
  - Key: `"pause_\(groupID)_\(appToken)"`
  - Store: First display Date
- [ ] Check elapsed time on each shield display
- [ ] If elapsed >= `pauseForSeconds`, show "Open App" button
- [ ] If elapsed < pause, show "Wait Xs..." message
- [ ] Reset timestamp on daily reset
- [ ] Add method: `shouldShowOpenButton(group: AppGroup, token: ApplicationToken) -> Bool`

**Acceptance Criteria:**
- ✅ First open stores timestamp
- ✅ Subsequent opens calculate elapsed time
- ✅ Button appears after pause expires
- ✅ Timestamp resets at midnight

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Technical Notes:**
- Shield is stateless - user must close/reopen to see button
- Use UserDefaults in App Group suite
- Date comparison must handle timezone

---

### 4.4 Update ShieldConfigurationExtension - Daily Counter
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Add counter increment on shield display
  - Key: `"usage_\(groupID)_\(appToken)_\(dateString)"`
- [ ] Prevent double-counting with unique key per display
  - Key: `"incremented_\(groupID)_\(appToken)_\(timestamp)"`
- [ ] Check daily limit before incrementing
- [ ] Add method: `incrementAndGetCount(group: AppGroup, token: ApplicationToken) -> Int`
- [ ] Add daily reset check
- [ ] Also increment global health score counter

**Acceptance Criteria:**
- ✅ Counter increments once per shield display
- ✅ No double-counting
- ✅ Resets at midnight
- ✅ Health score synced

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Dependencies:**
- HealthScoreService must be accessible to extension

---

### 4.5 Update ShieldConfigurationExtension - Hard Block Logic
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Check if daily limit reached
- [ ] If limit reached and `blockAfterMaxUse` is true:
  - Show hard block shield (no button)
  - Display "Daily Limit Reached" message
  - Show attempt count
- [ ] If limit reached and `blockAfterMaxUse` is false:
  - Continue normal pause timer behavior
  - Show quote as usual
- [ ] Add method: `getShieldConfiguration(group: AppGroup, token: ApplicationToken) -> ShieldConfiguration`

**Acceptance Criteria:**
- ✅ Hard block shows when enabled and limit reached
- ✅ Soft mode continues showing quotes when disabled
- ✅ Message displays current attempt count
- ✅ No button shown in hard block mode

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

---

### 4.6 Update ShieldConfigurationExtension - Quote Display
**File:** `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Tasks:**
- [ ] Keep existing QuoteScheduler integration
- [ ] Get current quote: `QuoteScheduler.shared.getCurrentQuote()`
- [ ] Display quote text, author, book in shield
- [ ] Add pause timer button below quote
- [ ] Style button based on pause state:
  - Available: "Open App" (blue)
  - Waiting: "Wait Xs..." (gray)
- [ ] Maintain existing formatting logic

**Acceptance Criteria:**
- ✅ Quotes continue rotating every 2 hours
- ✅ Quote formatting preserved
- ✅ Button styled correctly
- ✅ No IPC between Shield and main app

**Files Modified:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

---

## Phase 5: DeviceActivityMonitor Integration (Week 3, Days 1-2) ✅ COMPLETED

### 5.1 Update DeviceActivityMonitorExtension - Daily Reset
**File:** `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

**Tasks:**
- [ ] Access AppGroupManager in `intervalDidEnd()`
- [ ] Iterate through all groups
- [ ] Reset daily counters for each group
  - Clear `"usage_*"` keys for yesterday
- [ ] Clear pause timestamps
- [ ] Clear increment tracking keys
- [ ] Update last reset date

**Acceptance Criteria:**
- ✅ Runs at midnight (end of 24h monitoring interval)
- ✅ Resets all groups simultaneously
- ✅ No data loss
- ✅ Logging for debugging

**Files Modified:**
- `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

---

### 5.2 Update DeviceActivityMonitorExtension - Streak Calculation
**File:** `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

**Tasks:**
- [ ] Add method: `updateStreak(for group: AppGroup)`
- [ ] Check if group was used yesterday (lastUsedDate)
- [ ] If used yesterday: increment streak, update lastUsedDate to today
- [ ] If used today already: no change
- [ ] If missed days: reset streak to 0
- [ ] Save updated group to AppGroupManager
- [ ] Call for each group in `intervalDidEnd()`

**Acceptance Criteria:**
- ✅ Streak increments on consecutive days
- ✅ Streak resets when day missed
- ✅ Works across multiple groups independently
- ✅ Updates visible in UI immediately

**Files Modified:**
- `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

---

### 5.3 Update DeviceActivityMonitorExtension - Health Score Sync
**File:** `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

**Tasks:**
- [ ] Keep existing health score reconciliation
- [ ] Ensure global counter aggregates all group attempts
- [ ] Verify daily reset syncs with health score reset
- [ ] Test calibration period still works
- [ ] No changes needed if already working

**Acceptance Criteria:**
- ✅ Health score includes all app group attempts
- ✅ Calibration continues working
- ✅ Daily reset synchronized
- ✅ No regression in existing functionality

**Files Modified:**
- `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift` (verify only)

---

## Phase 6: ScreenTimeService Integration (Week 3, Days 3-4) ✅ COMPLETED

### 6.1 Update ScreenTimeService - Shield Application
**File:** `PageInstead/Core/Services/ScreenTimeService.swift`

**Tasks:**
- [ ] Add method: `applyShields(for groups: [AppGroup])`
- [ ] Collect all applicationTokens from all groups
- [ ] Collect all webDomainTokens from all groups
- [ ] Apply shields to ManagedSettingsStore
  - `store.shield.applications = allAppTokens`
  - `store.shield.webDomains = allDomainTokens`
- [ ] Remove old `applyShield(to:)` method
- [ ] Call new method whenever groups change

**Acceptance Criteria:**
- ✅ All apps from all groups are shielded
- ✅ Removing group removes shields for those apps
- ✅ No duplicate shields
- ✅ Changes apply immediately

**Files Modified:**
- `PageInstead/Core/Services/ScreenTimeService.swift`

---

### 6.2 Update ScreenTimeService - Observer Pattern
**File:** `PageInstead/Core/Services/ScreenTimeService.swift`

**Tasks:**
- [ ] Subscribe to AppGroupManager changes
- [ ] On group add/update/delete:
  - Refresh shields via `applyShields(for:)`
- [ ] Handle authorization state changes
- [ ] Remove old selectedApps property
- [ ] Update getBlockedAppsCount() to sum all groups

**Acceptance Criteria:**
- ✅ Shields update automatically on group changes
- ✅ No manual refresh needed
- ✅ Authorization flow unchanged
- ✅ App count accurate

**Files Modified:**
- `PageInstead/Core/Services/ScreenTimeService.swift`

---

### 6.3 Update ScreenTimeService - DeviceActivityMonitor Setup
**File:** `PageInstead/Core/Services/ScreenTimeService.swift`

**Tasks:**
- [ ] Keep existing monitoring setup
- [ ] Ensure 24-hour interval covers midnight
- [ ] Verify intervalDidEnd triggers daily
- [ ] No changes if already correct
- [ ] Test on device

**Acceptance Criteria:**
- ✅ Daily reconciliation runs at midnight
- ✅ Monitoring active continuously
- ✅ No performance impact
- ✅ Works in background

**Files Modified:**
- `PageInstead/Core/Services/ScreenTimeService.swift` (verify only)

---

## Phase 7: Testing & Polish (Week 3-4)

### 7.1 Unit Tests
**Files:** Multiple test files

**Tasks:**
- [ ] AppGroup model tests (encoding, computed properties)
- [ ] AppGroupManager tests (CRUD, validation, conflict detection)
- [ ] Schedule validation tests (overnight ranges, edge cases)
- [ ] Streak calculation tests
- [ ] Migration tests
- [ ] Shield logic tests (pause timer, daily counter, hard block)

**Target Coverage:** 80%+ for new code

**Files Created:**
- `PageInsteadTests/Models/AppGroupTests.swift`
- `PageInsteadTests/Services/AppGroupManagerTests.swift`
- `PageInsteadTests/Services/ScheduleValidationTests.swift`

---

### 7.2 Integration Tests
**Files:** Test files + physical device

**Tasks:**
- [ ] FamilyActivityPicker selection → storage
- [ ] Shield Extension lookups (app → group)
- [ ] DeviceActivityMonitor daily reconciliation
- [ ] Migration from old blocking system
- [ ] Health score synchronization
- [ ] Test on physical device (Shield doesn't work in simulator)

**Test Devices:**
- iPhone with iOS 16+
- Real apps installed (Instagram, Twitter, etc.)

---

### 7.3 Manual Testing Checklist
**Ref:** Specification Section 15

**Tasks:**
- [ ] Create group → select apps → save → appears on main screen
- [ ] Edit group → change rules → save → updates reflected
- [ ] Delete group → apps become unblocked
- [ ] Pause timer: open app, wait, reopen, button appears
- [ ] Daily limit: open 20 times, 21st shows hard block
- [ ] Schedule: set to weekdays only, verify works Monday, not Saturday
- [ ] Overnight schedule: set 22:00-06:00, test at 23:00 and 05:00
- [ ] Conflict detection: try adding same app to two groups
- [ ] Streak: block app 3 days in a row, verify streak = 3
- [ ] Migration: existing blocked apps appear in "Group #1"

**Test Scenarios:**
- Multiple groups with different rules
- Overlapping schedules (different groups)
- Edge cases (empty group, 0s pause, unlimited opens)

---

### 7.4 UI Polish
**Files:** All view files

**Tasks:**
- [ ] Verify all Liquid Glass styling consistent
- [ ] Check dark mode compatibility
- [ ] Test on different iPhone sizes (SE, Pro, Pro Max)
- [ ] Verify accessibility (VoiceOver labels, dynamic type)
- [ ] Add loading states where needed
- [ ] Add error states with retry
- [ ] Smooth animations (sheet presentations, toggles)
- [ ] Haptic feedback on important actions

**Acceptance Criteria:**
- ✅ Matches HTML mockups visually
- ✅ Smooth 60fps animations
- ✅ Accessible to all users
- ✅ Works on all supported devices

---

### 7.5 Performance Optimization
**Files:** All service files

**Tasks:**
- [ ] Profile group lookup performance
- [ ] Optimize Shield Extension render time
- [ ] Check UserDefaults read/write frequency
- [ ] Minimize JSON encoding overhead
- [ ] Add caching where appropriate
- [ ] Test with 10+ groups, 100+ apps

**Performance Targets:**
- Shield render: < 50ms
- Group lookup: < 10ms
- Save operation: < 100ms
- UI updates: < 16ms (60fps)

---

## Phase 8: Documentation & Release (Week 4)

### 8.1 Update CLAUDE.md
**File:** `CLAUDE.md`

**Tasks:**
- [ ] Add App Groups file locations
- [ ] Document critical implementation rules
- [ ] Add common issues and solutions
- [ ] Update build/test instructions
- [ ] Add troubleshooting section

**Files Modified:**
- `CLAUDE.md`

---

### 8.2 Update README.md
**File:** `README.md`

**Tasks:**
- [ ] Add App Groups to feature list
- [ ] Update screenshots (optional)
- [ ] Document new settings
- [ ] Update version number

**Files Modified:**
- `README.md`

---

### 8.3 Create Release Notes
**File:** `RELEASE_NOTES_APP_GROUPS.md` (new)

**Tasks:**
- [ ] Document all new features
- [ ] Migration instructions for existing users
- [ ] Known limitations
- [ ] Future enhancements roadmap

**Files Created:**
- `RELEASE_NOTES_APP_GROUPS.md`

---

### 8.4 Mark Specification as Implemented
**File:** `App_Groups_Specification.md`

**Tasks:**
- [ ] Check all testing checklist items
- [ ] Update status to "IMPLEMENTED"
- [ ] Add implementation completion date
- [ ] Archive specification

**Files Modified:**
- `App_Groups_Specification.md`

---

## File Structure

### New Files Created (20+)
```
PageInstead/
├── Core/
│   ├── Models/
│   │   └── AppGroup.swift (NEW)
│   └── Services/
│       └── AppGroupManager.swift (NEW)
├── Features/
│   └── AppGroups/ (NEW)
│       ├── AppGroupsListView.swift
│       ├── AppGroupRulesView.swift
│       └── Components/
│           ├── AppGroupCard.swift
│           ├── AppGroupsEmptyState.swift
│           ├── DayPillSelector.swift (optional)
│           └── NumberPicker.swift (optional)
PageInsteadTests/
├── Models/
│   └── AppGroupTests.swift (NEW)
└── Services/
    ├── AppGroupManagerTests.swift (NEW)
    └── ScheduleValidationTests.swift (NEW)
```

### Modified Files (5)
```
PageInstead/
├── App/
│   ├── PageInsteadApp.swift (migration call)
│   └── ContentView.swift (navigation update)
└── Core/
    └── Services/
        └── ScreenTimeService.swift (shield integration)
ShieldConfiguration/
└── ShieldConfigurationExtension.swift (all shield logic)
DeviceActivityMonitor/
└── DeviceActivityMonitorExtension.swift (daily reset, streaks)
```

---

## Dependencies

### Critical Path
```
Phase 1 (Models)
    ↓
Phase 2 (Rules UI) + Phase 4 (Shield Extension)
    ↓
Phase 3 (Main Screen UI)
    ↓
Phase 5 (DeviceActivityMonitor) + Phase 6 (ScreenTimeService)
    ↓
Phase 7 (Testing)
    ↓
Phase 8 (Release)
```

### External Dependencies
- iOS 16.0+ (FamilyControls framework)
- Xcode 15.0+
- Physical iOS device for Shield testing
- Active Apple Developer account

---

## Risk Mitigation

### High Risk Items
1. **Shield Extension caching** - iOS may cache shields for hours
   - Mitigation: Document limitation, add timestamp-based logic
2. **FamilyActivitySelection serialization** - Not directly Codable
   - Mitigation: Store tokens separately, convert on access
3. **Migration data loss** - Converting from old system
   - Mitigation: Keep old data, rollback on error

### Testing Gaps
- Simulator cannot test Shield Extension fully
- Need physical device for end-to-end testing
- Timezone edge cases require manual testing

---

## Success Metrics

### Functional
- [ ] All 15 testing checklist items pass
- [ ] Zero crashes in Shield Extension
- [ ] Migration success rate: 100%
- [ ] Conflict detection: 0 false positives

### Performance
- [ ] Shield render: < 50ms average
- [ ] App launch time increase: < 100ms
- [ ] UI interactions: 60fps maintained
- [ ] Battery impact: < 2% increase

### User Experience
- [ ] Matches HTML mockups visually
- [ ] All interactions feel native
- [ ] No scrolling on empty state
- [ ] Buttons always tappable (glass UI)

---

## Rollback Plan

If critical issues found in production:

1. **Phase 1 rollback:** Revert to old AppSelectionView
2. **Phase 2 rollback:** Disable Rules screen, use defaults
3. **Phase 3 rollback:** Hide App Groups tab
4. **Full rollback:** Restore pre-AppGroups commit

**Rollback triggers:**
- Shield Extension crashes > 5%
- Data corruption in migration > 1%
- Performance regression > 20%
- Critical bug affecting core functionality

---

## Post-MVP Enhancements

From Specification Section 14:

**Low Complexity (Next Sprint):**
- Quick Setup Templates
- Icon/Color Customization
- Export Data

**Medium Complexity (Future):**
- Empty State Onboarding
- Category-Based Rules
- Quote Personalization
- Weekly Goals

**High Complexity (Backlog):**
- Per-App Different Rules
- Total Time Tracking (API workaround)

---

## Notes

- This task list is living document - update as implementation progresses
- Check off tasks as completed
- Add notes about blockers or decisions
- Reference specification for detailed behavior
- Consult HTML mockups for visual design

**Last Updated:** October 31, 2025
**Status:** Ready for Implementation
**Owner:** Development Team
