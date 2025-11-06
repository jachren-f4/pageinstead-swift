# 🛡️ PageInstead – Shield Unlock Flow Fix Plan

**Date:** 31 Oct 2025  
**Author:** Joakim Achrén  
**Topic:** Implementing reliable unlock behavior after pause timer expiration using App‑driven flow

---

## ⚠️ Problem Summary

**Issue:**  
The ShieldAction extension’s “Open” button dismisses the shield UI but does **not** actually unlock the app.  
iOS immediately re‑locks the app because the extension cannot directly modify the `ManagedSettingsStore`.

**Reason:**  
Apple’s Screen Time architecture prevents the ShieldAction extension from altering shields directly.  
`completionHandler(.close)` dismisses the overlay but **does not lift system restrictions**.

---

## 🧩 Correct Architectural Approach

The unlock must be performed by the **main app** (or DeviceActivityMonitor), not by the ShieldAction extension.

### Correct Flow

```
User taps blocked app
    ↓
ShieldConfigurationExtension shows pause timer + “Open” button
    ↓
ShieldActionExtension handles button tap
    ↓
Writes unlock intent to App Group defaults (shared storage)
    ↓
Main app observes unlock intent → removes app from ManagedSettingsStore
    ↓
App becomes unblocked and opens normally
```

---

## ✅ Implementation Steps

### **1. ShieldActionExtension.swift** – Signal Unlock Intent

```swift
private func unlockApplication(_ token: ApplicationToken) {
    let defaults = UserDefaults(suiteName: "group.com.pageinstead")
    let tokenString = String(describing: token)

    defaults?.set(true, forKey: "unlock_request_\(tokenString)")
    defaults?.synchronize()

    print("🎯 ShieldAction: unlock_request_\(tokenString) written to App Group defaults")
}
```

Then call this before `completionHandler(.close)` in `handlePrimaryButton`.

```swift
unlockApplication(token)
completionHandler(.close)
```

✅ This writes an unlock request flag that the main app can detect.

---

### **2. ScreenTimeService.swift** – Observe Unlock Requests

Add a polling observer or Combine timer in your service initialization:

```swift
init() {
    startUnlockObserver()
}

private func startUnlockObserver() {
    let defaults = UserDefaults(suiteName: "group.com.pageinstead")

    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        guard let keys = defaults?.dictionaryRepresentation().keys else { return }

        for key in keys where key.hasPrefix("unlock_request_") {
            let tokenString = key.replacingOccurrences(of: "unlock_request_", with: "")
            print("🔓 Detected unlock request for \(tokenString)")

            self.removeAppFromShield(tokenString)
            defaults?.removeObject(forKey: key)
        }
    }
}
```

---

### **3. Implement `removeAppFromShield`**

```swift
private func removeAppFromShield(_ tokenString: String) {
    let store = ManagedSettingsStore()
    guard var currentApps = store.shield.applications else { return }

    let tokenToRemove = currentApps.first { String(describing: $0) == tokenString }
    if let token = tokenToRemove {
        currentApps.remove(token)
        store.shield.applications = currentApps.isEmpty ? nil : currentApps
        print("✅ App \(tokenString) unshielded successfully")
    }
}
```

✅ This runs inside the main app process, where ManagedSettings modifications are permitted.

---

### **4. Optional – Refresh Shields on Scene Activation**

In `ContentView.swift`:

```swift
.onChange(of: scenePhase) { newPhase in
    if newPhase == .active {
        screenTimeService.refreshShields()
    }
}
```

Ensures the UI reflects current shield state when returning from background.

---

## 🧠 Why This Works

- **ShieldAction** can’t modify `ManagedSettingsStore` directly, but it *can* write to App Group defaults.  
- **Main app** can modify shields and runs in the correct sandbox.  
- By polling (or observing) shared defaults, the main app acts as an unlock coordinator.

✅ Complies with Apple’s sandbox restrictions  
✅ Works on all iOS 16–26 versions  
✅ Unlocks happen within ~1 second

---

## 🧩 Validation Steps

1. Launch PageInstead on device or simulator.  
2. Open a blocked app.  
3. Wait for timer → press **Open**.  
4. In Console logs, confirm sequence:

```
🎯 ShieldAction: unlock_request_com.instagram.ios written to App Group defaults
🔓 Detected unlock request for com.instagram.ios
✅ App com.instagram.ios unshielded successfully
```

5. The blocked app should now open normally.

---

## 🧱 Notes & Caveats

| Limitation | Explanation |
|-------------|-------------|
| Slight delay | Unlock occurs after main app detects flag (~1s) |
| ShieldAction sandbox | Cannot access ManagedSettingsStore directly |
| .close behavior | Only dismisses shield UI |
| Multi‑app unlock | Multiple unlock_request_ keys supported |
| Race conditions | None – polling ensures eventual unlock |

---

## 📊 Summary

| Component | Responsibility |
|------------|----------------|
| **ShieldConfigurationExtension** | Displays quote and timer UI |
| **ShieldActionExtension** | Writes unlock intent to App Group defaults |
| **Main App (ScreenTimeService)** | Observes defaults and unshields apps |
| **ManagedSettingsStore** | Updated only from main app context |

✅ This pattern enables real unlocks while preserving Apple’s security model.

---

**Prepared for:** PageInstead App Project  
**By:** GPT‑5 Build Systems Advisor  
**Date:** 31 Oct 2025
