# PageInstead Onboarding Flow (v5) – Full Specification

This document describes the complete user onboarding experience for PageInstead, combining the emotional storytelling, personalization, and education sequences into an elegant and fast 11-screen journey.

---

## 🪞 Overview

### Goals
- Guide new users through PageInstead’s purpose and setup in under 90 seconds.
- Build emotional connection before asking for permissions.
- Deliver an “aha” moment by making users experience the quote shield first.
- Minimize friction while maintaining trust and clarity.

### Structure
| Phase | Focus | Screens |
|-------|--------|----------|
| Phase 1 | Emotion & Purpose | 1–3 |
| Phase 2 | Personalization | 4–6 |
| Phase 3 | Setup & Education | 7–9 |
| Phase 4 | Completion & Discovery | 10–11 |

---

## Phase 1 – Emotion & Purpose

### Screen 1 – Hero Moment
**Goal:** Introduce the concept and evoke curiosity.

**Visuals:**
- Top 2/3 of the screen: looping demo video (e.g., user tapping Instagram → morphs into a book cover → quote appears).
- Transparent → opaque purple gradient overlay (100% → 0%).
- Bottom 1/3: solid purple container.

**Text:**
> *What if every distraction became a discovery?*  
> *PageInstead replaces mindless scrolling with meaningful moments.*

**Button:** `See How It Works`  
*(Single primary button, no “Skip Intro.”)*

**Animation:**
- Background video fades in smoothly.
- Button slides up with slight bounce.

---

### Screen 2 – The Difference
**Goal:** Show what makes PageInstead unique.

**Visuals:**
Split-screen or carousel comparison:

| Before PageInstead | With PageInstead |
|--------------------|------------------|
| Grayed out social media icons | Icons glowing with golden aura |
| Red prohibition symbol | Book covers and quotes emerging |
| Text: “Traditional app blockers feel like punishment.” | Text: “Transform distractions into discoveries.” |

**Copy:**
> *Most blockers say “no.”*  
> *We say “here’s something better.”*

**Button:** `Next`

---

### Screen 3 – How It Works
**Goal:** Simplify core mechanics into three steps.

**Visuals:** Three illustrated cards (animated icons).

| Icon | Title | Description |
|------|--------|-------------|
| 🛡️ Shield | Block what drains you | Choose distracting apps to shield. |
| 🕰️ Clock | See quotes instead | Each quote changes throughout the day. |
| 📈 Chart | Build your Screen Health Score | Watch your focus improve. |

**Button:** `Personalize My Experience`

**Animation:**
- Each card slides in sequentially (0.3 s delay).
- Button fades in last.

---

## Phase 2 – Personalization

### Screen 4 – Gender
**Goal:** Capture tone/curation preferences.

**Prompt:**
> *How do you identify?*

**Options:**
- Female  
- Male  
- Non-binary / Prefer not to say

**Button:** `Next`

---

### Screen 5 – Age Group
**Prompt:**
> *What’s your age group?*

**Options:**
- Under 18  
- 18–24  
- 25–34  
- 35–44  
- 45–54  
- 55+

**Button:** `Next`

---

### Screen 6 – Favorite Book Categories
**Goal:** Personalize quote library themes.

**Prompt:**
> *What kinds of books inspire you most?*  
> *(Pick up to three.)*

**Options (multi-select chips):**
- Self-help & Growth  
- Productivity & Focus  
- Philosophy & Mindfulness  
- Psychology & Relationships  
- Business & Leadership  
- Creativity & Art  
- Spirituality & Meaning  
- Women’s Empowerment  
- Classics & Literature  
- Science & Nature

**Microcopy:** “You can pick a few more if you like.”  
**Button:** `Next`

---

## Phase 3 – Setup & Education

### Screen 7 – Permissions
**Goal:** Gain trust before requesting Screen Time API access.

**Visuals:**
Mock iOS permission popup image with arrow pointing at “Continue”.

**Text:**
> *PageInstead will need permission to block harmful apps.*  
> *This allows us to replace distractions with quotes.*

**Below image:**  
✅ “Private and secure. Your data stays on your device.”

**Button:** `OK` (triggers FamilyControls permission)

**Animation:**
- Image fades in with gentle scale-up.
- Button pulsates slightly after 1 s delay.

---

### Screen 8 – App Selection
**Goal:** Get the user to block at least one app.

**Visuals:**
Mock iOS App Picker image with arrow pointing at “Select Apps.”

**Text:**
> *Let’s block a few apps you want to take a break from.*  
> *You can change these anytime.*

**Button:** `OK` (launches FamilyActivityPicker)

**Animation:**
- Mock image parallax shift on scroll.
- Button glows briefly on tap.

---

### Screen 9 – How Unlock Works
**Goal:** Explain the unlock logic simply.

**Visuals:** 3-step static illustration (Shield → App Icon → Unlock).

**Text:**
> *Need to check an app later? Just open PageInstead and tap the unlock icon.*  
> *This unlocks everything for 30 seconds.*

**Button:** `Got It`

---

## Phase 4 – Completion & Discovery

### Screen 10 – Setup Complete

**Purpose:** Celebrate completion and closure.

**Text:**
> *All set!*  
> *You’ve created your first mindful space.*  
> *From now on, when you open a blocked app, we’ll greet you with inspiration instead of noise.*

**Quote Card:**  
> *“Between stimulus and response there is a space. In that space is our power to choose.”*  
> — Viktor Frankl

**Button:** `Continue`

**Visuals & Animation:**
- Purple–indigo gradient background with shimmer.  
- Confetti effect (`ConfettiSwiftUI` or `CAEmitterLayer`).  
- Haptic feedback (medium impact).  
- Button triggers fade transition to next screen.

---

### Screen 11 – Try It Now

**Goal:** Let user see the quote shield before entering main UI.

#### **State A – Before Shield Seen**

**Text:**
> *Ready to see it in action?*  
> *Open one of the apps you just blocked — like Instagram or TikTok.*  
> *You’ll see your first quote appear there.*

**Instruction Card:**
📱 **How to try it now:**  
1. Press the Home button or swipe up.  
2. Open any blocked app.  
3. When you see the quote, come back here.

**Status:** “Waiting for your first shield to appear…”  
**Buttons:**  
- Primary: `Try It Now`  
- Secondary: `Skip for Now` (disabled for 10 s)

#### **State B – After Shield Detected**

**Text:**
> *Nice job — you just met your first quote!*  
> *Every time you reach for a distraction, you’ll see something worth reading instead.*

**Visual:** Glass card mock of quote shield.  
**Button:** `Continue to PageInstead`

**Animation & State Logic:**
- On appear → gentle bounce of `Try It Now`.  
- When app minimized → fade to waiting state.  
- On return + `firstShieldSeen == true`:  
  - Crossfade to “Nice job” state.  
  - Small confetti burst.  
  - Haptic feedback.

**Technical Behavior:**
- `firstShieldSeen` flag stored in App Group UserDefaults.  
- Checked via `sceneDidBecomeActive`.  
- After completion, routes to main Quote screen.

---

## 🎨 Visual Design Notes

| Element | Spec |
|----------|------|
| **Typography** | SF Pro Display (headings), SF Pro Text (body) |
| **Primary Color** | `#6F42C1` (Purple) |
| **Accent Color** | `#A17FE0` |
| **Backgrounds** | Soft gradients, glass blur layers with translucency |
| **Button Radius** | 16 pt |
| **Quote Card** | Glass blur, 80% opacity white overlay, shadow radius 12 |
| **Transitions** | Crossfade (0.4 s), Slide (0.5 s), EaseInOut curve |
| **Confetti Palette** | Lavender, Purple, Silver |

---

## ✅ Flow Summary

| Step | Focus | Emotion |
|------|--------|----------|
| 1 | Visual wow | Curiosity |
| 2–3 | Value clarity | Understanding |
| 4–6 | Personalization | Ownership |
| 7–8 | Permissions | Trust |
| 9 | Unlock tutorial | Competence |
| 10 | Completion | Celebration |
| 11 | First shield | Aha moment |

---

**End of Specification**
