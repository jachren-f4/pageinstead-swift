# Settings Implementation Plan - Self-Restriction Features

## Overview
Implement a Settings section with self-restriction features to prevent users from easily disabling their app blocking settings. These features add intentional friction to protect users from impulsive decisions to disable their productivity tools.

## Feature Set

### 1. Lock Settings Timer
**Purpose**: Add a countdown timer that activates when opening PageInstead settings, creating a delay before changes can be made.

**Components**:
- Toggle switch to enable/disable the feature
- Timer duration selector (dropdown/picker)
- Default: 15 seconds (configurable from 5-120 seconds)
- Countdown UI overlay when settings are accessed

**Implementation Notes**:
- Store timer preference in UserDefaults
- Show countdown overlay on SettingsView appearance
- Disable all settings controls until countdown completes
- Option to show motivational quote during countdown

### 2. Lock Settings Passcode
**Purpose**: Require a passcode to access or modify app blocking settings.

**Components**:
- Toggle switch to enable/disable passcode protection
- "Change" button to set/update passcode
- Passcode entry screen (4-6 digit PIN or alphanumeric)
- Optional: Face ID/Touch ID integration

**Implementation Notes**:
- Store hashed passcode in Keychain (never UserDefaults)
- Use LocalAuthentication framework for biometric option
- Show passcode prompt before allowing settings access
- Include "Forgot Passcode" recovery option (see Emergency Unlock)

### 3. Emergency Settings Unlock
**Purpose**: Provide an emergency escape hatch that requires deliberate action (monetary tip) to discourage casual use.

**Components**:
- In-app purchase for emergency unlock ($5 suggested)
- One-time unlock vs. permanent unlock options
- Unlock history tracking (to show patterns of weakness)
- Optional: Charity donation instead of tip

**Implementation Notes**:
- StoreKit integration for IAP
- Server-side receipt validation
- Consider time-delayed unlock (e.g., unlock in 24 hours)
- Track unlock frequency for self-awareness

### 4. Prevent App Uninstall
**Purpose**: Use iOS Screen Time API to prevent uninstalling PageInstead and other productivity apps.

**Components**:
- Toggle switch to enable/disable
- List of protected apps (PageInstead + user selected)
- Warning dialog about iOS limitations

**Technical Constraints**:
- **iOS Limitation**: Apps cannot directly prevent their own uninstallation
- **Workaround Options**:
  1. Use Screen Time API to restrict app deletion system-wide
  2. MDM profile (requires enterprise deployment)
  3. Guided Access mode (temporary solution)
  4. Shortcuts automation to re-enable if disabled

**Recommended Approach**:
- Use `ManagedSettingsStore` to set `denyAppRemoval = true`
- This prevents ALL app deletions, not selective
- Clear warning to users about system-wide impact

### 5. Prevent Time Change
**Purpose**: Stop users from changing device time to bypass scheduled blocks.

**Components**:
- Toggle switch to enable/disable
- Integration with existing Screen Time restrictions
- Warning about automatic time zone updates

**Technical Constraints**:
- **iOS Limitation**: Apps cannot prevent system time changes
- **Partial Solutions**:
  1. Detect time changes and reset blocks
  2. Use server time validation
  3. Screen Time API parental controls (if available)
  4. Log time change attempts

**Recommended Approach**:
- Monitor for significant time changes using `NSSystemClockDidChangeNotification`
- Validate against network time (NTP)
- Reset all active blocks if tampering detected
- Show warning notification about detected manipulation

## Technical Architecture

### Data Model
```swift
struct SelfRestrictionSettings {
    // Timer Lock
    var isTimerLockEnabled: Bool
    var timerDuration: TimeInterval // seconds

    // Passcode Lock
    var isPasscodeLockEnabled: Bool
    var passcodeHash: String? // Stored in Keychain
    var useBiometrics: Bool

    // Emergency Unlock
    var emergencyUnlockHistory: [Date]
    var hasActiveEmergencyUnlock: Bool
    var emergencyUnlockExpiry: Date?

    // App Protection
    var isAppUninstallPreventionEnabled: Bool
    var protectedAppIdentifiers: Set<String>

    // Time Protection
    var isTimeChangePreventionEnabled: Bool
    var lastKnownSystemTime: Date
    var timeManipulationAttempts: [Date]
}
```

### Required Frameworks
- `LocalAuthentication` - Biometric authentication
- `StoreKit` - In-app purchases
- `KeychainServices` - Secure passcode storage
- `FamilyControls` - Extended Screen Time controls

### New Views Required
1. `SettingsView.swift` - Main settings interface
2. `TimerLockOverlay.swift` - Countdown overlay
3. `PasscodeEntryView.swift` - Passcode input screen
4. `PasscodeSetupView.swift` - Create/change passcode
5. `EmergencyUnlockView.swift` - IAP and unlock flow
6. `ProtectedAppsListView.swift` - Select apps to protect

## Implementation Phases

### Phase 1: Basic Timer & Passcode (Week 1)
- [ ] Create SettingsView with toggle controls
- [ ] Implement countdown timer overlay
- [ ] Add passcode creation and validation
- [ ] Integrate with existing navigation

### Phase 2: Advanced Locks (Week 2)
- [ ] Add biometric authentication option
- [ ] Implement Keychain storage for passcode
- [ ] Create passcode recovery flow
- [ ] Add timer duration customization

### Phase 3: System Integration (Week 3)
- [ ] Research Screen Time API capabilities for app deletion
- [ ] Implement time change detection
- [ ] Add notification system for tampering attempts
- [ ] Create protected apps selection interface

### Phase 4: Monetization & Polish (Week 4)
- [ ] Integrate StoreKit for emergency unlock
- [ ] Add unlock history and analytics
- [ ] Implement receipt validation
- [ ] Create onboarding for new features

## User Experience Considerations

### Onboarding
- Explain each restriction's purpose
- Start with minimal restrictions, gradually increase
- Provide "commitment level" presets (Light, Moderate, Strict)

### Friction Balance
- Too little: Features are ineffective
- Too much: Users abandon the app
- Solution: Progressive enhancement based on user behavior

### Recovery Options
- Always provide an escape hatch
- Make recovery deliberately inconvenient, not impossible
- Track recovery usage for self-reflection

## Privacy & Security
- Passcodes stored as salted hashes
- No passcode recovery via email/cloud
- Emergency unlocks are anonymous transactions
- Time manipulation detection is local only

## iOS Limitations & Workarounds

### What We CAN Do:
- ✅ Add timer delays to our own settings
- ✅ Require authentication for our app's settings
- ✅ Detect time changes and respond
- ✅ Use Screen Time API for some restrictions

### What We CANNOT Do:
- ❌ Prevent our own app from being deleted (directly)
- ❌ Block iOS Settings app access
- ❌ Prevent system time changes
- ❌ Override Screen Time parental controls

### Recommended Messaging:
"These features add helpful friction to prevent impulsive changes. They work best when combined with iOS Screen Time restrictions and personal accountability."

## Success Metrics
- Reduction in settings access frequency
- Decrease in app blocking disablement
- Emergency unlock usage patterns
- User retention after enabling restrictions

## Next Steps
1. Review technical feasibility with iOS 16+ APIs
2. Design UI mockups for each component
3. Implement Phase 1 features
4. User test friction levels
5. Iterate based on feedback

## Notes
- Consider adding a "Accountability Partner" feature where someone else holds the passcode
- Explore integration with Focus modes for additional context
- Add motivational statistics showing how long restrictions have been active
- Consider gamification elements (streaks, achievements) for maintaining restrictions