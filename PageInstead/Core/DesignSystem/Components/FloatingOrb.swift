import SwiftUI

/// Floating animated orb with gradient and blur
/// Used for atmospheric background effects, especially in Shield screen
/// Based on Opus mockup design system
struct FloatingOrb: View {
    let colors: [Color]
    let size: CGFloat
    let blurRadius: CGFloat
    let animationDuration: Double
    let animationDelay: Double

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        colors: [Color],
        size: CGFloat = 300,
        blurRadius: CGFloat = 80,
        animationDuration: Double = 20,
        animationDelay: Double = 0
    ) {
        self.colors = colors
        self.size = size
        self.blurRadius = blurRadius
        self.animationDuration = animationDuration
        self.animationDelay = animationDelay
    }

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blurRadius)
            .opacity(0.4)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                if !reduceMotion {
                    startFloating()
                }
            }
    }

    private func startFloating() {
        // Randomize initial position slightly
        let randomOffsetX = CGFloat.random(in: -20...20)
        let randomOffsetY = CGFloat.random(in: -20...20)

        withAnimation(
            .easeInOut(duration: animationDuration)
            .repeatForever(autoreverses: true)
            .delay(animationDelay)
        ) {
            offset = CGSize(
                width: 30 + randomOffsetX,
                height: -30 + randomOffsetY
            )
            scale = 1.1
        }
    }
}

// MARK: - Convenience Initializers

extension FloatingOrb {
    /// Purple orb (Opus primary gradient)
    static func purple(
        size: CGFloat = 300,
        animationDelay: Double = 0
    ) -> FloatingOrb {
        FloatingOrb(
            colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2")
            ],
            size: size,
            animationDelay: animationDelay
        )
    }

    /// Pink orb
    static func pink(
        size: CGFloat = 300,
        animationDelay: Double = 0
    ) -> FloatingOrb {
        FloatingOrb(
            colors: [
                Color(hex: "f093fb"),
                Color(hex: "f5576c")
            ],
            size: size,
            animationDelay: animationDelay
        )
    }

    /// Blue orb
    static func blue(
        size: CGFloat = 300,
        animationDelay: Double = 0
    ) -> FloatingOrb {
        FloatingOrb(
            colors: [
                Color(hex: "4facfe"),
                Color(hex: "00f2fe")
            ],
            size: size,
            animationDelay: animationDelay
        )
    }

    /// Green orb
    static func green(
        size: CGFloat = 300,
        animationDelay: Double = 0
    ) -> FloatingOrb {
        FloatingOrb(
            colors: [
                Color(hex: "43e97b"),
                Color(hex: "38f9d7")
            ],
            size: size,
            animationDelay: animationDelay
        )
    }

    /// Orange orb
    static func orange(
        size: CGFloat = 300,
        animationDelay: Double = 0
    ) -> FloatingOrb {
        FloatingOrb(
            colors: [
                Color(hex: "fa709a"),
                Color(hex: "fee140")
            ],
            size: size,
            animationDelay: animationDelay
        )
    }
}

// MARK: - Floating Orb Background

/// Container view with multiple floating orbs for atmospheric effect
struct FloatingOrbBackground: View {
    let orbs: [(orb: FloatingOrb, position: UnitPoint)]

    init(orbs: [(FloatingOrb, UnitPoint)]) {
        self.orbs = orbs
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(orbs.enumerated()), id: \.offset) { index, orbData in
                    orbData.orb
                        .position(
                            x: orbData.position.x * geometry.size.width,
                            y: orbData.position.y * geometry.size.height
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Convenience Background Presets

extension FloatingOrbBackground {
    /// Shield screen preset: 3 orbs (purple, pink, blue)
    static func shieldScreen() -> FloatingOrbBackground {
        FloatingOrbBackground(orbs: [
            (.purple(size: 350, animationDelay: 0), .init(x: 0.2, y: 0.3)),
            (.pink(size: 400, animationDelay: 7), .init(x: 0.8, y: 0.7)),
            (.blue(size: 300, animationDelay: 14), .init(x: 0.5, y: 0.1))
        ])
    }

    /// Subtle preset: 2 small orbs
    static func subtle() -> FloatingOrbBackground {
        FloatingOrbBackground(orbs: [
            (.purple(size: 250, animationDelay: 0), .init(x: 0.15, y: 0.25)),
            (.pink(size: 200, animationDelay: 10), .init(x: 0.85, y: 0.75))
        ])
    }

    /// Vibrant preset: 4 orbs various colors
    static func vibrant() -> FloatingOrbBackground {
        FloatingOrbBackground(orbs: [
            (.purple(size: 300, animationDelay: 0), .init(x: 0.1, y: 0.2)),
            (.pink(size: 350, animationDelay: 5), .init(x: 0.9, y: 0.8)),
            (.blue(size: 280, animationDelay: 10), .init(x: 0.7, y: 0.3)),
            (.orange(size: 320, animationDelay: 15), .init(x: 0.3, y: 0.7))
        ])
    }
}

// MARK: - Preview

#Preview("Single Orbs") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 60) {
            HStack(spacing: 40) {
                ZStack {
                    FloatingOrb.purple(size: 150)
                    Text("Purple")
                        .foregroundColor(.white)
                        .font(.caption)
                }

                ZStack {
                    FloatingOrb.pink(size: 150)
                    Text("Pink")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }

            HStack(spacing: 40) {
                ZStack {
                    FloatingOrb.blue(size: 150)
                    Text("Blue")
                        .foregroundColor(.white)
                        .font(.caption)
                }

                ZStack {
                    FloatingOrb.green(size: 150)
                    Text("Green")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview("Shield Screen Background") {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "1a0033"),
                Color(hex: "330066"),
                Color(hex: "4d0073")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        FloatingOrbBackground.shieldScreen()

        // Sample content on top
        VStack(spacing: 24) {
            Image(systemName: "shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text("App is Blocked")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("\"The only way to do great work is to love what you do.\"")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text("— Steve Jobs")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(32)
            .background(Color.white.opacity(0.1))
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
    }
}

#Preview("Vibrant Background") {
    ZStack {
        Color.black.ignoresSafeArea()

        FloatingOrbBackground.vibrant()

        Text("Vibrant Preset")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

#Preview("Subtle Background") {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "1a0033"),
                Color(hex: "330066")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        FloatingOrbBackground.subtle()

        VStack(spacing: 20) {
            Text("Subtle Preset")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Perfect for main app screens")
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
