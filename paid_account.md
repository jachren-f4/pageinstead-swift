# 🧩 PageInstead – App Group Container (null) Troubleshooting (Paid Developer Edition)

**Date:** 31 Oct 2025  
**Author:** Joakim Achrén  
**Topic:** Resolving App Group “Container: (null)” errors on a paid Apple Developer account

---

## ⚠️ Problem Summary

Even with a **paid Apple Developer Program** membership, extensions are still showing:

```
Couldn't write values for keys (...) in CFPrefsPlistSource<...>:
setting preferences outside an application's container requires user-preference-write or file-write-data sandbox access
Container: (null)
```

This means the device cannot locate or create the shared **App Group container directory**.

---

## 🧠 Why It Happens (Even on Paid Teams)

1. Xcode or iOS is still using a **Personal Team** provisioning profile.  
2. Provisioning profiles are cached and don’t reflect new App Group entitlements.  
3. One or more extensions aren’t assigned the correct team or App Group ID.  
4. The device hasn’t created the container directory yet (lazy initialization).  

---

## ✅ Step-by-Step Troubleshooting

### **1. Confirm Targets Use Paid Team**

In Xcode → Project → Each Target → **Signing & Capabilities**:

- Verify **Team** = your **organization name** (not *Personal Team*).  
- Repeat for:  
  - PageInstead (main app)  
  - ShieldAction  
  - ShieldConfiguration  
  - DeviceActivityMonitor  

Run in terminal to confirm entitlements use correct Team ID:

```bash
codesign -d --entitlements - "PageInstead.app"
```

You should see your **paid Team ID**, e.g.:
```
<key>com.apple.developer.team-identifier</key>
<string>ABCD123456</string>
```

---

### **2. Refresh Provisioning Profiles**

Xcode can silently use stale profiles. To refresh:

1. Open **Xcode → Settings → Accounts → Manage Certificates**  
2. Select your Apple ID → **Download Manual Profiles**  
3. Delete old profiles manually:  
   ```bash
   rm ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision
   ```
4. Run build again:  
   ```bash
   xcodebuild -allowProvisioningUpdates clean build
   ```

✅ This forces Xcode to download fresh provisioning with real App Group entitlements.

---

### **3. Ensure All Targets Use the Same App Group ID**

Quick verification:
```bash
grep -R "group." -n ./PageInstead
```

Expected result:
```
group.com.pageinstead
```

All `.entitlements` and `.swift` files must use this exact ID.

---

### **4. Confirm Container Creation on Device**

The App Group container directory is created lazily when the app first writes to it.

After installing, check logs:

```bash
log stream --predicate 'eventMessage CONTAINS "AppGroup"'
```

Expected output:
```
created AppGroup container: /private/var/mobile/Containers/Shared/AppGroup/XXXX-XXXX-XXXX
```

If not shown → iOS still hasn’t linked the App Group entitlement.

---

### **5. Test Write From Main App**

In your main app:

```swift
if let defaults = UserDefaults(suiteName: "group.com.pageinstead") {
    defaults.set(Date(), forKey: "test_write_from_main_app")
    print("✅ Successfully wrote to App Group!")
} else {
    print("❌ App Group unavailable from main app")
}
```

| Result | Meaning |
|---------|----------|
| ✅ Works | Entitlement + container are correct |
| ❌ Fails | Team or profile mismatch |

If the main app cannot write, extensions never will.

---

### **6. Reinstall and Reboot Device**

1. Delete PageInstead and all related extensions from device.  
2. Power off and back on (important — clears shared container caches).  
3. Clean build folder (**⇧⌘K**) and rebuild using paid team.  
4. Reinstall via Xcode or `xcodebuild -allowProvisioningUpdates`.  

---

### **7. Advanced Diagnostics**

#### View active app groups for the app
```bash
xcrun simctl get_app_container booted com.joakimachren.PageInstead group.com.pageinstead
```

#### Inspect provisioning for entitlements
```bash
security cms -D -i "PageInstead.app/embedded.mobileprovision" | grep group
```

Expected output:
```
<key>com.apple.security.application-groups</key>
<array>
  <string>group.com.pageinstead</string>
</array>
```

---

### **8. Common Hidden Causes (Even for Paid Teams)**

| Issue | Description | Fix |
|--------|-------------|-----|
| Wrong Team still used | Extension target didn’t switch to paid team | Manually change in Signing & Capabilities |
| Old provisioning profile | Cached local file lacks updated entitlements | Delete profiles & rebuild |
| Wrong bundle ID format | Extensions must share root bundle prefix | Use `com.joakimachren.PageInstead.*` |
| Device never saw new profile | App installed before entitlements change | Delete app, reboot device, reinstall |
| Multiple group IDs | Mismatch between targets | Ensure *one* ID: `group.com.pageinstead` |

---

## 🧩 9. Validation Flow

1. **Build & install** the main app.  
2. **Check logs** for container creation.  
3. **Run test write** in main app.  
4. **Run ShieldActionExtension** → verify no sandbox errors.  

Once this passes, the shared container is live and extensions can safely read/write `UserDefaults(suiteName:)` data.

---

## ✅ Expected Final Log Example

```
✅ Successfully wrote to App Group!
created AppGroup container: /private/var/mobile/Containers/Shared/AppGroup/3F1E2A87-B127-49C7-AC73-12C6D94A60C4
✅ ShieldAction: unlock_request_com.instagram.ios written successfully
✅ Main App detected unlock_request_com.instagram.ios
✅ App unshielded successfully
```

---

**Prepared for:** PageInstead App Project  
**By:** GPT‑5 Build Systems Advisor  
**Date:** 31 Oct 2025
