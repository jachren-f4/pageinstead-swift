# PageInstead Onboarding Flow (v5) – Final Screens

## 🎉 Screen 10 – Setup Complete

### Purpose
Celebrate completion, trigger a short dopamine hit, and mark emotional closure before the “Try It Now” moment.

### User-Facing Copy

**Title:**  
*All set!*

**Subtitle:**  
*You’ve created your first mindful space.*  
*From now on, when you open a blocked app, we’ll greet you with inspiration instead of noise.*

**Quote Card:**  
*“Between stimulus and response there is a space. In that space is our power to choose.”*  
— Viktor Frankl

**Button:**  
`Continue`

**VoiceOver Hint:**  
“Double-tap to continue to your first test experience.”

### Layout Spec

| Element | Position | Style |
|----------|-----------|-------|
| Background | Full-screen purple-to-indigo animated gradient (matches hero video tone) | Subtle vertical shimmer |
| Confetti Emitter | Top center → downward spread; `CAEmitterLayer` or `ConfettiSwiftUI` | Duration ≈ 2 s; velocity ≈ 80; fade out |
| Title | Center top (safe area + 48 pt) | SF Pro Display Bold 28 pt, white |
| Subtitle | Below title + 16 pt margin | SF Pro Text Regular 17 pt, 80% white |
| Quote Card | Centered vertically | 320 pt wide × 200 pt high; glass blur + drop shadow |
| Continue Button | Bottom safe area − 32 pt | Primary purple button, full width, rounded |

**Animation Cues**
- On appear → confetti burst + medium haptic
- `Continue` tap → fade out → Screen 11 slide-in from right

---

## 🚀 Screen 11 – Try It Now

### Purpose
Drive user to experience their *first shield moment* immediately after onboarding, before entering main app content.

### User-Facing Copy (State A – Before Shield Seen)

**Title:**  
*Ready to see it in action?*

**Body:**  
*Open one of the apps you just blocked — like Instagram or TikTok.*  
*You’ll see your first quote appear there.*

**Instruction Tip Card (Glass Overlay):**  
📱 **How to try it now**  
1. Press the Home button or swipe up to go to your home screen.  
2. Open any blocked app.  
3. When you see the quote, come back here.

**Status Message Below Tip:**  
“Waiting for your first shield to appear …”

**Primary Button:**  
`Try It Now`

**Secondary Button:**  
`Skip for Now` — disabled until 10 seconds passed (prevents accidental skip)

**VoiceOver Hint:**  
“Double-tap to minimize PageInstead and open one of your blocked apps.”

---

### User-Facing Copy (State B – After Shield Detected)

**Title:**  
*Nice job — you just met your first quote!*

**Body:**  
*That’s how PageInstead works: every time you reach for a distraction, you’ll see something worth reading instead.*

**Quote Preview Image:**  
Glass card mock showing quote and “Visit PageInstead to Unlock” text.

**Primary Button:**  
`Continue to PageInstead`

---

### Layout Spec

| Element | Position | Style |
|----------|-----------|-------|
| Background | Soft off-white → lavender gradient, animated slow pulse | Matches end of onboarding |
| Illustration | Center top (≈ 220 pt height) | Minimal vector: phone + app icons + shield overlay |
| Tip Card | Below illustration (280 pt wide) | Glass blur, rounded XL, small shadow |
| Status Text | Center bottom − 80 pt | SF Pro Text Medium 16 pt, purple 70% |
| Buttons | Bottom safe area stack | Primary + secondary |

**Animation Cues**
- On appear → gentle bounce of “Try It Now” button.  
- When app goes to background → fade to dimmed state.  
- When user returns and `firstShieldSeen == true`:  
  - Auto-transition (A → B) with dissolve animation.  
  - Small confetti burst (top only) + light haptic.

---

### State Logic

| State | Trigger | Transition |
|-------|----------|-------------|
| A – Waiting | `firstShieldSeen == false` | User taps “Try It Now” → minimize app |
| Background task | FamilyControls extension fires → write `firstShieldSeen = true` to App Group UserDefaults |
| Foreground resume | Detect flag true → switch to State B |
| B – Completed | User sees “Nice job” → taps “Continue to PageInstead” |
| Post-B | Route to MainTabView (Quotes tab default) |

---

### Implementation Tips
- Use `sceneDidBecomeActive` to poll UserDefaults flag once per session.  
- Guard against multiple confetti bursts with `hasCelebratedShield = true`.  
- If user never triggers shield within 2 minutes, show tooltip: “Try again later from Settings → Blocked Apps.”  
- Ensure background return flow is smooth (no double animation stack).

---

### ✅ Why This Sequence Works
1. **Screen 10** rewards effort → closure.  
2. **Screen 11A** creates curiosity → motivates action.  
3. **Shield event** delivers the *aha moment*.  
4. **Screen 11B** anchors habit association.  
5. **Main UI** follows only after core mechanic experienced.
