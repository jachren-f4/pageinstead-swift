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
│   ├── Core/Services/              # ScreenTimeService, QuoteScheduler, AffiliateService
│   ├── Features/
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
✅ Time-window based quote history with daily variation
✅ Amazon affiliate links with 292 curated quotes from 147 books
✅ App Groups for extension communication
✅ Onboarding UI with feature highlights

## Design System

### Liquid Glass (iOS 26)
PageInstead uses iOS 26's Liquid Glass design language for a modern, translucent UI.

**Reusable Modifiers:**
```swift
.liquidGlassCard()              // Floating cards
.liquidGlassPrimaryButton()     // Primary CTAs (blue tint)
.liquidGlassDestructiveButton() // Destructive actions (red tint)
.liquidGlassPill()              // Tags and badges
```

**Guidelines:**
- Use glass ONLY for navigation/control layers (not content)
- Never stack multiple glass layers
- Selective tinting: primary = blue, destructive = red, secondary = no tint
- Spring animations: `.animation(.liquidGlassSpring, value: state)`

**Files:**
- Styles: `PageInstead/Core/DesignSystem/LiquidGlassStyles.swift`
- Colors: `PageInstead/Core/DesignSystem/Colors.swift`

## How It Works

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
  "id": 293,
  "text": "Your quote text here",
  "author": "Author Name",
  "bookTitle": "Book Title",
  "bookId": "unique_id",
  "asin": "B00EXAMPLE",
  "coverImageURL": "https://m.media-amazon.com/images/P/B00EXAMPLE.jpg",
  "isActive": true,
  "tags": ["reading", "wisdom"],
  "dateAdded": "2025-10-30"
}
```

**Note**: ASINs must be valid Amazon product IDs. Cover URLs use format: `https://m.media-amazon.com/images/P/{ASIN}.jpg`

## Troubleshooting

### Quote System

**Q: Quotes seem to repeat at the same time every day?**
A: Check that QuoteScheduler includes day-of-year offset calculation. Should be `(windowIndex + dailyOffset) % count`, not just `windowIndex % count`.

## Development Notes

- Minimum iOS version: 16.0
- Bundle ID: `com.joakimachren.PageInstead`
- Extension Bundle ID: `com.joakimachren.PageInstead.ShieldConfiguration`
- Development Team: NA6936A56Q
