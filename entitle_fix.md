# 🧩 PageInstead – App Group Entitlements Fix

**Date:** 31 Oct 2025  
**Author:** Joakim Achrén  
**Topic:** Fixing App Group write permission errors in ShieldAction, ShieldConfiguration, and DeviceActivityMonitor extensions

---

## ⚠️ Problem Summary

**Error:**
```
Couldn't write values for keys (...) in CFPrefsPlistSource<...>: 
setting preferences outside an application's container requires user-preference-write or file-write-data sandbox access
```

This indicates that the extension process (ShieldAction, ShieldConfiguration, or DeviceActivityMonitor) attempted to write to:
```swift
UserDefaults(suiteName: "group.com.pageinstead")
```
…but does not have proper App Group entitlements or provisioning permissions.

---

## 🧠 Why It Happens

iOS extensions are sandboxed.  
They can only read or write data to the App Group container if:

1. The App Group is declared in the extension’s `.entitlements` file  
2. The same group ID is added to the **App Groups capability** in Xcode  
3. The provisioning profile used for the extension includes that App Group entitlement  

If any of these are missing, attempts to write shared defaults will fail with the CFPrefsPlistSource error.

---

## ✅ Step-by-Step Fix

### 1. Verify Entitlements for Each Extension

Open these files in your project:

- `ShieldAction/ShieldAction.entitlements`
- `ShieldConfiguration/ShieldConfiguration.entitlements`
- `DeviceActivityMonitor/DeviceActivityMonitor.entitlements`

Each must include:

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.pageinstead</string>
</array>
```

✅ The group ID must match **exactly** what’s used in your Swift code.

---

### 2. Confirm App Group in Apple Developer Portal

1. Go to [Apple Developer → Identifiers → App Groups](https://developer.apple.com/account/resources/identifiers/list)
2. Confirm you have an App Group named:
   ```
   group.com.pageinstead
   ```
3. Ensure this App Group is linked to **all** of the following bundle IDs:
   - `com.joakimachren.PageInstead` (Main app)
   - `com.joakimachren.PageInstead.ShieldAction`
   - `com.joakimachren.PageInstead.ShieldConfiguration`
   - `com.joakimachren.PageInstead.DeviceActivityMonitor`

If it’s not, click “Edit” and attach it to those targets.

---

### 3. Re-Enable App Groups Capability in Xcode

In Xcode:

1. Select each target in the project navigator:
   - `PageInstead`
   - `ShieldAction`
   - `ShieldConfiguration`
   - `DeviceActivityMonitor`
2. Go to **Signing & Capabilities** tab  
3. Click “+ Capability” → Choose **App Groups**  
4. Check the box for:
   ```
   group.com.pageinstead
   ```

✅ This updates entitlements and regenerates the correct signing configuration.

---

### 4. Clean & Rebuild

Run from terminal:

```bash
xcodebuild clean build -project PageInstead.xcodeproj -scheme PageInstead
```

Or from Xcode GUI: **Product → Clean Build Folder (⇧⌘K)** then **Build (⌘B)**

✅ Once the entitlement is correct, the CFPrefsPlistSource warning will disappear.

---

### 5. Test App Group Access

Add temporary debug code in your `ShieldActionExtension.swift`:

```swift
if let defaults = UserDefaults(suiteName: "group.com.pageinstead") {
    defaults.set(Date(), forKey: "app_group_write_test")
    print("✅ Successfully wrote to App Group!")
} else {
    print("❌ Failed to open App Group defaults")
}
```

Run the extension and check logs.  
If you see “✅ Successfully wrote to App Group!”, the entitlement is working.

---

### 6. Refresh Provisioning Profiles (If Needed)

If the entitlements are correct but the error persists:

1. Go to **Xcode → Settings → Accounts**  
2. Select your Apple ID → “Manage Certificates”  
3. Re‑download provisioning profiles for each target  
4. Rebuild the project

This ensures the profiles include the updated App Group entitlement.

---

## 🧱 Why This Matters

Your unlock logic relies on communication through **App Group shared UserDefaults**:

- ShieldActionExtension → writes unlock flags  
- Main app (ScreenTimeService) → reads them  

If ShieldAction can’t write to the group container, the main app never sees the unlock signal.  
That’s why your shield remains active even though everything else looks correct.

---

## ✅ After Fix Validation Checklist

| Check | Expected Result |
|--------|------------------|
| ShieldAction can write to defaults | ✅ No CFPrefsPlistSource error |
| Main app can read unlock_request_ keys | ✅ Flags appear in logs |
| Unlock flow works end‑to‑end | ✅ App unshields successfully |
| Xcode signing status | ✅ All targets show App Groups capability enabled |

---

**Prepared for:** PageInstead App Project  
**By:** GPT‑5 Build Systems Advisor  
**Date:** 31 Oct 2025
