# App Groups Implementation Checklist

Quick reference for implementing App Groups feature. See `APP_GROUPS_IMPLEMENTATION_TASKS.md` for detailed instructions.

---

## Phase 1: Data Layer ✅ (2 days)

- [ ] Create `AppGroup.swift` model (Identifiable, Codable)
- [ ] Create `AppGroupSchedule.swift` model
- [ ] Create `AppGroupManager.swift` service (CRUD + validation)
- [ ] Implement conflict detection (one app, one group)
- [ ] Implement migration from old system
- [ ] Write unit tests for models and manager

**Key Files:**
- `PageInstead/Core/Models/AppGroup.swift`
- `PageInstead/Core/Services/AppGroupManager.swift`

---

## Phase 2: Rules Screen UI ✅ (3 days)

- [ ] Create `AppGroupRulesView.swift`
- [ ] Header with back button + "Group Rules" title
- [ ] Section 1: Group name with pencil icon → alert dialog
- [ ] Section 2: App selection → FamilyActivityPicker
- [ ] Section 3: Pause duration → system list picker
- [ ] Section 4: Daily limit toggle + number picker + hard block toggle
- [ ] Section 5: Schedule toggle + time pickers + day pills
- [ ] Section 6: Save button (blue) + Delete button (red)
- [ ] Validation and conflict alerts

**Key Files:**
- `PageInstead/Features/AppGroups/AppGroupRulesView.swift`

---

## Phase 3: Main Screen UI ✅ (2 days)

- [ ] Create `AppGroupsListView.swift`
- [ ] Create `AppGroupCard.swift` component (no icon, just name)
- [ ] Create `AppGroupsEmptyState.swift` (simplified design)
- [ ] Update `ContentView.swift` to use new views
- [ ] Test navigation flow

**Key Files:**
- `PageInstead/Features/AppGroups/AppGroupsListView.swift`
- `PageInstead/Features/AppGroups/Components/AppGroupCard.swift`
- `PageInstead/Features/AppGroups/Components/AppGroupsEmptyState.swift`

---

## Phase 4: Shield Extension ✅ (3 days)

- [ ] Implement `lookupGroup(for token:)` method
- [ ] Implement `isGroupActive(_:)` schedule checking
- [ ] Implement pause timer (timestamp-based)
- [ ] Implement daily counter increment
- [ ] Implement hard block logic
- [ ] Keep existing quote display
- [ ] Test on physical device

**Key Files:**
- `ShieldConfiguration/ShieldConfigurationExtension.swift`

**Critical:**
- Must test on real device (Shield doesn't work in simulator)
- Use timestamps, not timers (Shield is stateless)

---

## Phase 5: DeviceActivityMonitor ✅ (2 days)

- [ ] Implement daily reset in `intervalDidEnd()`
- [ ] Implement streak calculation
- [ ] Verify health score synchronization
- [ ] Test midnight rollover

**Key Files:**
- `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

---

## Phase 6: ScreenTimeService ✅ (2 days)

- [ ] Update `applyShields(for groups:)` method
- [ ] Subscribe to AppGroupManager changes
- [ ] Remove old `selectedApps` property
- [ ] Update `getBlockedAppsCount()`
- [ ] Test shield application

**Key Files:**
- `PageInstead/Core/Services/ScreenTimeService.swift`

---

## Phase 7: Testing & Polish ✅ (3-5 days)

### Unit Tests (80%+ coverage)
- [ ] AppGroup model encoding/decoding
- [ ] AppGroupManager CRUD operations
- [ ] Conflict detection algorithm
- [ ] Schedule validation (overnight ranges)
- [ ] Streak calculation logic
- [ ] Migration from old system

### Manual Testing (All 15 items)
- [ ] Create/edit/delete groups
- [ ] Pause timer functionality
- [ ] Daily limit enforcement
- [ ] Schedule enforcement (weekdays, overnight)
- [ ] Conflict detection
- [ ] Streak tracking
- [ ] Migration verification

### UI Polish
- [ ] Liquid Glass styling consistent
- [ ] Dark mode compatible
- [ ] All iPhone sizes (SE, Pro, Pro Max)
- [ ] Accessibility (VoiceOver, Dynamic Type)
- [ ] Smooth animations (60fps)
- [ ] Haptic feedback

---

## Phase 8: Documentation ✅ (1 day)

- [ ] Update `CLAUDE.md` with App Groups details
- [ ] Update `README.md` with new features
- [ ] Create release notes
- [ ] Mark specification as implemented
- [ ] Archive task list

---

## Quick Start Commands

### View Mockups
```bash
open mockups/index.html
```

### Run Tests
```bash
xcodebuild test -scheme PageInstead -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build & Install to Device
```bash
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
  -destination 'platform=iOS,id=YOUR_DEVICE_ID' \
  -allowProvisioningUpdates build

xcrun devicectl device install app --device YOUR_DEVICE_ID \
  ~/Library/Developer/Xcode/DerivedData/PageInstead-*/Build/Products/Debug-iphoneos/PageInstead.app
```

---

## Critical Rules

1. **NO icons** next to group names (cleaner design)
2. **System dialogs** for name editing (native iOS pattern)
3. **Timestamp-based** pause timer (Shield is stateless)
4. **One app, one group** (enforce via conflict detection)
5. **Test on physical device** (Shield Extension doesn't work in simulator)

---

## Progress Tracking

**Total Tasks:** 14 major phases
**Completed:** ☐ 0/14
**In Progress:** ☐ None
**Blocked:** ☐ None

**Estimated Timeline:** 3-4 weeks
**Started:** ___________
**Target Completion:** ___________

---

## Blockers & Notes

_(Add notes here as you work)_

---

**Last Updated:** October 31, 2025
**Status:** Ready to Start
