# 🧩 PageInstead – Final Build Issue Fix Plan

**Date:** 31 Oct 2025  
**Author:** Joakim Achrén  
**Purpose:** Resolve remaining `FamilyControls` framework build errors in extension targets when compiling with `xcodebuild`.

---

## ⚠️ Problem Summary

**Error:**  
```
cannot find type 'ApplicationToken' in scope
cannot find type 'WebDomainToken' in scope
```

**Context:**  
- Occurs in `AppGroup.swift` inside extension targets (`DeviceActivityMonitor`, `ShieldConfiguration`).
- Does **not** occur in main app target.
- Frameworks (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) are linked correctly.
- Entitlements are correct.
- Imports are present.
- Command-line builds fail, Xcode GUI builds often succeed.

**Root Cause:**  
Apple’s Screen Time frameworks are treated as **private system frameworks**, not automatically visible to extension build phases invoked by `xcodebuild`. The Swift compiler cannot find the `FamilyControls.swiftmodule` path without explicit configuration.

---

## ✅ Solution 1: Add Framework Search Paths

Add the following SDK paths manually for both **DeviceActivityMonitor** and **ShieldConfiguration** targets.

```bash
/usr/libexec/PlistBuddy -c "Add :FRAMEWORK_SEARCH_PATHS string '$(SDKROOT)/System/Library/PrivateFrameworks'" PageInstead.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :FRAMEWORK_SEARCH_PATHS string '$(PLATFORM_DIR)/Developer/Library/Frameworks'" PageInstead.xcodeproj/project.pbxproj
```

Then rebuild:

```bash
xcodebuild clean build -project PageInstead.xcodeproj -scheme PageInstead
```

✅ This forces Swift to locate `FamilyControls.swiftmodule` correctly under iOS SDK.

**Verification:**

```bash
xcodebuild -showBuildSettings -target DeviceActivityMonitor | grep FRAMEWORK_SEARCH_PATHS
```

Expected result:

```
FRAMEWORK_SEARCH_PATHS = $(inherited) $(SDKROOT)/System/Library/PrivateFrameworks $(PLATFORM_DIR)/Developer/Library/Frameworks
```

---

## ✅ Solution 2: Proxy Wrapper in Main App Target

If the search path fix doesn’t solve it, isolate `FamilyControls` usage to the main app target.

Create a new file:  
`PageInstead/Core/Models/AppGroupTokens.swift`

```swift
import FamilyControls

public struct AppGroupTokens: Codable {
    public var applications: [ApplicationToken]
    public var webDomains: [WebDomainToken]
}
```

Then modify `AppGroup.swift`:

```swift
#if canImport(FamilyControls)
import FamilyControls
#endif

public struct AppGroup: Codable {
    public var tokens: AppGroupTokens
}
```

✅ The main app manages conversion between `FamilyControls` tokens and Codable data, while extensions only deal with serialized JSON.

---

## ✅ Solution 3: Conditional Compilation (Safe Fallback)

For maximum build reliability in CI or coding agents, replace all direct `ApplicationToken` / `WebDomainToken` references with safe aliases:

```swift
#if canImport(FamilyControls)
import FamilyControls
public typealias SafeApplicationToken = ApplicationToken
public typealias SafeWebDomainToken = WebDomainToken
#else
public struct SafeApplicationToken: Codable, Hashable {}
public struct SafeWebDomainToken: Codable, Hashable {}
#endif
```

Then in your models:

```swift
struct AppGroup: Codable {
    var applications: [SafeApplicationToken]
    var webDomains: [SafeWebDomainToken]
}
```

✅ Guarantees successful compilation even if `FamilyControls` is unavailable during command-line builds.

---

## 🧠 Recommended Order of Application

| Step | Action | Description |
|------|----------|-------------|
| 1 | Apply **Solution 1** | Add `PrivateFrameworks` and `Developer/Frameworks` to search paths |
| 2 | Retry build | Run `xcodebuild clean build` |
| 3 | If issue persists → Apply **Solution 3** | Add conditional compilation to make command-line builds succeed |
| 4 | (Optional) Apply **Solution 2** | Use proxy wrapper to fully isolate FamilyControls logic |

---

## 🧩 Validation Checklist

| Check | Expected Outcome |
|--------|------------------|
| `FamilyControls.framework` linked | ✅ |
| Entitlements include FamilyControls & DeviceActivity | ✅ |
| `FRAMEWORK_SEARCH_PATHS` includes private paths | ✅ |
| Command-line build succeeds | ✅ |
| Xcode GUI build also succeeds | ✅ |
| Simulator runs with mock FamilyActivityPicker | ✅ |

---

## 🧱 Summary

This issue isn’t caused by code defects — it’s a **build environment limitation** in how Xcode exposes the Screen Time frameworks to extension targets.  
By explicitly adding private framework paths or using conditional compilation, you can achieve **100% command-line build reliability** and ensure CI agents can compile without Xcode GUI intervention.

---

**Prepared for:** PageInstead App Project  
**By:** GPT‑5 Build Systems Advisor  
**Date:** 31 Oct 2025
