# PageInstead

Replace distracting apps with inspiring book quotes using iOS Screen Time API.

## Technology Stack

**Native iOS (Swift)** - Rebuilt from Flutter for better Screen Time API integration
- SwiftUI for UI
- iOS 16.0+ (FamilyControls framework requirement)
- Shield Configuration Extension for custom blocking UI
- App Groups for data sharing between app and extension

## Project Structure

```
pageinstead-swift/
├── PageInstead/                    # Main app
│   ├── App/                        # Entry point, root views
│   ├── Core/
│   │   ├── Models/AppGroup.swift   # App group data model
│   │   └── Services/
│   │       ├── ScreenTimeService.swift
│   │       ├── QuoteScheduler.swift
│   │       └── AppGroupManager.swift
│   ├── Features/
│   │   ├── AppGroups/              # App groups UI
│   │   ├── Blocking/               # App selection UI
│   │   ├── CurrentQuoteView.swift  # Main quote display with auto-refresh
│   │   └── History/                # Time-window based history
│   └── Resources/
│       ├── quotes.json             # 292 curated quotes from 147 books
│       └── affiliate-config.json   # Amazon affiliate tags
└── ShieldConfiguration/            # Shield Extension
    ├── ShieldConfigurationExtension.swift
    └── QuoteData.swift             # Quotes + shared storage
```

## Building & Running

1. **Open project:**
   ```bash
   cd pageinstead-swift
   open PageInstead.xcodeproj
   ```

2. **Select your iPhone** from device dropdown (Simulator not supported for Screen Time)

3. **Run** (⌘R) - Xcode will handle provisioning automatically

**Command line build:**
```bash
xcodebuild -project PageInstead.xcodeproj \
  -scheme PageInstead \
  -destination 'platform=iOS,id=YOUR_DEVICE_ID' \
  -allowProvisioningUpdates build
```

## Current Features

✅ Screen Time authorization flow
✅ Block app selection with FamilyActivityPicker
✅ Custom shield showing time-synced book quotes
✅ Current Quote View with auto-refresh and book covers
✅ Time-window based quote history - shows book titles, tap to view full quote with bookmark/affiliate buttons
✅ Amazon affiliate links with 292 curated quotes from 147 books
✅ Book descriptions - Each book has a concise (≤10 words) description for context
✅ App Groups for extension communication
✅ Onboarding UI with feature highlights
✅ Self-restriction features (timer lock, passcode lock)
✅ Screen Health Score with 3-day calibration and hybrid tracking

### Onboarding Flow

First-launch 11-screen onboarding flow that guides users through:
1. Welcome screen with app explanation
2. Gender selection (optional personalization)
3. Age group selection
4. Book category preferences (multi-select)
5. App blocking explanation + app selection
6. "Try It Now" interactive demo with shield detection

**Testing**: Settings → Development → "Reset & Show Onboarding"

**Architecture**:
- `OnboardingData.shared`: Singleton state manager with UserDefaults persistence
- `OnboardingCoordinator`: Navigation controller for 11 screens
- Reusable components: button styles, option buttons, category chips, confetti
- Auto-detects shield display via App Groups and completes onboarding when user returns from background

### App Groups
Organize blocked apps into groups with custom rules:
- **Custom pause durations** - Set wait time before app access (0-5 minutes)
- **Daily limits** - Restrict number of app opens per day
- **Scheduling** - Active only during specific times/days
- **Streak tracking** - Monitor consecutive days of use

### App Unlock System
PageInstead uses a **main app unlock** approach (similar to apps like Stryde):

1. **Shield Display**: When user tries to open blocked app, shows quote with message "Visit PageInstead to unlock app" (no buttons)
2. **Main App Unlock**: User opens PageInstead → Current Quote tab → "Unlock Blocked Apps" section
3. **Countdown Timer**: 5-second countdown prevents impulsive unlocking
4. **Temporary Access**: All shields removed for 30 seconds, then automatically reapplied

**Why no unlock button in shield?**
iOS ShieldAction extensions are extremely unreliable on physical devices - button callbacks often don't fire. Moving unlock to the main app provides a bulletproof user experience.

### Lock Button UI
Top-right corner lock button provides quick visual feedback and access to unlock functionality:
- **Locked state**: Red border (2px) with 15% red background
- **Unlocked state**: Green background with pulsating animation (30s window indicator)
- **Navigation**: Taps open full-screen UnlockScreen modal with countdown

**Design:**
- Two-row header layout: Lock button above, "Quote" title + "Get this book" button below
- Minimal top spacing (5px) keeps lock button near status bar
- Uses `.liquidGlassSoftGhostButton()` style for subtle secondary actions

### Bookmark System
Save favorite quotes for later reference with persistent bookmarking.

**Features:**
- One-tap bookmark/unbookmark with spring animation
- Gold highlight (#FFD700) for bookmarked quotes
- Persists across app launches via UserDefaults
- Automatic state sync when quotes change

**Location:** Quote screen header, left of "Get this book" button

**Storage:** Bookmarks saved as Set<Int> of quote IDs in UserDefaults key `"bookmarked_quotes"`

### Books Screen
View all bookmarked quotes organized by book with rich metadata.

**Features:**
- Quotes grouped by book with cover image, title, author
- Bookmark count and category tags per book
- "Get this book" Amazon affiliate links
- Empty state with instructions when no bookmarks exist
- Books sorted by most bookmarked first

**How to use:**
1. Bookmark quotes from the Quote tab (tap bookmark icon)
2. Navigate to Books tab to view collection
3. Tap "Get this book" to purchase via Amazon affiliate link

**Storage:** Bookmarks persist in UserDefaults as `Set<Int>` of quote IDs (key: `"bookmarked_quotes"`)

### Self-Restriction Features
Lock Settings Timer and Passcode features prevent impulsive changes to app blocking settings.

**Lock Settings Timer** (5-120 seconds)
- Locks navigation on app launch
- Only Current Quote tab accessible during timer
- Alert shows when tapping locked tabs
- Bypassed in simulator for testing

**Lock Settings Passcode** (4-digit PIN)
- Locks navigation until correct passcode entered
- Only Current Quote tab accessible without passcode
- Passcode stored securely in iOS Keychain (SHA-256 + salt)
- Session-based unlock (re-required on app relaunch)
- Biometric auth ready (Face ID/Touch ID)
- Simulator bypass: "0000"

**How It Works**:
- `SelfRestrictionManager.shared` handles all restriction logic
- Timer: Starts on `ContentView.onAppear()`, blocks navigation in `.onChange(selectedTab)`
- Passcode: Stored in Keychain via `KeychainHelper`, verified on tab navigation

### Screen Health Score
Tracks your progress in reducing distracting app usage through a 0-100% health score.

**How it works:**
- Counts blocked app attempts (how often you try to open apps you've chosen to limit)
- 3-day calibration period establishes your baseline
- Score improves as you reduce attempts below baseline
- Formula: `100 - ((attempts_today / baseline) * 100)`, clamped 0-100%

**Why blocked attempts, not screen time?**
Apple's FamilyControls API doesn't expose total device screen time. Instead, we track meaningful behavior: how often you resist distractions.

**Calibration:**
- Days 1-3: App learns your typical usage pattern
- Day 4+: Real scoring begins with your personalized baseline
- Default score during calibration: 75%

**Hybrid Tracking:**
- Shield Extension counts attempts in real-time
- DeviceActivityMonitor reconciles at end of day (handles iOS caching)
- 180-day history stored in App Group container

**Display:**
- Current Quote tab: Large progress ring showing score
- Settings footer: "Blocked Attempts: 5 / 15 baseline | Health Score: 85%"

## Design System

### Liquid Glass (iOS 26 - Opus Variant)
PageInstead uses a custom "Liquid Glass" design system with translucent glassmorphism effects on a purple gradient backdrop.

**Core Components:**
- **GlassCard** - Translucent cards using `UIVisualEffectView` (white 0.08 opacity, blur 0.33)
- **AnimatedGradientBackground** - Purple gradient (`#1a0033` → `#330066` → `#4d0073`)
- **CircularProgressRing** - Progress indicators with inline percentages (green/blue)

**Reusable Modifiers:**
```swift
.liquidGlassCard()              // Floating cards
.liquidGlassPrimaryButton()     // Primary CTAs (blue tint)
.liquidGlassDestructiveButton() // Destructive actions (red tint)
.liquidGlassPill()              // Tags and badges
```

**Liquid Glass Tab Bar:**
Custom bottom navigation with advanced iOS 26 design patterns.
- 5-layer shadow system (inner glow → ambient shadow)
- Adaptive blur: `.ultraThin` at rest, `.regular` when scrolling
- Parallax motion effects via CoreMotion (physical device only)
- Respects Reduce Transparency and Reduce Motion accessibility settings
- **Implementation:** `PageInstead/Core/DesignSystem/Components/LiquidGlassTabBar.swift`

**Guidelines:**
- Use glass ONLY for navigation/control layers (not content like quotes/images)
- Never stack multiple glass layers
- Always test on physical iPhone - simulator renders glass differently due to GPU differences
- Selective tinting: primary = blue, destructive = red, secondary = no tint

**Scroll Fade Overlay:**
Content fades smoothly behind headers when scrolling using a gradient overlay.
```swift
ScrollView { /* content */ }
    .scrollFadeOverlay()
```
**Implementation:** `PageInstead/Core/DesignSystem/Components/ScrollFadeOverlay.swift`

**Files:**
- Glass components: `PageInstead/Core/DesignSystem/Components/GlassCard.swift`
- Styles: `PageInstead/Core/DesignSystem/LiquidGlassStyles.swift`
- Colors: `PageInstead/Core/DesignSystem/Colors.swift`
- Implementation guide: `GLASS_UI_IMPLEMENTATION.md`

## How It Works

### Unlock Flow
- **UnlockManager.swift**: Singleton that removes/reapplies shields via ManagedSettingsStore
- **UnlockAppsView.swift**: SwiftUI countdown timer component (5s → unlock → 30s window)
- **Shield extensions are read-only**: Display quotes only, no interactive elements

### Time-Based Quote Synchronization
PageInstead uses deterministic time-based quote selection to ensure the Shield Extension and main app always show the same quote without communication:

- **5-minute windows**: Day divided into 288 windows (00:00-00:05, 00:05-00:10, etc.)
- **Daily variation**: Day-of-year offset (× 37) ensures same time shows different quotes each day
- **Synchronized**: Main app and Shield Extension calculate same quote independently (no IPC needed)
- **Grace period**: 30-second buffer after window change shows previous quote

Example: 11:00 AM coffee break shows different quote each day:
- Day 1: Quote #169
- Day 2: Quote #206
- Day 3: Quote #243

The algorithm uses coprime number 37 for good distribution across 292 quotes. Both components independently calculate the current quote from system time, ensuring perfect synchronization with zero IPC overhead.

**Implementation**: `PageInstead/Core/Services/QuoteScheduler.swift`

### Quote History Detail View
Tapping a book title in the history list opens a sliding detail sheet with:
- Full formatted quote text with proper punctuation
- Book cover, title, and author
- Bookmark button (syncs with main quote screen)
- "Get this book" affiliate link button

**Implementation**: Uses `.sheet(item:)` binding pattern to ensure quote data is ready before presentation, preventing blank screen on first tap.

### Quote Management
Quotes are stored in `PageInstead/Resources/quotes.json` with metadata:
- 292 curated quotes from 147 books with author, ASIN, cover URL, tags
- ASINs link to Amazon product pages with affiliate tracking
- Cover images loaded via AsyncImage from Amazon CDN
- Quotes intelligently shuffled to spread same-book quotes apart

## Configuration

**App Groups:** `group.com.pageinstead`
- Required for data sharing between main app and extension
- Configured in entitlements for both targets

**Capabilities Required:**
- Family Controls
- App Groups

## Adding Quotes

Edit `PageInstead/Resources/quotes.json`:

```json
{
  "id": 296,
  "text": "Your quote text here",
  "author": "Author Name",
  "bookTitle": "Book Title",
  "bookId": "unique_id",
  "asin": "B00EXAMPLE",
  "coverImageURL": "https://m.media-amazon.com/images/P/B00EXAMPLE.jpg",
  "bookDescription": "Brief 10-word book summary for context display",
  "isActive": true,
  "tags": ["reading", "wisdom"],
  "dateAdded": "2025-11-03"
}
```

**Note**: ASINs must be valid Amazon product IDs. Cover URLs use format: `https://m.media-amazon.com/images/P/{ASIN}.jpg`. The `bookDescription` should be ≤10 words summarizing what the book is about.

## Troubleshooting

### Quote System

**Q: Quotes seem to repeat at the same time every day?**
A: Check that QuoteScheduler includes day-of-year offset calculation. Should be `(windowIndex + dailyOffset) % count`, not just `windowIndex % count`.

### Self-Restriction Features

**Q: Timer/passcode not working in simulator?**
A: Both have simulator bypasses for testing. Timer is disabled, passcode "0000" always works.

**Q: Can't change passcode after updating from 6-digit to 4-digit?**
A: Uninstall app to clear old Keychain data: `xcrun simctl uninstall DEVICE_ID com.joakimachren.PageInstead`

**Q: Quotes showing double quotes like """text"""?**
A: Fixed. App now detects existing curly quotes (", ") and straight quotes (").

### Health Score

**Q: Health score stuck at 75%?**
A: You're in the 3-day calibration period. Score updates after baseline is established.

**Q: Counter not incrementing when I open blocked apps?**
A: iOS may cache shield configurations. DeviceActivityMonitor reconciles at midnight to ensure accuracy.

**Q: Can I reset my baseline?**
A: Uninstall and reinstall the app to clear UserDefaults and start fresh calibration.

### Bookmark System

**Q: Bookmarks not persisting after app restart?**
A: Check that `bookmarked_quotes` key exists in UserDefaults. Verify `saveBookmarks()` is called after toggle.

**Q: Bookmark state out of sync with current quote?**
A: `checkBookmarkStatus()` runs on init and quote changes. Check that `currentQuote.id` matches stored IDs.

### Liquid Glass Tab Bar

**Q: "Get this book" button text wrapping to multiple lines?**
A: Add `.lineLimit(1)` and `.fixedSize(horizontal: true, vertical: false)` to prevent wrapping.

**Q: Bottom stats cards hidden behind floating tab bar?**
A: Add `Spacer(minLength: 120)` at end of ScrollView content for clearance.

**Q: Tab bar parallax/motion effects not working?**
A: Parallax requires physical device (uses CoreMotion accelerometer). Simulator shows static tab bar only.

**Q: Tab bar shadows look different on device vs. simulator?**
A: GPU rendering differs - always test on physical iPhone for accurate glass/shadow appearance.

## Development Notes

- Minimum iOS version: 16.0
- Bundle ID: `com.joakimachren.PageInstead`
- Extension Bundle ID: `com.joakimachren.PageInstead.ShieldConfiguration`
- Development Team: NA6936A56Q

### Onboarding Development

Reset onboarding flow from Settings → Development → "Reset & Show Onboarding"

File locations:
- State: `PageInstead/Features/Onboarding/OnboardingData.swift`
- Navigation: `PageInstead/Features/Onboarding/OnboardingCoordinator.swift`
- Components: `PageInstead/Features/Onboarding/Components/`
- Screens: `PageInstead/Features/Onboarding/Screens/`
