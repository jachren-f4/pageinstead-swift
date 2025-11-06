# Shield Unlock Issue - Technical Documentation

## Problem Statement

**Issue**: The ShieldAction extension's "Open" button does not unlock blocked apps after the pause timer expires.

**Expected Behavior**:
1. User taps blocked app → Shield appears with quote
2. Button shows "Open (in 10s)" (grayed out)
3. After 10 seconds elapse → Button shows "Open" (active blue)
4. User taps "Open" → App unlocks and opens

**Current Behavior**:
1. Steps 1-3 work correctly (timer updates when tapping before expiry via `.defer`)
2. Step 4: Tapping "Open" after timer expires dismisses the shield but returns to home screen
3. The blocked app never actually opens

## Architecture Overview

### Extension Structure

PageInstead uses 3 iOS extensions:

1. **ShieldConfiguration Extension** (`ShieldConfiguration/`)
   - Extension Point: `com.apple.ManagedSettingsUI.shield-configuration-service`
   - Purpose: Displays custom UI (quote, buttons, timer text)
   - Entitlements: `app-groups` ONLY
   - **Limitation**: Cannot modify ManagedSettings, only provides UI

2. **ShieldAction Extension** (`ShieldAction/`)
   - Extension Point: `com.apple.ManagedSettings.shield-action-service`
   - Purpose: Handles button tap events from shield
   - Entitlements: `app-groups`, `family-controls`
   - **Expected**: Can modify ManagedSettingsStore to unlock apps

3. **DeviceActivityMonitor Extension** (`DeviceActivityMonitor/`)
   - Extension Point: `com.apple.DeviceActivity.monitor-extension`
   - Purpose: Daily resets, streak tracking, health score
   - Entitlements: `app-groups`, `family-controls`

### Data Flow

```
User taps blocked app
    ↓
iOS shows shield (calls ShieldConfigurationExtension)
    ↓
User taps "Open" button
    ↓
iOS calls ShieldActionExtension.handle(action:for:completionHandler:)
    ↓
ShieldAction checks timer, attempts unlock
    ↓
Completion handler called: .close, .defer, or .none
    ↓
Shield dismisses → [PROBLEM: App doesn't open]
```

## Implementation Details

### File Locations

**Main App:**
- Screen Time service: `PageInstead/Core/Services/ScreenTimeService.swift`
- App Groups manager: `PageInstead/Core/Services/AppGroupManager.swift`
- App entry point: `PageInstead/App/ContentView.swift`

**ShieldAction Extension:**
- Handler: `ShieldAction/ShieldActionExtension.swift` (CREATED)
- App Group model: `ShieldAction/AppGroup.swift`
- Info.plist: `ShieldAction/Info.plist`
- Entitlements: `ShieldAction/ShieldAction.entitlements`

### Pause Timer Implementation

**ShieldConfigurationExtension.swift** (Lines 224-249):
```swift
private func checkPauseTimer(group: AppGroup, token: String) -> (shouldShow: Bool, remaining: Int) {
    let pauseKey = "pause_\(group.id.uuidString)_\(token)"
    let defaults = getUserDefaults()

    let pauseStart = defaults.object(forKey: pauseKey) as? Date

    if pauseStart == nil {
        // First time showing shield - record timestamp
        defaults.set(Date(), forKey: pauseKey)
        defaults.synchronize()
        return (false, group.pauseForSeconds)
    }

    let elapsed = Date().timeIntervalSince(pauseStart ?? Date())
    let remaining = max(0, group.pauseForSeconds - Int(elapsed))
    let showButton = elapsed >= Double(group.pauseForSeconds)

    return (showButton, remaining)
}
```

**Key Data:**
- Timer start stored in App Groups: `pause_{groupID}_{token}`
- Button enabled when: `elapsed >= pauseForSeconds`

### Button Tap Handler

**ShieldActionExtension.swift** (Lines 12-44):
```swift
override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    print("🎯 ShieldAction: Button tapped for app")

    switch action {
    case .primaryButtonPressed:
        handlePrimaryButton(for: application, completionHandler: completionHandler)

    case .secondaryButtonPressed:
        // Close button - just dismiss shield
        print("🎯 ShieldAction: Close button pressed")
        completionHandler(.close)

    @unknown default:
        completionHandler(.defer)
    }
}
```

**Primary Button Handler** (Lines 49-96):
```swift
private func handlePrimaryButton(for token: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {

    // Look up which group this app belongs to
    guard let group = lookupGroup(for: token) else {
        print("⚠️ ShieldAction: App not in any group, dismissing")
        completionHandler(.close)
        return
    }

    // Check if pause timer has elapsed
    let pauseKey = "pause_\(group.id.uuidString)_\(token)"
    let defaults = getUserDefaults()

    guard let pauseStart = defaults.object(forKey: pauseKey) as? Date else {
        print("⚠️ ShieldAction: No pause timer found")
        completionHandler(.defer) // Redraw shield
        return
    }

    let elapsed = Date().timeIntervalSince(pauseStart)

    if elapsed < Double(group.pauseForSeconds) {
        // Timer hasn't expired yet - don't unlock
        let remaining = group.pauseForSeconds - Int(elapsed)
        print("🎯 ShieldAction: Timer not expired (\(remaining)s remaining), redrawing shield")
        completionHandler(.defer) // Redraw shield to update countdown
        return
    }

    // Timer has expired - unlock the app!
    print("🎯 ShieldAction: Timer expired, unlocking app")
    unlockApplication(token)

    // Clear the pause timer so next time starts fresh
    defaults.removeObject(forKey: pauseKey)
    defaults.synchronize()

    // Close shield and allow app to open
    completionHandler(.close)
}
```

## Attempted Solutions

### Approach 1: Direct ManagedSettings Modification (FAILED)

**Attempted Code** (ShieldActionExtension.swift):
```swift
private func unlockApplication(_ token: ApplicationToken) {
    let store = ManagedSettingsStore()

    // Remove this specific app from the shield
    var currentApps = store.shield.applications ?? Set()
    currentApps.remove(token)
    store.shield.applications = currentApps.isEmpty ? nil : currentApps
}
```

**Why It Failed:**
- Main app's ScreenTimeService has a Combine subscriber that auto-reapplies shields
- When extension removes app, main app immediately adds it back
- Race condition: extension unlocks → main app re-locks

### Approach 2: Temporary Unlock List (CURRENT - NOT WORKING)

**Implementation:**

1. **ShieldAction adds to unlock list** (ShieldActionExtension.swift Lines 129-150):
```swift
private func unlockApplication(_ token: ApplicationToken) {
    let defaults = getUserDefaults()

    // Add to temporary unlock list
    var unlockedApps = getUnlockedAppsList()
    let tokenString = String(describing: token)
    unlockedApps.insert(tokenString)

    // Save unlocked apps list
    if let encoded = try? JSONEncoder().encode(Array(unlockedApps)) {
        defaults.set(encoded, forKey: "temporarily_unlocked_apps")
    }

    // Record unlock timestamp
    defaults.set(Date(), forKey: "unlock_timestamp_\(tokenString)")
    defaults.synchronize()

    print("🎯 ShieldAction: App \(tokenString) added to temporary unlock list")
}
```

2. **ScreenTimeService excludes unlocked apps** (ScreenTimeService.swift Lines 79-101):
```swift
// Exclude temporarily unlocked apps
let unlockedApps = getTemporarilyUnlockedApps()
let filteredAppTokens = allAppTokens.filter { token in
    let tokenString = String(describing: token)
    return !unlockedApps.contains(tokenString)
}

// Apply to ManagedSettings store
store.shield.applications = filteredAppTokens.isEmpty ? nil : filteredAppTokens
```

3. **ContentView refreshes on activation** (ContentView.swift Lines 87-93):
```swift
.onChange(of: scenePhase) { newPhase in
    if newPhase == .active {
        // Refresh shields when app becomes active
        screenTimeService.refreshShields()
    }
}
```

**Why It's Not Working:**
- Unknown - likely timing issue or ManagedSettings caching
- Extension may be sandboxed differently than expected
- iOS may cache shield configurations

## Potential Issues & Questions

### 1. Extension Permissions
**Question**: Does ShieldAction extension have proper permissions to:
- Modify ManagedSettingsStore?
- Access App Groups UserDefaults?
- Trigger changes that persist after completion handler returns?

**Verification Needed:**
- Check Console.app logs for ShieldAction prints (🎯 prefix)
- Verify App Groups entitlements are correct

### 2. ManagedSettingsStore Behavior
**Question**: Can extensions modify the same ManagedSettingsStore instance as the main app?

**Apple Documentation Gaps:**
- Unclear if extensions can remove individual apps from shield
- Unclear if changes persist after extension terminates
- May require main app to be running

### 3. Completion Handler Timing
**Question**: Does `.close` response actually allow the app to open, or just dismiss the shield UI?

**Current Assumption**: `.close` should allow app to open
**Reality**: May only dismiss shield, still blocking app

### 4. Token String Comparison
**Question**: Are ApplicationToken descriptions consistent between extensions and main app?

**Concern**:
```swift
let tokenString = String(describing: token)
```
May produce different strings in different contexts.

**Test Needed**: Log actual token strings in both places

## Debugging Steps

### 1. Enable Verbose Logging

Add to **ShieldActionExtension.swift** `handlePrimaryButton`:
```swift
print("🎯 Token String: \(String(describing: token))")
print("🎯 Group ID: \(group.id.uuidString)")
print("🎯 Pause Key: \(pauseKey)")
print("🎯 Timer Start: \(pauseStart)")
print("🎯 Elapsed: \(elapsed)")
print("🎯 Calling unlockApplication...")
unlockApplication(token)
print("🎯 After unlockApplication, calling .close")
```

Add to **unlockApplication**:
```swift
print("🎯 Unlock List Before: \(unlockedApps)")
print("🎯 Adding Token: \(tokenString)")
print("🎯 Unlock List After: \(getUnlockedAppsList())")
print("🎯 Timestamp Saved: \(Date())")
```

Add to **ScreenTimeService.swift** `applyShieldsForAllGroups`:
```swift
print("🔍 All App Tokens: \(allAppTokens.map { String(describing: $0) })")
print("🔍 Unlocked Apps: \(unlockedApps)")
print("🔍 Filtered Tokens: \(filteredAppTokens.map { String(describing: $0) })")
```

### 2. Check Console Logs

On Mac:
1. Open Console.app
2. Connect iPhone via cable
3. Filter by "PageInstead" or "🎯"
4. Trigger unlock flow
5. Look for prints from ShieldAction extension

### 3. Verify App Groups Data

Add to **SettingsView.swift** for debugging:
```swift
Button("Check Unlock List") {
    if let defaults = UserDefaults(suiteName: "group.com.pageinstead"),
       let data = defaults.data(forKey: "temporarily_unlocked_apps"),
       let list = try? JSONDecoder().decode([String].self, from: data) {
        print("📋 Unlocked Apps: \(list)")
    } else {
        print("📋 No unlocked apps")
    }
}
```

### 4. Test Direct ManagedSettings Access

Add to **ShieldActionExtension.swift** for testing:
```swift
// After calling unlockApplication, test direct removal
let store = ManagedSettingsStore()
let beforeCount = store.shield.applications?.count ?? 0
store.shield.applications = nil // Remove ALL shields
let afterCount = store.shield.applications?.count ?? 0
print("🧪 Before: \(beforeCount) apps, After: \(afterCount) apps")
```

If this doesn't work, extensions cannot modify ManagedSettings.

## Alternative Approaches to Consider

### Option 1: URL Scheme Redirect
Instead of unlocking in-place, redirect to main app:

```swift
// ShieldActionExtension.swift
completionHandler(.close)

// Attempt to open main app with URL scheme
if let url = URL(string: "pageinstead://unlock/\(tokenString)") {
    // Note: Extensions may not be able to open URLs
    extensionContext?.open(url)
}
```

Main app handles unlock in AppDelegate/SceneDelegate.

### Option 2: Multiple ManagedSettings Stores
Use named stores for different purposes:

```swift
// Main app uses default store
let mainStore = ManagedSettingsStore()

// Extension uses named store for unlocks
let unlockStore = ManagedSettingsStore(named: .init("unlocks"))
unlockStore.shield.applications = unlockedTokens
```

Combine stores may allow more granular control.

### Option 3: Remove Shield, Use Application Policy
Instead of shields, use `shield.applicationCategories` with scheduled policies via DeviceActivityMonitor.

### Option 4: Accept Current Limitation
Make pause timer purely "friction delay" - user must wait, but app stays blocked. Focus on other features.

## Apple Developer Forums Research

### Known Similar Issues

**Thread 1**: "Open parent app from ShieldAction extension"
- Response: Not possible as of iOS 16-18
- ShieldAction cannot open URLs or communicate with parent app
- Completion handlers only control shield UI, not app launch

**Thread 2**: "ShieldActionDelegate methods not called"
- Common cause: Deployment target mismatch
- Fix: Ensure ShieldAction target deployment = main app deployment

**Thread 3**: "Temporarily unblock app after timer"
- Apple response: "Not currently supported"
- Recommendation: Use DeviceActivitySchedule with time windows instead
- DeviceActivityMonitor can enable/disable shields at specific times

## Recommended Next Steps

1. **Verify Extension is Running**
   - Check Console.app for ShieldAction prints
   - If no prints, extension isn't being called → check Info.plist

2. **Test Direct Store Modification**
   - Add debug code to test `store.shield.applications = nil`
   - If this doesn't work, API doesn't support it

3. **Research Alternative: DeviceActivity Schedules**
   - Instead of manual unlock, use scheduled activity
   - User taps "Open" → extension writes schedule for next 5 minutes
   - DeviceActivityMonitor enables app access during schedule

4. **Contact Apple Developer Support**
   - File TSI (Technical Support Incident) with code
   - Ask specifically: "Can ShieldActionDelegate unlock apps?"

5. **Consider Pivot**
   - If unlock isn't possible, pivot pause timer to:
     - Friction delay only (must wait to dismiss shield)
     - Notification reminder after X minutes of blocking
     - Daily "break windows" where all apps unlock

## Code References

### Files Modified
- `ShieldAction/ShieldActionExtension.swift` - NEW FILE (button handler)
- `ShieldAction/AppGroup.swift` - NEW FILE (copied model)
- `ShieldAction/Info.plist` - NEW FILE
- `ShieldAction/ShieldAction.entitlements` - NEW FILE
- `PageInstead/Core/Services/ScreenTimeService.swift` - Modified (Lines 79-129)
- `PageInstead/App/ContentView.swift` - Modified (Lines 11, 87-93)
- `ShieldConfiguration/ShieldConfigurationExtension.swift` - Modified (pause timer logic)

### Xcode Project Changes
- Added ShieldAction target via `add_shield_action_extension.rb`
- Embedded ShieldAction.appex in main app bundle
- Bundle ID: `com.joakimachren.PageInstead.ShieldAction`

### App Groups Keys Used
- `app_groups` - Main group data
- `pause_{groupID}_{token}` - Timer start timestamps
- `temporarily_unlocked_apps` - JSON array of unlocked token strings
- `unlock_timestamp_{token}` - Unlock time for re-locking

## Build & Install Commands

```bash
# Build for device
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
  -destination 'platform=iOS,id=00008110-00011D4A340A401E' \
  -allowProvisioningUpdates build

# Install
xcrun devicectl device install app --device 00008110-00011D4A340A401E \
  /Users/joakimachren/Library/Developer/Xcode/DerivedData/PageInstead-*/Build/Products/Debug-iphoneos/PageInstead.app
```

## Questions for Swift Expert

1. **Can ShieldActionDelegate modify ManagedSettingsStore effectively?**
   - Is this the right approach for unlocking apps?
   - Or is this API purely for UI responses (close/defer)?

2. **What does ShieldActionResponse.close actually do?**
   - Does it allow the app to launch?
   - Or just dismiss the shield UI and return to home?

3. **How should temporary unlocks be implemented?**
   - Should we use DeviceActivitySchedule instead?
   - Is there a way to communicate unlock intent to main app?

4. **Why might the current approach not work?**
   - Extension sandboxing issues?
   - Timing/threading issues?
   - ManagedSettings caching?

5. **Is there example code from Apple showing app unlocking?**
   - WWDC sessions about Screen Time API?
   - Sample projects demonstrating ShieldAction?

---

**Document Version**: 1.0
**Date**: 2025-10-31
**iOS Version Tested**: 26.0.1 (iPhone 14)
**Xcode Version**: Latest (as of Oct 2025)
