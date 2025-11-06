# Self-Restriction Features - Detailed Implementation Task List

## Overview
This document breaks down the implementation of self-restriction features into detailed, actionable tasks. Each task is specific enough to be completed independently and includes file locations and technical requirements.

---

## Phase 1: Core Infrastructure & Data Models

### Task 1.1: Create SelfRestrictionSettings Model
**File**: `PageInstead/Core/Models/SelfRestrictionSettings.swift`
- [ ] Create new `Models` directory under `Core/`
- [ ] Define `SelfRestrictionSettings` struct with Codable conformance
- [ ] Add properties for timer lock (enabled, duration)
- [ ] Add properties for passcode lock (enabled, useBiometrics)
- [ ] Add properties for emergency unlock (history, active status, expiry)
- [ ] Add properties for app uninstall prevention (enabled, protected apps)
- [ ] Add properties for time change prevention (enabled, last known time, attempts)
- [ ] Add default initializer with sensible defaults

### Task 1.2: Create Settings Manager Service
**File**: `PageInstead/Core/Services/SelfRestrictionManager.swift`
- [ ] Create singleton service class `SelfRestrictionManager`
- [ ] Add `@Published` property for settings state
- [ ] Implement UserDefaults persistence for settings (except passcode)
- [ ] Add methods: `loadSettings()`, `saveSettings()`, `resetSettings()`
- [ ] Add validation logic for settings values
- [ ] Add observers for settings changes

### Task 1.3: Create Keychain Helper
**File**: `PageInstead/Core/Utilities/KeychainHelper.swift`
- [ ] Create new `Utilities` directory under `Core/`
- [ ] Create `KeychainHelper` class for secure storage
- [ ] Implement `savePasscode(hash: String)` method
- [ ] Implement `getPasscode() -> String?` method
- [ ] Implement `deletePasscode()` method
- [ ] Add error handling for Keychain operations
- [ ] Use service identifier: `com.joakimachren.PageInstead.passcode`

### Task 1.4: Create Passcode Hashing Utility
**File**: `PageInstead/Core/Utilities/PasscodeHasher.swift`
- [ ] Create `PasscodeHasher` utility class
- [ ] Implement `hash(passcode: String) -> String` using SHA-256 with salt
- [ ] Implement `verify(passcode: String, hash: String) -> Bool`
- [ ] Generate random salt for each passcode
- [ ] Store salt with hash (format: `salt:hash`)

---

## Phase 2: Lock Settings Timer Feature

### Task 2.1: Update SettingsView UI for Timer Lock
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Remove placeholder sections
- [ ] Add "Lock Settings Timer" toggle with info button
- [ ] Add timer duration picker (5s, 10s, 15s, 30s, 60s, 120s)
- [ ] Show current timer duration when enabled
- [ ] Add description text explaining the feature
- [ ] Style using Liquid Glass design system

### Task 2.2: Create Timer Lock Overlay Component
**File**: `PageInstead/Features/Settings/Components/TimerLockOverlay.swift`
- [ ] Create `TimerLockOverlay` view with glass card design
- [ ] Add circular countdown progress indicator
- [ ] Display remaining time in center (e.g., "14s")
- [ ] Add random motivational quote from quotes.json
- [ ] Animate countdown with smooth transitions
- [ ] Disable interaction with content below during countdown
- [ ] Add skip button with warning (only in debug mode)

### Task 2.3: Implement Timer Lock Logic
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Add `@State` variable for countdown timer
- [ ] Add `@State` variable for timer completion status
- [ ] Implement `.onAppear` to start countdown when enabled
- [ ] Use `Timer.publish()` for countdown updates
- [ ] Disable all settings controls until timer completes
- [ ] Show TimerLockOverlay when timer is active
- [ ] Add bypass for simulator: `#if targetEnvironment(simulator)`

### Task 2.4: Persist Timer Settings
**File**: `PageInstead/Core/Services/SelfRestrictionManager.swift`
- [ ] Add UserDefaults keys: `isTimerLockEnabled`, `timerDuration`
- [ ] Implement `updateTimerLock(enabled: Bool, duration: TimeInterval)`
- [ ] Load timer settings on app launch
- [ ] Add validation: duration must be 5-120 seconds

---

## Phase 3: Lock Settings Passcode Feature

### Task 3.1: Create Passcode Entry View
**File**: `PageInstead/Features/Settings/Passcode/PasscodeEntryView.swift`
- [ ] Create new `Passcode` directory under `Features/Settings/`
- [ ] Build UI with 6 passcode dot indicators
- [ ] Add number pad (0-9) with delete button
- [ ] Show error state for incorrect passcode
- [ ] Add haptic feedback for button taps
- [ ] Add shake animation for incorrect entry
- [ ] Support both 4-digit and 6-digit passcodes

### Task 3.2: Create Passcode Setup View
**File**: `PageInstead/Features/Settings/Passcode/PasscodeSetupView.swift`
- [ ] Build two-step passcode creation flow
- [ ] Step 1: Enter new passcode
- [ ] Step 2: Confirm passcode (must match)
- [ ] Show strength indicator (weak/medium/strong)
- [ ] Add "Cancel" button to abort setup
- [ ] Save hashed passcode to Keychain on success
- [ ] Show success confirmation

### Task 3.3: Create Passcode Change View
**File**: `PageInstead/Features/Settings/Passcode/PasscodeChangeView.swift`
- [ ] Build three-step passcode change flow
- [ ] Step 1: Enter current passcode
- [ ] Step 2: Enter new passcode
- [ ] Step 3: Confirm new passcode
- [ ] Validate current passcode before allowing change
- [ ] Update Keychain with new hashed passcode
- [ ] Show success confirmation

### Task 3.4: Integrate Biometric Authentication
**File**: `PageInstead/Core/Services/BiometricAuthService.swift`
- [ ] Create `BiometricAuthService` using LocalAuthentication
- [ ] Check biometric availability (Face ID / Touch ID)
- [ ] Implement `authenticate(reason: String) async -> Bool`
- [ ] Handle authentication errors gracefully
- [ ] Add fallback to passcode if biometric fails
- [ ] Request biometric permission on first use

### Task 3.5: Update SettingsView for Passcode Lock
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Add "Lock Settings Passcode" toggle
- [ ] Add "Change Passcode" button (shows PasscodeChangeView)
- [ ] Add "Use Face ID / Touch ID" toggle
- [ ] Show biometric icon (face/fingerprint) when available
- [ ] Add navigation to PasscodeSetupView when first enabled
- [ ] Disable toggle if passcode not set

### Task 3.6: Implement Passcode Gate on Settings Access
**File**: `PageInstead/App/ContentView.swift`
- [ ] Check if passcode lock is enabled when Settings tab tapped
- [ ] Show PasscodeEntryView as modal if enabled
- [ ] Try biometric auth first if enabled
- [ ] Only show SettingsView after successful authentication
- [ ] Add timeout: require re-auth after 5 minutes

---

## Phase 4: Emergency Settings Unlock

### Task 4.1: Create Emergency Unlock View
**File**: `PageInstead/Features/Settings/Emergency/EmergencyUnlockView.swift`
- [ ] Create new `Emergency` directory under `Features/Settings/`
- [ ] Design warning screen explaining emergency unlock
- [ ] Show unlock history (previous emergency unlocks)
- [ ] Display purchase options ($5 one-time unlock)
- [ ] Add "Are you sure?" confirmation dialog
- [ ] Show countdown timer (e.g., "Unlock in 1 hour")

### Task 4.2: Set Up StoreKit Products
**File**: `PageInstead/Core/Services/StoreKitManager.swift`
- [ ] Create `StoreKitManager` service
- [ ] Define product IDs: `emergency_unlock_onetime`
- [ ] Implement `loadProducts()` to fetch from App Store
- [ ] Implement `purchase(product:) async throws`
- [ ] Handle purchase states (pending, success, failed, cancelled)
- [ ] Add restore purchases functionality

### Task 4.3: Implement Emergency Unlock Logic
**File**: `PageInstead/Core/Services/SelfRestrictionManager.swift`
- [ ] Add `emergencyUnlock()` method
- [ ] Check if emergency unlock is active
- [ ] If not active, show purchase flow
- [ ] On successful purchase, grant unlock for 24 hours
- [ ] Track unlock in history array
- [ ] Add analytics event for unlock usage
- [ ] Send notification: "Emergency unlock expires in 1 hour"

### Task 4.4: Add "Forgot Passcode" Flow
**File**: `PageInstead/Features/Settings/Passcode/PasscodeEntryView.swift`
- [ ] Add "Forgot Passcode?" button below number pad
- [ ] On tap, navigate to EmergencyUnlockView
- [ ] After successful unlock, allow passcode reset
- [ ] Show PasscodeSetupView to create new passcode
- [ ] Log forgot passcode events in history

### Task 4.5: Create App Store Connect Configuration
**External**: App Store Connect
- [ ] Create in-app purchase: "Emergency Settings Unlock"
- [ ] Type: Consumable
- [ ] Price: $4.99 (Tier 5)
- [ ] Product ID: `com.joakimachren.PageInstead.emergency_unlock`
- [ ] Upload screenshot and description
- [ ] Submit for review

---

## Phase 5: Prevent App Uninstall

### Task 5.1: Research Screen Time API for App Deletion
**File**: `PageInstead/Core/Services/ScreenTimeService.swift`
- [ ] Research `ManagedSettings.shield.applicationRemoval` property
- [ ] Test `denyAppRemoval` on physical device
- [ ] Document limitations (system-wide vs. selective)
- [ ] Test interaction with existing app blocking

### Task 5.2: Create App Uninstall Prevention UI
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Add "Prevent App Uninstall" toggle
- [ ] Show warning alert on first enable
- [ ] Warning text: "This prevents ALL app deletions system-wide"
- [ ] Add info button with detailed explanation
- [ ] Require passcode confirmation to enable (if passcode enabled)

### Task 5.3: Implement App Uninstall Prevention Logic
**File**: `PageInstead/Core/Services/ScreenTimeService.swift`
- [ ] Add `setAppDeletionRestriction(enabled: Bool)` method
- [ ] Use `ManagedSettingsStore().shield.applicationRemoval` property
- [ ] Set to `.restricted` when enabled
- [ ] Set to `.unrestricted` when disabled
- [ ] Handle authorization errors
- [ ] Add notification on success/failure

### Task 5.4: Create Protected Apps List View (Optional)
**File**: `PageInstead/Features/Settings/Protection/ProtectedAppsListView.swift`
- [ ] Create new `Protection` directory under `Features/Settings/`
- [ ] Note: iOS limitation means this is informational only
- [ ] Show list of "conceptually protected" apps
- [ ] Add PageInstead + user-selected productivity apps
- [ ] Display warning that protection is system-wide
- [ ] Add educational content about iOS limitations

---

## Phase 6: Prevent Time Change

### Task 6.1: Create Time Change Monitor Service
**File**: `PageInstead/Core/Services/TimeChangeMonitor.swift`
- [ ] Create `TimeChangeMonitor` service
- [ ] Add observer for `NSSystemClockDidChangeNotification`
- [ ] Implement `detectTimeChange()` method
- [ ] Calculate time delta (actual vs. expected)
- [ ] Flag changes > 5 minutes as suspicious
- [ ] Store last known system time in UserDefaults

### Task 6.2: Implement Network Time Validation
**File**: `PageInstead/Core/Services/NetworkTimeService.swift`
- [ ] Create `NetworkTimeService` using NTP
- [ ] Use pool.ntp.org as time server
- [ ] Implement `fetchNetworkTime() async -> Date?`
- [ ] Compare system time vs. network time
- [ ] Cache network time for offline validation
- [ ] Add timeout handling (5 seconds)

### Task 6.3: Create Time Change Response Logic
**File**: `PageInstead/Core/Services/TimeChangeMonitor.swift`
- [ ] Implement `handleTimeChangeDetection()` method
- [ ] Log time change attempt with timestamp
- [ ] Show alert notification to user
- [ ] Reset all active block schedules (if enabled)
- [ ] Recalculate current quote window
- [ ] Add entry to manipulation attempts array

### Task 6.4: Update SettingsView for Time Change Prevention
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Add "Prevent Time Change" toggle
- [ ] Add description: "Detects and responds to system time changes"
- [ ] Show warning about automatic time zone updates
- [ ] Display count of detected manipulation attempts
- [ ] Add "View History" button (shows attempt log)

### Task 6.5: Create Time Manipulation History View
**File**: `PageInstead/Features/Settings/Protection/TimeManipulationHistoryView.swift`
- [ ] Create list view showing time change attempts
- [ ] Display: date, detected change (+/- hours), response taken
- [ ] Show empty state if no attempts detected
- [ ] Add "Clear History" button
- [ ] Style using Liquid Glass cards

---

## Phase 7: UI Polish & Integration

### Task 7.1: Create Settings Sections Organization
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Organize settings into collapsible sections
- [ ] Section 1: "Lock Settings" (Timer + Passcode)
- [ ] Section 2: "Emergency Access" (Emergency Unlock)
- [ ] Section 3: "System Protection" (App Uninstall + Time Change)
- [ ] Add section headers with icons
- [ ] Add expand/collapse animations

### Task 7.2: Add Info Sheets for Each Feature
**Files**: `PageInstead/Features/Settings/Info/*.swift`
- [ ] Create `Info` directory under `Features/Settings/`
- [ ] `TimerLockInfoSheet.swift` - Explains timer feature
- [ ] `PasscodeLockInfoSheet.swift` - Explains passcode feature
- [ ] `EmergencyUnlockInfoSheet.swift` - Explains emergency access
- [ ] `AppProtectionInfoSheet.swift` - Explains app deletion prevention
- [ ] `TimeProtectionInfoSheet.swift` - Explains time change detection
- [ ] Each sheet: purpose, how it works, limitations, tips

### Task 7.3: Implement Commitment Level Presets
**File**: `PageInstead/Features/Settings/SettingsView.swift`
- [ ] Add "Quick Setup" section at top
- [ ] Preset 1: "Light" - Timer 10s only
- [ ] Preset 2: "Moderate" - Timer 30s + Passcode
- [ ] Preset 3: "Strict" - Timer 60s + Passcode + All protections
- [ ] Show dialog explaining preset before applying
- [ ] One-tap apply all settings in preset

### Task 7.4: Add Settings Statistics Dashboard
**File**: `PageInstead/Features/Settings/Components/SettingsStatsCard.swift`
- [ ] Create dashboard card showing restriction stats
- [ ] Stat 1: Days with restrictions enabled
- [ ] Stat 2: Settings access attempts (with timer)
- [ ] Stat 3: Passcode failures
- [ ] Stat 4: Emergency unlocks used
- [ ] Display as circular progress rings (reuse CircularProgressRing)

### Task 7.5: Implement Haptic Feedback
**File**: `PageInstead/Core/Utilities/HapticManager.swift`
- [ ] Create `HapticManager` utility
- [ ] Add haptic for toggle switch changes
- [ ] Add haptic for timer completion
- [ ] Add haptic for passcode entry (light tap)
- [ ] Add haptic for passcode error (heavy thud)
- [ ] Add haptic for successful authentication (success pattern)

---

## Phase 8: Testing & Edge Cases

### Task 8.1: Add Simulator Bypass for Testing
**Files**: Various
- [ ] Add `#if targetEnvironment(simulator)` bypasses
- [ ] Passcode: Allow "0000" as bypass in simulator
- [ ] Biometrics: Auto-succeed in simulator
- [ ] StoreKit: Use sandbox purchases in simulator
- [ ] Time validation: Disable network check in simulator

### Task 8.2: Handle Screen Time Permission Denial
**File**: `PageInstead/Core/Services/SelfRestrictionManager.swift`
- [ ] Check Screen Time authorization before enabling features
- [ ] Show alert if permission denied
- [ ] Provide deep link to Settings app
- [ ] Disable system-level features if no permission
- [ ] Keep app-level features (timer, passcode) working

### Task 8.3: Handle Keychain Access Errors
**File**: `PageInstead/Core/Utilities/KeychainHelper.swift`
- [ ] Test Keychain access with device locked
- [ ] Handle `errSecInteractionNotAllowed` error
- [ ] Fallback to UserDefaults with warning (insecure)
- [ ] Show alert if Keychain unavailable
- [ ] Add retry logic for transient errors

### Task 8.4: Test Purchase Edge Cases
**File**: `PageInstead/Core/Services/StoreKitManager.swift`
- [ ] Test purchase during flight mode
- [ ] Test purchase cancellation
- [ ] Test purchase with insufficient funds
- [ ] Test restore purchases with no previous purchases
- [ ] Test receipt validation failure

### Task 8.5: Test Time Change Scenarios
**File**: `PageInstead/Core/Services/TimeChangeMonitor.swift`
- [ ] Test legitimate time zone change (travel)
- [ ] Test daylight saving time transitions
- [ ] Test manual time change (forward/backward)
- [ ] Test airplane mode (no network time available)
- [ ] Test device restart (time continuity)

---

## Phase 9: Documentation & User Education

### Task 9.1: Add Feature Onboarding Flow
**File**: `PageInstead/Features/Settings/Onboarding/SelfRestrictionOnboardingView.swift`
- [ ] Create onboarding carousel (3-4 screens)
- [ ] Screen 1: "Protect Your Progress" - Overview
- [ ] Screen 2: "Lock Your Settings" - Timer & Passcode
- [ ] Screen 3: "Emergency Access" - Escape hatch
- [ ] Screen 4: "System Protection" - Advanced features
- [ ] Show only on first Settings view access

### Task 9.2: Create In-App Help Documentation
**File**: `PageInstead/Features/Settings/Help/SelfRestrictionHelpView.swift`
- [ ] Create help screen with FAQs
- [ ] Q: "What if I forget my passcode?"
- [ ] Q: "Can I disable restrictions temporarily?"
- [ ] Q: "What happens if I delete the app?"
- [ ] Q: "Are my settings backed up?"
- [ ] Add "Contact Support" button (email link)

### Task 9.3: Update README with New Features
**File**: `README.md`
- [ ] Add "Self-Restriction Features" section
- [ ] Document each feature with screenshot
- [ ] Explain iOS limitations clearly
- [ ] Add setup instructions
- [ ] Add troubleshooting section

### Task 9.4: Update CLAUDE.md with Implementation Notes
**File**: `CLAUDE.md`
- [ ] Add file locations for new components
- [ ] Document Keychain service identifier
- [ ] Document UserDefaults keys used
- [ ] Add common issues and solutions
- [ ] Document StoreKit product IDs

---

## Phase 10: Analytics & Monitoring

### Task 10.1: Add Analytics Events
**File**: `PageInstead/Core/Services/AnalyticsService.swift`
- [ ] Create `AnalyticsService` (local only, no third-party)
- [ ] Track: `settings_timer_enabled`, `settings_passcode_enabled`
- [ ] Track: `emergency_unlock_purchased`, `emergency_unlock_used`
- [ ] Track: `time_manipulation_detected`
- [ ] Track: `passcode_failed_attempts`
- [ ] Store analytics in UserDefaults (privacy-first)

### Task 10.2: Create Analytics Dashboard for User
**File**: `PageInstead/Features/Settings/Analytics/SelfRestrictionAnalyticsView.swift`
- [ ] Show user their own restriction usage stats
- [ ] Chart: Timer lock usage over time
- [ ] Chart: Passcode success/failure rate
- [ ] Chart: Settings access frequency
- [ ] Insight: "You've maintained restrictions for X days"
- [ ] Style with Liquid Glass design

### Task 10.3: Implement Streak Tracking
**File**: `PageInstead/Core/Services/StreakManager.swift`
- [ ] Track consecutive days with restrictions enabled
- [ ] Reset streak if all restrictions disabled
- [ ] Award badges at milestones (7, 30, 90, 365 days)
- [ ] Show current streak on Settings screen
- [ ] Add celebration animation for milestones

---

## Testing Checklist

### Manual Testing Requirements
- [ ] Test on physical iPhone (iOS 16+)
- [ ] Test all features with Screen Time permission granted
- [ ] Test all features with Screen Time permission denied
- [ ] Test passcode flow (create, verify, change, forgot)
- [ ] Test biometric flow (Face ID / Touch ID)
- [ ] Test emergency unlock purchase flow
- [ ] Test timer countdown in various scenarios
- [ ] Test time change detection
- [ ] Test app uninstall prevention
- [ ] Test all UI transitions and animations
- [ ] Test simulator bypass code paths
- [ ] Test with VoiceOver (accessibility)
- [ ] Test with large text sizes (accessibility)
- [ ] Test with reduced motion (accessibility)

### Edge Cases to Test
- [ ] What happens if user force quits during timer?
- [ ] What happens if user changes device time during timer?
- [ ] What happens if Keychain is locked?
- [ ] What happens if StoreKit is unavailable?
- [ ] What happens if network is offline?
- [ ] What happens if user has existing Screen Time restrictions?
- [ ] What happens during iOS version upgrade?

---

## Files to Create (Summary)

### Models
- `PageInstead/Core/Models/SelfRestrictionSettings.swift`

### Services
- `PageInstead/Core/Services/SelfRestrictionManager.swift`
- `PageInstead/Core/Services/BiometricAuthService.swift`
- `PageInstead/Core/Services/StoreKitManager.swift`
- `PageInstead/Core/Services/TimeChangeMonitor.swift`
- `PageInstead/Core/Services/NetworkTimeService.swift`
- `PageInstead/Core/Services/AnalyticsService.swift`
- `PageInstead/Core/Services/StreakManager.swift`

### Utilities
- `PageInstead/Core/Utilities/KeychainHelper.swift`
- `PageInstead/Core/Utilities/PasscodeHasher.swift`
- `PageInstead/Core/Utilities/HapticManager.swift`

### Views - Main Settings
- `PageInstead/Features/Settings/SettingsView.swift` (update existing)

### Views - Components
- `PageInstead/Features/Settings/Components/TimerLockOverlay.swift`
- `PageInstead/Features/Settings/Components/SettingsStatsCard.swift`

### Views - Passcode
- `PageInstead/Features/Settings/Passcode/PasscodeEntryView.swift`
- `PageInstead/Features/Settings/Passcode/PasscodeSetupView.swift`
- `PageInstead/Features/Settings/Passcode/PasscodeChangeView.swift`

### Views - Emergency
- `PageInstead/Features/Settings/Emergency/EmergencyUnlockView.swift`

### Views - Protection
- `PageInstead/Features/Settings/Protection/ProtectedAppsListView.swift`
- `PageInstead/Features/Settings/Protection/TimeManipulationHistoryView.swift`

### Views - Info Sheets
- `PageInstead/Features/Settings/Info/TimerLockInfoSheet.swift`
- `PageInstead/Features/Settings/Info/PasscodeLockInfoSheet.swift`
- `PageInstead/Features/Settings/Info/EmergencyUnlockInfoSheet.swift`
- `PageInstead/Features/Settings/Info/AppProtectionInfoSheet.swift`
- `PageInstead/Features/Settings/Info/TimeProtectionInfoSheet.swift`

### Views - Onboarding
- `PageInstead/Features/Settings/Onboarding/SelfRestrictionOnboardingView.swift`

### Views - Help
- `PageInstead/Features/Settings/Help/SelfRestrictionHelpView.swift`

### Views - Analytics
- `PageInstead/Features/Settings/Analytics/SelfRestrictionAnalyticsView.swift`

---

## Estimated Time

- **Phase 1** (Infrastructure): 4-6 hours
- **Phase 2** (Timer Lock): 3-4 hours
- **Phase 3** (Passcode): 6-8 hours
- **Phase 4** (Emergency Unlock): 4-6 hours (+ App Store setup)
- **Phase 5** (App Uninstall): 2-3 hours
- **Phase 6** (Time Change): 4-5 hours
- **Phase 7** (UI Polish): 6-8 hours
- **Phase 8** (Testing): 4-6 hours
- **Phase 9** (Documentation): 2-3 hours
- **Phase 10** (Analytics): 3-4 hours

**Total Estimated Time**: 38-53 hours

---

## Dependencies & Prerequisites

### External Services Required
- Apple Developer Account (for StoreKit)
- App Store Connect access (for IAP setup)
- NTP server access (for network time)

### iOS Frameworks to Add
- LocalAuthentication.framework
- Security.framework (Keychain)
- StoreKit.framework

### Existing Code Dependencies
- ScreenTimeService (already exists)
- QuoteScheduler (for random quotes in timer overlay)
- AnimatedGradientBackground (for consistent styling)
- Liquid Glass design system components

---

## Risk Assessment

### High Risk Items
1. **StoreKit Integration** - Complex, requires App Store review
2. **Keychain Security** - Must handle edge cases properly
3. **Screen Time API Limitations** - May not support all desired features

### Medium Risk Items
1. **Network Time Validation** - May fail in poor connectivity
2. **Biometric Authentication** - Device-specific behavior
3. **Timer Persistence** - Must survive app backgrounding

### Low Risk Items
1. **UI Components** - Straightforward with existing design system
2. **UserDefaults Storage** - Well-understood, low complexity
3. **Analytics Tracking** - Local only, simple implementation

---

## Success Criteria

### Feature Completeness
- [ ] All 5 core features implemented and working
- [ ] All UI components match Liquid Glass design system
- [ ] All edge cases handled gracefully
- [ ] All accessibility features working

### Quality Standards
- [ ] No crashes on physical device
- [ ] No security vulnerabilities in passcode handling
- [ ] Smooth animations (60 fps)
- [ ] Clear, helpful error messages

### User Experience
- [ ] Features effectively prevent impulsive disabling
- [ ] Emergency escape hatch always available
- [ ] Onboarding clearly explains each feature
- [ ] Settings organization is intuitive

---

## Next Steps

1. **Review this task list** - Confirm scope and priorities
2. **Adjust phases if needed** - Reorder based on importance
3. **Begin Phase 1** - Create core infrastructure
4. **Iterate incrementally** - Build and test each phase separately

Ready to proceed with implementation? Let me know which phase you'd like to start with!