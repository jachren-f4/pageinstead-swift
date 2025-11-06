# PageInstead Onboarding Flow - Complete Documentation

## Overview

The PageInstead onboarding flow is an 11-screen progressive experience designed to:
- Build emotional connection before requesting permissions
- Personalize the user experience based on preferences
- Guide users through essential setup steps
- Deliver an "aha moment" by having users experience the core product mechanic
- Complete the entire flow in under 90 seconds

**Total Screens**: 11
**Estimated Time**: 60-90 seconds
**Conversion Goal**: Get users to block at least 1 app and see their first quote shield

---

## Visual Design System

### Color Palette
- **Primary Purple**: `#6f42c1`
- **Accent Purple**: `#a17fe0`
- **Background Gradient**: `#1a0033` → `#330066` → `#6f42c1` (top to bottom, static)
- **Glass Overlay**: White 8% opacity with 20px blur
- **Success Green**: `#4ade80`

### Typography
- **Headings**: SF Pro Display, 36px, Bold (-1px letter spacing)
- **Subheadings**: SF Pro Text, 17px, Regular
- **Body Text**: SF Pro Text, 16px, Regular
- **Button Text**: SF Pro Text, 17px, Semibold

### Component Styles
- **Glass Cards**: White 8% bg, blur 20px, border white 10%, radius 24px
- **Primary Buttons**: Purple gradient (`#6f42c1` → `#a17fe0`), radius 16px, shadow
- **Secondary Buttons**: Transparent bg, white 20% border, radius 16px
- **Option Buttons**: White 8% bg, white 15% border, radius 16px
- **Chips**: White 8% bg, white 15% border, compact padding, adaptive radius

---

## Screen-by-Screen Breakdown

### Phase 1: Emotion & Purpose

#### Screen 1: Hero Moment
**Goal**: Evoke curiosity and introduce the core concept

**Layout**:
```
┌─────────────────────────────────┐
│                                 │
│   [Animated Hero Visual]        │
│      📱 → 📖                    │
│   (280px height, floating)      │
│                                 │
├─────────────────────────────────┤
│  What if every distraction      │
│  became a discovery?            │
│                                 │
│  PageInstead replaces mindless  │
│  scrolling with meaningful      │
│  moments.                       │
│                                 │
│  [See How It Works]             │
└─────────────────────────────────┘
```

**Components**:
- **Video Hero**: 280px animated visual with floating animation (phone morphing to book)
- **Title**: 36px bold, center-aligned
- **Subtitle**: 17px, 85% white opacity
- **Primary Button**: Full-width CTA

**User Action**: Tap "See How It Works" → Navigate to Screen 2

**Design Notes**:
- Button is fully visible without scrolling
- Hero animation loops continuously (3s float cycle)
- No "Skip" option - all users see value prop

---

#### Screen 2: The Difference
**Goal**: Position PageInstead as unique vs. traditional blockers

**Layout**:
```
┌─────────────────────────────────┐
│       The Difference            │
│                                 │
│  Most blockers say "no."        │
│  We say "here's something       │
│  better."                       │
│                                 │
│  ┌──────────┐  ┌──────────┐   │
│  │   🚫      │  │    ✨     │   │
│  │ Before   │  │  After   │   │
│  │ Punish-  │  │ Transform│   │
│  │ ment     │  │ Discover │   │
│  └──────────┘  └──────────┘   │
│                                 │
│         [Next]                  │
└─────────────────────────────────┘
```

**Components**:
- **Split Comparison**: Two side-by-side cards (before/after)
  - Before: Red tint (10% opacity), red border, prohibition symbol
  - After: Green tint (10% opacity), green border, sparkle icon
- **Icons**: 48px emoji
- **Card Text**: 13px, 80% white opacity

**User Action**: Tap "Next" → Navigate to Screen 3

---

#### Screen 3: How It Works
**Goal**: Simplify mechanics into three understandable steps

**Layout**:
```
┌─────────────────────────────────┐
│      How It Works               │
│  Three simple steps to mindful  │
│  productivity                   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🛡️  Block what drains   │   │
│  │     you                 │   │
│  │  Choose distracting apps│   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🕰️  See quotes instead  │   │
│  │  Each quote changes     │   │
│  │  throughout the day     │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 📈  Build Screen Health │   │
│  │  Watch your focus improve│   │
│  └─────────────────────────┘   │
│                                 │
│  [Personalize My Experience]   │
└─────────────────────────────────┘
```

**Components**:
- **Feature Cards**: 3 glass cards with icon + title + description
  - Icon: 32px emoji, left-aligned
  - Title: 17px semibold
  - Description: 14px, 70% opacity
- **Gap**: 16px between cards
- **Sequential Animation**: Cards slide in with 0.3s delay (mockup shows all at once)

**User Action**: Tap "Personalize My Experience" → Navigate to Screen 4

---

### Phase 2: Personalization

#### Screen 4: Gender
**Goal**: Capture demographic data for content personalization

**Layout**:
```
┌─────────────────────────────────┐
│    How do you identify?         │
│  This helps us personalize your │
│  experience                     │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Female                  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Male               ✓    │   │ ← Selected
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Non-binary / Prefer not │   │
│  │ to say                  │   │
│  └─────────────────────────┘   │
│                                 │
│         [Next]                  │
└─────────────────────────────────┘
```

**Components**:
- **Option Buttons**: Single-select (radio behavior)
  - Default: White 8% bg, white 15% border
  - Hover: White 15% bg, purple 50% border, slide right 5px
  - **Selected**: Purple gradient bg (50% opacity), purple border (3px), green checkmark ✓ on right

**Visual Indicators (Selected State)**:
- Background changes to purple gradient
- Border becomes thicker (3px) and purple
- Green checkmark (✓) appears on right side (24px, bold)
- Clear visual feedback that option was selected

**User Action**: Tap option → Auto-selects → Tap "Next" → Navigate to Screen 5

**Data Stored**: `onboarding_gender: String`

---

#### Screen 5: Age Group
**Goal**: Further refine content personalization

**Layout**: Same as Screen 4, but with 6 options:
- Under 18
- 18–24
- 25–34
- 35–44
- 45–54
- 55+

**User Action**: Tap option → Tap "Next" → Navigate to Screen 6

**Data Stored**: `onboarding_age_group: String`

---

#### Screen 6: Book Categories
**Goal**: Personalize quote library themes (up to 3 selections)

**Layout (V2 - Two Columns)**:
```
┌─────────────────────────────────┐
│ What kinds of books inspire     │
│ you most?                       │
│ Pick up to three         [V2]   │ ← Variant selector
│                                 │
│ ┌─────────┐  ┌─────────┐       │
│ │Self-help│  │Product- │       │
│ │& Growth │  │ivity &  │       │
│ │         │  │Focus    │       │
│ └─────────┘  └─────────┘       │
│                                 │
│ ┌─────────┐  ┌─────────┐       │
│ │Philosoph│  │Psycho-  │       │
│ │y & Mind-│  │logy &   │       │
│ │fulness  │  │Relations│       │
│ └─────────┘  └─────────┘       │
│                                 │
│ [... 6 more chips ...]          │
│                                 │
│ You can pick a few more if you  │
│ like.                           │
│                                 │
│         [Next]                  │
└─────────────────────────────────┘
```

**Components**:
- **Variant Selector**: 4 small buttons in top-right (V1, V2, V3, V4)
- **Chips (V2)**: 2-column grid, 10 total options
  - Size: 48px min-height
  - Text: Center-aligned, vertically centered
  - Single-line text: Perfectly centered
  - Multi-line text: Vertically centered in container
- **Multi-Select**: Up to 3+ selections allowed
- **Selected State**: Purple bg (40% opacity), purple border

**Options**:
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

**Layout Variants** (accessible via V1-V4 buttons):
- **V1**: Compact flowing rows (smallest, most compact)
- **V2**: 2-column grid (balanced, default) ← **Selected**
- **V3**: 3-column grid (most dense, text wraps)
- **V4**: Full-width vertical stack (largest tap targets)

**User Action**:
1. Tap 1-3+ chips to select
2. Tap "Next" → Navigate to Screen 7

**Data Stored**: `onboarding_book_categories: [String]`

---

### Phase 3: Setup & Education

#### Screen 7: Permissions
**Goal**: Build trust before requesting Screen Time API access

**Layout**:
```
┌─────────────────────────────────┐
│   We need your permission      │
│                                 │
│  PageInstead will need          │
│  permission to block apps. This │
│  allows us to replace           │
│  distractions with quotes.      │
│                                 │
│     ┌─────────────────┐         │
│     │                 │         │
│     │       🔒        │         │
│     │   [Mockup of    │         │
│     │   iOS Screen    │         │
│     │   Time Dialog]  │         │
│     │                 │         │
│     └─────────────────┘         │
│                                 │
│  ✓ Private and secure. Your    │
│    data stays on your device.  │
│                                 │
│            [OK]                 │
└─────────────────────────────────┘
```

**Components**:
- **Mockup Image**: 280×280px placeholder with lock icon
  - Dashed border (white 30% opacity)
  - White 10% background
- **Trust Indicator**: Green checkmark + reassurance text
- **Primary Button**: Triggers actual iOS permission dialog

**User Action**:
1. Tap "OK"
2. iOS shows native Screen Time permission dialog
3. User grants permission
4. Navigate to Screen 8

**System Behavior**:
```swift
try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
```

**Data Stored**: Permission status handled by iOS, tracked in app state

---

#### Screen 8: App Selection
**Goal**: Get user to block at least 1 app

**Layout**:
```
┌─────────────────────────────────┐
│   Let's block a few apps        │
│                                 │
│  Choose apps you want to take a │
│  break from. You can change     │
│  these anytime.                 │
│                                 │
│     ┌─────────────────┐         │
│     │                 │         │
│     │       📱        │         │
│     │   [Mockup of    │         │
│     │   iOS Family    │         │
│     │   Activity      │         │
│     │   Picker]       │         │
│     │                 │         │
│     └─────────────────┘         │
│                                 │
│            [OK]                 │
└─────────────────────────────────┘
```

**Components**:
- **Mockup Image**: 280×280px placeholder with phone icon
- **Reassurance Text**: "You can change these anytime"
- **Primary Button**: Launches FamilyActivityPicker

**User Action**:
1. Tap "OK"
2. iOS shows FamilyActivityPicker sheet
3. User selects 1+ apps to block
4. Dismiss picker
5. Navigate to Screen 9

**System Behavior**:
```swift
@State private var selection = FamilyActivitySelection()
// Present picker sheet
// On dismiss, create first app group with selected apps
```

**Data Stored**:
- `AppGroup` created with name "My First Group"
- `applicationTokens` and `webDomainTokens` stored
- Shields applied via `ScreenTimeService`

---

#### Screen 9: How Unlock Works
**Goal**: Explain unlock mechanism to prevent user confusion

**Layout**:
```
┌─────────────────────────────────┐
│   How to unlock apps            │
│                                 │
│  Need to check an app later?    │
│  Just open PageInstead and tap  │
│  the unlock icon. This unlocks  │
│  everything for 30 seconds.     │
│                                 │
│     🛡️  →  📱  →  🔓           │
│   Shield  App  Unlock           │
│                                 │
│                                 │
│          [Got It]               │
└─────────────────────────────────┘
```

**Components**:
- **3-Step Illustration**: Shield → App Icon → Unlock
  - Icons: 48px emoji
  - Arrows: 24px, 50% opacity
- **Explanation Text**: Clear, concise instructions
- **Primary Button**: Confirmation

**Key Points Explained**:
1. Unlock happens IN THE MAIN APP (not in shield)
2. Lock button is in top-right of Current Quote view
3. 30-second temporary unlock window
4. Shields auto-reapply after timeout

**User Action**: Tap "Got It" → Navigate to Screen 10

---

### Phase 4: Completion & Discovery

#### Screen 10: Setup Complete
**Goal**: Celebrate completion and provide closure

**Layout**:
```
┌─────────────────────────────────┐
│  🎊 [Confetti Animation] 🎊     │
│                                 │
│         All set!                │
│                                 │
│  You've created your first      │
│  mindful space. From now on,    │
│  when you open a blocked app,   │
│  we'll greet you with           │
│  inspiration instead of noise.  │
│                                 │
│  ┌─────────────────────────┐   │
│  │ "Between stimulus and   │   │
│  │ response there is a     │   │
│  │ space. In that space is │   │
│  │ our power to choose."   │   │
│  │                         │   │
│  │      — Viktor Frankl    │   │
│  └─────────────────────────┘   │
│                                 │
│        [Continue]               │
└─────────────────────────────────┘
```

**Components**:
- **Confetti Animation**: 50 particles falling from top (2s duration)
  - Colors: Purple palette (`#6f42c1`, `#a17fe0`, `#c4b5fd`, `#e9d5ff`)
  - Physics: Rotation + gravity simulation
- **Glass Quote Card**: Featuring Viktor Frankl quote
  - Italic text: 18px
  - Author attribution: Right-aligned, 70% opacity
- **Primary Button**: Advance to final screen

**Animation Sequence**:
1. Screen appears → Confetti bursts
2. Medium haptic feedback
3. Quote card fades in (0.3s delay)
4. Button slides up (0.5s delay)

**User Action**: Tap "Continue" → Navigate to Screen 11

**Data Stored**: `onboarding_completed: Bool = false` (still)

---

#### Screen 11: Try It Now
**Goal**: Deliver "aha moment" by having user experience the core mechanic

**Layout (State A: Before Shield Seen)**:
```
┌─────────────────────────────────┐
│   Ready to see it in action?    │
│                                 │
│  Open one of the apps you just  │
│  blocked — like Instagram or    │
│  TikTok. You'll see your first  │
│  quote appear there.            │
│                                 │
│           📱                    │
│    (bouncing animation)         │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 📱 How to try it now:   │   │
│  │                         │   │
│  │ 1. Press Home or swipe  │   │
│  │    up to go home.       │   │
│  │ 2. Open any blocked app.│   │
│  │ 3. When you see quote,  │   │
│  │    come back here.      │   │
│  └─────────────────────────┘   │
│                                 │
│  Waiting for your first shield  │
│  to appear ...                  │
│                                 │
│      [Try It Now]               │
│      [Skip for Now]             │
└─────────────────────────────────┘
```

**Components (State A)**:
- **Illustration**: Phone emoji with gentle bounce (2s cycle)
- **Instruction Card**: Glass card with 3-step guide
  - Numbered list, 14px
  - White 80% opacity text
- **Status Text**: Pulsing animation (2s fade cycle)
- **Primary Button**: "Try It Now" - triggers app minimization
- **Secondary Button**: "Skip for Now" (disabled for 10 seconds)

**User Actions (State A)**:
1. Read instructions
2. Tap "Try It Now"
3. App minimizes to background
4. User navigates to home screen
5. User opens blocked app (e.g., Instagram)

---

**Layout (State B: After Shield Detected)**:
```
┌─────────────────────────────────┐
│  🎊 [Mini Confetti] 🎊          │
│                                 │
│   Nice job — you just met       │
│   your first quote!             │
│                                 │
│  That's how PageInstead works:  │
│  every time you reach for a     │
│  distraction, you'll see        │
│  something worth reading        │
│  instead.                       │
│                                 │
│           🎉                    │
│                                 │
│  ┌─────────────────────────┐   │
│  │ "The reading of all     │   │
│  │ good books is like a    │   │
│  │ conversation with the   │   │
│  │ finest minds..."        │   │
│  │                         │   │
│  │ Visit PageInstead to    │   │
│  │ Unlock                  │   │
│  └─────────────────────────┘   │
│                                 │
│   [Continue to PageInstead]    │
└─────────────────────────────────┘
```

**Components (State B)**:
- **Mini Confetti**: 20 particles from top (1.5s duration)
- **Celebration Icon**: Party emoji
- **Shield Preview Card**: Mock of what they just saw
  - Example quote in italic
  - "Visit PageInstead to Unlock" text
  - Purple tinted background (10% opacity)
- **Primary Button**: "Continue to PageInstead"

**User Actions (State B)**:
1. App automatically transitions to State B when shield was seen
2. Celebrate with confetti
3. Read confirmation
4. Tap "Continue to PageInstead"
5. Navigate to main app (Current Quote tab)

---

## Technical Implementation: "Try It Now" Flow

### Step-by-Step Process

#### 1. User Taps "Try It Now" Button
```swift
func tryItNow() {
    // Minimize the app to background
    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))

    // OR use scene-based approach (iOS 13+)
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        scene.windows.first?.rootViewController?.view.endEditing(true)
    }
}
```

#### 2. App Minimizes to Background
- iOS returns user to home screen
- PageInstead enters background state
- Screen 11 remains in "State A" (waiting mode)

#### 3. User Opens Blocked App
- User taps Instagram (or any blocked app)
- iOS triggers Shield Configuration Extension

#### 4. Shield Extension Displays Quote
```swift
// ShieldConfigurationExtension.swift
func configuration(shielding application: Application) -> ShieldConfiguration {
    // Get current quote from QuoteScheduler
    let quote = QuoteScheduler.shared.getCurrentQuote()

    // Increment health score counter
    incrementBlockedAttempts()

    // CRITICAL: Set flag that shield was seen
    let defaults = UserDefaults(suiteName: "group.com.pageinstead")
    defaults?.set(true, forKey: "firstShieldSeen")
    defaults?.set(Date(), forKey: "firstShieldSeenDate")
    defaults?.synchronize()

    // Return shield configuration with quote
    return ShieldConfiguration(
        backgroundBlurStyle: .systemMaterial,
        backgroundColor: UIColor(red: 0.1, green: 0, blue: 0.2, alpha: 1),
        icon: UIImage(systemName: "book.fill"),
        title: ShieldConfiguration.Label(
            text: formatQuoteText(quote.text),
            color: .white
        ),
        subtitle: ShieldConfiguration.Label(
            text: "— \(quote.author)",
            color: UIColor.white.withAlphaComponent(0.7)
        ),
        primaryButtonLabel: nil, // No button in shield (unreliable)
        primaryButtonBackgroundColor: nil,
        secondaryButtonLabel: ShieldConfiguration.Label(
            text: "Visit PageInstead to unlock",
            color: UIColor.systemPurple.withAlphaComponent(0.8)
        )
    )
}
```

#### 5. User Returns to PageInstead
- User swipes up or taps PageInstead icon
- App comes back to foreground
- `sceneDidBecomeActive` is triggered

#### 6. App Detects Shield Was Seen
```swift
// ContentView.swift or OnboardingCoordinator.swift
.onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
    checkForFirstShieldSeen()
}

func checkForFirstShieldSeen() {
    guard currentOnboardingScreen == 11 else { return }

    let defaults = UserDefaults(suiteName: "group.com.pageinstead")
    let shieldSeen = defaults?.bool(forKey: "firstShieldSeen") ?? false

    if shieldSeen && !hasTransitionedToStateB {
        transitionToStateB()
    }
}
```

#### 7. Transition to State B
```swift
func transitionToStateB() {
    hasTransitionedToStateB = true

    // Trigger mini confetti
    createMiniConfetti()

    // Haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()

    // Animate to State B with crossfade
    withAnimation(.easeInOut(duration: 0.4)) {
        screen11State = .afterShield
    }
}
```

#### 8. User Taps "Continue to PageInstead"
```swift
func completeOnboarding() {
    // Mark onboarding as completed
    UserDefaults.standard.set(true, forKey: "onboarding_completed")
    UserDefaults.standard.set(Date(), forKey: "onboarding_completed_date")

    // Navigate to main app
    withAnimation {
        showOnboarding = false
        selectedTab = 0 // Current Quote tab
    }
}
```

---

### Edge Cases & Error Handling

#### User Doesn't Open Blocked App
**Problem**: User minimizes, gets confused, returns without opening app

**Solution**:
```swift
// After 2 minutes in background, show tooltip
if timeInBackground > 120 && !shieldSeen {
    showTooltip = true
    tooltipMessage = "Try opening one of your blocked apps like Instagram or TikTok to see the quote shield."
}
```

#### User Skips "Try It Now"
**Problem**: User taps "Skip for Now" button (after 10s delay)

**Solution**:
```swift
func skipTryItNow() {
    // Mark onboarding as completed (but note they skipped)
    UserDefaults.standard.set(true, forKey: "onboarding_completed")
    UserDefaults.standard.set(true, forKey: "skipped_try_it_now")

    // Show in-app tutorial tooltip on first main app load
    UserDefaults.standard.set(false, forKey: "has_seen_unlock_tutorial")

    completeOnboarding()
}
```

#### Shield Extension Cached
**Problem**: iOS caches shield, flag not written immediately

**Solution**:
```swift
// Poll App Group defaults every 2 seconds while in State A
Timer.publish(every: 2, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        if screen11State == .beforeShield {
            checkForFirstShieldSeen()
        }
    }
```

#### No Apps Blocked
**Problem**: User granted permission but selected 0 apps in Screen 8

**Solution**:
- Disable "Try It Now" button
- Show message: "You haven't blocked any apps yet. Go back to Screen 8 to select apps."
- Provide "Go Back" button

---

## Data Collection & Storage

### UserDefaults (Standard)
```swift
// Onboarding state
"onboarding_completed": Bool
"onboarding_step": Int // For resuming if interrupted
"onboarding_completed_date": Date
"onboarding_version": String // "v5"

// Personalization data
"onboarding_gender": String // "Female", "Male", "Non-binary"
"onboarding_age_group": String // "25-34"
"onboarding_book_categories": [String] // ["Self-help & Growth", ...]

// Behavioral flags
"skipped_try_it_now": Bool
"has_seen_unlock_tutorial": Bool
```

### UserDefaults (App Group)
```swift
// App Group: group.com.pageinstead

// Shield detection
"firstShieldSeen": Bool
"firstShieldSeenDate": Date

// Health score data (initialized during onboarding)
"install_date": Date
"blocked_attempts_today": Int
"last_attempt_date": String
"baseline_attempts": Int
"is_calibrated": Bool
```

### Core Data / Persistent Storage
```swift
// AppGroup model (created in Screen 8)
AppGroup(
    id: UUID(),
    name: "My First Group",
    icon: "shield.fill",
    applicationTokens: Set<ApplicationToken>,
    webDomainTokens: Set<WebDomainToken>,
    pauseForSeconds: 30,
    dailyOpenLimit: nil,
    blockAfterMaxUse: false,
    schedule: AppGroupSchedule(alwaysActive: true),
    streakDays: 0,
    lastUsedDate: nil
)
```

---

## Analytics Events (If Implemented)

### Recommended Tracking

```swift
// Phase 1
analytics.track("onboarding_started")
analytics.track("onboarding_screen_viewed", properties: ["screen": 1])
analytics.track("onboarding_screen_viewed", properties: ["screen": 2])
analytics.track("onboarding_screen_viewed", properties: ["screen": 3])

// Phase 2
analytics.track("onboarding_gender_selected", properties: ["gender": "Female"])
analytics.track("onboarding_age_selected", properties: ["age_group": "25-34"])
analytics.track("onboarding_categories_selected", properties: [
    "categories": ["Self-help & Growth", "Productivity & Focus"],
    "count": 2
])

// Phase 3
analytics.track("onboarding_permission_requested")
analytics.track("onboarding_permission_granted")
analytics.track("onboarding_apps_selected", properties: [
    "count": 3,
    "has_social": true
])

// Phase 4
analytics.track("onboarding_setup_complete")
analytics.track("onboarding_try_it_now_tapped")
analytics.track("onboarding_first_shield_seen", properties: [
    "time_to_shield": 15 // seconds
])
analytics.track("onboarding_completed")
analytics.track("onboarding_skipped", properties: ["last_screen": 11])
```

---

## Conversion Funnel

### Expected Drop-Off Points

| Screen | Expected Retention | Drop-Off Rate |
|--------|-------------------|---------------|
| 1 → 2  | 85-90% | 10-15% |
| 2 → 3  | 95% | 5% |
| 3 → 4  | 95% | 5% |
| 4 → 5  | 98% | 2% |
| 5 → 6  | 98% | 2% |
| 6 → 7  | 95% | 5% |
| **7 → 8** | **70-80%** | **20-30%** ← Critical (permission) |
| 8 → 9  | 90% | 10% |
| 9 → 10 | 98% | 2% |
| 10 → 11 | 98% | 2% |
| **11 → Complete** | **80-90%** | **10-20%** ← Some may skip |

**Overall Completion Rate Target**: 50-60%

---

## Accessibility Features

### VoiceOver Support
- All screens fully narrated
- Custom hints for interactive elements
- Grouped content for logical flow

Example:
```swift
Text("What if every distraction became a discovery?")
    .accessibilityLabel("What if every distraction became a discovery?")
    .accessibilityHint("Tagline explaining PageInstead's core concept")

Button("See How It Works") { }
    .accessibilityLabel("See How It Works")
    .accessibilityHint("Double tap to learn how PageInstead works")
```

### Dynamic Type
- All text scales with system font size settings
- Layout adapts to prevent overflow
- Buttons remain tappable at all sizes

### Reduced Motion
- Confetti animation disabled
- Crossfade transitions instead of slides
- No parallax or floating effects

### Color Contrast
- All text meets WCAG AA standards (4.5:1 minimum)
- Selected states have clear visual indicators
- Not dependent on color alone (checkmarks, borders, icons)

---

## Localization Considerations

### Supported Languages (Future)
- English (default)
- Spanish
- French
- German
- Japanese
- Chinese (Simplified)

### Text That Needs Translation
- All screen titles, subtitles, body text
- Button labels
- Option labels (gender, age, categories)
- Instruction text
- Toast/alert messages

### RTL Language Support
- Layout mirrors for Arabic, Hebrew
- Icons flip horizontally
- Text alignment reversed

---

## Testing Checklist

### Unit Tests
- [ ] QuoteScheduler returns different quotes at different times
- [ ] App Group UserDefaults read/write works correctly
- [ ] Shield Extension sets `firstShieldSeen` flag
- [ ] State transition logic (A → B) is correct
- [ ] Skip button enables after 10 seconds

### UI Tests
- [ ] All 11 screens navigate correctly
- [ ] Buttons are tappable
- [ ] Text is readable
- [ ] Animations don't block interaction
- [ ] Selected states are visually clear

### Integration Tests
- [ ] Screen Time permission request works
- [ ] FamilyActivityPicker launches and returns selection
- [ ] App Group created with selected apps
- [ ] Shields are applied after Screen 8
- [ ] Opening blocked app shows shield
- [ ] Returning to app transitions to State B

### Device Testing
- [ ] iPhone 14 Pro Max (large screen)
- [ ] iPhone SE 3rd gen (small screen)
- [ ] iPad (if supported)
- [ ] Dark Mode
- [ ] Light Mode (if applicable)
- [ ] VoiceOver enabled
- [ ] Increased font size
- [ ] Reduced motion enabled

---

## Known Limitations

### iOS Simulator
- FamilyActivityPicker shows disabled state
- Screen Time authorization auto-approves
- Shield Extension doesn't trigger
- Can't test full "Try It Now" flow

**Workaround**: Always test onboarding on physical device

### Shield Extension Reliability
- iOS may cache shield configurations
- Callbacks are unreliable on device
- No way to force refresh from main app

**Workaround**: Use App Group UserDefaults for communication, poll periodically

### Background State Detection
- App may be terminated while minimized
- `sceneDidBecomeActive` may not fire reliably
- User may force-quit app

**Workaround**: Resume onboarding on next launch if incomplete

---

## Future Enhancements

### V2 Features (Post-Launch)
- [ ] Video demo on Screen 1 (replace static emoji)
- [ ] Animated illustrations for Screen 3 features
- [ ] Preset app group templates in Screen 8 ("Social Media", "News", "Games")
- [ ] Live preview of quote in Screen 11 before minimizing
- [ ] Onboarding progress indicator (dots at bottom)
- [ ] Ability to go back to previous screens
- [ ] Save/resume progress if app is closed mid-onboarding

### A/B Testing Opportunities
- Screen 1: Video hero vs. static illustration
- Screen 2: Split comparison vs. carousel
- Screen 6: V1 vs. V2 vs. V3 layouts
- Screen 7: Permission timing (earlier vs. later)
- Screen 11: "Try It Now" mandatory vs. skippable

---

## Conclusion

The PageInstead onboarding flow balances **emotional storytelling**, **personalization**, **education**, and **hands-on experience** to convert new users into engaged participants.

**Key Success Metrics**:
- ✅ Permission grant rate > 70%
- ✅ At least 1 app blocked > 85%
- ✅ First shield seen > 60%
- ✅ Overall completion > 50%

**Critical Moments**:
1. **Screen 1**: Hook with emotional value proposition
2. **Screen 7**: Build trust before requesting permission
3. **Screen 8**: Get commitment (block at least 1 app)
4. **Screen 11B**: Deliver "aha moment" (see the magic)

By the end of onboarding, users should feel:
- **Inspired** by the concept
- **Confident** they understand how it works
- **Excited** to reduce distractions
- **Empowered** by seeing the product in action

---

**Document Version**: 1.0
**Last Updated**: 2025-01-03
**Author**: Claude (based on v5 specification)
