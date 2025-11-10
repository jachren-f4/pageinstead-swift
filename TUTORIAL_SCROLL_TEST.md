# Tutorial Tooltip Scroll Position - Test Plan

## Implementation Summary

Added automatic scroll-to-position when tutorial reaches step 4 (metricsSection) to ensure the tooltip doesn't get cut off behind the tab bar.

### Changes Made

1. **CurrentQuoteView.swift**
   - Added `@State var tutorialScrollProxy: ScrollViewProxy?` to capture scroll proxy
   - Added `@State var tutorialCurrentStep: Int = 0` to track current step
   - Wrapped ScrollView in `ScrollViewReader` and captured proxy
   - Added `.id("metricsSection")` to the metrics HStack
   - Added `handleTutorialStepChange(step:)` function that scrolls to center when step == 3
   - Passed callback to `HybridTutorialOverlay`

2. **HybridTutorialOverlay.swift**
   - Changed from `@State private var currentStep` to `@Binding var currentStep`
   - Added `onStepChange: (Int) -> Void` callback parameter
   - Calls `onStepChange(currentStep)` when advancing to next step

## Edge Cases to Test

### 1. ✅ Short Quotes (4 lines or less)
**Scenario**: Quote is very short, metrics section is already visible
**Expected**: Scroll animation should still work smoothly, centering metrics section
**Why it could break**: Unnecessary scroll when content already visible
**Mitigation**: ScrollView handles this gracefully - scrolling to already-visible content is a no-op

### 2. ✅ Long Quotes (8+ lines)
**Scenario**: Quote is very long, metrics section is pushed down near/below tab bar
**Expected**: When step 4 appears, scroll animates to center metrics section
**Why it could break**: This is the main issue being fixed
**Mitigation**: `.center` anchor ensures metrics are centered regardless of initial position

### 3. ✅ Tutorial Skipped Before Step 4
**Scenario**: User taps background/dismisses before reaching step 4
**Expected**: No scroll happens, tutorial closes normally
**Why it could break**: Scroll callback might be triggered incorrectly
**Mitigation**: Callback only fires on `nextStep()`, not on dismiss

### 4. ✅ Tutorial Replayed from Help Sheet
**Scenario**: User taps "Replay Tutorial" in help sheet
**Expected**: Tutorial starts from step 0, scrolls to metrics at step 4
**Why it could break**: State might not reset properly
**Mitigation**: `showTutorial = true` creates fresh overlay instance with step 0

### 5. ✅ Tutorial Replayed from Settings
**Scenario**: User taps tutorial replay in Settings via NotificationCenter
**Expected**: Same as help sheet replay
**Why it could break**: Notification timing
**Mitigation**: Sets `showTutorial = true` which resets state

### 6. ✅ Very Long Book Descriptions
**Scenario**: Quote has long book description, pushing metrics even lower
**Expected**: Scroll brings metrics to center with tooltip visible
**Why it could break**: Extreme content length
**Mitigation**: `.center` anchor handles any content size

### 7. ✅ Rapid Step Navigation
**Scenario**: User quickly taps "Next" through all steps
**Expected**: Scroll animation at step 4 doesn't lag or cause jank
**Why it could break**: Animation overlap, race conditions
**Mitigation**:
- 0.15s delay before scroll prevents immediate trigger
- 0.4s scroll duration is fast enough
- SwiftUI animation queue handles overlaps

### 8. ✅ Portrait to Landscape Rotation (iOS)
**Scenario**: User rotates device during tutorial step 4
**Expected**: Metrics remain properly positioned
**Why it could break**: Geometry changes during scroll
**Mitigation**: SwiftUI's GeometryReader and anchor preferences auto-update

### 9. ✅ ScrollView Already at Bottom
**Scenario**: User manually scrolled to metrics before tutorial reaches step 4
**Expected**: Minimal/no scroll animation, tooltip appears correctly
**Why it could break**: Redundant scroll
**Mitigation**: ScrollView's `scrollTo` with same position is handled gracefully

### 10. ✅ First-Time Onboarding
**Scenario**: Brand new user sees tutorial for first time after onboarding
**Expected**: Tutorial shows normally, scrolls at step 4
**Why it could break**: Initial state not set
**Mitigation**: `tutorialCurrentStep` defaults to 0, callback wired from start

### 11. ✅ Tab Switch During Tutorial
**Scenario**: User switches tabs during tutorial (shouldn't be possible with lock, but defensive)
**Expected**: Tutorial dismisses or pauses appropriately
**Why it could break**: ScrollProxy becomes invalid
**Mitigation**: Tutorial is modal overlay - tab switches dismiss it via `isPresented`

### 12. ✅ Memory Pressure / Background App
**Scenario**: App backgrounds during tutorial, returns
**Expected**: Tutorial state preserved or gracefully reset
**Why it could break**: ScrollProxy might be released
**Mitigation**: SwiftUI view lifecycle recreates proxy on reappear

### 13. ✅ Accessibility - Large Text Sizes
**Scenario**: User has very large dynamic type enabled
**Expected**: Content scales, scroll still centers metrics properly
**Why it could break**: Text overflow changes layout dramatically
**Mitigation**: `.center` anchor adapts to actual rendered size

### 14. ✅ Accessibility - VoiceOver
**Scenario**: VoiceOver user navigates tutorial
**Expected**: Scroll doesn't interfere with VO focus
**Why it could break**: Scroll might disrupt VO reading order
**Mitigation**: Animation is visual-only, doesn't affect VO tree traversal

### 15. ✅ Slow/Laggy Device
**Scenario**: Older device with slower animations
**Expected**: Scroll completes before tooltip settles
**Why it could break**: Animation timing mismatch
**Mitigation**: 0.15s delay + 0.4s animation = 0.55s total, longer than tooltip fade (0.3s)

## Testing Checklist

- [ ] Test with 4-line quote (short)
- [ ] Test with 8+ line quote (long)
- [ ] Test with very long book description
- [ ] Skip tutorial before step 4
- [ ] Complete full tutorial flow
- [ ] Replay tutorial from Help sheet
- [ ] Replay tutorial from Settings
- [ ] Rapid tap through all steps
- [ ] Manually scroll before step 4
- [ ] Test first-time user flow (reset UserDefaults)
- [ ] Enable large accessibility text
- [ ] Test with VoiceOver enabled

## Potential Future Improvements

1. **Smart Scroll Detection**: Only scroll if metrics are below fold
   ```swift
   if metricsSectionY > (screenHeight - 300) {
       // Only scroll if needed
   }
   ```

2. **Dynamic Anchor Based on Space**: If enough space, show tooltip above; if not, scroll

3. **Scroll to Different Anchors**: Use `.bottom` anchor if metrics are very low, `.top` if high

## Rollback Plan

If issues arise:
1. Revert `HybridTutorialOverlay.swift` to use `@State private var currentStep`
2. Revert `CurrentQuoteView.swift` changes (remove ScrollViewReader, callback, etc.)
3. Consider alternative solutions (fixed tooltip position, modal presentation)
