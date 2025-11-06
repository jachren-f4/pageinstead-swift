# 🧰 PageInstead – Automated Build Fix Instructions

**Purpose:**  
Enable your coding agent (or CI setup) to fix Xcode target configuration issues **from the terminal**, without manual changes inside the Xcode GUI.

---

## 1. Overview

These scripts repair all build issues related to **App Group extensions** not finding the Screen Time API frameworks (`FamilyControls`, `ManagedSettings`, `DeviceActivity`).  
They also ensure:
- Correct framework linking  
- Proper App Group & Screen Time entitlements  
- Correct file target membership  
- Automated clean build

Once run, your project should compile successfully from terminal using `xcodebuild`.

---

## 2. Requirements

- macOS environment with **Xcode command line tools** installed  
- Ruby available (`ruby -v`)  
- Access to project root containing:  
  `PageInstead.xcodeproj`

---

## 3. Step 1 – Add Frameworks Programmatically

Use Ruby’s **xcodeproj** gem to attach required frameworks to both extensions.

```bash
gem install xcodeproj
ruby -e "
require 'xcodeproj';
proj = Xcodeproj::Project.open('PageInstead.xcodeproj');
['ShieldConfiguration', 'DeviceActivityMonitor'].each do |target_name|
  t = proj.targets.find { |t| t.name == target_name };
  %w[FamilyControls.framework ManagedSettings.framework DeviceActivity.framework].each do |fw|
    t.add_system_framework(fw)
  end
end;
proj.save;
"
```

✅ This links all necessary frameworks to both `ShieldConfiguration` and `DeviceActivityMonitor` targets.

---

## 4. Step 2 – Enable Capabilities via Entitlements

Create entitlement files directly from the terminal:

```bash
cat > ShieldConfiguration/ShieldConfiguration.entitlements <<EOF
{
  "com.apple.security.application-groups": ["group.com.joakimachren.pageinstead"],
  "com.apple.developer.family-controls": true,
  "com.apple.developer.device-activity": true
}
EOF

cat > DeviceActivityMonitor/DeviceActivityMonitor.entitlements <<EOF
{
  "com.apple.security.application-groups": ["group.com.joakimachren.pageinstead"],
  "com.apple.developer.device-activity": true
}
EOF
```

Then assign them to each target in the project file:

```bash
/usr/libexec/PlistBuddy -c "Set :CODE_SIGN_ENTITLEMENTS ShieldConfiguration/ShieldConfiguration.entitlements" PageInstead.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Set :CODE_SIGN_ENTITLEMENTS DeviceActivityMonitor/DeviceActivityMonitor.entitlements" PageInstead.xcodeproj/project.pbxproj
```

---

## 5. Step 3 – Verify Target Membership for Shared Files

Ensure `AppGroup.swift` and `AppGroupManager.swift` belong to **all targets**:

```bash
ruby -e "
require 'xcodeproj'
p = Xcodeproj::Project.open('PageInstead.xcodeproj')
['AppGroup.swift', 'AppGroupManager.swift'].each do |f|
  file_ref = p.files.find { |fref| fref.path&.end_with?(f) }
  next unless file_ref
  ['PageInstead', 'ShieldConfiguration', 'DeviceActivityMonitor'].each do |target|
    t = p.targets.find { |t| t.name == target }
    file_ref.add_referrer(t.source_build_phase) unless t.source_build_phase.files_references.include?(file_ref)
  end
end
p.save
"
```

---

## 6. Step 4 – Rebuild Everything

Run a clean build from terminal:

```bash
xcodebuild clean build   -project PageInstead.xcodeproj   -scheme PageInstead   -configuration Debug   -destination 'platform=iOS Simulator,name=iPhone 15'
```

If successful, you can run the full simulator test suite.

---

## 7. Step 5 – If Compilation Still Fails

Add these imports manually to your extensions (sometimes required for indexing):

```swift
import FamilyControls
import ManagedSettings
import DeviceActivity
```

Re-run:

```bash
xcodebuild clean build
```

---

## 8. Summary

| Issue | Fix | Automated By |
|--------|-----|---------------|
| Missing FamilyControls types | Add frameworks via `xcodeproj` | ✅ |
| Missing entitlements | Create and assign `.entitlements` files | ✅ |
| File target membership | Add shared models to all targets | ✅ |
| Build failure | Run clean build with `xcodebuild` | ✅ |

After running these steps, both **ShieldConfiguration** and **DeviceActivityMonitor** targets should compile correctly without opening Xcode.

---

**File created for:** Joakim Achrén  
**Date:** 31 Oct 2025  
**Project:** PageInstead – App Groups & Screen Time API integration
