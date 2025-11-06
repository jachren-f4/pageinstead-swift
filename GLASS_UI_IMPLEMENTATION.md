# Glass UI Implementation Guide - PageInstead

## Overview

PageInstead uses an iOS 26 "Liquid Glass" design system (Opus variant) based on HTML mockups. This document explains the implementation, key learnings, and how to maintain the glass effect across iOS devices and simulator.

## Key Files

### Glass Card Component
**File:** `PageInstead/Core/DesignSystem/Components/GlassCard.swift`

The core reusable glass card component using `UIVisualEffectView` for proper translucency.

```swift
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var blurRadius: CGFloat = 40
    var padding: CGFloat = 30
    var content: () -> Content

    var body: some View {
        ZStack {
            // Background layers
            Color.white.opacity(0.08)

            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                .blur(radius: blurRadius)
                .opacity(0.33)

            // Card content
            content()
                .padding(padding)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}
```

**Convenience initializers:**
- `GlassCard(standard:)` - Default 24px radius, 40px blur, 30px padding
- `GlassCard(compact:)` - Smaller 20px radius, 30px blur, 20px padding
- `GlassCard(small:)` - Stats cards: 24px radius, 20px blur, 20px padding

### UIKit Blur Wrapper
```swift
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
```

## Critical Opacity Values

### Final Working Values
These values provide consistent glass appearance on both iPhone and simulator:

| Property | Value | Purpose |
|----------|-------|---------|
| White background | `0.08` | Base translucent tint |
| Blur opacity | `0.33` | Frosted glass effect strength |
| Border stroke | `0.2` | Subtle outline |
| Shadow | `0.3` | Depth and elevation |

### Why These Values?

**Simulator vs. Device Rendering:**
- iOS Simulator uses GPU approximations for blur/translucency
- Physical devices use hardware-accelerated compositing
- Same opacity values render differently on each platform
- `0.08` white opacity is the sweet spot that works on both

**Evolution of opacity values:**
1. Started with `0.027` (too transparent on device)
2. Increased to `0.03` (+5%, still too transparent)
3. Increased to `0.08` (HTML mockup value, perfect!)

## Background Gradient

**File:** `PageInstead/Core/DesignSystem/Components/AnimatedGradientBackground.swift`

```swift
LinearGradient(
    colors: [
        Color(hex: "1a0033"), // Dark purple
        Color(hex: "330066"), // Mid purple
        Color(hex: "4d0073")  // Bright purple
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

The purple gradient must be clearly visible through the glass cards.

## Progress Rings

**File:** `PageInstead/Core/DesignSystem/Components/CircularProgressRing.swift`

```swift
CircularProgressRing.success(
    progress: 0.75,
    showPercentage: true,  // Must come before size!
    size: 90
)
```

**Parameter Order:** `showPercentage` MUST precede `size` or compilation fails.

**Color schemes:**
- `.success` - Green (#4CD964) for Focus Time
- `.focus` - Blue (#007AFF) for Quotes Seen
- `.primary` - Purple gradient
- `.activity` - Orange-pink gradient

## CurrentQuoteView Implementation

**File:** `PageInstead/Features/CurrentQuoteView.swift`

### Quote Card (Lines 24-75)
```swift
GlassCard(standard: {
    VStack(spacing: 24) {
        Text("\"\(viewModel.currentQuote.text)\"")
            .font(.system(size: 24, weight: .regular))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineSpacing(8)  // Tight line spacing

        // Book attribution with cover and details
    }
})
.padding(.horizontal)
```

**IMPORTANT:** No `.shimmerEffect()` - causes white flashing!

### Stats Cards (Lines 78-110)
```swift
HStack(spacing: 16) {
    // Focus Time
    GlassCard(small: {
        VStack(spacing: 16) {
            CircularProgressRing.success(
                progress: viewModel.mockFocusProgress,
                showPercentage: true,
                size: 90
            )

            Text("Focus Time")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    })

    // Quotes Seen (same structure)
}
```

**Design notes:**
- No headers or icons above rings
- Percentage inline with number (75% not 75 / %)
- No activity bars below rings
- 20pt font labels (25% larger than default)

## Common Issues & Solutions

### Issue: White Flashing on Quote Card
**Cause:** `.shimmerEffect()` modifier
**Solution:** Remove shimmer effect entirely
**Location:** CurrentQuoteView.swift:75 (was `.shimmerEffect()`, now removed)

### Issue: Cards Too Transparent on Device
**Cause:** Simulator renders differently than hardware
**Solution:** Increase white opacity to 0.08
**Why:** Device GPU compositing is more subtle than simulator

### Issue: Parameter Order Error
**Error:** `argument 'showPercentage' must precede argument 'size'`
**Solution:** Always put `showPercentage` before `size` in CircularProgressRing calls

### Issue: Cards Appear Too Opaque
**Cause:** Stacking multiple white layers or overlays
**Solution:** Use single white layer + blur, avoid multiple Material effects

## Design System Rules

### ✅ DO
- Use `GlassCard` for navigation/control surfaces
- Test on both simulator AND physical device
- Use `VisualEffectBlur` wrapper for CSS-like blur
- Keep glass cards clean and minimal
- Use white text with appropriate opacity (0.7 for secondary)

### ❌ DON'T
- Apply glass to content (quotes, images, book covers)
- Stack multiple glass layers
- Use `.shimmerEffect()` on glass cards
- Use only simulator for opacity tuning
- Guess at white opacity values (use tested values)

## Typography

**Quote text:**
- Font: System, 24pt, regular weight
- Color: White
- Line spacing: 8pt
- Quotes: Always wrapped in `"..."`

**Labels:**
- Primary: 20pt, medium weight
- Secondary: 14pt, regular weight
- Opacity: 0.7 for secondary text

## Testing Checklist

When modifying glass UI:

- [ ] Build for iPhone device
- [ ] Build for iOS Simulator
- [ ] Verify glass translucency shows purple gradient
- [ ] Check no white flashing during animations
- [ ] Confirm text readability (white on glass)
- [ ] Test on actual iPhone hardware (not just simulator)
- [ ] Verify progress rings display percentages inline
- [ ] Check border visibility (subtle white stroke)

## References

**HTML Mockup:** `opus-mockups/opus-current-quote.html`
**Design Guidelines:** `opus-mockups/Tips_on_iOS_26_and_Glass_UI.md`
**Debug Guide:** `PageInstead_Glass_UI_Debug_and_Swift_Fix.md`
**Issue Tracking:** `GLASS_UI_ISSUE.md`

## Version History

| Date | Change | Opacity Values |
|------|--------|---------------|
| 2025-10-30 | Initial implementation | 0.027 white, 0.30 blur |
| 2025-10-30 | +5% opacity increase | 0.02835 white, 0.315 blur |
| 2025-10-30 | +5% opacity increase | 0.03 white, 0.33 blur |
| 2025-10-30 | Return to HTML mockup value | 0.08 white, 0.33 blur ✅ |
| 2025-10-30 | Remove shimmer effect | (Fixed white flashing) |
| 2025-10-30 | Line spacing adjustment | 9pt → 8pt |

## Expert Consultation Notes

Credit to Swift expert who identified the root cause:

1. **SwiftUI `.ultraThinMaterial` ≠ CSS `backdrop-filter: blur()`**
   - Material system uses Vibrancy + Blur with dynamic tint blending
   - Not just blur + opacity like CSS

2. **Solution: `UIVisualEffectView` wrapper**
   - Provides CSS-style control via UIKit
   - Better translucency fidelity than pure SwiftUI Material

3. **Simulator limitations**
   - Doesn't fully render GPU-based translucency
   - Real device shows Material closer to HTML, but still different
   - Always test on hardware for final approval

## Maintenance

When updating glass effects:

1. Modify `GlassCard.swift` opacity values
2. Build for BOTH simulator and device
3. Test on physical iPhone first (it's more subtle)
4. Adjust based on device appearance
5. Verify simulator doesn't look too opaque
6. Document any value changes in this file

---

**Last Updated:** 2025-10-30
**Status:** Stable - Glass UI working consistently on iPhone and Simulator
**Current Values:** White 0.08, Blur 0.33
