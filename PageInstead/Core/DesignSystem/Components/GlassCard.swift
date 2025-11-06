import SwiftUI
import UIKit

/// Custom glass card component that matches CSS backdrop-filter behavior
/// Uses UIVisualEffectView for proper translucency
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var blurRadius: CGFloat = 40
    var padding: CGFloat = 30
    var content: () -> Content

    var body: some View {
        ZStack {
            // Background layers
            Color.white.opacity(0.08)

            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                .blur(radius: blurRadius)
                .opacity(0.33)

            // Card content
            content()
                .padding(padding)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

/// UIKit blur effect wrapper for SwiftUI
/// Provides CSS-style backdrop-filter behavior
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Convenience Initializers

extension GlassCard {
    /// Standard glass card with default settings
    init(standard content: @escaping () -> Content) {
        self.init(cornerRadius: 24, blurRadius: 40, padding: 30, content: content)
    }

    /// Compact glass card with less padding
    init(compact content: @escaping () -> Content) {
        self.init(cornerRadius: 20, blurRadius: 30, padding: 20, content: content)
    }

    /// Small glass card for stats/metrics
    init(small content: @escaping () -> Content) {
        self.init(cornerRadius: 24, blurRadius: 20, padding: 20, content: content)
    }
}

// MARK: - Preview

#Preview("Glass Card on Gradient") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "1a0033"), Color(hex: "330066"), Color(hex: "4d0073")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassCard(standard: {
            VStack(spacing: 16) {
                Text("\"You don't rise to the level of your goals, you fall to the level of your systems.\"")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("— James Clear, *Atomic Habits*")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        })
        .padding(40)
    }
}

#Preview("Multiple Glass Cards") {
    ZStack {
        AnimatedGradientBackground.standard()

        VStack(spacing: 24) {
            GlassCard(standard: {
                VStack(spacing: 12) {
                    Text("Standard Card")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("With default padding and blur")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            })

            HStack(spacing: 16) {
                GlassCard(small: {
                    VStack {
                        Text("75%")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Focus")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                })

                GlassCard(small: {
                    VStack {
                        Text("18")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Quotes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                })
            }
        }
        .padding()
    }
}
