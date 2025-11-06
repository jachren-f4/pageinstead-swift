import SwiftUI
import UIKit

/// Screen 11: Try It Now - Two-state screen with shield detection
struct OnboardingScreen11_TryItNow: View {
    let onComplete: () -> Void
    let onSkip: () -> Void

    @StateObject private var data = OnboardingData.shared
    @State private var screenState: TryItNowState = .beforeShield
    @State private var skipButtonEnabled = false
    @State private var showConfetti = false
    @State private var wasBackgrounded = false
    @Environment(\.scenePhase) private var scenePhase

    // Timer for polling shield detection
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if screenState == .beforeShield {
                stateA_BeforeShield
            } else {
                stateB_AfterShield
            }

            // Mini confetti for State B
            if showConfetti {
                MiniConfetti()
            }
        }
        .onAppear {
            // Enable skip button after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                skipButtonEnabled = true
            }
        }
        .onReceive(timer) { _ in
            // Poll for shield detection while in State A
            if screenState == .beforeShield {
                checkForShieldDetection()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            // Detect when app goes to background
            if newPhase == .background {
                wasBackgrounded = true
            }

            // When user returns from background, automatically complete onboarding
            if newPhase == .active && wasBackgrounded && screenState == .beforeShield {
                // Small delay for smooth transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completeOnboardingDirectly()
                }
            } else if newPhase == .active && screenState == .beforeShield {
                // Still check for shield detection via timer (legacy path)
                checkForShieldDetection()
            }
        }
    }

    // MARK: - State A: Before Shield Seen
    private var stateA_BeforeShield: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("Ready to see it in action?")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Explanation
            Text("Open one of the apps you just blocked — like Instagram or TikTok. You'll see your first quote appear there.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // Bouncing phone icon
            Text("📱")
                .font(.system(size: 80))
                .modifier(BounceAnimation())

            Spacer().frame(height: 20)

            // Instruction card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("📱")
                        .font(.system(size: 20))
                    Text("How to try it now:")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    instructionRow(number: "1", text: "Press Home or swipe up to go home.")
                    instructionRow(number: "2", text: "Open any blocked app.")
                    instructionRow(number: "3", text: "When you see quote, come back here.")
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(20)
            .padding(.horizontal, 30)

            // Status text
            Text("Waiting for your first shield to appear ...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .modifier(PulseAnimation())

            Spacer()

            // Try It Now button
            Button(action: {
                minimizeApp()
            }) {
                Text("Try It Now")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)

            // Skip/Continue button (changes text after backgrounding)
            Button(action: onSkip) {
                Text(wasBackgrounded ? "Continue to PageInstead" : "Skip for Now")
            }
            .onboardingSecondaryButton()
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            .opacity((skipButtonEnabled || wasBackgrounded) ? 1.0 : 0.3)
            .disabled(!(skipButtonEnabled || wasBackgrounded))
        }
    }

    // MARK: - State B: After Shield Detected
    private var stateB_AfterShield: some View {
        VStack(spacing: 30) {
            Spacer()

            // Celebration emoji
            Text("🎉")
                .font(.system(size: 60))

            // Title
            Text("Nice job — you just met\nyour first quote!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Explanation
            Text("That's how PageInstead works: every time you reach for a distraction, you'll see something worth reading instead.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // Shield preview card
            VStack(alignment: .leading, spacing: 12) {
                Text("\"The reading of all good books is like a conversation with the finest minds...\"")
                    .font(.system(size: 16))
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer().frame(height: 8)

                Text("Visit PageInstead to Unlock")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
            .background(Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(20)
            .padding(.horizontal, 30)

            Spacer()

            // Continue button
            Button(action: onComplete) {
                Text("Continue to PageInstead")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Helper Views
    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Helper Functions
    private func minimizeApp() {
        // Method 1: Using UIApplication suspend selector (iOS 13+)
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))

        // Alternative for newer iOS: Request scene deactivation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.view.endEditing(true)
        }
    }

    private func checkForShieldDetection() {
        data.checkForFirstShield()

        if data.hasSeenFirstShield && screenState == .beforeShield {
            transitionToStateB()
        }
    }

    private func transitionToStateB() {
        // Trigger mini confetti
        showConfetti = true

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Animate to State B
        withAnimation(.easeInOut(duration: 0.4)) {
            screenState = .afterShield
        }
    }

    private func completeOnboardingDirectly() {
        // Haptic feedback for completion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Mark onboarding as complete
        data.completeOnboarding()

        // Transition to main app
        withAnimation(.easeInOut(duration: 0.4)) {
            onComplete()
        }
    }
}

// MARK: - Supporting Types
enum TryItNowState {
    case beforeShield
    case afterShield
}

// MARK: - Animations
struct BounceAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
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

struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.5 : 1.0)
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
