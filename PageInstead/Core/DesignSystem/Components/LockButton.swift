import SwiftUI

/// Lock button component with hybrid styling
/// - Locked: Red border and background (Variant 2)
/// - Unlocked: Green background with pulse animation (Variant 5)
struct LockButton: View {
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background and border
                Circle()
                    .fill(isUnlocked ? Color(hex: "4CD964").opacity(0.1) : Color(hex: "FF3B30").opacity(0.15))
                    .frame(width: 56, height: 56)

                Circle()
                    .strokeBorder(
                        isUnlocked ? Color(hex: "4CD964").opacity(0.3) : Color(hex: "FF3B30").opacity(0.4),
                        lineWidth: isUnlocked ? 1 : 2
                    )
                    .frame(width: 56, height: 56)

                // Lock icon
                Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .scaleEffect(isUnlocked ? 1.0 : 1.0)
        }
        .modifier(PulseModifier(isActive: isUnlocked))
    }
}

/// Pulse animation modifier for unlocked state
struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(Color(hex: "4CD964").opacity(0.4), lineWidth: 2)
                    .frame(width: 56, height: 56)
                    .scaleEffect(animating ? 1.4 : 1.0)
                    .opacity(animating ? 0 : 1)
                    .animation(
                        isActive ? Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false) : .default,
                        value: animating
                    )
                    .onAppear {
                        if isActive {
                            animating = true
                        }
                    }
                    .onChange(of: isActive) { newValue in
                        animating = newValue
                    }
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - Preview

#Preview("Locked") {
    ZStack {
        AnimatedGradientBackground.standard()

        VStack(spacing: 40) {
            LockButton(isUnlocked: false) {
                print("Locked button tapped")
            }

            Text("Locked State")
                .foregroundColor(.white)
        }
    }
}

#Preview("Unlocked") {
    ZStack {
        AnimatedGradientBackground.standard()

        VStack(spacing: 40) {
            LockButton(isUnlocked: true) {
                print("Unlocked button tapped")
            }

            Text("Unlocked State (Pulsing)")
                .foregroundColor(.white)
        }
    }
}
