import SwiftUI

/// Circular progress ring with gradient stroke
/// Based on Opus mockup design system
struct CircularProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let gradient: LinearGradient
    let lineWidth: CGFloat
    let showPercentage: Bool
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        progress: Double,
        gradient: LinearGradient,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) {
        self.progress = max(0, min(1, progress)) // Clamp to 0-1
        self.gradient = gradient
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background circle (track)
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)

            // Progress arc with gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90)) // Start at top
                .animation(
                    reduceMotion ? .none : .spring(response: 1, dampingFraction: 0.8),
                    value: progress
                )

            // Center content
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("%")
                        .font(.system(size: size * 0.12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Convenience Initializers

extension CircularProgressRing {
    /// Progress ring with Opus's primary gradient (purple)
    static func primary(
        progress: Double,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) -> CircularProgressRing {
        CircularProgressRing(
            progress: progress,
            gradient: LinearGradient(
                colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: lineWidth,
            showPercentage: showPercentage,
            size: size
        )
    }

    /// Progress ring with focus time gradient (blue-purple)
    static func focus(
        progress: Double,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) -> CircularProgressRing {
        CircularProgressRing(
            progress: progress,
            gradient: LinearGradient(
                colors: [
                    Color(hex: "4facfe"),
                    Color(hex: "00f2fe")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: lineWidth,
            showPercentage: showPercentage,
            size: size
        )
    }

    /// Progress ring with activity gradient (orange-pink)
    static func activity(
        progress: Double,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) -> CircularProgressRing {
        CircularProgressRing(
            progress: progress,
            gradient: LinearGradient(
                colors: [
                    Color(hex: "fa709a"),
                    Color(hex: "fee140")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: lineWidth,
            showPercentage: showPercentage,
            size: size
        )
    }

    /// Progress ring with success gradient (green)
    static func success(
        progress: Double,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true,
        size: CGFloat = 100
    ) -> CircularProgressRing {
        CircularProgressRing(
            progress: progress,
            gradient: LinearGradient(
                colors: [
                    Color(hex: "4ADE80"),
                    Color(hex: "22C55E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: lineWidth,
            showPercentage: showPercentage,
            size: size
        )
    }
}

// MARK: - Preview

#Preview("Progress Variants") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    CircularProgressRing.primary(progress: 0.75)
                    Text("Primary")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 8) {
                    CircularProgressRing.focus(progress: 0.45)
                    Text("Focus")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 8) {
                    CircularProgressRing.activity(progress: 0.92)
                    Text("Activity")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    CircularProgressRing.success(progress: 0.60, size: 120)
                    Text("Success")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 8) {
                    CircularProgressRing.primary(
                        progress: 0.33,
                        lineWidth: 12,
                        showPercentage: false,
                        size: 80
                    )
                    Text("No Percentage")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
    }
}

#Preview("Animated") {
    struct AnimatedRingPreview: View {
        @State private var progress: Double = 0.0

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    CircularProgressRing.primary(progress: progress, size: 150)

                    Button("Animate") {
                        withAnimation {
                            progress = Double.random(in: 0...1)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .onAppear {
                progress = 0.65
            }
        }
    }

    return AnimatedRingPreview()
}
