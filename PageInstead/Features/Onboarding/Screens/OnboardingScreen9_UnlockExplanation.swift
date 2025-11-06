import SwiftUI

/// Screen 9: Unlock Mechanism Explanation
struct OnboardingScreen9_UnlockExplanation: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("How to unlock apps")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Explanation
            Text("Need to check an app later? Just open PageInstead and tap the unlock icon. This unlocks everything for 30 seconds.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 40)

            // 3-step illustration
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("🛡️")
                        .font(.system(size: 48))
                    Text("Shield")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("→")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))

                VStack(spacing: 8) {
                    Text("📱")
                        .font(.system(size: 48))
                    Text("App")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("→")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))

                VStack(spacing: 8) {
                    Text("🔓")
                        .font(.system(size: 48))
                    Text("Unlock")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 30)

            Spacer()

            // Got It button
            Button(action: onNext) {
                Text("Got It")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
