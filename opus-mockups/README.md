# PageInstead Liquid Glass Design System - Implementation Guide

## Overview
These HTML mockups demonstrate iOS 26's Liquid Glass design language adapted for PageInstead. Each mockup showcases specific UI patterns that can be implemented in SwiftUI using iOS 17+ features.

## Mockup Files

### 1. `opus-dashboard.html` - Main Dashboard
**Key Features:**
- Animated gradient background
- Metrics cards with circular progress rings
- Activity heatmap
- Current quote preview card

**SwiftUI Implementation:**
```swift
// Gradient Background
LinearGradient(
    colors: [Color(hex: "1a0033"), Color(hex: "330066"), Color(hex: "4d0073")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Glass Card Effect
.background(.ultraThinMaterial)
.background(Color.white.opacity(0.05))
.cornerRadius(24)
.overlay(
    RoundedRectangle(cornerRadius: 24)
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
)

// Circular Progress Ring
Circle()
    .trim(from: 0, to: progress)
    .stroke(
        LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")]),
        style: StrokeStyle(lineWidth: 8, lineCap: .round)
    )
    .rotationEffect(Angle(degrees: -90))
    .animation(.easeInOut(duration: 1.5), value: progress)
```

### 2. `opus-current-quote.html` - Quote Display
**Key Features:**
- Time-synced quote display
- Progress rings for focus time & quotes seen
- Activity bars visualization
- Glass cards with shimmer effect

**SwiftUI Implementation:**
```swift
// Shimmer Effect Overlay
.overlay(
    GeometryReader { geometry in
        LinearGradient(
            colors: [Color.clear, Color.white.opacity(0.05), Color.clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: geometry.size.width * 2)
        .offset(x: shimmerOffset)
        .animation(
            Animation.linear(duration: 3)
                .repeatForever(autoreverses: false),
            value: shimmerOffset
        )
    }
    .mask(RoundedRectangle(cornerRadius: 24))
)

// Activity Bars
HStack(spacing: 4) {
    ForEach(0..<7) { index in
        RoundedRectangle(cornerRadius: 2)
            .fill(index == 6 ?
                LinearGradient(colors: [Color(hex: "FFD60A"), Color(hex: "FFA500")]) :
                Color.white.opacity(0.15)
            )
            .frame(height: CGFloat.random(in: 20...80))
    }
}
.frame(height: 40)
```

### 3. `opus-shield-screen.html` - Blocking Screen
**Key Features:**
- Animated floating orbs in background
- Gradient border effect on quote card
- Particle animations
- Pulsing shield icon

**SwiftUI Implementation:**
```swift
// Floating Orb Animation
struct FloatingOrb: View {
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: 80)
            .opacity(0.5)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 20)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(width: 30, height: -30)
                    scale = 1.1
                }
            }
    }
}

// Gradient Border
.overlay(
    RoundedRectangle(cornerRadius: 32)
        .stroke(
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2"),
                    Color(hex: "f093fb"),
                    Color(hex: "f5576c")
                ]),
                center: .center
            ),
            lineWidth: 2
        )
        .opacity(0.5)
)

// Pulse Animation
.scaleEffect(pulseScale)
.onAppear {
    withAnimation(
        .easeInOut(duration: 2)
        .repeatForever(autoreverses: true)
    ) {
        pulseScale = 1.05
    }
}
```

### 4. `opus-quote-history.html` - History View
**Key Features:**
- Stats overview cards
- Time-based filter tabs
- Quote cards with mini book covers
- Weekly activity graph

**SwiftUI Implementation:**
```swift
// Filter Tabs (iOS 17+)
Picker("Filter", selection: $selectedFilter) {
    Text("Today").tag(Filter.today)
    Text("Week").tag(Filter.week)
    Text("Month").tag(Filter.month)
}
.pickerStyle(.segmented)
.background(.ultraThinMaterial)
.cornerRadius(16)

// Activity Graph
Chart(weekData) { day in
    BarMark(
        x: .value("Day", day.name),
        y: .value("Activity", day.value)
    )
    .foregroundStyle(
        LinearGradient(
            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
            startPoint: .bottom,
            endPoint: .top
        )
    )
    .cornerRadius(4)
}
.frame(height: 120)
```

### 5. `opus-app-selection.html` - App Selection
**Key Features:**
- Search bar with glass effect
- Category filter chips
- App grid with selection states
- Floating action button with counter

**SwiftUI Implementation:**
```swift
// Glass Search Bar
HStack {
    Image(systemName: "magnifyingglass")
        .opacity(0.5)
    TextField("Search apps...", text: $searchText)
        .foregroundColor(.white)
}
.padding()
.background(Color.white.opacity(0.08))
.background(.ultraThinMaterial)
.cornerRadius(20)
.overlay(
    RoundedRectangle(cornerRadius: 20)
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
)

// Category Chips
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 12) {
        ForEach(categories) { category in
            Text(category.name)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    category == selectedCategory ?
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    Color.white.opacity(0.06)
                )
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .opacity(category == selectedCategory ? 0 : 1)
                )
        }
    }
}

// App Selection State
@State private var selectedApps = Set<String>()

// Visual feedback for selection
.overlay(
    Circle()
        .fill(selectedApps.contains(app.id) ? Color.red : Color.clear)
        .frame(width: 28, height: 28)
        .overlay(
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .opacity(selectedApps.contains(app.id) ? 1 : 0)
        ),
    alignment: .topTrailing
)
```

## Core Design Patterns

### 1. Glass Morphism
```swift
struct GlassCard<Content: View>: ViewModifier {
    let content: Content

    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.05))
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard(content: self))
    }
}
```

### 2. Animated Gradients
```swift
struct AnimatedGradient: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "1a0033"),
                Color(hex: animateGradient ? "330066" : "4d0073"),
                Color(hex: animateGradient ? "4d0073" : "330066")
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .animation(.easeInOut(duration: 3).repeatForever(), value: animateGradient)
        .onAppear {
            animateGradient.toggle()
        }
    }
}
```

### 3. Progress Indicators
```swift
struct CircularProgress: View {
    let progress: Double
    let color: LinearGradient
    let lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1, dampingFraction: 0.8), value: progress)

            // Center value
            Text("\(Int(progress * 100))%")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 100)
    }
}
```

## Color Palette
```swift
extension Color {
    static let liquidGlass = LiquidGlassColors()

    struct LiquidGlassColors {
        // Background gradients
        let darkPurple = Color(hex: "1a0033")
        let midPurple = Color(hex: "330066")
        let brightPurple = Color(hex: "4d0073")

        // Accent colors
        let primaryBlue = Color(hex: "007AFF")
        let successGreen = Color(hex: "4CD964")
        let warningOrange = Color(hex: "FF9500")
        let dangerRed = Color(hex: "FF3B30")

        // Glass effects
        let glassWhite = Color.white.opacity(0.05)
        let glassBorder = Color.white.opacity(0.1)
        let glassShimmer = Color.white.opacity(0.03)
    }
}
```

## Animation Timing
```swift
extension Animation {
    static let liquidGlassSpring = Animation.spring(
        response: 0.6,
        dampingFraction: 0.8,
        blendDuration: 0
    )

    static let liquidGlassEase = Animation.easeInOut(duration: 0.3)

    static let shimmer = Animation.linear(duration: 3)
        .repeatForever(autoreverses: false)

    static let float = Animation.easeInOut(duration: 20)
        .repeatForever(autoreverses: true)

    static let pulse = Animation.easeInOut(duration: 2)
        .repeatForever(autoreverses: true)
}
```

## Implementation Tips

1. **Performance**: Use `.drawingGroup()` for complex animated views to improve rendering performance
2. **Accessibility**: Ensure sufficient contrast for text on glass surfaces
3. **Dark Mode**: These designs are optimized for dark mode; consider light mode variants
4. **Battery**: Limit continuous animations to preserve battery life
5. **iOS Version**: Most effects require iOS 15+ for Material backgrounds, iOS 17+ for advanced Charts

## Testing the Mockups

1. Open `opus-index.html` in Safari for the most accurate iOS rendering
2. Use Safari's Responsive Design Mode to test different iPhone sizes
3. Enable "Reduce Motion" in accessibility settings to test animation fallbacks

## Integration with Existing Code

These designs should integrate with the existing `LiquidGlassStyles.swift` file in the project:

```swift
// Update existing modifiers in LiquidGlassStyles.swift
extension View {
    func liquidGlassCard() -> some View {
        self
            .background(Color.white.opacity(0.05))
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}
```

## Next Steps

1. Test these patterns in SwiftUI previews
2. Measure performance impact of backdrop filters
3. Create reusable components for common patterns
4. Add haptic feedback to interactive elements
5. Implement accessibility labels and hints