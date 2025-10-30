import SwiftUI

// MARK: - Liquid Glass Design System
// iOS 26 Liquid Glass implementation following Apple's HIG guidelines

/// Liquid Glass view modifiers for consistent iOS 26 design
extension View {

    // MARK: - Glass Cards

    /// Floating glass card with Liquid Glass material
    /// Enhanced with Opus design system standards
    /// Use for navigation layers floating above content
    func liquidGlassCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(Color.white.opacity(0.05))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
    }

    /// Floating glass card with glow effect
    func liquidGlassCardWithGlow(cornerRadius: CGFloat = 20, glowColor: Color = .white) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: glowColor.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    // MARK: - Glass Buttons

    /// Primary action button with Liquid Glass and selective tinting
    /// Capsule shape following iOS 26 guidelines
    func liquidGlassPrimaryButton(tintColor: Color = .blue) -> some View {
        self
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .fill(tintColor.opacity(0.25))
                    .allowsHitTesting(false)
            )
            .overlay(
                Capsule()
                    .strokeBorder(tintColor.opacity(0.5), lineWidth: 1.5)
                    .allowsHitTesting(false)
            )
    }

    /// Secondary action button with pure glass (no tint)
    func liquidGlassSecondaryButton() -> some View {
        self
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }

    /// Destructive action button with red tint
    func liquidGlassDestructiveButton() -> some View {
        self
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .fill(Color.red.opacity(0.1))
                    .allowsHitTesting(false)
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }

    // MARK: - Glass Pills & Badges

    /// Small glass pill for tags or badges
    func liquidGlassPill(tintColor: Color? = nil) -> some View {
        self
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Group {
                    if let tint = tintColor {
                        Capsule()
                            .fill(tint.opacity(0.1))
                            .allowsHitTesting(false)
                    }
                }
            )
    }

    /// Info badge with glass effect
    func liquidGlassInfoBadge(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Glass Backgrounds

    /// Full-screen glass layer for overlays
    /// Use with dimming layer beneath for legibility
    func liquidGlassBackground() -> some View {
        self
            .background(.thinMaterial)
    }

    // MARK: - Interactive Glass Effects

    /// Glass element with press animation
    func liquidGlassInteractive(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.liquidGlassSpring, value: isPressed)
    }

    /// Glass element with hover glow (for larger tap targets)
    func liquidGlassHoverable(isHovered: Bool, glowColor: Color = .blue) -> some View {
        self
            .shadow(
                color: isHovered ? glowColor.opacity(0.3) : Color.clear,
                radius: isHovered ? 12 : 0,
                x: 0,
                y: 0
            )
            .animation(.liquidGlassSpring, value: isHovered)
    }
}

// MARK: - Liquid Glass Animations

extension Animation {
    /// Standard spring animation for Liquid Glass interactions
    /// Response: 0.4s, Damping: 0.7 (organic, fluid feel)
    static let liquidGlassSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    /// Quick spring for subtle interactions
    static let liquidGlassSpringQuick = Animation.spring(response: 0.3, dampingFraction: 0.8)

    /// Smooth spring for larger movements
    static let liquidGlassSpringSmooth = Animation.spring(response: 0.5, dampingFraction: 0.75)
}

// MARK: - Liquid Glass Shapes

struct LiquidGlassCapsule: ViewModifier {
    let fillColor: Color?

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Group {
                    if let color = fillColor {
                        Capsule()
                            .fill(color.opacity(0.12))
                    }
                }
            )
    }
}

extension View {
    func liquidGlassCapsule(fillColor: Color? = nil) -> some View {
        modifier(LiquidGlassCapsule(fillColor: fillColor))
    }
}

// MARK: - Dimming Layer

struct DimmingLayer: View {
    var opacity: Double = 0.3

    var body: some View {
        Color.black.opacity(opacity)
            .ignoresSafeArea()
    }
}

// MARK: - Glass Divider

struct LiquidGlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(height: 1)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
            )
    }
}

// MARK: - Enhanced Modifiers (Opus Design System)

extension View {
    /// Hero-sized glass card with enhanced blur and padding
    /// Use for primary content cards (quotes, featured content)
    func liquidGlassHeroCard() -> some View {
        self
            .background(Color.white.opacity(0.05))
            .background(.ultraThinMaterial)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    /// Shimmer effect overlay for interactive cards
    /// Creates a subtle horizontal sweep animation
    func shimmerEffect(duration: Double = 3.0) -> some View {
        self.modifier(ShimmerEffect(duration: duration))
    }

    /// Gradient border overlay for special emphasis
    /// Used on shield screen quote cards
    func gradientBorder(
        gradient: LinearGradient,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 24
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(gradient, lineWidth: lineWidth)
                .opacity(0.5)
        )
    }

    /// Angular gradient border (for more dynamic effect)
    func angularGradientBorder(
        colors: [Color],
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 32
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    AngularGradient(
                        colors: colors,
                        center: .center
                    ),
                    lineWidth: lineWidth
                )
                .opacity(0.5)
        )
    }
}

// MARK: - Shimmer Effect Implementation

struct ShimmerEffect: ViewModifier {
    let duration: Double
    @State private var shimmerOffset: CGFloat = -1

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if !reduceMotion {
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: shimmerOffset * geometry.size.width)
                        .animation(
                            .linear(duration: duration)
                                .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                    }
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                if !reduceMotion {
                    shimmerOffset = 1
                }
            }
    }
}
