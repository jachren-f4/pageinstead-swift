
# Understanding Custom Shield Extensions (Screen Time API)

## ✅ What You’ve Got Exactly Right

### 1. Info.plist Configuration
The Info.plist tells iOS which extension provides your custom shield UI. The critical keys are:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.familycontrols.shield-configuration</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ShieldConfigurationProvider</string>
</dict>
```

If these keys are incorrect, iOS will show the default grey “Restricted” shield.

### 2. Embedding
Your shield extensions must be **embedded** in the main app bundle:

```
AppName.app/PlugIns/
```

In **Build Phases**, make sure both appear under **Embed App Extensions** with **Embed & Sign**.

### 3. Behavior: Default vs Custom Shield
| Condition | Result |
|------------|---------|
| ShieldConfiguration extension loads successfully | Custom shield appears |
| Extension fails to load or not embedded | Default “Restricted” shield appears |

---

## ⚙️ Small Corrections & Clarifications

### 1. Correct Extension Point Identifier
Use the proper identifier:

```xml
<string>com.apple.familycontrols.shield-configuration</string>
```

*Do not* use `com.apple.ManagedSettings.shield-configuration-service` — it won’t be discovered by iOS.

### 2. Entitlements

| Target | Entitlements | Notes |
|---------|--------------|-------|
| Main App | Family Controls, App Groups, (optional Device Activity) | Required for managing shields |
| ShieldConfigurationExtension | Family Controls, App Groups | Needed to talk to ManagedSettings |
| ShieldActionExtension | Family Controls, App Groups | Handles button presses |

> ❌ Incorrect: Only App Groups  
> ✅ Correct: App Groups + Family Controls for all related targets

### 3. Class Naming
You can name your provider class anything, as long as the `Info.plist` matches:
```swift
class ShieldConfigurationProvider: ShieldConfigurationDataSource { … }
```

and

```xml
<string>$(PRODUCT_MODULE_NAME).ShieldConfigurationProvider</string>
```

### 4. Caching Behavior
iOS may cache shield configurations until reboot, but redeploying the app updates them immediately. Persistent defaults usually mean the extension didn’t load or crashed.

---

## ✅ Summary of Correct Setup

| Target | Entitlements | Identifier | Principal Class | Embed |
|---------|--------------|-------------|-----------------|--------|
| App | Family Controls, App Groups | — | — | — |
| ShieldConfigurationExtension | Family Controls, App Groups | `com.apple.familycontrols.shield-configuration` | `$(PRODUCT_MODULE_NAME).ShieldConfigurationProvider` | Embed & Sign |
| ShieldActionExtension | Family Controls, App Groups | `com.apple.familycontrols.shield-action` | `$(PRODUCT_MODULE_NAME).ShieldActionHandler` | Embed & Sign |

---

## 💡 TL;DR
- ✅ Info.plist must use `com.apple.familycontrols.shield-configuration`  
- ✅ Keep Family Controls + App Groups on every Screen Time target  
- ✅ Ensure both extensions are embedded and signed  
- ✅ Add `init()` print logs to confirm load success  
- ⚙️ Once all aligned, the grey “Restricted” shield disappears and your custom one works perfectly.
