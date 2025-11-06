# How to Use Xcode Canvas to Preview Tutorial Examples

## Quick Start

1. **Open any example file in Xcode**
   ```bash
   open -a Xcode tutorial_examples/Option5_HybridSimplified.swift
   ```

2. **Enable the Canvas** (if not already visible)
   - Press `⌥⌘↩` (Option + Command + Return)
   - OR: Menu Bar → Editor → Canvas

3. **Start the Preview**
   - Click the "Resume" button (▶️ play icon) in the canvas
   - OR: Press `⌥⌘P` (Option + Command + P)

4. **Interact with the Preview**
   - Click buttons, scroll, and interact with the UI in real-time
   - Changes to code update the preview automatically (with Live Preview enabled)

## Tips

### Live Preview Mode
- **Enable**: Click the "Live" button in canvas toolbar (shows live interactions)
- **Disable**: Click "Selectable" (allows selecting specific views for inspection)

### Preview Multiple Devices
You can preview different device sizes by modifying the `#Preview` macro:

```swift
#Preview("iPhone 15 Pro") {
    CurrentQuoteView_Hybrid()
}

#Preview("iPhone SE") {
    CurrentQuoteView_Hybrid()
        .previewDevice("iPhone SE (3rd generation)")
}
```

### Pin Canvas
- Click the 📌 pin icon to keep canvas open when switching files
- Useful when comparing multiple options

### Troubleshomezhooting

**Canvas won't show?**
- Make sure file is in Xcode project (not just opened separately)
- Try: Menu Bar → Editor → Canvas → Refresh Canvas

**Preview fails to build?**
- Check the error message in canvas
- These examples are standalone and don't require the full app to build
- Make sure you're running Xcode 15.0+ (for `#Preview` syntax)

**Performance slow?**
- Disable "Live Preview" mode when not interacting
- Close other Xcode windows/tabs

## File Locations

All tutorial examples are in:
```
tutorial_examples/
├── Option1_AnchorBased.swift       # Anchor-based auto-positioning
├── Option2_SimpleTextOnly.swift    # Carousel slides (zero fragility)
├── Option3_FeatureDiscoveryTips.swift  # Contextual tooltips
├── Option4_HelpButton.swift        # On-demand help menu
└── Option5_HybridSimplified.swift  # ⭐ RECOMMENDED: Anchors + Help
```

## Opening All Examples at Once

```bash
cd /Users/joakimachren/pageinstead-swift
open -a Xcode tutorial_examples/Option1_AnchorBased.swift
open -a Xcode tutorial_examples/Option2_SimpleTextOnly.swift
open -a Xcode tutorial_examples/Option3_FeatureDiscoveryTips.swift
open -a Xcode tutorial_examples/Option4_HelpButton.swift
open -a Xcode tutorial_examples/Option5_HybridSimplified.swift
```

Then use Xcode's tab bar to switch between them, with Canvas pinned.

## Interactive Features in Previews

Each preview has interactive elements:

- **Option 1**: Click "Next" to cycle through tutorial steps
- **Option 2**: Swipe left/right to navigate slides, click Next/Back
- **Option 3**: Click X buttons to dismiss tips
- **Option 4**: Click help button to open help menu, expand/collapse items
- **Option 5**: Tutorial overlay + help button in navigation bar

## Comparing Options Side-by-Side

1. Open Option5_HybridSimplified.swift in Xcode
2. Pin the canvas (📌)
3. Open another option file (e.g., Option2_SimpleTextOnly.swift)
4. Both canvases will stay visible if you arrange Xcode windows side-by-side

## Next Steps

Once you've previewed the options:
1. Decide which approach fits best
2. Let me know which one you'd like to integrate into the app
3. I'll add it to your Xcode project and wire it into CurrentQuoteView

**My recommendation**: Start with **Option 5 (Hybrid)** - it's the best balance of robust + maintainable + user-friendly.
