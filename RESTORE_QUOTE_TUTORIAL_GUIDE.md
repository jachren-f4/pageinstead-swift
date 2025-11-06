# Restore Quote Tutorial - Step-by-Step Guide

**Time required:** 3-5 minutes
**Xcode should be open** (if not, run `xed PageInstead.xcodeproj`)

---

## Overview

The Quote Tutorial files exist on disk but were never added to the Xcode project. When the build failed with "cannot find" errors, I removed all the integration code from CurrentQuoteView to fix the build. This guide restores the full tutorial functionality.

---

## Part 1: Add Tutorial Files to Xcode Project

### Step 1: Locate the Tutorial Folder

1. In Xcode's **Project Navigator** (left sidebar, press ⌘1 if hidden)
2. Navigate to: `PageInstead` → `Features`
3. You should see folders like: `Blocking`, `History`, `Settings`, etc.
4. Notice that **Tutorial folder is missing** from the list

### Step 2: Add Tutorial Folder to Project

1. **Right-click** on the **`Features`** folder
2. Select **"Add Files to 'PageInstead'..."**
3. In the file picker dialog:
   - Navigate to `PageInstead/Features/`
   - You should see the `Tutorial` folder
   - **Select the `Tutorial` folder** (click once to highlight it)

4. **Check the options at the bottom:**
   - ☑️ **"Copy items if needed"** - Check this
   - ☑️ **"Create groups"** - Make sure this is selected (NOT "Create folder references")
   - ☑️ **"Add to targets"** - Make sure **"PageInstead"** is checked

5. **Click "Add"**

### Step 3: Verify Tutorial Files Were Added

In the Project Navigator, expand `Features` → `Tutorial`:

You should now see (in **white/normal text**, not red):
- `HybridTutorialOverlay.swift`
- `Option5_HybridSimplified.swift`
- `QuoteHelpSheet.swift`
- `QuoteTutorialOverlay.swift`
- `TutorialAnchorSystem.swift`

**If any files are red**, remove and re-add the Tutorial folder.

---

## Part 2: Restore CurrentQuoteView Integration

### Step 4: Open CurrentQuoteView.swift

1. In Project Navigator: `PageInstead` → `Features` → `CurrentQuoteView.swift`
2. Click to open in editor

### Step 5: Restore Tutorial State Variables

**Find this section** (around line 14-16):
```swift
@State private var showPasscodeEntry = false

// Particle Dissolve animation state
```

**Add these lines BETWEEN them:**
```swift
@State private var showPasscodeEntry = false

// Tutorial state
@State private var showTutorial: Bool = false
@State private var showHelp = false

// Particle Dissolve animation state
```

### Step 6: Restore Help Button

**Find this section** (around line 254-258):
```swift
VStack {
    HStack {
        // Help button (top-left)
        Spacer()

        // Lock button (top-right)
```

**Replace with:**
```swift
VStack {
    HStack {
        // Help button (top-left)
        Button(action: {
            showHelp = true
        }) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 44, height: 44)
        }

        Spacer()

        // Lock button (top-right)
```

### Step 7: Restore Tutorial Anchor Modifiers

**Find the bookmark button** (around line 96-97):
```swift
.scaleEffect(viewModel.bookmarkAnimationScale)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isBookmarked)

// Get this book button
```

**Add `.tutorialAnchor` after the animation:**
```swift
.scaleEffect(viewModel.bookmarkAnimationScale)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isBookmarked)
.tutorialAnchor(id: "bookmarkButton")

// Get this book button
```

---

**Find the quote card** (around line 178):
```swift
})
.padding(.horizontal)

// Stats cards grid
```

**Add `.tutorialAnchor`:**
```swift
})
.padding(.horizontal)
.tutorialAnchor(id: "quoteCard")

// Stats cards grid
```

---

**Find the stats section** (around line 244):
```swift
})
}
.padding(.horizontal)

// Bottom spacing to allow stats cards
```

**Add `.tutorialAnchor`:**
```swift
})
}
.padding(.horizontal)
.tutorialAnchor(id: "metricsSection")

// Bottom spacing to allow stats cards
```

---

**Find the lock button** (around line 261):
```swift
LockButton(isUnlocked: unlockManager.isUnlocked) {
    handleLockButtonTap()
}
}
.padding(.horizontal)
```

**Add `.tutorialAnchor`:**
```swift
LockButton(isUnlocked: unlockManager.isUnlocked) {
    handleLockButtonTap()
}
.tutorialAnchor(id: "lockButton")
}
.padding(.horizontal)
```

### Step 8: Restore Tutorial Overlay

**Find the closing braces of the main body** (around line 267):
```swift
            Spacer()
        }
    }
    .onAppear {
```

**Add the overlay BETWEEN the two closing `}` braces and `.onAppear`:**
```swift
            Spacer()
        }
    }
    .overlayPreferenceValue(TutorialAnchorKey.self) { anchors in
        // Tutorial overlay reads preference values here
        if showTutorial {
            HybridTutorialOverlay(isPresented: $showTutorial, anchors: anchors)
        }
    }
    .onAppear {
```

### Step 9: Restore Tutorial Check in onAppear

**Find the onAppear block** (around line 285-290):
```swift
.onAppear {
    viewModel.refreshQuote()
    // Record that user viewed this quote
    QuoteHistoryService.shared.addQuoteView(viewModel.currentQuote)
    // Fallback: Check if date changed (in case monitor didn't fire)
    viewModel.checkStreakDailyFallback()
}
```

**Add the tutorial check before the closing `}`:**
```swift
.onAppear {
    viewModel.refreshQuote()
    // Record that user viewed this quote
    QuoteHistoryService.shared.addQuoteView(viewModel.currentQuote)
    // Fallback: Check if date changed (in case monitor didn't fire)
    viewModel.checkStreakDailyFallback()

    // Check if tutorial should be shown
    checkAndShowTutorial()
}
```

### Step 10: Restore Notification Observer

**Find the Timer.publish receiver** (around line 292-295):
```swift
.onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { time in
    currentTime = time
    checkAndRefreshQuoteWithAnimation()
}
.sheet(isPresented: $showUnlockScreen) {
```

**Add notification observer AFTER the timer and BEFORE the sheet:**
```swift
.onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { time in
    currentTime = time
    checkAndRefreshQuoteWithAnimation()
}
.onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReplayQuoteTutorial"))) { _ in
    print("🎓 CurrentQuoteView: Received ReplayQuoteTutorial notification")
    showTutorial = true
}
.sheet(isPresented: $showUnlockScreen) {
```

### Step 11: Restore Help Sheet Presentation

**Find the unlock screen sheet** (around line 296-298):
```swift
.sheet(isPresented: $showUnlockScreen) {
    UnlockScreen()
}
.sheet(isPresented: $showHealthScoreDetail) {
```

**Add help sheet BETWEEN unlock and health score sheets:**
```swift
.sheet(isPresented: $showUnlockScreen) {
    UnlockScreen()
}
.sheet(isPresented: $showHelp) {
    QuoteHelpSheet(showTutorial: $showTutorial)
}
.sheet(isPresented: $showHealthScoreDetail) {
```

### Step 12: Restore checkAndShowTutorial Function

**Find the end of handleLockButtonTap function** (around line 431-433):
```swift
    // No locks active, show unlock screen
    showUnlockScreen = true
}
}

// MARK: - ViewModel
```

**Add the tutorial functions BEFORE the `// MARK: - ViewModel`:**
```swift
    // No locks active, show unlock screen
    showUnlockScreen = true
}

// MARK: - Tutorial Functions

private func checkAndShowTutorial() {
    let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenQuoteTutorial")
    print("🎓 CurrentQuoteView: Checking tutorial status - hasSeenTutorial: \(hasSeenTutorial)")

    if !hasSeenTutorial {
        print("🎓 CurrentQuoteView: Tutorial not seen yet, scheduling to show in 1 second")
        // Show tutorial after a delay to let the view and anchors settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🎓 CurrentQuoteView: Setting showTutorial = true")
            self.showTutorial = true
        }
    } else {
        print("🎓 CurrentQuoteView: Tutorial already seen, skipping")
    }
}

}

// MARK: - ViewModel
```

---

## Part 3: Build and Test

### Step 13: Clean Build Folder

1. In Xcode menu bar: **Product**
2. Hold down **Option** key (⌥)
3. Click **"Clean Build Folder..."**
4. Wait for it to complete

### Step 14: Build the Project

1. Press **⌘B** (or Product → Build)
2. **Expected result:** ✅ "Build Succeeded"

If you get errors:
- Make sure Tutorial files are added to project (not red)
- Double-check all code additions match exactly
- Check for typos in function names

### Step 15: Install on iPhone

1. Make sure iPhone is connected and selected (top of Xcode window)
2. Press **⌘R** (or click Play ▶️ button)
3. Xcode will build, install, and launch the app

---

## Part 4: Test the Tutorial

### Test 1: First-Time Tutorial (New User)

1. **Reset tutorial flag:**
   - In the app, go to Settings tab
   - Scroll to "Tutorials" section
   - Tap **"Replay Quote Tutorial"** button

2. **Switch to Current Quote tab:**
   - Tutorial overlay should appear after ~1 second
   - Shows purple highlights on interactive elements
   - Tap through tutorial steps

3. **Tutorial features:**
   - ✨ Highlights bookmark button
   - ✨ Shows quote card info
   - ✨ Explains health score and streak
   - ✨ Shows lock button purpose

### Test 2: Help Button

1. On Current Quote screen
2. Tap **question mark (?)** button (top-left)
3. Help sheet should appear with tutorial option
4. Can replay tutorial from there

### Test 3: Notification-Based Trigger

1. Go to Settings → Tutorials
2. Tap "Replay Quote Tutorial"
3. Switch to Current Quote tab
4. Tutorial should show automatically

---

## Troubleshooting

### "Build Failed - Cannot find HybridTutorialOverlay"
- Tutorial files not added to Xcode project
- Go back to Step 2, make sure to add Tutorial folder with correct settings

### "Build Failed - Unknown member tutorialAnchor"
- TutorialAnchorSystem.swift not in project
- Verify all 5 tutorial files are in Xcode (not red)

### Tutorial Doesn't Show
- Check UserDefaults: Delete app and reinstall
- Or use "Replay Quote Tutorial" button in Settings
- Check console logs for "🎓 CurrentQuoteView:" messages

### Help Button Not Visible
- Make sure you added it in Step 6
- Should be top-left corner of Current Quote screen

---

## What You'll Have After This

✅ **Full Quote Tutorial restored:**
- Interactive tutorial on first app launch
- "Replay Quote Tutorial" button in Settings works
- Help button (?) on Current Quote screen
- Tutorial highlights key features:
  - Bookmark button
  - Quote card and timing
  - Health score meter
  - Unlock streak
  - Lock button

✅ **Same purple-themed design** matching your app

✅ **Timer Lock Sheet still works** (we didn't break that)

---

## Summary

This guide restores the Quote Tutorial feature that was removed during the build fix. The tutorial system was intact on disk but never added to the Xcode project, causing build errors. Now it's properly integrated and working.

**Total changes:**
- Add 5 Tutorial files to Xcode project
- Restore ~40 lines of code in CurrentQuoteView.swift
- No changes to tutorial system itself (already working)

The tutorial will automatically show to new users and can be replayed anytime from Settings.
