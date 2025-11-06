# App Groups Sandbox Error - Expert Consultation Needed

**Date:** 31 Oct 2025
**Project:** PageInstead Swift iOS App
**Issue:** Shield extensions cannot write to App Groups despite complete configuration

---

## Problem Statement

ShieldAction and ShieldConfiguration extensions are getting sandbox permission errors when attempting to write to App Groups UserDefaults:

```
Couldn't write values for keys (...) in CFPrefsPlistSource<0x...>
(Domain: group.com.pageinstead, User: kCFPreferencesCurrentUser, ByHost: No, Container: (null), Contents Need Refresh: No):
setting preferences outside an application's container requires user-preference-write or file-write-data sandbox access
```

**Critical detail:** `Container: (null)` suggests iOS cannot find the App Group container.

---

## What We Need to Work

**Goal:** ShieldAction extension needs to write unlock request flags to App Groups that the main app can read:

```swift
// In ShieldAction extension:
let defaults = UserDefaults(suiteName: "group.com.pageinstead")
defaults.set(true, forKey: "unlock_request_\(tokenString)")
defaults.synchronize()

// In main app:
// Poll for unlock_request_* keys and remove apps from shield
```

---

## Complete Verification Checklist

### ✅ 1. Entitlements Files

**ShieldAction/ShieldAction.entitlements:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.pageinstead</string>
	</array>
</dict>
</plist>
```

**Verified:** ✅ ShieldConfiguration.entitlements, DeviceActivityMonitor.entitlements, and PageInstead.entitlements all have identical App Groups configuration.

### ✅ 2. Xcode Signing & Capabilities

**All four targets checked in Xcode GUI:**
- PageInstead (main app)
- ShieldAction
- ShieldConfiguration
- DeviceActivityMonitor

**Each shows:**
- App Groups capability section present
- `group.com.pageinstead` checkbox: ✅ checked
- Status: "Enabled App Groups (1)"

### ✅ 3. Apple Developer Portal Configuration

**App Groups:**
- Created: `group.com.pageinstead`
- Status: Active

**App IDs with App Groups enabled:**
- ✅ `com.joakimachren.PageInstead` - App Groups enabled, `group.com.pageinstead` selected
- ✅ `com.joakimachren.PageInstead.ShieldAction` - App Groups enabled, `group.com.pageinstead` selected
- ✅ `com.joakimachren.PageInstead.ShieldConfiguration` - App Groups enabled, `group.com.pageinstead` selected
- ✅ `com.joakimachren.PageInstead.DeviceActivityMonitor` - App Groups enabled, `group.com.pageinstead` selected

### ✅ 4. Provisioning Profiles

**Embedded profile verification:**
```bash
security cms -D -i "ShieldAction.appex/embedded.mobileprovision"
```

**Result:**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.pageinstead</string>
</array>
```

**Verified:** ✅ All three extensions have provisioning profiles with App Groups entitlement.

### ✅ 5. Code Signing Verification

```bash
codesign -d --entitlements - "ShieldAction.appex"
```

**Result:**
```
[Key] com.apple.security.application-groups
[Value]
    [Array]
        [String] group.com.pageinstead
```

**Verified:** ✅ Extensions are actually signed with App Groups entitlement.

### ✅ 6. Build Settings

**Checked:** No `PRODUCT_BUNDLE_PACKAGE_TYPE` set (correct for extensions)

**Frameworks linked:**
- DeviceActivity.framework
- FamilyControls.framework
- ManagedSettings.framework
- ManagedSettingsUI.framework

### ✅ 7. Device Reset

**Performed:**
1. Deleted PageInstead app from device
2. Powered off iPhone completely
3. Powered back on
4. Reinstalled app with `-allowProvisioningUpdates`

**Reason:** Clear iOS App Group container cache.

**Result:** ❌ Error persists after restart.

---

## Code Implementation

**ShieldActionExtension.swift:**
```swift
private func unlockApplication(_ token: ApplicationToken) {
    print("🔓🔓🔓 unlockApplication() ENTERED")

    let defaults = getUserDefaults()
    let tokenString = String(describing: token)
    let unlockKey = "unlock_request_\(tokenString)"

    // Write unlock request flag that main app will detect
    defaults.set(true, forKey: unlockKey)
    let success = defaults.synchronize()

    print("🔓 defaults.synchronize() result: \(success)")

    // Verify it was written
    if let value = defaults.object(forKey: unlockKey) {
        print("✅✅✅ VERIFIED: unlock_request flag written successfully")
    } else {
        print("❌❌❌ ERROR: unlock_request flag NOT found after write!")
    }
}

private func getUserDefaults() -> UserDefaults {
    return UserDefaults(suiteName: "group.com.pageinstead") ?? .standard
}
```

**ScreenTimeService.swift (main app):**
```swift
private func startUnlockObserver() {
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.checkForUnlockRequests()
    }
}

private func checkForUnlockRequests() {
    guard let defaults = UserDefaults(suiteName: "group.com.pageinstead") else {
        return
    }

    let keys = defaults.dictionaryRepresentation().keys
    let unlockRequests = keys.filter { $0.hasPrefix("unlock_request_") }

    for key in unlockRequests {
        let tokenString = key.replacingOccurrences(of: "unlock_request_", with: "")
        removeAppFromShield(tokenString)
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
}
```

---

## Development Environment

- **Xcode:** Latest version
- **iOS Deployment Target:** 16.0
- **Device:** iPhone 14 (physical device, iOS 18.6)
- **Team:** Personal Development Team (NA6936A56Q)
- **Signing:** Automatic signing enabled

---

## Questions for Expert

1. **Is there a limitation with personal development teams and App Groups?**
   - Does this require a paid Apple Developer Program membership?
   - Are there additional provisioning steps needed?

2. **Why is "Container: (null)" appearing despite all configuration being correct?**
   - What triggers iOS to create the App Group container?
   - Could there be a device-level issue preventing container creation?

3. **Are Shield extensions sandboxed more strictly than other extension types?**
   - Do ShieldAction/ShieldConfiguration extensions have additional restrictions?
   - Is there an alternative communication method we should use?

4. **Could this be an iOS 18.6 specific issue?**
   - Are there known issues with App Groups in iOS 18?
   - Should we test on an older iOS version?

5. **Is there a way to manually verify/initialize the App Group container?**
   - Can we trigger container creation from the main app?
   - Are there any diagnostic tools to check container status?

---

## Alternative Approaches Considered

1. **Direct ManagedSettingsStore modification from extension**
   - ❌ Extensions don't have permission to modify store
   - Main app auto-reapplies shields due to Combine subscription

2. **NSUserDefaults without App Groups**
   - ❌ Each process has isolated UserDefaults
   - Cannot share data between extension and app

3. **File-based communication**
   - 🤔 Would require App Groups anyway for shared container
   - Same sandbox restrictions likely apply

---

## Additional Context

This is a Screen Time blocking app that uses:
- **ShieldConfiguration extension** - displays custom shield UI with quotes
- **ShieldAction extension** - handles button taps on the shield
- **DeviceActivityMonitor extension** - handles daily resets
- **Main app** - manages shields via ManagedSettingsStore

The unlock flow requires the ShieldAction extension to signal the main app when the pause timer expires so the main app can remove the app from the shield.

---

## Files for Reference

- `ShieldAction/ShieldActionExtension.swift`
- `ShieldAction/ShieldAction.entitlements`
- `PageInstead/Core/Services/ScreenTimeService.swift`
- `PageInstead/App/PageInsteadApp.swift`
- `PageInstead.xcodeproj/project.pbxproj`

---

**Request:** Please advise on next steps to resolve the App Groups sandbox error. We've exhausted all standard configuration steps and the error persists.
