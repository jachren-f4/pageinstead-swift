# PageInstead

Replace distracting apps with inspiring book quotes using iOS Screen Time API.

## Tech Stack

**Native iOS (Swift)**
- SwiftUI + FamilyControls framework
- iOS 16.0+ minimum
- Shield Configuration Extension
- App Groups for data sharing

## Quick Start

```bash
cd pageinstead-swift
open PageInstead.xcodeproj
```

Select your iPhone (physical device required for Screen Time) and run (⌘R).

**Command line:**
```bash
xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
  -destination 'platform=iOS,id=YOUR_DEVICE_ID' -allowProvisioningUpdates build
```

## Features

### Core
- **Time-synced quotes**: 5-minute windows, 292 quotes from 147 books
- **App groups**: Custom rules per group (pause timer, daily limit, schedule)
- **Unlock system**: Main app unlock with 30s window (no shield buttons)
- **Unlock reminder**: 1-hour push notification after unlocking blocked apps
  - Message: "You left your apps unblocked. Come back and block them again."
  - Permission requested automatically on first unlock (just-in-time)
  - Notification scheduled whenever apps are unlocked (manual or pause timer)
- **Health score**: 0-100% based on blocked attempts, 3-day calibration
- **Unlock Streak**: Tracks consecutive days without unlocking blocked apps
  - Shows actual day count in meter (not percentage)
  - 5% minimum display after breaking streak
  - Both manual unlock and pause timer expiry reset streak
  - Tap ">" for detailed explanation and stats

### Content
- **Bookmarks**: Save favorite quotes, sync across views via NotificationCenter
- **Books screen**: Groups bookmarked quotes by book, shows book count, yellow bookmark button for removal with confirmation, formatted quotes with "..." prefix for lowercase starts, quote counter hidden for single-quote books
- **Quote history**: Last 10 viewed quotes with stats card (today's count + streak), detail sheets with bookmark functionality, formatted quotes matching Quote screen style
- **Book descriptions**: 4-line descriptions with book info (cover, title, author, category tags)

### Restrictions
- **Timer lock**: 5-120s on app launch
- **Passcode lock**: 4-digit PIN + Keychain storage

### Onboarding
- **11-screen guided setup** with automatic trigger for new users
- **Mandatory app selection** on Screen 8 (no skip option)
- **SwiftUI permission dialog mockup** with animated arrow indicator
- Reset via Settings → Development → "Reset & Show Onboarding"

### Design
- **Liquid Glass**: iOS 18+ native tab bar with adaptive blur
- **Scrollable headers**: All screens scroll naturally
- **Typography hierarchy**: Opacity-based (100%→85%→70%→65%)
- **Glass cards**: White 0.08, blur 0.33, 0.2 opacity border
- **Metric detail sheets**: Tap ">" chevron next to meter titles
  - Health Score: Shows calibration status, formula, explanation
  - Unlock Streak: Shows current/record, last unlock, what breaks streak
  - During calibration: Health Score hides stats, only shows 75%

## How It Works

### Time-Based Quotes
Both app and extension calculate current quote independently:
```
quoteIndex = (windowIndex + (dayOfYear × 37)) % totalQuotes
```
- No IPC needed
- Same quote everywhere
- Different quote each day at same time

### Health Score
- Tracks **blocked attempts** (Screen Time API limitation)
- Formula: `100 - ((attempts / baseline) * 100)`
- Shield Extension increments real-time
- DeviceActivityMonitor reconciles daily

### Unlock Streak System
Tracks consecutive days without accessing blocked apps.

**Formula:**
- Current = Record → 100% (full meter)
- Current < Record → Shows progress (minimum 5%)
- Example: 8 days / 12 day record = 67%

**Breaks On:**
- Manual unlock via unlock screen
- Pause timer expiring (automatic unlock)

**Increments:**
- Daily at midnight (DeviceActivityMonitor)
- Fallback check on app launch (defensive)

**Display:**
- Quote screen meter: Shows "X days" with dynamic font sizing
- Detail sheet: Full stats with record comparison
- Storage: `group.com.pageinstead` UserDefaults

### App Groups
- Multiple named groups with independent rules
- Conflict detection (apps in one group only)
- Timestamp-based pause timers (stateless Shield)
- Daily reset + streak tracking at midnight

## Adding Quotes

Edit `PageInstead/Resources/quotes.json`:

```json
{
  "id": 296,
  "text": "Your quote text here",
  "author": "Author Name",
  "bookTitle": "Book Title",
  "asin": "B00EXAMPLE",
  "coverImageURL": "https://m.media-amazon.com/images/P/B00EXAMPLE.jpg",
  "bookDescription": "Book about [topic]",
  "tags": ["wisdom"]
}
```

## Configuration

- **App Group**: `group.com.pageinstead`
- **Bundle ID**: `com.joakimachren.PageInstead`
- **Capabilities**: Family Controls, App Groups

## Troubleshooting

**Simulator**: Screen Time bypassed for UI testing. Use `#if targetEnvironment(simulator)` checks. Passcode "0000" works.

**Quotes repeat**: Check QuoteScheduler has day-of-year offset: `(dayOfYear * 37)`.

**Health score stuck at 75%**: You're in 3-day calibration. Wait until Day 4.

**Tab bar not transparent**: Missing `.ignoresSafeArea()` on tab backgrounds.

**Shield buttons don't work**: Expected on device. Use main app unlock.

## Distribution Status

### ⏳ Waiting for Apple Approval

**Family Controls Distribution Entitlement**: Requested from Apple (required for TestFlight/App Store)
- **Status**: Pending approval
- **Submitted**: 2025-11-06
- **Expected timeline**: 3-6 weeks (typically 4 weeks)
- **Targets submitted**: Main app + DeviceActivityMonitor extension

**Current distribution options while waiting**:
- ✅ Development builds on registered devices (up to 100 devices/year)
- ✅ Ad Hoc distribution via Xcode or Diawi
- ❌ TestFlight (requires distribution entitlement approval)
- ❌ App Store (requires distribution entitlement approval)

**What works now**:
- All Family Controls features work in development/Ad Hoc builds
- Can install on physical devices for testing
- See `DISTRIBUTE_WITHOUT_TESTFLIGHT.md` for beta testing options

**After approval**:
- TestFlight distribution enabled
- App Store submission enabled
- See `TESTFLIGHT_DEPLOYMENT_GUIDE.md` for deployment steps

**Reference documents**:
- `FAMILY_CONTROLS_ENTITLEMENT_REQUEST.md` - Full approval process details
- `DISTRIBUTE_WITHOUT_TESTFLIGHT.md` - Beta testing options now
- `TESTFLIGHT_DEPLOYMENT_GUIDE.md` - For after approval

---

## Development

- **Min iOS**: 16.0
- **Recommended Build Target**: iOS 18.0+ (prefer latest iOS version)
  - iOS 18.0 was released recently and Xcode has been updated to support it
  - Always build for iOS 18.0 or newer when developing to take advantage of latest features
- **Team**: NA6936A56Q
- **Onboarding reset**: Settings → Development → "Reset & Show Onboarding"

See `CLAUDE.md` for implementation details.
