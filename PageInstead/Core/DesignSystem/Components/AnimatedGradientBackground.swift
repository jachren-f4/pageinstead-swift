import SwiftUI

/// Animated gradient background with radial overlays
/// Based on Opus mockup design system - purple gradient with animated radial accents
struct AnimatedGradientBackground: View {
    let includeOrbOverlays: Bool
    let animationDuration: Double

    @State private var animateGradient = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(includeOrbOverlays: Bool = true, animationDuration: Double = 20) {
        self.includeOrbOverlays = includeOrbOverlays
        self.animationDuration = animationDuration
    }

    var body: some View {
        ZStack {
            // Base purple gradient
            LinearGradient(
                colors: [
                    Color(hex: "1a0033"), // Dark purple
                    Color(hex: "330066"), // Mid purple
                    Color(hex: "4d0073")  // Bright purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated radial overlay accents (optional)
            if includeOrbOverlays {
                RadialOverlays(animateGradient: animateGradient)
            }
        }
        .onAppear {
            if !reduceMotion {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: animationDuration)
            .repeatForever(autoreverses: true)
        ) {
            animateGradient = true
        }
    }
}

// MARK: - Radial Overlays

private struct RadialOverlays: View {
    let animateGradient: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Top-left radial gradient
                RadialGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(
                    x: animateGradient ? -geometry.size.width * 0.3 : -geometry.size.width * 0.2,
                    y: animateGradient ? -geometry.size.height * 0.2 : -geometry.size.height * 0.3
                )
                .scaleEffect(animateGradient ? 1.1 : 1.0)

                // Bottom-right radial gradient
                RadialGradient(
                    colors: [
                        Color(hex: "f45d6c").opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(
                    x: animateGradient ? geometry.size.width * 0.4 : geometry.size.width * 0.3,
                    y: animateGradient ? geometry.size.height * 0.4 : geometry.size.height * 0.3
                )
                .scaleEffect(animateGradient ? 1.0 : 1.1)

                // Center-top radial gradient
                RadialGradient(
                    colors: [
                        Color(hex: "4cd964").opacity(0.05),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.5
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(
                    x: animateGradient ? geometry.size.width * 0.1 : geometry.size.width * 0.2,
                    y: animateGradient ? -geometry.size.height * 0.3 : -geometry.size.height * 0.2
                )
                .rotationEffect(.degrees(animateGradient ? 5 : 0))
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Convenience Initializers

extension AnimatedGradientBackground {
    /// Standard animated background (with orb overlays)
    static func standard() -> AnimatedGradientBackground {
        AnimatedGradientBackground(includeOrbOverlays: true)
    }

    /// Simple background (no animated overlays, solid gradient)
    static func simple() -> AnimatedGradientBackground {
        AnimatedGradientBackground(includeOrbOverlays: false)
    }

    /// Fast animated background (10s cycle)
    static func fast() -> AnimatedGradientBackground {
        AnimatedGradientBackground(includeOrbOverlays: true, animationDuration: 10)
    }

    /// Slow animated background (30s cycle)
    static func slow() -> AnimatedGradientBackground {
        AnimatedGradientBackground(includeOrbOverlays: true, animationDuration: 30)
    }
}

// MARK: - View Extension for Easy Application

extension View {
    /// Apply animated gradient background behind this view
    func animatedGradientBackground(includeOrbOverlays: Bool = true) -> some View {
        ZStack {
            AnimatedGradientBackground(includeOrbOverlays: includeOrbOverlays)
            self
        }
    }
}

// MARK: - Preview

#Preview("Standard Background") {
    ZStack {
        AnimatedGradientBackground.standard()

        VStack(spacing: 20) {
            Text("Animated Gradient")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("With radial overlays")
                .foregroundColor(.white.opacity(0.7))

            VStack(spacing: 16) {
                Text("Sample Content")
                    .font(.headline)
                Text("This is how your content will look on the animated background")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .background(Color.white.opacity(0.08))
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding()
        }
    }
}

#Preview("Simple Background") {
    ZStack {
        AnimatedGradientBackground.simple()

        VStack(spacing: 20) {
            Text("Simple Gradient")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("No animated overlays")
                .foregroundColor(.white.opacity(0.7))

            Text("Better for Shield Extension\n(performance-conscious)")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
        }
    }
}

#Preview("With Sample UI") {
    ZStack {
        AnimatedGradientBackground.standard()

        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Current Quote")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Changes every 5 minutes")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 40)

                // Sample card
                VStack(spacing: 16) {
                    Text("\"The only way to do great work is to love what you do.\"")
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    Text("— Steve Jobs")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(32)
                .foregroundColor(.white)
                .background(Color.white.opacity(0.08))
                .background(.ultraThinMaterial)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding()

                // Stats cards
                HStack(spacing: 16) {
                    VStack(spacing: 12) {
                        CircularProgressRing.focus(progress: 0.75, size: 80)
                        Text("Focus Time")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.06))
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)

                    VStack(spacing: 12) {
                        CircularProgressRing.primary(progress: 0.60, size: 80)
                        Text("Quotes Seen")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.06))
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

#Preview("View Extension") {
    VStack(spacing: 20) {
        Text("Using View Extension")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)

        Text("Content automatically gets animated gradient background")
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.7))
            .padding()
    }
    .animatedGradientBackground()
}
