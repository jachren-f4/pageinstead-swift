# PageInstead Onboarding Flow - Implementation Plan

**Last Updated:** 2025-10-29
**Status:** Planning - Ready for Implementation

---

## Overview

This document outlines the complete onboarding flow for PageInstead Swift app, adapted from the original Flutter plan to work with iOS Screen Time API constraints.

---

## Flow Summary

**Total Screens:** 9
**Estimated Implementation Time:** 2-3 days
**Design Style:** Playful & friendly, following system theme (light/dark mode)

### Screen Sequence

1. Welcome Screen - Hero introduction
2. Feature Highlight 1 - "Stop doomscrolling, start transforming"
3. Feature Highlight 2 - "Replace distraction with wisdom"
4. Feature Highlight 3 - "Build better habits"
5. Feature Highlight 4 - "Discover books that fit your mindset"
6. Permission Education - Explain Screen Time access
7. Authorization Request - Trigger iOS authorization
8. App Selection Intro - Explain what app picker does
9. Success Screen - Celebration and transition to main app

---

## Implementation Task List

### Phase 1: Foundation & Structure

#### Task 1: Create OnboardingView container with TabView page navigation
- **File:** `PageInstead/Features/Onboarding/OnboardingView.swift`
- **Details:**
  - Container view using `TabView` with `.tabViewStyle(.page)`
  - State management for current page tracking (`@State private var currentPage = 0`)
  - Navigation between screens
  - Handle page transitions

#### Task 2: Add AppStorage persistence for hasCompletedOnboarding flag
- **Implementation:** `@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false`
- **Purpose:** Persists across app launches
- **Trigger:** Set to `true` when user completes onboarding
- **Reset:** Can be cleared for testing via UserDefaults

#### Task 3: Integrate onboarding check in ContentView
- **File:** Modify existing `ContentView.swift`
- **Logic:**
  ```swift
  if !hasCompletedOnboarding {
      OnboardingView()
  } else {
      // Existing authorization/tab flow
  }
  ```

---

### Phase 2: Welcome & Feature Screens

#### Task 4: Welcome Screen (Screen 1)
- **File:** `PageInstead/Features/Onboarding/WelcomeScreen.swift`
- **Content:**
  - Large app icon (SF Symbol: `book.fill`, size: 80-100pt)
  - App name: "PageInstead"
  - Headline: "PageInstead helps you take back your time — one book at a time"
  - Friendly, inviting design
  - "Get Started" button
- **Visual Style:** Clean, spacious, centered layout

#### Task 5: Feature Highlight 1 - Transform
- **File:** `PageInstead/Features/Onboarding/FeatureHighlightScreen.swift` (reusable component)
- **Content:**
  - Icon: `arrow.triangle.2.circlepath` or `arrow.clockwise.circle.fill` (80pt)
  - Title: "Stop doomscrolling, start transforming"
  - Description: "Break the cycle of mindless scrolling with intentional moments of inspiration"
  - Color: Blue gradient or solid blue
- **Navigation:** Swipeable or "Next" button

#### Task 6: Feature Highlight 2 - Replace
- **Content:**
  - Icon: `book.pages` or `lightbulb.fill` (80pt)
  - Title: "Replace distraction with wisdom"
  - Description: "We show quotes and insights from the best self-help books when you try to open distracting apps"
  - Color: Purple or teal
- **Navigation:** Swipeable or "Next" button

#### Task 7: Feature Highlight 3 - Habits
- **Content:**
  - Icon: `calendar.badge.checkmark` or `flame.fill` (80pt)
  - Title: "Build better habits"
  - Description: "Start building streaks of focused, intentional screen time"
  - Color: Orange or red
- **Navigation:** Swipeable or "Next" button

#### Task 8: Feature Highlight 4 - Discover
- **Content:**
  - Icon: `books.vertical.fill` or `sparkles` (80pt)
  - Title: "Discover books that fit your mindset"
  - Description: "PageInstead learns from your choices and suggests self-help books tailored to your personal growth goals"
  - Color: Green or mint
- **Navigation:** Swipeable or "Next" button

---

### Phase 3: Permissions & Authorization

#### Task 9: Permission Education Screen
- **File:** `PageInstead/Features/Onboarding/PermissionEducationScreen.swift`
- **Content:**
  - Title: "We need Screen Time access"
  - Visual: Mockup of iPhone showing quote shield (can use SF Symbols composition)
  - Explanation: "This lets PageInstead show inspiring quotes when you try to open distracting apps"
  - Privacy reassurance: "Your data stays private on your device"
  - Icon: `lock.shield.fill`
- **Navigation:** "Continue" button

#### Task 10: Authorization Request Screen
- **File:** `PageInstead/Features/Onboarding/AuthorizationScreen.swift`
- **Logic:**
  - Reuse/adapt existing `AuthorizationView` logic from ContentView.swift
  - Button triggers `ScreenTimeService.shared.requestAuthorization()`
  - Show loading spinner while awaiting response
  - Automatic progression on success
- **Content:**
  - "Grant Screen Time Access"
  - Button: "Allow Access"
  - Loading state: ProgressView

#### Task 11: Authorization error handling and retry UI
- **Handle States:**
  - `.denied` - Show retry button with instructions
  - Error message: "Oops! We need Screen Time access to show quotes"
  - Instructions: "Go to Settings > Screen Time > Family Controls and enable PageInstead"
  - "Try Again" button
  - "Skip for Now" option (with warning that app won't work fully)

---

### Phase 4: App Selection

#### Task 12: App Selection Intro Screen
- **File:** `PageInstead/Features/Onboarding/AppSelectionIntroScreen.swift`
- **Content:**
  - Title: "Choose apps to replace with quotes"
  - Visual: Row of popular app icons (Instagram, X, TikTok - use generic representations)
  - Subtitle: "When you tap these apps, you'll see an inspiring quote first"
  - Friendly tone: "Select your top distractions (social media, news apps, etc.)"
  - Icon: `app.badge.checkmark.fill`
- **Navigation:** "Select Apps" button

#### Task 13: Integrate FamilyActivityPicker in App Selection Screen
- **File:** `PageInstead/Features/Onboarding/AppSelectionScreen.swift`
- **Implementation:**
  ```swift
  .familyActivityPicker(
      isPresented: $isPickerPresented,
      selection: $screenTimeService.selectedApps
  )
  .onChange(of: screenTimeService.selectedApps) { newSelection in
      screenTimeService.applyShield(to: newSelection)
      // Proceed to success screen
  }
  ```
- **Handle:** User cancels picker - allow retry with "Select Apps" button

---

### Phase 5: Completion

#### Task 14: Success/Completion Screen
- **File:** `PageInstead/Features/Onboarding/SuccessScreen.swift`
- **Content:**
  - Celebratory icon: `checkmark.circle.fill` (100pt, green)
  - Title: "You're all set!"
  - Message: "Try opening a blocked app to see your first inspiring quote"
  - Encouraging note: "Books come first from now on"
- **Action:**
  - "Start Using PageInstead" button
  - Sets `hasCompletedOnboarding = true`
  - Dismisses to main TabView
- **Optional:** Confetti animation or subtle celebration effect

---

### Phase 6: Navigation & Polish

#### Task 15: Add page progress indicator
- **Implementation:** Native iOS page dots
- **Style:** `.indexViewStyle(.page(backgroundDisplayMode: .always))`
- **Shows:** Current position (e.g., screen 1 of 9)
- **Updates:** Automatically with swipes/navigation

#### Task 16: Add Next/Continue buttons to each screen
- **Styling:**
  - Prominent blue button (matching existing app style)
  - `.font(.headline)`, white text
  - `.frame(maxWidth: .infinity)`, `.padding()`, `.cornerRadius(12)`
  - Consistent across all screens
- **States:**
  - Default: "Next" or "Continue"
  - Loading: ProgressView (on authorization screen)
  - Disabled during async operations

#### Task 17: Add Skip button option on feature highlight screens
- **Screens:** Only on feature highlights (screens 2-5)
- **Action:** Jumps directly to Permission Education screen (screen 6)
- **Styling:**
  - Small text button, secondary color
  - Top-right or bottom-center position
  - Text: "Skip"

#### Task 18: Implement swipe-to-advance gesture
- **Implementation:** Built-in with `TabView` + `.tabViewStyle(.page)`
- **Behavior:**
  - Swipe left to advance
  - Swipe right to go back
  - Works alongside button taps
- **Screens:** Feature highlights are fully swipeable

#### Task 19: Add playful SF Symbols icons
- **Icon Sizing:** 80-100pt for main feature icons
- **Color Rendering:**
  - `.symbolRenderingMode(.multicolor)` for multi-color icons
  - `.foregroundStyle(.blue, .cyan)` for gradient effects
  - Single color with `.foregroundColor()` for simpler icons
- **Icons Selected:**
  - Welcome: `book.fill`
  - Transform: `arrow.triangle.2.circlepath`
  - Replace: `lightbulb.fill`
  - Habits: `flame.fill`
  - Discover: `sparkles`
  - Permission: `lock.shield.fill`
  - App Selection: `app.badge.checkmark.fill`
  - Success: `checkmark.circle.fill`

#### Task 20: Implement friendly microcopy and messaging
- **Tone Guidelines:**
  - Playful, encouraging, friendly
  - Short sentences, active voice
  - Avoid corporate/formal language
  - Use contractions (we'll, you'll, let's)
- **Examples:**
  - "Let's go!"
  - "You've got this"
  - "Almost there!"
  - "Nice! Time to pick your apps"
  - "Woohoo! You're ready to go"
- **Review:** All button labels, titles, descriptions for tone consistency

#### Task 21: Add subtle animations
- **Screen Transitions:** `.transition(.slide)` or `.transition(.opacity)`
- **Button States:** `.animation(.spring())` for press effects
- **Element Entrance:** `.transition(.move(edge: .bottom).combined(with: .opacity))`
- **Keep it lightweight:** Don't overdo animations, maintain performance
- **Examples:**
  ```swift
  .transition(.slide)
  .animation(.easeInOut(duration: 0.3), value: currentPage)
  ```

---

### Phase 7: Testing & Validation

#### Task 22: Test onboarding flow on device with fresh install
- **Setup:**
  - Clear UserDefaults: `UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")`
  - Or use Xcode: Product > Clean Build Folder, then reinstall
- **Test Cases:**
  - All screens display correctly
  - Text is readable in light and dark mode
  - Icons render properly
  - Buttons are tappable and responsive
  - Progress dots update correctly
- **Device Required:** Physical iPhone (Screen Time API doesn't work in Simulator)

#### Task 23: Verify authorization flow works correctly
- **Test Scenarios:**
  1. **Grant Authorization:** User taps "Allow Access" → System dialog → Grant → Proceeds to app selection
  2. **Deny Authorization:** User denies → Show error state → "Try Again" button works
  3. **Skip Authorization:** If skip option provided → Warning message → Can still proceed
- **Verify:** Transition to main TabView after completion

#### Task 24: Test app picker integration and shield application
- **Test Flow:**
  1. Reach app selection intro screen
  2. Tap "Select Apps" → FamilyActivityPicker appears
  3. Select multiple apps (try 2-3 apps)
  4. Confirm selection
  5. Verify picker dismisses and shows success screen
  6. Complete onboarding
  7. Exit app
  8. **Critical:** Open a blocked app → Verify quote shield appears
- **Validation:** Shields must work immediately after onboarding completes

---

## File Structure

```
PageInstead/Features/Onboarding/
├── OnboardingView.swift              # Main container with TabView
├── WelcomeScreen.swift               # Screen 1: Welcome
├── FeatureHighlightScreen.swift      # Reusable component for screens 2-5
├── PermissionEducationScreen.swift   # Screen 6: Explain Screen Time
├── AuthorizationScreen.swift         # Screen 7: Request authorization
├── AppSelectionIntroScreen.swift     # Screen 8: Explain picker
├── AppSelectionScreen.swift          # Screen 9: Show picker (optional separate file)
└── SuccessScreen.swift               # Screen 10: Completion
```

**Note:** `FeatureHighlightScreen.swift` should be a reusable component that accepts parameters:
```swift
FeatureHighlightScreen(
    icon: "lightbulb.fill",
    color: .purple,
    title: "Replace distraction with wisdom",
    description: "We show quotes and insights..."
)
```

---

## Key Design Decisions

### 1. Screen Count
- **9 total screens** (Welcome + 4 Features + Permission + Auth + App Intro + Success)
- Balances education with conciseness
- Users can skip feature screens if desired

### 2. Navigation Pattern
- **Swipeable pages** with visible progress dots
- **Next/Continue buttons** for explicit control
- **Skip option** on feature screens for returning users or impatient users

### 3. Visual Style
- **System theme** (automatic light/dark mode support)
- **SF Symbols** for all icons (no custom assets needed)
- **Playful colors** for feature screens (blue, purple, orange, green)
- **Spacious layout** with generous padding

### 4. Tone & Messaging
- **Playful and friendly** throughout
- **Encouraging language** ("You've got this!", "Let's go!")
- **Clear value proposition** on each screen
- **No jargon** - simple, conversational

### 5. Permissions Approach
- **Education first** - Explain why we need Screen Time access before requesting
- **Graceful handling** - Retry option if denied, clear instructions
- **No forced permissions** - User can theoretically skip (though app won't work)

### 6. App Selection
- **Native iOS picker** - Use FamilyActivityPicker (can't customize)
- **Intro screen critical** - Must explain what picker is before showing it
- **No app limit** - iOS doesn't support enforcing "max 3 apps" in picker

---

## What We're NOT Doing (Deferred Features)

### From Original Flutter Plan - Not Applicable to iOS:

1. **Daily time limits** - iOS Screen Time shields are binary (blocked or not), no time tracking
2. **Session limits** - Can't set "max opens per day" or "minutes per session" with shields
3. **Quote delay timers** - Shields can't auto-dismiss after countdown; user must dismiss
4. **Notification permissions** - Deferred for future "reminders" feature
5. **Analytics tracking** - No analytics implementation in MVP
6. **Custom app picker UI** - iOS provides system picker, can't customize
7. **Accessibility permission** - Not needed; iOS uses Screen Time API instead

---

## iOS-Specific Constraints

### Screen Time API Limitations:
- **System UI:** `FamilyActivityPicker` is a system component - no custom styling
- **Binary blocking:** Apps are either blocked (show shield) or not - no partial/timed blocks
- **User-controlled:** Users dismiss shields manually - no auto-unlock after delay
- **Privacy-focused:** Can't access app names/icons directly, only tokens

### Why These Constraints Are Okay:
- Respects user agency - users control when they proceed past shields
- Privacy-first design aligns with iOS philosophy
- Quote intervention still happens - that's the key behavior
- Simpler implementation = fewer bugs, faster MVP

---

## Implementation Notes

### Reusing Existing Code:
- **ScreenTimeService:** Already handles authorization and shield application
- **AuthorizationView:** Can be adapted for onboarding flow
- **FamilyActivityPicker:** Already implemented in AppSelectionView

### New Code Required:
- OnboardingView container
- Individual screen components (Welcome, Features, Permission Education, Success)
- Navigation/pagination logic
- AppStorage persistence
- ContentView integration

### SwiftUI Patterns to Use:
```swift
// Page-style TabView
TabView(selection: $currentPage) {
    WelcomeScreen().tag(0)
    FeatureHighlightScreen(...).tag(1)
    // etc.
}
.tabViewStyle(.page)
.indexViewStyle(.page(backgroundDisplayMode: .always))

// AppStorage for persistence
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

// Conditional view in ContentView
if hasCompletedOnboarding {
    // Main app
} else {
    OnboardingView()
}
```

---

## Testing Checklist

- [ ] Onboarding shows on fresh install
- [ ] All 9 screens display correctly
- [ ] Swipe navigation works
- [ ] Next/Continue buttons work
- [ ] Skip button works (feature screens)
- [ ] Progress dots update correctly
- [ ] Dark mode looks good
- [ ] Authorization flow succeeds
- [ ] Authorization denial handled gracefully
- [ ] App picker appears and works
- [ ] App selection persists
- [ ] Success screen appears
- [ ] Main app appears after completion
- [ ] Onboarding doesn't show again after completion
- [ ] Shields work immediately after onboarding
- [ ] No crashes or errors in flow

---

## Future Enhancements (Post-MVP)

1. **Animation polish:** Add more sophisticated transitions/micro-interactions
2. **Onboarding analytics:** Track completion rates, drop-off points
3. **A/B testing:** Test different messaging/screen orders
4. **Video previews:** Show actual shield in action (screen recording)
5. **Personalization:** Ask about user's goals/interests for better book recommendations
6. **Notification onboarding:** Add optional screen for notification permissions
7. **Reset option:** Settings toggle to "Re-show onboarding"
8. **Localization:** Support multiple languages

---

## Questions to Resolve Before Implementation

1. **Skip behavior:** If user skips feature screens, should we track that separately?
2. **Authorization failure:** Should we allow proceeding without authorization (app won't work)?
3. **App selection:** Should we require at least 1 app selected, or allow 0 apps?
4. **Animation budget:** How much time to spend on polish vs shipping quickly?
5. **Testing:** Do we want analytics/crash reporting in onboarding for beta testing?

---

## Related Files

- Current authorization: `PageInstead/App/ContentView.swift` (lines 34-124)
- App selection: `PageInstead/Features/Blocking/AppSelectionView.swift`
- Screen Time service: `PageInstead/Core/Services/ScreenTimeService.swift`
- Quote display: `PageInstead/Features/CurrentQuoteView.swift`

---

## Estimated Timeline

- **Foundation (Tasks 1-3):** 2-3 hours
- **Screen components (Tasks 4-14):** 6-8 hours
- **Navigation & polish (Tasks 15-21):** 4-6 hours
- **Testing & refinement (Tasks 22-24):** 2-4 hours

**Total:** 14-21 hours (2-3 full workdays)

---

**Status:** Ready for implementation
**Next Step:** Begin with Phase 1 (Foundation) tasks

---

**Notes:**
- This plan prioritizes MVP completion over perfection
- Design decisions favor iOS native patterns over custom solutions
- Implementation can be done incrementally (screen by screen)
- Testing on physical device is mandatory due to Screen Time API requirements
