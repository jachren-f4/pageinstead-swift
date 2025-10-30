# Build Instructions - DeviceActivityMonitor

## Current Issue

The DeviceActivityMonitor extension has been created and configured, but needs Apple provisioning profile update for App Group access.

**Error:**
```
Provisioning profile doesn't match the entitlements file's value for
the com.apple.security.application-groups entitlement
```

## Solution: Build in Xcode First

Since this is a **personal development team**, Apple needs to provision the App Group for the new bundle ID. This happens automatically when building through Xcode GUI.

### Steps:

1. **Open Project in Xcode**
   ```bash
   open PageInstead.xcodeproj
   ```

2. **Select DeviceActivityMonitor Target**
   - In Xcode, select the PageInstead project in the navigator
   - Select the "DeviceActivityMonitor" target
   - Go to "Signing & Capabilities" tab

3. **Verify Settings**
   Should see:
   - Team: Joakim Achren (Personal Team)
   - Automatically manage signing: ✅ (checked)
   - App Groups capability with `group.com.pageinstead`

4. **Build the Project**
   - Select your iPhone as the destination device
   - Press Cmd+B to build
   - Xcode will automatically:
     - Register the new bundle ID with Apple
     - Create provisioning profile with App Group
     - Download and install the profile

5. **Verify Success**
   - Build should succeed without errors
   - All three targets should build: PageInstead, ShieldConfiguration, DeviceActivityMonitor

6. **Run on Device**
   - Press Cmd+R to run on your iPhone
   - App should install with all extensions embedded

## What Was Implemented

### New Extension: DeviceActivityMonitor
- **Purpose:** Track when apps are blocked and save events to App Group
- **Why:** Shield Configuration Extensions CANNOT write to App Group (iOS restriction)
- **How:** DeviceActivityMonitor runs in main app context with write access

### Files Created:
```
DeviceActivityMonitor/
├── DeviceActivityMonitorExtension.swift  - Main implementation
├── Info.plist                            - Extension configuration
└── DeviceActivityMonitor.entitlements    - App Group + Family Controls
```

### Files Modified:
```
PageInstead/Core/Services/ScreenTimeService.swift
  - Added DeviceActivity monitoring
  - Starts monitoring when shields applied
  - Stops monitoring when shields removed

ShieldConfiguration/ShieldConfigurationExtension.swift
  - Removed non-functional save attempts
  - Cleaned up to display-only

CLAUDE.md
  - Documented new architecture
  - Added platform limitations

ISSUE_SUMMARY.md
  - Added solution section
  - Explained DeviceActivityMonitor approach
```

## Testing After Build

### 1. Test Quote History
1. Open PageInstead app
2. Grant Screen Time permission
3. Go to "Block Apps" tab
4. Select apps to block (e.g., Safari)
5. Tap "Block Selected Apps"
6. Try opening a blocked app
   - Should see custom quote shield ✅
7. Return to PageInstead → "Quote History" tab
8. **Should see blocking event** 🎉

### 2. Check Logs
```bash
# Terminal 1: Stream logs
log stream --device --predicate 'processImagePath CONTAINS "PageInstead" OR processImagePath CONTAINS "DeviceActivityMonitor"' --level debug

# Terminal 2: Trigger the app blocking
# (Open a blocked app on your iPhone)
```

Look for these log messages:
```
📊 ScreenTimeService: Starting DeviceActivity monitoring...
✅ ScreenTimeService: Monitoring started successfully
🚨 DeviceActivityMonitor: Event threshold reached!
📝 DeviceActivityMonitor: Saving blocking event...
✅ DeviceActivityMonitor: Event saved successfully
```

## Troubleshooting

### Provisioning Still Fails in Xcode
1. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/PageInstead-*`
3. Restart Xcode
4. Try building again

### Extension Not Embedded
Check that the app bundle contains the extension:
```bash
ls -la /Users/joakimachren/Library/Developer/Xcode/DerivedData/PageInstead-*/Build/Products/Debug-iphoneos/PageInstead.app/PlugIns/

# Should see:
# DeviceActivityMonitor.appex
# ShieldConfiguration.appex
```

### Events Not Appearing
1. Verify monitoring started (check logs for "Monitoring started successfully")
2. Try the "Test App Group" button in Quote History to verify write access
3. Check that ShieldDataStore can write to App Group from main app context

## Implementation Notes

### Why DeviceActivityMonitor?
The expert confirmed that Shield Configuration Extensions have a platform-level restriction preventing writes to App Group storage. DeviceActivityMonitor extensions run in the main app context and have full write access.

### How Monitoring Works
```
User blocks apps
    ↓
ScreenTimeService.applyShield()
    ↓
DeviceActivityCenter.startMonitoring()
    ↓
User opens blocked app
    ↓
iOS triggers DeviceActivityMonitor.eventDidReachThreshold()
    ↓
Monitor saves ShieldEvent to shieldEvents.json in App Group
    ↓
Main app reads and displays in Quote History
```

### Known Limitations
1. **Event Trigger Configuration:** The current implementation uses a basic monitoring schedule. We may need to configure specific `DeviceActivityEvent` thresholds for more reliable triggering.

2. **App Name Detection:** Currently using generic "Blocked App" string. We may need to correlate event data with application tokens to get actual app names.

3. **Testing Required:** DeviceActivityMonitor behavior needs real-device testing to confirm events trigger correctly.

## Next Steps After Successful Build

1. ✅ Test that DeviceActivityMonitor can write to App Group
2. ✅ Verify events appear in Quote History when apps are blocked
3. ⚠️ If events don't appear, may need to adjust monitoring configuration
4. ⚠️ May need to implement event thresholds for specific apps
5. ⚠️ May need to improve app name detection from event data

## References

- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Complete implementation details
- [ISSUE_SUMMARY.md](./ISSUE_SUMMARY.md) - Problem investigation and solution
- [CLAUDE.md](./CLAUDE.md) - Architecture documentation

---

**Status:** ✅ Implementation complete, awaiting Xcode build for provisioning
