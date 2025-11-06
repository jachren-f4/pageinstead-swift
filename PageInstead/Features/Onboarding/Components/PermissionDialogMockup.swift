import SwiftUI

/// iOS-style permission dialog mockup for onboarding
struct PermissionDialogMockup: View {
    var body: some View {
        VStack(spacing: 0) {
            // Dialog content
            VStack(spacing: 12) {
                // Title
                Text("\"PageInstead\" Would Like to\nAccess Screen Time")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                // Body text
                Text("Providing \"PageInstead\" access to Screen Time may allow it to see your activity data, restrict content, and limit the usage of apps and websites.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                // Buttons
                HStack(spacing: 12) {
                    // Continue button
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(white: 0.24).opacity(0.6))
                        .cornerRadius(12)

                    // Don't Allow button
                    Text("Don't Allow")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: 280)
            .background(Color(white: 0.17))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

            // Animated arrow pointing to Continue button
            UpArrow()
                .padding(.top, 8)
        }
    }
}

/// Animated up arrow component
struct UpArrow: View {
    @State private var isAnimating = false

    var body: some View {
        Text("↑")
            .font(.system(size: 32))
            .foregroundColor(.white.opacity(0.8))
            .offset(y: isAnimating ? -10 : 0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    ZStack {
        // Purple gradient background
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0, blue: 0.20),
                Color(red: 0.20, green: 0, blue: 0.40),
                Color(red: 0.44, green: 0.26, blue: 0.76)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PermissionDialogMockup()
    }
}
