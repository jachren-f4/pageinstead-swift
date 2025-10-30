# Claude Code Instructions - PageInstead Swift

## Critical Implementation Rules

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

## File Locations

```
Main App:
- Entry: PageInstead/App/PageInsteadApp.swift
- Screen Time service: PageInstead/Core/Services/ScreenTimeService.swift
- App selection: PageInstead/Features/Blocking/AppSelectionView.swift

Quote System:
- QuoteScheduler: PageInstead/Core/Services/QuoteScheduler.swift
- CurrentQuoteView: PageInstead/Features/CurrentQuoteView.swift
- Quote data: PageInstead/Resources/quotes.json
- History (time-based): PageInstead/Features/History/QuoteHistoryView.swift
- Affiliate service: PageInstead/Core/Services/AffiliateService.swift

Design System (iOS 26 Liquid Glass):
- Liquid Glass styles: PageInstead/Core/DesignSystem/LiquidGlassStyles.swift
- Color system: PageInstead/Core/DesignSystem/Colors.swift

Shield Configuration Extension:
- Shield UI: ShieldConfiguration/ShieldConfigurationExtension.swift
- Quote data: ShieldConfiguration/QuoteData.swift
- Quote service: ShieldConfiguration/QuoteService.swift
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
- Used in: `ShieldConfiguration/QuoteData.swift`, preview code, quotes.json

### Amazon Affiliate Links
- **MUST use** `www` subdomain: `https://www.amazon.com/dp/{ASIN}`
- **WRONG**: `https://amazon.com/dp/{ASIN}` (returns 404)
- File: `PageInstead/Core/Services/AffiliateService.swift` line 88

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
