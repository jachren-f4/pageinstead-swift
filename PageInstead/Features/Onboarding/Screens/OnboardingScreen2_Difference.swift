import SwiftUI

/// Screen 2: The Difference - Position against traditional blockers
struct OnboardingScreen2_Difference: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("The Difference")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)

            // Subtitle
            Text("Most blockers say \"no.\"\nWe say \"here's something\nbetter.\"")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // Comparison cards
            HStack(spacing: 16) {
                // Before card
                VStack(spacing: 12) {
                    Text("🚫")
                        .font(.system(size: 48))

                    Text("Before")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Punishment")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(20)

                // After card
                VStack(spacing: 12) {
                    Text("✨")
                        .font(.system(size: 48))

                    Text("After")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Transform\nDiscover")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(20)
            }
            .padding(.horizontal, 30)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
