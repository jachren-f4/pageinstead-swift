import SwiftUI

/// Screen 10: Setup Complete Celebration
struct OnboardingScreen10_SetupComplete: View {
    let onNext: () -> Void
    @State private var showConfetti = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()

                // Title
                Text("All set!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(-1)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: showContent)

                // Explanation
                Text("You've created your first mindful space. From now on, when you open a blocked app, we'll greet you with inspiration instead of noise.")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.2), value: showContent)

                Spacer().frame(height: 20)

                // Quote card
                VStack(alignment: .leading, spacing: 16) {
                    Text("\"Between stimulus and response there is a space. In that space is our power to choose.\"")
                        .font(.system(size: 18, weight: .regular))
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Text("— Viktor Frankl")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(24)
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(20)
                .padding(.horizontal, 30)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.3), value: showContent)

                Spacer()

                // Continue button
                Button(action: onNext) {
                    Text("Continue")
                }
                .onboardingPrimaryButton()
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
            }

            // Confetti overlay
            if showConfetti {
                FullConfetti()
            }
        }
        .onAppear {
            // Trigger confetti
            showConfetti = true

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            // Show content after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}
