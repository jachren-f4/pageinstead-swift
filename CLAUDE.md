# Claude Code Instructions - PageInstead Swift

## Critical Implementation Rules

### Token Types (ManagedSettings)
- **ALWAYS import ManagedSettings** when using ApplicationToken/WebDomainToken
- Types are `ManagedSettings.Token<Application>` and `ManagedSettings.Token<WebDomain>`
- **NOT in FamilyControls** - common mistake that causes "cannot find type" errors
- Token<T> is already Codable - encode/decode directly, no Data conversion needed
- Files using tokens: `AppGroup.swift`, `AppGroupManager.swift`

### Extension Entitlements
- **ShieldConfiguration**: ONLY `app-groups` (no family-controls, no device-activity)
- **DeviceActivityMonitor**: `app-groups` + `family-controls` ONLY
- Adding extra entitlements breaks provisioning profiles on device builds
- Files: `ShieldConfiguration/ShieldConfiguration.entitlements`, `DeviceActivityMonitor/DeviceActivityMonitor.entitlements`

### ScreenTimeService
- **ALWAYS** use `store.shield.webDomains` (NOT `webDomainCategories`)
  - Line 49 in ScreenTimeService.swift was incorrect, caused type mismatch
  - `webDomains` expects `Set<WebDomainToken>`
  - `webDomainCategories` expects `Set<ActivityCategoryToken>` (wrong type)

### Bundle Identifiers
- Main app: `com.joakimachren.PageInstead`
- Shield Configuration Extension: `com.joakimachren.PageInstead.ShieldConfiguration`
- Must use personal team ID prefix (not generic `com.pageinstead.*`)

### App Groups Configuration
- Suite name: `group.com.pageinstead`
- Required in Shield Configuration Extension entitlements
- Used for shared quote data storage

### Shield Unlock System
- **NEVER add unlock buttons to shields** - ShieldAction callbacks don't work reliably on physical devices
- **Unlock MUST happen in main app** - Use UnlockManager.shared to remove shields
- **Shield extensions are READ-ONLY** - Display quotes only, no user interaction
- **30-second unlock window** - Prevents abuse, shields auto-reapply after timeout

### Sheet Presentation Pattern
- **ALWAYS use** `.sheet(item:)` for quote detail views, NOT `.sheet(isPresented:)`
- Prevents blank screen on first tap (state sync issue)
- Requires model to conform to `Identifiable`
- BookQuote already conforms via `id: Int` property

### Book Descriptions
- **ALWAYS start with "Book about"** - All 295 quotes standardized (quotes.json)
- Format: "Book about [lowercase description]" (unless proper noun)
- Used in: CurrentQuoteView, BooksView, QuoteHistoryView

### Scroll Fade Overlay
- **MUST use `.ignoresSafeArea(edges: .top)`** on gradient overlay
- Without this, content bleeds through Y=0 gap above safe area
- File: `PageInstead/Core/DesignSystem/Components/ScrollFadeOverlay.swift`

## File Locations

```
Main App:
- Entry: PageInstead/App/PageInsteadApp.swift
- Screen Time service: PageInstead/Core/Services/ScreenTimeService.swift

App Groups System:
- Model: PageInstead/Core/Models/AppGroup.swift
- Manager: PageInstead/Core/Services/AppGroupManager.swift
- Main list: PageInstead/Features/AppGroups/AppGroupsListView.swift
- Rules editor: PageInstead/Features/AppGroups/AppGroupRulesView.swift
- Components: PageInstead/Features/AppGroups/Components/

Quote System:
- QuoteScheduler: PageInstead/Core/Services/QuoteScheduler.swift
- CurrentQuoteView: PageInstead/Features/CurrentQuoteView.swift (includes bookmark system)
- Quote data: PageInstead/Resources/quotes.json (includes bookDescription field)
- History (time-based): PageInstead/Features/History/QuoteHistoryView.swift
- Quote detail sheet: PageInstead/Features/History/QuoteHistoryView.swift (QuoteDetailSheet component)
- Affiliate service: PageInstead/Core/Services/AffiliateService.swift

Books Screen:
- Main view: PageInstead/Features/BooksView.swift
- Uses existing bookmark system (CurrentQuoteView bookmark button)
- Storage: UserDefaults key `"bookmarked_quotes"` (Set<Int>)

Design System (iOS 26 Liquid Glass):
- Glass card component: PageInstead/Core/DesignSystem/Components/GlassCard.swift
- Progress rings: PageInstead/Core/DesignSystem/Components/CircularProgressRing.swift
- Background gradient: PageInstead/Core/DesignSystem/Components/AnimatedGradientBackground.swift
- Liquid Glass tab bar: PageInstead/Core/DesignSystem/Components/LiquidGlassTabBar.swift
- Liquid Glass styles: PageInstead/Core/DesignSystem/LiquidGlassStyles.swift
- Color system: PageInstead/Core/DesignSystem/Colors.swift
- Implementation guide: GLASS_UI_IMPLEMENTATION.md

Shield Configuration Extension:
- Shield UI: ShieldConfiguration/ShieldConfigurationExtension.swift
- Quote data: ShieldConfiguration/QuoteData.swift
- Quote service: ShieldConfiguration/QuoteService.swift

Self-Restriction Features:
- Manager: PageInstead/Core/Services/SelfRestrictionManager.swift
- Settings model: PageInstead/Core/Models/SelfRestrictionSettings.swift
- Keychain: PageInstead/Core/Utilities/KeychainHelper.swift
- Passcode hasher: PageInstead/Core/Utilities/PasscodeHasher.swift
- Biometric auth: PageInstead/Core/Services/BiometricAuthService.swift
- Settings UI: PageInstead/Features/Settings/SettingsView.swift
- Timer overlay: PageInstead/Features/Settings/Components/TimerLockOverlay.swift
- Passcode views: PageInstead/Features/Settings/Passcode/*.swift

Health Score System:
- Service: PageInstead/Core/Services/HealthScoreService.swift
- Displayed on: CurrentQuoteView (replaces Focus Time), SettingsView
- Shield counter: ShieldConfiguration/ShieldConfigurationExtension.swift
- Daily reconciliation: DeviceActivityMonitor/DeviceActivityMonitorExtension.swift

Unlock System:
- Lock button component: PageInstead/Core/DesignSystem/Components/LockButton.swift
- Unlock screen: PageInstead/Features/UnlockScreen.swift
- Unlock manager: UnlockManager singleton in UnlockAppsView.swift
- Integration: CurrentQuoteView displays lock button in top-right corner

Onboarding System:
- State manager: PageInstead/Features/Onboarding/OnboardingData.swift
- Navigation: PageInstead/Features/Onboarding/OnboardingCoordinator.swift
- Components: PageInstead/Features/Onboarding/Components/{OnboardingButtonStyles, OnboardingOptionButton, OnboardingCategoryChip, OnboardingConfetti}.swift
- Screens: PageInstead/Features/Onboarding/Screens/OnboardingScreen{1-11}_*.swift
- Integration: ContentView shows onboarding if `!OnboardingData.shared.hasCompletedOnboarding`
- Dev reset: SettingsView → Development section
```

## Xcode Project Manipulation

- Use Ruby + xcodeproj gem to modify PageInstead.xcodeproj
- File paths in project must match physical group hierarchy (no duplication)
- Example: File in `App/` group should have path `PageInsteadApp.swift` (not `App/PageInsteadApp.swift`)

## Build Commands

```bash
# Build and install to device
cd pageinstead-swift
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
  -destination 'platform=iOS,id=DEVICE_ID' \
  -allowProvisioningUpdates build

# Install built app
xcrun devicectl device install app --device DEVICE_ID \
  /Users/joakimachren/Library/Developer/Xcode/DerivedData/PageInstead-*/Build/Products/Debug-iphoneos/PageInstead.app
```

## Testing Shield Extension

1. Build and install app
2. Grant Screen Time permission in app
3. Select apps to block
4. Try opening blocked app → Should show quote shield

## Time-Based Quote System

### QuoteScheduler - CRITICAL Rules
- **NO IPC**: Shield Extension and main app NEVER communicate about quotes
- Both calculate current quote independently using: `QuoteScheduler.shared.getCurrentQuote()`
- **Algorithm**: `quoteIndex = (windowIndex + (dayOfYear × 37)) % totalQuotes`
- **DO NOT** remove or modify day-of-year offset - prevents daily repetition
- **DO NOT** change coprime multiplier (37) without math verification
- **quotes.json order matters**: Must remain shuffled (same-book quotes spread apart)
- Shield Extension uses `QuoteScheduler.shared` - inherits all changes automatically
- File: `PageInstead/Core/Services/QuoteScheduler.swift`

### CurrentQuoteView - Auto-Refresh Implementation
- **MUST use** `.onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect())`
- **DO NOT use** `Timer.scheduledTimer` (doesn't integrate with SwiftUI lifecycle)
- Checks every 10 seconds if window changed, only refreshes if different
- File: `PageInstead/Features/CurrentQuoteView.swift`

### BookQuote Struct
- **MUST include** `coverImageURL: String?` parameter in all initializers
- **MUST include** `bookDescription: String?` field (optional for backward compatibility)
- Descriptions should be ≤10 words summarizing the book's content
- Used in: `ShieldConfiguration/QuoteData.swift`, preview code, quotes.json
- **DO NOT** omit from new quotes - include even if brief

### Book Description Display
- **Shows in:** CurrentQuoteView, QuoteHistoryView detail sheet
- **Does NOT show in:** ShieldConfigurationExtension (shield screens)
- **Format requirement:** ALL descriptions must start with "Book about"
- **Styling:**
  - Font: 12pt (smaller than author's 14pt)
  - Opacity: 65% white (author is 85%)
  - Position: Below author name with 2pt top padding
- **Layout:** VStack containing book details MUST have `.frame(maxWidth: .infinity, alignment: .leading)` to prevent premature text wrapping
- **Files:**
  - Display logic: `PageInstead/Features/CurrentQuoteView.swift` lines 114-119
  - Data: `PageInstead/Resources/quotes.json` (bookDescription field)

### Amazon Affiliate Links
- **MUST use** `www` subdomain: `https://www.amazon.com/dp/{ASIN}`
- **WRONG**: `https://amazon.com/dp/{ASIN}` (returns 404)
- File: `PageInstead/Core/Services/AffiliateService.swift` line 88

## Self-Restriction Features - CRITICAL Rules

### Lock Settings Timer
- **Timer triggers on app launch**, NOT settings access (`ContentView.onAppear`)
- Locks all tabs except Current Quote (tab 0)
- Alert shown when tapping locked tabs
- **Simulator bypass**: Timer disabled automatically
- Settings stored in UserDefaults: `isTimerLockEnabled`, `timerDuration`

### Lock Settings Passcode
- **ALWAYS 4 digits** (not 6) - `maxLength = 4` in all passcode views
- **Passcode stored in Keychain** via `KeychainHelper.shared` (service: `com.joakimachren.PageInstead.passcode`)
- **SHA-256 with random salt** - format: `"salt:hash"`
- Locks navigation on tab change, NOT settings access
- Session-based unlock: `isPasscodeUnlocked` resets on app background
- **Simulator bypass**: "0000" always works
- Settings: `isPasscodeLockEnabled` in UserDefaults

### Quote Formatting
- **Check for existing quotes** before adding: `"`, `"`, `"`
- **Lowercase first letter** = mid-sentence quote → add "..." prefix
- Applied in: `CurrentQuoteView.formattedQuoteText` AND `ShieldConfigurationExtension.formatQuoteText()`
- DO NOT use literal curly quotes in code - use Unicode: `\u{201C}` ("), `\u{201D}` (")

## Health Score System - CRITICAL Rules

### Overview
- Tracks **blocked app attempts** (not total screen time - API limitation)
- Score formula: `100 - ((attempts_today / baseline) * 100)`, clamped 0-100
- **3-day calibration period** to establish baseline
- **First 24 hours**: Default score of 75%
- Hybrid tracking: Shield Extension (real-time) + DeviceActivityMonitor (daily reconciliation)

### Counter Increment (Shield Extension)
- **Increments on every shield display** in `configuration(shielding:)` methods
- Uses App Group UserDefaults: `group.com.pageinstead`
- Key: `blocked_attempts_today`
- **Daily reset logic**: Checks if date changed, resets counter at midnight
- File: `ShieldConfiguration/ShieldConfigurationExtension.swift`

### Daily Reconciliation (DeviceActivityMonitor)
- Runs at end of 24-hour monitoring interval in `intervalDidEnd()`
- Reconciles counter in case Shield Extension was cached by iOS
- Handles calibration: adds day to calibration data if not yet complete
- Saves daily summary to history (last 180 days)
- Calculates and stores health score
- File: `DeviceActivityMonitor/DeviceActivityMonitorExtension.swift`

### Data Storage (App Group)
All data stored in `group.com.pageinstead` UserDefaults:
- `install_date`: First app launch (for 24-hour default score logic)
- `last_attempt_date`: Date of last attempt (for daily reset)
- `blocked_attempts_today`: Current day's counter (incremented by Shield)
- `baseline_attempts`: Average attempts/day from calibration (default: 15)
- `is_calibrated`: Boolean - true after 3 days
- `calibration_days_data`: Array of {date, attempts} for 3-day calibration
- `screen_health_score`: Current score (0-100)
- `daily_history`: Array for 180-day history

### UI Display
**Current Quote View** (replaces Focus Time metric):
- Large `CircularProgressRing.success()` showing health score percentage
- Auto-updates with real data from `HealthScoreService.shared`
- File: `PageInstead/Features/CurrentQuoteView.swift` line 113-126

**Settings Screen**:
- "Screen Health" section with 140pt progress ring
- Shows "Blocked Attempts Today: X / Y baseline" (after calibration)
- Shows "Calibrating... Day X of 3" (during calibration)
- Debug footer: "Blocked Attempts: 3 | Health Score: 85%"
- File: `PageInstead/Features/Settings/SettingsView.swift` line 42-92

### Critical Implementation Notes
- **DO NOT** track total screen time - FamilyControls API doesn't expose this
- **DO NOT** skip daily reset logic - causes counter to accumulate indefinitely
- **Score clamping**: ALWAYS clamp to 0-100 (never negative)
- **Shield caching**: iOS may cache shield configs - DeviceActivityMonitor ensures accuracy
- **Baseline default**: Use 15 attempts if not calibrated (reasonable for average user)

## App Groups System - CRITICAL Rules

### Overview
- Replaces single app selection with **multiple named groups**
- Each group has independent rules: pause timer, daily limit, schedule, blocking mode
- Apps can only be in **one group at a time** (conflict detection enforced)
- Shield Extension uses group lookup to apply correct rules per app
- Migration: Existing blocked apps auto-migrate to "Group #1" on first launch

### AppGroup Model (Codable)
- **Stores tokens directly**: `applicationTokens: Set<ApplicationToken>`, `webDomainTokens: Set<WebDomainToken>`
- **Computed property**: `selection: FamilyActivitySelection` for UI binding to FamilyActivityPicker
- **DO NOT** try to make FamilyActivitySelection Codable - it's not supported
- **Schedule**: `AppGroupSchedule` with `alwaysActive`, `activeDays`, `startTime`, `endTime`
- **Streak tracking**: `streakDays`, `lastUsedDate` (updated daily by DeviceActivityMonitor)

### AppGroupManager
- **Singleton service**: `AppGroupManager.shared`
- **Persistence**: App Group UserDefaults (`group.com.pageinstead`, key: `app_groups`)
- **Conflict detection**: `validateGroup()` checks for token overlap with existing groups
- **Auto-naming**: Generates "Group #1", "Group #2", etc. for new groups
- **@Published groups**: ScreenTimeService auto-applies shields when groups change

### Shield Extension Integration
- **Group lookup**: `lookupGroup(for: ApplicationToken)` finds which group an app belongs to
- **Schedule checking**: `isGroupActive()` handles overnight ranges (e.g., 22:00-06:00)
- **Pause timer**: Timestamp-based (not live countdown due to stateless Shield)
  - First shield display: saves current time to UserDefaults
  - Subsequent displays: checks if `pauseForSeconds` elapsed
  - Button shows when elapsed, otherwise grayed out
- **Daily counter**: Increments on each shield display with duplicate prevention
- **Hard block mode**: When `dailyOpenLimit` reached and `blockAfterMaxUse = true`, show no button

### DeviceActivityMonitor Integration
- **Daily reset** (`intervalDidEnd`): Clears usage keys and pause timers at midnight
- **Streak calculation**:
  - If used yesterday: increment streak
  - If used today: no change
  - If missed day: reset streak to 0
- **UserDefaults keys**:
  - `usage_{groupID}_{token}_{date}`: Daily open count
  - `pause_{groupID}_{token}`: Pause timer start time
  - `last_reset_{groupID}`: Last reset date

### ScreenTimeService Integration
- **Auto-apply shields**: Subscribes to `AppGroupManager.shared.$groups` via Combine
- **Collects all tokens**: Unions all `applicationTokens` and `webDomainTokens` from all groups
- **Single ManagedSettings store**: Applies all tokens at once
- **Deprecated methods**: Old `applyShield(to:)` marked as deprecated

### UI Components
**AppGroupsListView**:
- Main screen showing all groups as cards
- Empty state with CTA to create first group
- Tapping card opens AppGroupRulesView

**AppGroupRulesView**:
- 6 sections: Name, Apps, Pause For, Daily Limit, Schedule, Actions
- System pickers: Alert dialog for name, FamilyActivityPicker for apps, Menu for pause duration
- Schedule UI: Toggle for "Always Active", time pickers, day pills (Su-Sa)
- Conflict detection on save with alert

**AppGroupCard**:
- Shows group name (no icon), app count/icons, streak badge
- Liquid Glass design

### Simulator Support
- **FamilyActivityPicker**: Shows "SIMULATOR MODE" badge with disabled button
- **Orange warning text**: Explains device is required for full functionality
- **ScreenTimeService**: Auto-approves authorization in simulator (`#if targetEnvironment(simulator)`)
- **UI testing**: All layouts testable in simulator, only app selection requires device

### Critical Implementation Notes
- **Conflict prevention**: ALWAYS check `validateGroup()` before saving
- **Token storage**: Store tokens, not FamilyActivitySelection (not Codable)
- **Overnight schedules**: Handle `startTime > endTime` with OR logic
- **Pause timer caching**: iOS may cache Shield configs - use timestamp, not live timers
- **Daily reset**: MUST clear usage/pause keys daily to prevent accumulation
- **Streak logic**: Update only at midnight via DeviceActivityMonitor
- **Migration**: Run `AppGroupManager.shared.performMigrationIfNeeded()` in app init

## Liquid Glass Design System (iOS 26)

### Critical Rules
- **ALWAYS add `.allowsHitTesting(false)` to overlay layers** - buttons won't respond to taps without this
- **Use blue text on glass buttons** - white text is invisible on glass background
- **ONLY glass navigation/control layers** - never apply to content (quotes, book covers)
- **DO NOT stack glass layers** - causes visual clutter

### Simulator Testing
Add bypass for Screen Time in simulator:
```swift
#if targetEnvironment(simulator)
isAuthorized = true  // Auto-approve for UI testing
#endif
```
File: `PageInstead/Core/Services/ScreenTimeService.swift` lines 24-27, 40-45

### View Modifiers
```swift
.liquidGlassCard()              // Cards with .ultraThinMaterial
.liquidGlassPrimaryButton()     // Blue tint, capsule shape
.liquidGlassDestructiveButton() // Red tint for delete/remove
.liquidGlassPill()              // Small badges
```
Files: `PageInstead/Core/DesignSystem/LiquidGlassStyles.swift`, `Colors.swift`

## Scroll Fade Overlay - CRITICAL Rules

### Implementation Pattern
- **Headers MUST be outside ScrollView** - prevents bleeding/transparency issues
- **Structure**: ZStack with ScrollView + fixed header overlay
- **Top spacing required**: Add `Spacer().frame(height: X)` in ScrollView for header clearance

### Component Details
- **File**: `PageInstead/Core/DesignSystem/Components/ScrollFadeOverlay.swift`
- **Usage**: `.scrollFadeOverlay()` modifier on ScrollView
- **Gradient**: 150px height, Strong variant (6 opacity stops: 100%→100%→85%→50%→15%→0%)
- **Color**: Must match background `Color(red: 26/255, green: 0, blue: 51/255)`
- **Hit testing**: `.allowsHitTesting(false)` on overlay to pass taps through

### Views Using Fade Overlay
- CurrentQuoteView (150px header spacing)
- QuoteHistoryView (120px header spacing)
- AppGroupsListView (140px header spacing)
- SettingsView (120px header spacing)

### Common Issues
- **Header bleeding/transparency**: Header is inside ScrollView - move to fixed overlay
- **Buttons not tappable**: Missing `.allowsHitTesting(false)` on gradient layer
- **Wrong fade color**: Gradient color doesn't match background - use #1a0033

## Lock Button UI - CRITICAL Rules

### Lock Button States
- **Locked**: Red border (2px, 40% opacity) + red background (15% opacity)
- **Unlocked**: Green background (10% opacity) + green pulse animation
- **SF Symbols**: Use `lock.fill` / `lock.open.fill` (NOT emojis)
- **File**: `PageInstead/Core/DesignSystem/Components/LockButton.swift`

### Header Layout
- **Two-row structure**:
  - Row 1: Lock button (right-aligned)
  - Row 2: "Quote" title (left) + "Get this book" button (right)
- **Top padding**: 5px (NOT 60px) - keeps lock button near status bar
- **DO NOT** increase top padding - wastes vertical space

### Soft Ghost Button Style
- **When to use**: Subtle secondary actions (e.g., "Get this book", "Start Unlock Timer")
- **Style**: 3% white bg, 10% white border, 70% white text
- **Modifier**: `.liquidGlassSoftGhostButton()`
- **File**: `PageInstead/Core/DesignSystem/LiquidGlassStyles.swift`

## Bookmark System - CRITICAL Rules

### Overview
Save favorite quotes for later with persistent bookmarking via UserDefaults.

### Implementation
- **Button placement**: Left of "Get this book" button in header
- **States**: Empty bookmark (white 70%) vs. filled bookmark (gold #FFD700)
- **Animation**: Spring scale effect (1.0 → 1.2 → 1.0) on toggle
- **Storage**: `Set<Int>` of quote IDs in UserDefaults key `"bookmarked_quotes"`
- **File**: `PageInstead/Features/CurrentQuoteView.swift` lines 72-87, 351-406

### UI Layout
- **HStack spacing**: 12px between bookmark and "Get this book" buttons
- **Button size**: 44x44pt touch target
- **Background states**:
  - Bookmarked: Gold bg 15% opacity, gold border 40% opacity
  - Not bookmarked: White bg 3% opacity, white border 10% opacity

### State Management
- **Check on init**: `checkBookmarkStatus()` syncs state with current quote
- **Check on quote change**: Auto-syncs when window changes (every 5 min)
- **Persist immediately**: Save to UserDefaults on every toggle
- **Encode as JSON**: Use `JSONEncoder().encode(Set<Int>)` for storage

### Text Wrapping Prevention
- **ALWAYS use** `.lineLimit(1)` on "Get this book" button text
- **ALWAYS use** `.fixedSize(horizontal: true, vertical: false)` to prevent wrapping
- Without these, bookmark button causes text to break into multiple lines

## Onboarding System - CRITICAL Rules

### Button Tap Areas
- **ALWAYS add** `.contentShape(Rectangle())` to button modifiers
- Without this, only text is tappable, not full button frame
- Applied to: OnboardingPrimaryButton, OnboardingSecondaryButton, OnboardingCategoryChip

### Confetti Animation Pattern
- **Use immutable particle properties** + boolean `animate` state
- **DO NOT** mutate particle properties inside animation block (breaks SwiftUI tracking)
- Trigger: Set `animate = true` after 0.05s delay in `.onAppear`
- File: `PageInstead/Features/Onboarding/Components/OnboardingConfetti.swift`

### Screen 11 Shield Detection
- **Timer stops when app backgrounds** - polling doesn't work reliably
- **Use scene phase detection**: `.onChange(of: scenePhase)` to detect `.background` → `.active`
- Auto-complete onboarding when returning from background (smooth UX)
- Shield Extension writes: `appGroupDefaults.set(true, forKey: "firstShieldSeen")`

### Category Chip Selection Visibility
- Selected state MUST be highly visible: checkmark icon + gradient bg + thicker border + scale + shadow
- Background: Purple gradient at 0.7/0.6 opacity (not flat color)
- Border: 3px bright purple (#c4b5fd) when selected
- Scale: 1.02x larger when selected
- Animation: Spring effect (response: 0.3, damping: 0.7)

### BookQuote Initializers
- **ALWAYS include** `bookDescription: nil` parameter in preview code
- Common error: "missing argument for parameter 'bookDescription'"
- Applies to: ShieldEventRow.swift previews, onboarding screen previews

## Liquid Glass Tab Bar - CRITICAL Rules

### Overview
Custom bottom navigation with iOS 26 Liquid Glass design, replacing standard TabView.

### Advanced Features
- **5-layer shadow system**: Inner glow → ambient shadow for realistic depth
- **Adaptive blur**: Changes from `.ultraThin` (rest) to `.regular` (scrolling)
- **Parallax motion**: CoreMotion device tilt effects (physical device only)
- **Accessibility**: Respects Reduce Transparency and Reduce Motion settings

### Implementation
- **Component**: `PageInstead/Core/DesignSystem/Components/LiquidGlassTabBar.swift`
- **Container**: `LiquidGlassTabContainer` replaces `TabView` in `ContentView.swift`
- **Motion manager**: Singleton `MotionManager` handles CoreMotion (60 FPS updates)
- **Environment keys**: `IsScrollingKey` for adaptive blur state

### Shadow Layers (Top to Bottom)
```swift
.shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)   // Inner glow
.shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: -1)     // Sharp close
.shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: -2)     // Mid-range
.shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: -3)    // Soft distant
.shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)    // Ambient
```

### Critical Notes
- **Physical device required**: Parallax motion only works on real iPhone (uses accelerometer)
- **Simulator**: Parallax disabled, shows static tab bar
- **Content spacing**: Add 120pt bottom spacing to ScrollViews for tab bar clearance
- **DO NOT** modify shadow values without testing on device - GPU rendering differs

## Common Issues

- **File not found errors**: Check Xcode project file references match physical paths
- **Provisioning errors**: Bundle IDs must use `com.joakimachren.*` prefix
- **Extension not showing**: Verify App Groups entitlements in Shield target
- **Type mismatch**: Use `webDomains` property, not `webDomainCategories`
- **Auto-refresh not working**: Use `.onReceive` with `Timer.publish()`, not `Timer.scheduledTimer`
- **Affiliate links 404**: Amazon URLs require `www` subdomain
- **BookQuote init error**: Add `coverImageURL: nil` parameter to all BookQuote initializers
- **Xcode project file paths**: Files in groups with a `path` property should have paths relative to that group (e.g., files in `Core` group with `path=Core` should use `DesignSystem/File.swift`, not `Core/DesignSystem/File.swift`)
- **Buttons not tappable**: Add `.allowsHitTesting(false)` to overlay layers in Liquid Glass modifiers
- **Button text invisible**: Use `.foregroundColor(.blue)` not `.white` on glass buttons
- **Screen Time in simulator**: Add `#if targetEnvironment(simulator)` bypass for UI testing
- **Same quote every day**: Check QuoteScheduler has `dailyOffset = (dayOfYear * 37) % count`
- **Glass cards too transparent/opaque**: White 0.08, Blur 0.33 - DO NOT change without testing on physical device
- **White flashing on glass cards**: NEVER use `.shimmerEffect()` on GlassCard components
- **CircularProgressRing compilation error**: `showPercentage` parameter MUST come before `size`
- **Glass looks different on simulator**: Always test on iPhone - simulator GPU renders opacity differently than hardware
- **Health score not updating**: Check install_date in UserDefaults - must be >24h for real scoring
- **Blocked attempts not counting**: Verify Shield Extension increments counter in `incrementBlockedAttempts()`
- **Calibration stuck**: DeviceActivityMonitor must call `intervalDidEnd()` daily - check monitoring is active
- **"cannot find type 'ApplicationToken'" error**: Add `import ManagedSettings` - tokens are in ManagedSettings, not FamilyControls
- **Extension provisioning profile error**: Check entitlements files - only add minimum required capabilities (see Extension Entitlements section)
- **App Groups conflict error**: App already in another group - remove from old group first
- **FamilyActivityPicker not showing**: Requires physical device, use simulator mode for UI testing
- **Pause timer not working**: Shield Extension is stateless - uses timestamps, not live countdown
- **Schedule not activating**: Check overnight logic if startTime > endTime (use OR, not AND)
- **Daily counter keeps growing**: DeviceActivityMonitor must reset at midnight - check `intervalDidEnd()` runs
- **Streaks not updating**: Only DeviceActivityMonitor updates streaks at midnight, not Shield Extension
- **Groups not persisting**: Check App Group entitlements (`group.com.pageinstead`) in all targets
- **ShieldAction buttons not working**: This is expected - iOS extension callbacks are unreliable on device. Unlock via main app instead.
- **Shields not reapplying**: Call `ScreenTimeService.shared.refreshShields()` to rebuild shield set from app groups
- **Lock button pulse not working**: Pulse animation only active when `isUnlocked = true` (30s window)
- **Top spacing too large**: Use `.padding(.top, 5)` not `.padding(.top, 60)` for header layout
- **Soft ghost button invisible**: White text at 70% opacity, increase to 100% if needed for contrast
- **"Get this book" button wraps**: Add `.lineLimit(1)` and `.fixedSize(horizontal: true, vertical: false)`
- **Bottom content hidden behind tab bar**: Add `Spacer(minLength: 120)` at end of ScrollView
- **Tab bar parallax not working**: Requires physical device - CoreMotion uses accelerometer (disabled in simulator)
- **Bookmark state not syncing**: Call `checkBookmarkStatus()` in `init()` and on quote change
- **Sheet shows blank on first tap**: Use `.sheet(item: $model)` not `.sheet(isPresented:)` - ensures data is ready before presentation
- **Quote detail layout misaligned**: Must match CurrentQuoteView - buttons in header, book details with trailing Spacer()
- **Scroll fade bleeding**: Header inside ScrollView causes transparency - must use fixed overlay pattern (ZStack with separate header VStack)
- **Header spacing too small**: ScrollView top spacing must match fixed header height to prevent overlap
- **Books screen empty despite bookmarks**: Check UserDefaults key is `"bookmarked_quotes"` (Set<Int>), verify QuoteService can find quotes by ID
- **Content bleeding at top of screen**: ScrollFadeOverlay missing `.ignoresSafeArea(edges: .top)` modifier
- **Book descriptions inconsistent**: All must start with "Book about" (see quotes.json standardization)
- **Onboarding buttons only work on text**: Add `.contentShape(Rectangle())` to button modifier
- **Confetti animation broken**: Use immutable ConfettiParticle properties + boolean animate state (don't mutate in animation block)
- **Screen 11 doesn't detect shield return**: Use scene phase `.onChange(of: scenePhase)` not Timer (stops when backgrounded)
- **Category chips not visible when selected**: Need gradient bg (0.7 opacity), checkmark icon, 3px border, 1.02x scale, shadow
- **BookQuote init error in previews**: Add `bookDescription: nil` parameter after `coverImageURL`
- **Book description wrapping too early**: VStack must have `.frame(maxWidth: .infinity)` - without it, text wraps prematurely due to HStack constraints
- **Description invisible/too faint**: Use 65% opacity minimum (not 50%) for readability on glass backgrounds
