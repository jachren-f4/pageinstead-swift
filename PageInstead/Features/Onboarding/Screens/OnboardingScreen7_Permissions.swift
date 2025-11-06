import SwiftUI
import FamilyControls

/// Screen 7: Permissions Request with trust-building
struct OnboardingScreen7_Permissions: View {
    let onNext: () -> Void
    @State private var isAuthorizing = false
    @State private var arrowAnimating = false
    @ObservedObject private var screenTimeService = ScreenTimeService.shared

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("We need your\npermission")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Explanation
            Text("PageInstead will need permission to block apps. This allows us to replace distractions with quotes.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // SwiftUI permission dialog mockup
            VStack(spacing: 0) {
                // Dialog content
                Button(action: {
                    requestPermission()
                }) {
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
                }
                .background(Color(white: 0.17))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                .disabled(isAuthorizing)

                // Animated arrow pointing to Continue button (moved further right)
                HStack {
                    Spacer()
                        .frame(width: 141)  // Two arrow widths to the right (77 + 64)
                    Text("↑")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: arrowAnimating ? -10 : 0)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                            ) {
                                arrowAnimating = true
                            }
                        }
                    Spacer()
                }
                .padding(.top, 8)
            }

            Spacer()

            // OK button
            Button(action: {
                requestPermission()
            }) {
                if isAuthorizing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("OK")
                }
            }
            .onboardingPrimaryButton(isEnabled: !isAuthorizing)
            .disabled(isAuthorizing)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }

    @available(iOS 16.0, *)
    private func requestPermission() {
        Task {
            isAuthorizing = true
            do {
                try await screenTimeService.requestAuthorization()
                // Wait a moment for the authorization to settle
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                onNext()
            } catch {
                print("Authorization error: \(error)")
            }
            isAuthorizing = false
        }
    }
}
