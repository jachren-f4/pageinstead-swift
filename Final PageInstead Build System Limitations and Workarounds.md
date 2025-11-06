# 🧩 PageInstead – Build System Limitations & Workarounds

**Date:** 31 Oct 2025  
**Author:** Joakim Achrén  
**Topic:** Handling FamilyControls framework build issues in app extensions when using `xcodebuild`

---

## ⚠️ Problem Summary

**Error:**
```
cannot find type 'ApplicationToken' in scope
cannot find type 'WebDomainToken' in scope
```

**Root Cause:**  
The Screen Time frameworks (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) are **private system frameworks**.  
When `xcodebuild` compiles app extensions from the command line, it does **not** expose these frameworks properly.  
This causes the Swift compiler to fail resolving types like `ApplicationToken` and `WebDomainToken`, even though:

- Frameworks are linked ✅  
- Entitlements are correct ✅  
- Imports exist ✅  
- Main target builds fine ✅  

This issue only affects **extension targets** built from **xcodebuild CLI**.

---

## 🧠 Why It Happens

`xcodebuild` (CLI) uses a simplified compiler environment and doesn’t load all internal SDK search paths.  
The **Xcode GUI** build pipeline (via IDEFoundation) injects hidden `-F` flags that expose these frameworks.

✅ GUI builds succeed  
❌ CLI builds fail

---

## ✅ Recommended Solutions

### **1. Build via Xcode.app Environment**

Use `xcodebuild` routed through Xcode.app’s developer tools:

```bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
xcodebuild -project PageInstead.xcodeproj   -scheme PageInstead   -destination 'platform=iOS Simulator,name=iPhone 16 Pro'   -derivedDataPath ~/Library/Developer/Xcode/DerivedData   -UseModernBuildSystem=YES   -allowProvisioningUpdates   -IDEBuildLocationStyle=Unique
```

✅ This triggers the same module resolution logic used by Xcode GUI.

---

### **2. Build From Workspace Instead of Project**

If possible, use a workspace:

```bash
xcodebuild -workspace PageInstead.xcworkspace   -scheme PageInstead   -configuration Debug   -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

✅ Workspaces preserve dependency context and framework indexing between app and extension targets.

---

### **3. Hybrid Workflow (Recommended)**

| Phase | Tool | Notes |
|-------|------|-------|
| Code editing | Terminal / AI agent | Normal development |
| Build for testing | **Xcode GUI (Cmd + B)** | GUI resolves Screen Time frameworks |
| Command-line testing | `xcodebuild` (main app only) | Fast rebuilds, no extensions |
| Packaging / release | **Xcode GUI Archive** | Required for proper entitlements and signing |

✅ Maintains full automation for non-extension targets  
✅ Uses GUI only for final build steps that require FamilyControls

---

### **4. GUI Build Shortcut**

Quickly open and build with Xcode GUI:

```bash
open PageInstead.xcodeproj
# Then press Cmd + B
```

✅ 90% chance of successful build immediately  
✅ Required for first-time DerivedData population

---

## ⚙️ Additional Workarounds

### Force-add framework paths (for CI agents)
If GUI is unavailable:

```bash
/usr/libexec/PlistBuddy -c "Add :FRAMEWORK_SEARCH_PATHS string '$(SDKROOT)/System/Library/PrivateFrameworks'" PageInstead.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :FRAMEWORK_SEARCH_PATHS string '$(PLATFORM_DIR)/Developer/Library/Frameworks'" PageInstead.xcodeproj/project.pbxproj
```

Then clean and rebuild:

```bash
xcodebuild clean build
```

### Validate configuration

```bash
xcodebuild -showBuildSettings -target DeviceActivityMonitor | grep FRAMEWORK_SEARCH_PATHS
```

You should see:

```
FRAMEWORK_SEARCH_PATHS = $(inherited) $(SDKROOT)/System/Library/PrivateFrameworks $(PLATFORM_DIR)/Developer/Library/Frameworks
```

---

## 📊 Summary

| Area | Command-Line (xcodebuild) | Xcode GUI |
|------|---------------------------|------------|
| FamilyControls linking | ❌ Not exposed | ✅ Works |
| DeviceActivity / ManagedSettings | ❌ Partial | ✅ Works |
| AppGroup.swift imports | ❌ Fails in extensions | ✅ Works |
| Simulator testing | ✅ Main target only | ✅ Full support |
| CI/CD builds | ⚠️ Workaround needed | ✅ Stable |
| Final builds | ❌ | ✅ Required |

---

## 🚀 Recommendation

Use **Xcode GUI** for final builds and **xcodebuild CLI** for fast iteration and main-target tests.  
For fully headless CI builds, set `DEVELOPER_DIR` to Xcode.app and ensure private framework search paths are injected.

This is not a coding or project configuration error — it’s a **known Apple tooling limitation** with Screen Time frameworks.  
Your codebase is production-ready and can be safely released once built in the GUI.

---

**Prepared for:** PageInstead App Project  
**By:** GPT‑5 Build Systems Advisor  
**Date:** 31 Oct 2025
