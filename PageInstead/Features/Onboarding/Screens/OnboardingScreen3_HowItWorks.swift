import SwiftUI

/// Screen 3: How It Works - Explain the three-step process
struct OnboardingScreen3_HowItWorks: View {
    let onNext: () -> Void
    @State private var showCards = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 60)

                // Title
                Text("How It Works")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(-1)

                // Subtitle
                Text("Three simple steps to mindful\nproductivity")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                // Feature cards
                VStack(spacing: 16) {
                    FeatureCard(
                        emoji: "🛡️",
                        title: "Block what drains you",
                        description: "Choose distracting apps",
                        delay: 0.0,
                        show: showCards
                    )

                    FeatureCard(
                        emoji: "🕰️",
                        title: "See quotes instead",
                        description: "Each quote changes throughout the day",
                        delay: 0.15,
                        show: showCards
                    )

                    FeatureCard(
                        emoji: "📈",
                        title: "Build Screen Health",
                        description: "Watch your focus improve",
                        delay: 0.3,
                        show: showCards
                    )
                }
                .padding(.horizontal, 30)

                Spacer().frame(height: 30)

                // CTA Button
                Button(action: onNext) {
                    Text("Personalize My Experience")
                }
                .onboardingPrimaryButton()
                .padding(.horizontal, 30)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            withAnimation {
                showCards = true
            }
        }
    }
}

/// Feature card component
private struct FeatureCard: View {
    let emoji: String
    let title: String
    let description: String
    let delay: Double
    let show: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding(20)
        .background(Color.white.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(24)
        .opacity(show ? 1 : 0)
        .offset(x: show ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(delay), value: show)
    }
}
