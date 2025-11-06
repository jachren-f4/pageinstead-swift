import SwiftUI

/// Screen 1: Hero Moment - Introduce the core concept
struct OnboardingScreen1_Hero: View {
    let onNext: () -> Void
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero visual with floating animation
            ZStack {
                Text("📱")
                    .font(.system(size: 80))
                    .offset(x: -60, y: animationOffset)

                Text("→")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))

                Text("📖")
                    .font(.system(size: 80))
                    .offset(x: 60, y: -animationOffset)
            }
            .frame(height: 280)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    animationOffset = 10
                }
            }

            Spacer().frame(height: 40)

            // Title
            Text("What if every distraction\nbecame a discovery?")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .tracking(-1)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // Subtitle
            Text("PageInstead replaces mindless\nscrolling with meaningful\nmoments.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            // CTA Button
            Button(action: onNext) {
                Text("See How It Works")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
