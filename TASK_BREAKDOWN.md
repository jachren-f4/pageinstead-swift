# Liquid Glass Redesign - Task Breakdown

Quick reference for implementation tasks. See `IMPLEMENTATION_PLAN.md` for detailed specifications.

---

## ✅ Phase 1: Core Components (2-3 hours)

### Audit & Setup
- [ ] 1.1.1 Review existing LiquidGlassStyles.swift
- [ ] 1.1.2 Review existing Colors.swift
- [ ] 1.1.3 Check QuoteScheduler for tracking capabilities
- [ ] 1.1.4 Document current design system usage

### New Components
- [ ] 1.2.1 Create `CircularProgressRing.swift`
  - Gradient stroke support
  - Animated progress changes
  - Optional percentage display
  - Test with different sizes

- [ ] 1.3.1 Create `ActivityBarChart.swift`
  - 7-bar mini chart
  - Gradient highlight for current bar
  - Responsive heights
  - Test with various data

- [ ] 1.4.1 Create `FloatingOrb.swift`
  - Circular gradient with blur
  - Infinite floating animation
  - Configurable size/colors
  - Test performance

- [ ] 1.5.1 Create `AnimatedGradientBackground.swift`
  - Purple gradient base
  - Radial overlay animations
  - 20s animation cycle
  - Test on different screen sizes

### View Modifiers
- [ ] 1.6.1 Add `.shimmerEffect()` to LiquidGlassStyles.swift
  - 3s horizontal sweep
  - Maskable to shape
  - Test on cards

- [ ] 1.6.2 Update `.liquidGlassCard()` modifier
  - Change to rgba(255,255,255,0.05) background
  - Increase corner radius to 24px
  - Update border opacity to 0.1
  - Add shadow

- [ ] 1.6.3 Add `.liquidGlassHeroCard()` modifier
  - Larger padding (40-45px)
  - Radius 32px
  - Heavier shadow

- [ ] 1.6.4 Add `.gradientBorder()` modifier
  - Angular gradient support
  - Custom colors
  - For shield screen

### Color System
- [ ] 1.7.1 Add Opus background colors to Colors.swift
  - backgroundDarkPurple (#1a0033)
  - backgroundMidPurple (#330066)
  - backgroundBrightPurple (#4d0073)

- [ ] 1.7.2 Add gradient definitions
  - progressGradient (667eea → 764ba2)
  - focusGradient (custom)
  - quotesGradient (custom)
  - activityGradient (custom)

- [ ] 1.7.3 Add glass tint colors
  - glassWhite (0.05)
  - glassBorder (0.1)
  - glassShimmer (0.03)

---

## ✅ Phase 2: Data Layer (1-2 hours)

### Quote View Tracking
- [ ] 2.1.1 Create `QuoteViewTracker.swift` service
  - Singleton pattern
  - @Published properties for SwiftUI
  - UserDefaults persistence

- [ ] 2.1.2 Add daily quote counter
  - Increment on quote change
  - Reset at midnight
  - Expose as @Published var

- [ ] 2.1.3 Add hourly activity tracking
  - Track quote views by hour
  - Return last 7 hours as array
  - For ActivityBarChart

### Focus Time Tracking
- [ ] 2.2.1 Design focus time tracking approach
  - **Decision needed:** Estimation vs. manual vs. app foreground time?
  - Document chosen approach

- [ ] 2.2.2 Implement focus time counter
  - Track based on chosen approach
  - Store daily total
  - Reset at midnight
  - Expose as @Published var

### Blocking Stats
- [ ] 2.3.1 Add block event tracking
  - Increment on shield view shown
  - Store daily count
  - Store weekly count
  - Calculate time saved estimate

- [ ] 2.3.2 Integrate with Shield Extension
  - Log blocking event via App Groups
  - Ensure no race conditions
  - Test persistence

---

## ✅ Phase 3: Screen Implementations (4-6 hours)

### Current Quote View (1.5-2 hours)
- [ ] 3.1.1 Replace background with AnimatedGradientBackground
- [ ] 3.1.2 Redesign header section
- [ ] 3.1.3 Add time indicator pill (current window)
- [ ] 3.1.4 Redesign quote card (hero style + shimmer)
- [ ] 3.1.5 Add 2-column stats section
  - Focus Time ring + activity bars
  - Quotes Seen ring + activity bars
- [ ] 3.1.6 Update "Get This Book" button (gradient style)
- [ ] 3.1.7 Wire up QuoteViewTracker data
- [ ] 3.1.8 Test auto-refresh still works
- [ ] 3.1.9 Test on different screen sizes

### App Blocking View (1.5-2 hours)
- [ ] 3.2.1 Replace background with AnimatedGradientBackground
- [ ] 3.2.2 Add status banner (green, blocking active)
- [ ] 3.2.3 Add 3 stat pills (blocks today, week, time saved)
- [ ] 3.2.4 Create app grid layout (2 columns)
- [ ] 3.2.5 Style blocked app cards (shield badge)
- [ ] 3.2.6 Style available app cards
- [ ] 3.2.7 Add "Add More Apps" button
- [ ] 3.2.8 Integrate FamilyActivityPicker
- [ ] 3.2.9 Update "Save Changes" button (gradient)
- [ ] 3.2.10 Wire up blocking stats data
- [ ] 3.2.11 Test selection state management

### History View (1.5-2 hours)
- [ ] 3.3.1 Replace background with AnimatedGradientBackground
- [ ] 3.3.2 Create daily summary card
- [ ] 3.3.3 Add metrics grid (3 columns)
- [ ] 3.3.4 Add 12-hour activity chart
  - **Decision:** Swift Charts or custom bars?
  - Implement chosen approach
- [ ] 3.3.5 Create week selector (horizontal scroll)
- [ ] 3.3.6 Style day pills (active state)
- [ ] 3.3.7 Redesign quote history list items
  - Time badge (hour + meridiem)
  - Quote text
  - Book info
  - Emoji badge
- [ ] 3.3.8 Wire up history data
- [ ] 3.3.9 Test date filtering

### Shield Screen (1-1.5 hours)
- [ ] 3.4.1 Replace background with AnimatedGradientBackground
- [ ] 3.4.2 Add 2-3 FloatingOrb instances
- [ ] 3.4.3 Create pulsing shield badge
- [ ] 3.4.4 Add blocked app name text
- [ ] 3.4.5 Redesign quote card (gradient border)
- [ ] 3.4.6 Add opening quotation mark
- [ ] 3.4.7 Style book attribution section
- [ ] 3.4.8 Update "Get This Book" button (blue glass tint)
- [ ] 3.4.9 Add "Return to Home" button (secondary)
- [ ] 3.4.10 Add time window indicator pill
- [ ] 3.4.11 Add dismiss hint text
- [ ] 3.4.12 Test animation performance
- [ ] 3.4.13 Verify quote sync with main app

---

## ✅ Phase 4: Polish & Enhancement (2-3 hours)

### Haptic Feedback
- [ ] 4.1.1 Add to app selection (light impact)
- [ ] 4.1.2 Add to button taps (medium impact)
- [ ] 4.1.3 Add to quote refresh (soft impact)
- [ ] 4.1.4 Add to shield screen appearance (heavy impact)
- [ ] 4.1.5 Test haptic timing feels natural

### Accessibility
- [ ] 4.2.1 Add Reduce Motion support to FloatingOrb
- [ ] 4.2.2 Add Reduce Motion support to ShimmerEffect
- [ ] 4.2.3 Add Reduce Motion support to CircularProgressRing
- [ ] 4.2.4 Add Reduce Motion support to AnimatedGradientBackground
- [ ] 4.2.5 Test with VoiceOver
- [ ] 4.2.6 Verify Dynamic Type support
- [ ] 4.2.7 Check color contrast ratios

### Animation Tuning
- [ ] 4.3.1 Fine-tune spring animations (dampening, response)
- [ ] 4.3.2 Adjust floating orb speeds
- [ ] 4.3.3 Adjust shimmer duration/opacity
- [ ] 4.3.4 Test all animations on device
- [ ] 4.3.5 Verify 60fps during animations

### Visual Polish
- [ ] 4.4.1 Verify SF Pro Display usage throughout
- [ ] 4.4.2 Check all padding/spacing matches mockups
- [ ] 4.4.3 Verify gradient hex colors
- [ ] 4.4.4 Check shadow intensities
- [ ] 4.4.5 Verify glass border visibility
- [ ] 4.4.6 Test on iPhone SE (small screen)
- [ ] 4.4.7 Test on iPhone Pro Max (large screen)

---

## ✅ Phase 5: Testing & Validation (2 hours)

### Functional Testing
- [ ] 5.1.1 Screen Time permission flow works
- [ ] 5.1.2 App selection persists correctly
- [ ] 5.1.3 Shield shows on blocked app launch
- [ ] 5.1.4 Shield shows correct time-synced quote
- [ ] 5.1.5 Multiple apps can be blocked
- [ ] 5.1.6 Blocking survives app restart
- [ ] 5.1.7 Quote changes every 5 minutes
- [ ] 5.1.8 Quote sync between app and shield
- [ ] 5.1.9 Daily variation works correctly
- [ ] 5.1.10 Auto-refresh works in CurrentQuoteView

### Data Tracking Testing
- [ ] 5.2.1 Quote counter increments correctly
- [ ] 5.2.2 Daily reset at midnight works
- [ ] 5.2.3 Focus time tracking is accurate
- [ ] 5.2.4 Block counters increment correctly
- [ ] 5.2.5 History data persists correctly
- [ ] 5.2.6 Stats aggregate correctly

### Performance Testing
- [ ] 5.3.1 Battery drain test (30 min active use)
- [ ] 5.3.2 Frame rate test (Xcode Instruments)
- [ ] 5.3.3 Memory leak test
- [ ] 5.3.4 Shield launch time (<1 second)
- [ ] 5.3.5 Animation smoothness on device
- [ ] 5.3.6 Scroll performance in lists

### Edge Cases
- [ ] 5.4.1 First launch (no data) - graceful defaults
- [ ] 5.4.2 Midnight rollover - stats reset correctly
- [ ] 5.4.3 Airplane mode - book covers fail gracefully
- [ ] 5.4.4 Slow network - loading states work
- [ ] 5.4.5 VoiceOver enabled - all actions accessible
- [ ] 5.4.6 Reduce Motion - animations disabled
- [ ] 5.4.7 Dynamic Type - layout doesn't break

---

## 🚀 Deployment Checklist

- [ ] All Phase 5 tests passing
- [ ] No console warnings/errors
- [ ] Build succeeds for both Debug and Release
- [ ] App size hasn't increased significantly
- [ ] No new crashes in common flows
- [ ] Existing quote system still works perfectly
- [ ] Shield Extension works reliably
- [ ] Performance is acceptable on older devices
- [ ] Accessibility features work correctly
- [ ] Ready for TestFlight/App Store

---

## 📊 Progress Tracking

**Total Tasks:** ~115
**Completed:** 0
**In Progress:** 0
**Remaining:** 115

**Estimated Time:** 10-14 hours
**Actual Time:** _TBD_

---

## 🎯 Critical Path

These tasks block other work and should be prioritized:

1. ✅ Phase 1 (all components) - blocks everything
2. QuoteViewTracker service - blocks Current Quote View data
3. Focus time tracking approach decision - blocks implementation
4. Current Quote View - highest visibility screen
5. Shield Screen - most critical for core functionality
6. Performance testing - gates deployment

---

## ❓ Open Questions

1. **Focus Time Tracking Method:**
   - Estimate (30sec per quote view)?
   - Manual tracker?
   - App foreground time?
   - **Decision needed before implementing**

2. **Activity Chart in History:**
   - Use Swift Charts (iOS 17+)?
   - Custom bar chart?
   - **Decision impacts iOS version requirement**

3. **App Icons in Blocking View:**
   - Keep FamilyActivityPicker?
   - Use generic category icons?
   - **FamilyControls API limitation**

4. **Shield Extension Animation:**
   - Will FloatingOrbs perform well?
   - Need performance testing
   - **May need to simplify if laggy**

---

## 📝 Notes

- Keep CLAUDE.md updated with new critical rules
- Document any deviations from Opus mockups
- Take screenshots of each completed screen
- Update README.md with new design system info
- Consider creating a CHANGELOG.md for this redesign

---

**Next Action:** Review this breakdown, make decisions on open questions, then start Phase 1!
