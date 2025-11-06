# App Groups UI/UX Mockups

HTML mockups for the PageInstead App Groups feature, designed with the Liquid Glass aesthetic.

## 📁 Files

### Main Navigation
- **`index.html`** - Interactive index page linking to all mockups with feature highlights

### Screen Mockups
1. **`app-groups-empty-state.html`** - First-time user onboarding view
2. **`app-groups-main-screen.html`** - Dashboard showing all app groups
3. **`app-groups-rules-screen.html`** - Configuration screen (default/collapsed state)
4. **`app-groups-rules-expanded.html`** - Configuration screen (expanded/customized state)

## 🎨 Design Features

- **Liquid Glass UI** - Matches PageInstead's iOS 26 design system
- **Dark Gradient Background** - Deep blue gradient (#1a1a2e → #16213e → #0f3460)
- **Glass Cards** - Frosted glass effect with `backdrop-filter: blur(20px)`
- **iOS-Style Toggles** - Animated switches with green active state
- **Interactive Elements** - Buttons, pickers, and day pills with hover/active states
- **Responsive Layout** - Mobile-first design at 390px width (iPhone 14 Pro)

## 🚀 How to View

Open `index.html` in any modern web browser to navigate all mockups.

Or open individual files directly:
```bash
open mockups/index.html
open mockups/app-groups-main-screen.html
open mockups/app-groups-rules-screen.html
```

## 📱 Screen Sections

### Rules Screen Layout

1. **Group Name** - Editable text field
2. **Apps** - FamilyActivityPicker launcher (shows count)
3. **Pause For** - Duration dropdown (0-300 seconds)
4. **Daily Open Limit** - Toggle + number picker + hard block toggle
5. **Schedule** - Always active toggle + time pickers + day pills
6. **Actions** - Save button + Delete button

## 🔧 Interactive Features

The mockups include basic JavaScript for:
- Toggle switches (click to activate/deactivate)
- Day pills (click to select/deselect)
- Number pickers (increment/decrement buttons)
- Collapsible sections (show/hide on toggle)

## 📝 Technical Notes

These mockups reflect iOS ScreenTime API constraints:
- No live countdown timers (Shield Extension is stateless)
- Timestamp-based pause mechanism
- Daily counter tracked in Shield Extension
- Schedule validation at render time

## 🎯 Next Steps

1. Review mockups for visual accuracy
2. Gather feedback on UX flow
3. Begin SwiftUI implementation based on these designs
4. Test on physical device for glass effect accuracy

---

## 📚 Book Category Preferences

### Category Selection Mockups
5. **`settings-categories.html`** - Settings screen showing Book Categories option (with emoji icons)
6. **`category-selection.html`** - Interactive category selection screen (with emoji icons)
7. **`settings-categories-v2.html`** - Settings screen, iOS 26 Liquid Glass style (no emojis) ⭐️
8. **`category-selection-v2.html`** - Category selection, iOS 26 Liquid Glass style (no emojis) ⭐️

### Design Features (v2 - iOS 26 Style)
- **Pure Liquid Glass** - No emoji icons, clean text-only design
- **Enhanced Blur** - 33px blur with 150% saturation for richer glass effect
- **Multi-layer Shadows** - Inset highlights + ambient shadows for depth
- **Gradient Highlights** - Selected state uses dual-gradient purple background
- **Checkmark Badges** - Circular gradient badges with rotation animation
- **Subtle Shine Effect** - Animated shimmer on selected chips
- **2-Column Grid** - Responsive layout

### Category List (matches Onboarding Flow)
1. Self-help & Growth
2. Productivity & Focus
3. Philosophy & Mindfulness
4. Psychology & Relationships
5. Business & Leadership
6. Creativity & Art
7. Spirituality & Meaning
8. Women's Empowerment
9. Classics & Literature
10. Science & Nature

### Implementation Notes
- Store selections in UserDefaults: `selected_book_categories: Set<String>`
- Add `category: String` field to BookQuote model
- Filter quotes in QuoteScheduler based on selected categories
- Use OnboardingCategoryChip component as base
- Update Shield Extension to respect category filter

---

**Version:** 2.0 MVP
**Last Updated:** November 4, 2025
**Based on:** App_Groups_Specification.md, CLAUDE.md
