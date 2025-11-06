import SwiftUI

/// Primary button style for onboarding (purple gradient)
/// NOTE: Apply this to a Button's content (Text/HStack), not the Button itself
struct OnboardingPrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .contentShape(Rectangle())  // Critical: Makes entire frame tappable
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [
                                Color(red: 0.44, green: 0.26, blue: 0.76), // #6f42c1
                                Color(red: 0.63, green: 0.50, blue: 0.88)  // #a17fe0
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.white.opacity(0.15)
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.3), radius: 8, x: 0, y: 4)
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style for onboarding (transparent with border)
struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .contentShape(Rectangle())  // Critical: Makes entire frame tappable
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func onboardingPrimaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(OnboardingPrimaryButtonStyle(isEnabled: isEnabled))
    }

    func onboardingSecondaryButton() -> some View {
        self.buttonStyle(OnboardingSecondaryButtonStyle())
    }
}
