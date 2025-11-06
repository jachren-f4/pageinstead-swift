# Family Controls Distribution Entitlement Request Guide

## ⚠️ Critical Blocker for TestFlight Distribution

You **cannot distribute PageInstead to TestFlight or App Store** without Apple's approval for the Family Controls Distribution entitlement. This is a mandatory review process.

**Timeline**: 3-6 weeks (typically 4 weeks)
**Cost**: Free, but requires active Apple Developer account
**Status Tracking**: None available (no confirmation email or ticket ID)

---

## Why This Is Required

PageInstead uses Apple's **Screen Time APIs**:
- `FamilyControls` framework (app blocking)
- `ManagedSettings` framework (shield configuration)
- `DeviceActivity` framework (monitoring)

These APIs require:
- **Development**: `Family Controls (Development)` - works automatically ✅
- **Distribution**: `Family Controls (Distribution)` - requires Apple approval ❌

You currently have development entitlement (working on your device), but need distribution approval for TestFlight/App Store.

---

## Step 1: Prepare Your Request

Before submitting, gather this information:

### App Details
- **App Name**: PageInstead
- **Bundle ID**: `com.joakimachren.PageInstead`
- **Team ID**: NA6936A56Q
- **App Category**: Productivity / Self-Improvement

### Target Audience
- Adults seeking to reduce phone distraction
- Individuals wanting to replace social media with reading inspiration
- Self-improvement focused users

### Use Case Description (Critical!)
Write a clear, compelling explanation of WHY your app needs Family Controls:

**Example description** (customize for your vision):
```
PageInstead helps adults reduce phone distraction by replacing blocked apps with
inspiring book quotes. When users attempt to open distracting apps (social media,
games, etc.), they see motivational quotes from personal development books instead.

Key Features Requiring Family Controls:
1. Block distracting applications chosen by the user
2. Display custom shield screens with literary quotes
3. Allow time-limited unlocking with streak tracking
4. Monitor blocked app access attempts for health scoring

This is NOT a parental control app. Users self-select their own apps to block as
a productivity tool. The Family Controls API is essential because:
- ManagedSettings allows us to apply shields to user-selected apps
- ShieldConfiguration lets us display custom motivational content
- DeviceActivity enables streak tracking and usage insights

Target audience: Adults (18+) using the app for personal productivity and
distraction management.
```

### Screenshots (Prepare but don't upload yet)
Take screenshots showing:
1. Onboarding screen explaining the concept
2. App selection screen
3. Shield screen with quote displayed
4. Main app interface with current quote

---

## Step 2: Submit Request to Apple

### For Main App

1. Go to: https://developer.apple.com/contact/request/family-controls-distribution

2. Sign in with your Apple Developer account

3. Fill out the form:
   - **App Name**: PageInstead
   - **Bundle ID**: `com.joakimachren.PageInstead`
   - **Team ID**: NA6936A56Q
   - **Use Case Description**: Paste your prepared description
   - **Target Audience**: Adults (18+) for self-directed productivity
   - **App Store Link**: Leave blank (not yet published)

4. Click **"Submit"**

5. **Important**: You'll see "Thank you for requesting" message
   - No confirmation email
   - No ticket number
   - No way to track status
   - This is normal (frustrating, but normal)

### For DeviceActivityMonitor Extension

**You MUST submit a separate request for this extension!**

1. Go to the same URL: https://developer.apple.com/contact/request/family-controls-distribution

2. Fill out form with **extension details**:
   - **App Name**: PageInstead - DeviceActivityMonitor
   - **Bundle ID**: `com.joakimachren.PageInstead.DeviceActivityMonitor`
   - **Team ID**: NA6936A56Q
   - **Use Case Description**:
     ```
     This is a DeviceActivity Monitor extension for PageInstead. It tracks daily
     usage patterns, calculates unlock streaks, and monitors blocked app access
     attempts. This extension requires Family Controls to:
     - Monitor when blocked apps are accessed
     - Calculate health scores based on blocking attempts
     - Track consecutive days without unlocking blocked apps
     - Reset daily usage counters at midnight

     This extension is part of the main PageInstead app (com.joakimachren.PageInstead)
     which has a separate entitlement request submitted.
     ```
   - **Target Audience**: Same as main app

3. Submit

### For ShieldConfiguration Extension

**This extension does NOT need Family Controls** (App Groups only), but verify:

<function_calls>
<invoke name="Read">
<parameter name="file_path">/Users/joakimachren/pageinstead-swift/ShieldConfiguration/ShieldConfiguration.entitlements