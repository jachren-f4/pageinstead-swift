# App Groups Troubleshooting Update - After Expert Advice

**Date:** 31 Oct 2025
**Follow-up to:** APP_GROUPS_SANDBOX_ERROR.md and paid_account.md
**Status:** Issue persists despite following all expert recommendations

---

## Expert Recommendations Followed

We followed all steps from the expert's **paid_account.md** document:

### ✅ 1. Confirmed Targets Use Paid Team

**Verification performed:**
```bash
# Checked team ID in all targets
PageInstead: Team ID: NA6936A56Q
ShieldAction: Team ID: NA6936A56Q
ShieldConfiguration: Team ID: NA6936A56Q
DeviceActivityMonitor: Team ID: NA6936A56Q

# Verified embedded provisioning profile
security cms -D -i "ShieldAction.appex/embedded.mobileprovision"
Result:
  <key>TeamIdentifier</key>
  <string>NA6936A56Q</string>
  <key>TeamName</key>
  <string>Joakim Achren</string>
```

**Conclusion:** ✅ All targets correctly using paid team (not Personal Team)

---

### ✅ 2. Refreshed Provisioning Profiles

**Actions taken:**
1. Deleted all cached provisioning profiles:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/PageInstead-*
   ```

2. Performed clean build:
   ```bash
   xcodebuild clean -project PageInstead.xcodeproj -scheme PageInstead
   ```

3. Built with `-allowProvisioningUpdates` to force fresh profile download:
   ```bash
   xcodebuild -allowProvisioningUpdates build
   ```

**Result:** ✅ Fresh provisioning profiles downloaded and embedded

---

### ✅ 3. Ensured All Targets Use Same App Group ID

**Verification:**
```bash
# Checked entitlements files
PageInstead.entitlements:        <string>group.com.pageinstead</string>
ShieldAction.entitlements:       <string>group.com.pageinstead</string>
ShieldConfiguration.entitlements: <string>group.com.pageinstead</string>
DeviceActivityMonitor.entitlements: <string>group.com.pageinstead</string>

# Checked Swift code
./ShieldConfiguration/QuoteData.swift:    private let suiteName = "group.com.pageinstead"
./ShieldConfiguration/ShieldConfigurationExtension.swift:    private let appGroupID = "group.com.pageinstead"
./ShieldAction/ShieldActionExtension.swift:    private let appGroupID = "group.com.pageinstead"
./PageInstead/Core/Services/ScreenTimeService.swift: "group.com.pageinstead"
./PageInstead/Core/Services/AppGroupManager.swift: "group.com.pageinstead"
./PageInstead/Core/Services/HealthScoreService.swift: "group.com.pageinstead"
```

**Conclusion:** ✅ Consistent App Group ID across all targets and code

---

### ✅ 4. Added Test Code to Main App

**Code added to PageInsteadApp.swift init():**
```swift
// Test App Groups access (from expert's paid_account.md)
print("🧪 TESTING APP GROUPS ACCESS FROM MAIN APP...")
if let defaults = UserDefaults(suiteName: "group.com.pageinstead") {
    defaults.set(Date(), forKey: "test_write_from_main_app")
    defaults.synchronize()
    print("✅ MAIN APP: Successfully wrote to App Group!")

    if let value = defaults.object(forKey: "test_write_from_main_app") {
        print("✅ MAIN APP: Successfully read from App Group: \(value)")
    }
} else {
    print("❌ MAIN APP: Failed to access App Groups - UserDefaults(suiteName:) returned nil!")
    print("❌ This means the App Group container was not created!")
}
```

**Result:** ❓ Could not verify logs via Console.app or `log stream` commands
**Note:** `print()` statements from iOS apps do not appear in macOS Console.app or `log show` output

---

### ✅ 5. Reinstalled and Rebooted Device

**Steps performed:**
1. Deleted PageInstead app from iPhone
2. Powered off iPhone completely (30+ seconds)
3. Powered back on
4. Clean rebuilt app with fresh provisioning:
   ```bash
   xcodebuild clean
   xcodebuild -allowProvisioningUpdates build
   ```
5. Reinstalled app:
   ```bash
   xcrun devicectl device install app --device [ID] PageInstead.app
   ```

**Result:** ❌ Issue persists after complete device restart and reinstall

---

## Current Error Status

**Error still occurring:**
```
fault    16:26:31.062629+0200    ShieldConfiguration    Couldn't write values for keys (
    "usage_CEB54AA5-D3AC-4C96-B0CD-8A5C91078356_ApplicationToken(data: 128 bytes)_2025-10-31"
) in CFPrefsPlistSource<0x1058d1080>
(Domain: group.com.pageinstead, User: kCFPreferencesCurrentUser, ByHost: No, Container: (null), Contents Need Refresh: No):
setting preferences outside an application's container requires user-preference-write or file-write-data sandbox access
```

**Critical observation:** `Container: (null)` - iOS cannot find or create the App Group container

---

## Additional Verification Performed

### Code Signing Verification
```bash
codesign -d --entitlements - "ShieldAction.appex"
Result:
  [Key] com.apple.security.application-groups
  [Value]
      [Array]
          [String] group.com.pageinstead
```
✅ Extensions are signed with correct App Groups entitlement

### Provisioning Profile Verification
```bash
security cms -D -i "ShieldAction.appex/embedded.mobileprovision"
Result:
  <key>com.apple.security.application-groups</key>
  <array>
      <string>group.com.pageinstead</string>
  </array>
```
✅ Provisioning profiles include App Groups entitlement

### Apple Developer Portal Verification

**App Group Status:**
- ✅ `group.com.pageinstead` exists in portal
- ✅ All four App IDs have App Groups capability enabled:
  - `com.joakimachren.PageInstead` ✅
  - `com.joakimachren.PageInstead.ShieldAction` ✅
  - `com.joakimachren.PageInstead.ShieldConfiguration` ✅
  - `com.joakimachren.PageInstead.DeviceActivityMonitor` ✅

---

## Attempted Diagnostics

### Console.app Log Monitoring

**Attempts:**
1. Used Console.app with filter: "TESTING APP GROUPS"
2. Used Console.app with filter: "Couldn't write"
3. Used command line: `log stream --predicate 'process == "PageInstead"'`
4. Used command line: `log show --last 2m`

**Result:**
- ❌ `print()` statements from app init do not appear in logs
- ✅ Sandbox errors DO appear in logs (confirming the issue persists)

### Test Results

**ShieldConfiguration Extension:**
- ❌ Cannot write to `group.com.pageinstead` UserDefaults
- ❌ Gets "Container: (null)" error
- Error occurs when trying to increment health score counter

**ShieldAction Extension:**
- ❌ Cannot write unlock request flags
- ❌ Same sandbox permission error expected (not yet fully tested due to ShieldConfiguration errors)

**Main App:**
- ❓ Cannot verify if it can access App Groups (logs not captured)
- According to expert's document: "If main app cannot write, extensions never will"

---

## Environment Details

**Development Setup:**
- **Xcode:** Latest version with automatic signing
- **Apple Developer Account:** Paid ($99/year) - Team ID: NA6936A56Q
- **Device:** iPhone 14, iOS 18.6 (physical device)
- **Signing:** All targets use paid team (not Personal Team)
- **Provisioning:** Xcode Managed Profiles with `-allowProvisioningUpdates`

**Extension Types:**
- ShieldConfiguration Extension (Custom shield UI)
- ShieldAction Extension (Button tap handling)
- DeviceActivityMonitor Extension (Daily resets)

---

## Configuration Summary

| Component | Status | Details |
|-----------|--------|---------|
| Entitlements files | ✅ Correct | All have `com.apple.security.application-groups` with `group.com.pageinstead` |
| Xcode Capabilities | ✅ Enabled | All targets show App Groups capability in GUI |
| Developer Portal | ✅ Configured | App Group exists and linked to all App IDs |
| Provisioning Profiles | ✅ Updated | Fresh profiles with App Groups entitlement |
| Code Signing | ✅ Valid | Extensions signed with correct entitlements |
| Team Configuration | ✅ Paid Team | NA6936A56Q (not Personal Team) |
| App Group ID | ✅ Consistent | `group.com.pageinstead` everywhere |
| Device Reset | ✅ Performed | Complete power cycle + app reinstall |

**Yet the error persists:** `Container: (null)`

---

## Questions for Expert

Given that ALL configuration appears correct and we've followed ALL recommendations:

1. **Why does iOS report "Container: (null)"?**
   - What could prevent iOS from creating the App Group container directory?
   - Is there a device-level issue that requires more than a restart?
   - Could there be a conflict with an old container from a previous app?

2. **Is there a way to manually verify/initialize the container?**
   - Can we check if the container directory exists on the device?
   - Can we force container creation from the main app?
   - Are there diagnostic commands to inspect container status?

3. **Could this be specific to the App Group ID format?**
   - Should we try a different App Group ID (e.g., `group.com.joakimachren.pageinstead`)?
   - Could there be a conflict with the existing `group.com.pageinstead`?

4. **Are there iOS 18.6 specific issues with App Groups?**
   - Should we test on an older iOS version?
   - Are there known bugs in iOS 18 related to App Groups?

5. **Could Shield extensions have additional restrictions?**
   - Do ShieldConfiguration/ShieldAction extensions have stricter sandboxing?
   - Are there specific entitlements required for these extension types?

6. **Alternative approaches?**
   - Is there a different IPC mechanism we should use?
   - Can we use file-based communication within App Groups?
   - Should we use Darwin notifications or XPC?

---

## Next Steps Considered

**Option A: Try different App Group ID**
- Create new App Group: `group.com.joakimachren.pageinstead`
- Update all entitlements, code, and portal configuration
- See if the issue is specific to the current App Group

**Option B: More aggressive device reset**
- Factory reset the iPhone (last resort)
- Test on a different iPhone

**Option C: Alternative communication method**
- Explore file-based communication within App Groups
- Use Darwin notifications (if Shield extensions support them)

**Option D: Verify with minimal test app**
- Create a minimal app with just App Groups + extensions
- Rule out conflicts with existing code

---

## Files Modified Since Last Expert Consultation

1. `PageInstead/App/PageInsteadApp.swift` - Added App Groups test code
2. All provisioning profiles regenerated
3. No other code changes

---

**Request:** Please advise on why "Container: (null)" persists despite complete configuration. Is there a deeper iOS or device-level issue we need to address?

**Urgency:** High - This is blocking the core unlock functionality of the app.
