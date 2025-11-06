# Claude Code Instructions - PageInstead Swift

## Critical Rules

### Imports & Types
- **ALWAYS import ManagedSettings** for ApplicationToken/WebDomainToken (NOT FamilyControls)
- Token<T> is already Codable - no Data conversion needed
- Use `store.shield.webDomains` NOT `webDomainCategories`

### Entitlements
- **ShieldConfiguration**: ONLY `app-groups`
- **DeviceActivityMonitor**: `app-groups` + `family-controls` ONLY
- Extra entitlements break provisioning on device

### Bundle IDs & App Groups
- Main: `com.joakimachren.PageInstead`
- Extension: `com.joakimachren.PageInstead.ShieldConfiguration`
- App Group: `group.com.pageinstead`

### Shield System
- **NO unlock buttons in shields** - callbacks don't work on device
- Shield extensions are READ-ONLY
- Unlock via UnlockManager in main app (30s window)

### Unlock Streak
- Pause timer expiry **BREAKS streak** (same as manual unlock)
- Both hooks required:
  - UnlockAppsView.swift:121 (manual unlock)
  - UnlockMonitorService.swift:183, 223 (pause expiry)
- DeviceActivityMonitor: Daily check at midnight
- Fallback: CurrentQuoteView checks on appear
- **StreakService MUST be in DeviceActivityMonitor target**

### Unlock Reminder Notifications
- **1-hour reminder** scheduled after any unlock event (manual or pause timer)
- **Just-in-time permission**: Requested on first unlock, not during onboarding
- Message: "You left your apps unblocked. Come back and block them again."
- Integration points:
  - UnlockAppsView.swift:124 (manual unlock via UnlockManager)
  - UnlockMonitorService.swift:186, 229 (pause timer expiry)
- Uses App Groups to track permission request state
- Notification cancelled/replaced if user unlocks again before 1 hour

## Time-Based Quote System

### QuoteScheduler
- **Algorithm**: `(windowIndex + (dayOfYear × 37)) % totalQuotes`
- **DO NOT** modify day-of-year offset or coprime 37
- No IPC - both app and extension calculate independently
- Auto-refresh: Use `.onReceive(Timer.publish())` NOT `Timer.scheduledTimer`

### Quote Formatting
- Check existing quotes before adding: `"`, `"`, `"`
- Lowercase first letter → add "..." prefix
- Book descriptions start with "Book about"
- Amazon links MUST use `www` subdomain

### Quote Formatting (Runtime)
- Pattern location: QuoteHistoryView.swift, QuoteDetailSheet.swift, BooksView.swift
- Checks Unicode quotes: `\u{201C}`, `\u{201D}` + regular `"`
- Lowercase first char → add "..." prefix
- Add double quotes if missing

## Health Score System

- Tracks blocked attempts (not screen time - API limitation)
- Formula: `100 - ((attempts / baseline) * 100)` clamped 0-100
- 3-day calibration, default score 75%
- Shield Extension increments real-time, DeviceActivityMonitor reconciles daily
- Storage: `group.com.pageinstead` UserDefaults

## App Groups

### Model (Codable)
- Stores `applicationTokens`/`webDomainTokens` directly
- **DO NOT** make FamilyActivitySelection Codable
- Computed `selection` property for UI binding only

### Rules Per Group
- Pause timer, daily limit, schedule, block mode
- Apps in ONE group only (conflict detection)
- Timestamp-based pause (not live countdown - Shield is stateless)

### DeviceActivityMonitor
- Daily reset at midnight (`intervalDidEnd`)
- Streak calculation: yesterday=increment, today=unchanged, missed=reset
- Keys: `usage_{groupID}_{token}_{date}`, `pause_{groupID}_{token}`

## Design System

### Glass Card Standards
- Border: `Color.white.opacity(0.2), lineWidth: 1` (ALWAYS)
- Background: White 0.08 + blur 0.33
- Corner radius: 24 (standard), 20 (compact)
- Shadow: `color: .black.opacity(0.3), radius: 20, y: 10`

### Glass Card Components
- Use `GlassCard(standard:)`, `GlassCard(compact:)`, `GlassCard(small:)` instead of manual styling
- Components auto-apply: White 0.08 + blur 0.33, border 0.2, shadow (0.3, 20, y:10)
- **DO NOT** mix manual `.background()` styling with GlassCard components

### Typography Hierarchy
- Screen titles: 48pt bold, white 100%
- Section titles: 20pt medium, white 70%
- Primary text: 100% → Secondary 85% → Tertiary 70% → Subtle 65%
- **Minimum**: 12pt (never go below)
- Line spacing: 8pt (large text), 4pt (medium text)

### Meter Display
- Health Score: Shows percentage (75% default during calibration)
- Unlock Streak: Shows day count ("X days") with dynamic sizing:
  - 1-99 days: 28pt
  - 100-999 days: 24pt
  - 1000+ days: 20pt (scales down further)

### Scrollable Headers
- Headers scroll inside ScrollView (not fixed overlay)
- Exception: Lock button on CurrentQuoteView stays fixed
- Top spacing: 20pt
- Bottom spacing: `Spacer(minLength: 120)` for tab bar

### Native TabView (iOS 18+)
- **MUST use `.ignoresSafeArea()` on ALL tab backgrounds**
- NO modifiers: `.tabViewStyle()`, `.tabBarBackground()`, `.accentColor()`
- Liquid glass automatic on iOS 18+ with correct setup

### Conditional UI Elements
- Quote counter (BooksView): Only show `if total > 1`
- Pattern: Wrap optional UI in conditional, not opacity/hidden tricks

## Sheet Patterns
- **ALWAYS use `.sheet(item:)` NOT `.sheet(isPresented:)`**
- Prevents blank screen on first tap
- Model must conform to Identifiable

## Self-Restriction

### Timer Lock
- Triggers when user taps lock button or Settings tab (NOT on app launch)
- Locks all tabs except Current Quote (tab 0)
- Simulator: bypassed automatically
- **Timer completion navigation**:
  - **ALWAYS** add `onTimerComplete` callback to `TimerLockSheet`
  - **MUST** include 0.3s delay before navigation (`DispatchQueue.main.asyncAfter`)
  - Pattern:
    ```swift
    onTimerComplete: {
        if restrictionManager.isNavigationLockedByPasscode() {
            showPasscodeEntry = true
        } else {
            // Navigate to destination
        }
    }
    ```
  - Both lock button (CurrentQuoteView) and Settings tab (ContentView) need separate implementations
  - Location: `PageInstead/Core/DesignSystem/Components/TimerLockSheet.swift`

### Passcode Lock
- **4 digits** (not 6) - `maxLength = 4`
- Keychain storage: SHA-256 + salt
- Session-based (resets on background)
- Simulator bypass: "0000"

## Onboarding

### Trigger
- Auto-shows when `OnboardingData.shared.isOnboardingCompleted == false`
- Set in ContentView.swift:11 - `@State private var showOnboarding = !OnboardingData.shared.isOnboardingCompleted`

### Screen 6 (Categories)
- No ScrollView - uses VStack for natural layout
- Text: "Pick at least three" (not "up to")
- No hint text after 3+ selections

### Screen 7 (Permissions)
- **SwiftUI mockup** of iOS permission dialog (not PNG)
- Animated arrow below Continue button (HStack with 77pt offset)
- Arrow: 32pt ↑, white 0.8 opacity, 2s bounce animation

### Screen 8 (App Selection)
- **Mandatory selection** - no skip button
- Primary button: "Select Apps" → "Continue" (when apps selected)
- Secondary button: "Change Apps" (only shown after selection)

### Button Tap Areas
- `.contentShape(Rectangle())` position: AFTER `.cornerRadius()`, BEFORE `.shadow()` and `.overlay()`
- Wrong: `.cornerRadius(16).shadow(...).contentShape(Rectangle())`
- Correct: `.cornerRadius(16).contentShape(Rectangle()).shadow(...)`

### Other
- Confetti: Use immutable particles + boolean animate state
- Screen 11: Use scene phase detection (`.onChange(of: scenePhase)`)
- **ALWAYS include `bookDescription: nil`** in preview BookQuote inits

## Common Issues

### Build & Setup
- **Import errors**: Add `import ManagedSettings` for tokens
- **Provisioning**: Check entitlements match requirements
- **Screen Time simulator**: Use `#if targetEnvironment(simulator)` bypass
- **StreakService not found in monitor**: Add StreakService.swift to DeviceActivityMonitor target
- **Authorization screen shows**: App goes directly to main interface (no auth screen)

### Glass UI
- **Borders inconsistent**: Use 0.2 opacity (not 0.08 or gradient)
- **Buttons not tappable**: Add `.allowsHitTesting(false)` to overlays
- **Text invisible**: Use blue text on glass buttons (not white)
- **Font too small**: Never below 12pt - use opacity hierarchy

### Layout
- **Headers not scrolling**: Move VStack inside ScrollView, use 20pt spacing
- **Content behind tab bar**: Add `Spacer(minLength: 120)` at ScrollView end
- **Text wrapping**: Add `.lineLimit(1)` + `.fixedSize(horizontal: true, vertical: false)`
- **Tab bar not transparent**: Missing `.ignoresSafeArea()` on backgrounds
- **CategorySelectionView pattern**: Everything in single ScrollView with bottom padding (140pt). DON'T use overlapping ZStack layers or safeAreaInset

### Data & State
- **Bookmarks not syncing**: Call `checkBookmarkStatus()` on init/quote change
- **Sheets blank on first tap**: Use `.sheet(item:)` not `.sheet(isPresented:)`
- **Streak not incrementing**: Check DeviceActivityMonitor fired at midnight, verify StreakService in monitor target
- **Pause doesn't break streak**: Missing hook in UnlockMonitorService (lines 183, 223)
- **Groups not persisting**: Check App Group entitlements
- **Streaks not updating**: Only DeviceActivityMonitor updates at midnight

### Quotes & Animation
- **Quote not refreshing**: Add `.id(quote.id)` to Text view and `objectWillChange.send()` before updating @Published quote property
- **Animation plays but content same**: SwiftUI doesn't detect @Published changes in async blocks - use explicit `.id()` modifier

### Quotes & Shields
- **Same quote daily**: Check `dailyOffset = (dayOfYear * 37) % count`
- **Shield buttons don't work**: Expected - use main app unlock
- **Daily counter grows**: DeviceActivityMonitor must reset at midnight
- **History rows not tappable**: WindowRow needs Button + onTap closure

### Health Score
- **Stuck at 75%**: In 3-day calibration period
- **Not counting**: Shield Extension must increment in `configuration(shielding:)`
- **Not updating**: Check install_date >24h, verify calibration complete

## Build Commands

```bash
# Device build
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
  -destination 'platform=iOS,id=DEVICE_ID' -allowProvisioningUpdates build

# Install
xcrun devicectl device install app --device DEVICE_ID \
  /Users/joakimachren/Library/Developer/Xcode/DerivedData/PageInstead-*/Build/Products/Debug-iphoneos/PageInstead.app
```

## Key Files

```
Core:
- PageInstead/Core/Services/ScreenTimeService.swift
- PageInstead/Core/Services/QuoteScheduler.swift
- PageInstead/Core/Services/AppGroupManager.swift
- PageInstead/Core/Services/HealthScoreService.swift
- PageInstead/Core/Services/UnlockReminderService.swift

Metrics:
- PageInstead/Core/Services/StreakService.swift
- PageInstead/Features/HealthScoreDetailSheet.swift
- PageInstead/Features/StreakDetailSheet.swift

Views:
- PageInstead/Features/CurrentQuoteView.swift
- PageInstead/Features/BooksView.swift
- PageInstead/Features/History/QuoteHistoryView.swift
- PageInstead/Features/History/QuoteDetailSheet.swift
- PageInstead/Features/Settings/SettingsView.swift
- PageInstead/Features/AppGroups/AppGroupsListView.swift

Onboarding:
- PageInstead/Features/Onboarding/OnboardingCoordinator.swift
- PageInstead/Features/Onboarding/OnboardingData.swift
- PageInstead/Features/Onboarding/Screens/OnboardingScreen1_Hero.swift (emoji spacing: ±60)
- PageInstead/Features/Onboarding/Screens/OnboardingScreen6_BookCategories.swift (no scroll)
- PageInstead/Features/Onboarding/Screens/OnboardingScreen7_Permissions.swift (SwiftUI dialog)
- PageInstead/Features/Onboarding/Screens/OnboardingScreen8_AppSelection.swift (mandatory)
- PageInstead/Features/Onboarding/Components/OnboardingButtonStyles.swift (contentShape fix)

Extensions:
- ShieldConfiguration/ShieldConfigurationExtension.swift
- DeviceActivityMonitor/DeviceActivityMonitorExtension.swift

Design:
- PageInstead/Core/DesignSystem/LiquidGlassStyles.swift
- PageInstead/Core/DesignSystem/Components/GlassCard.swift

Data:
- PageInstead/Resources/quotes.json
```
