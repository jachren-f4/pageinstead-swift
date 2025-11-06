import SwiftUI

/// Main onboarding coordinator managing all 11 screens
struct OnboardingCoordinator: View {
    @StateObject private var data = OnboardingData.shared
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            // Background gradient (static)
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0, blue: 0.20),    // #1a0033
                    Color(red: 0.20, green: 0, blue: 0.40),    // #330066
                    Color(red: 0.44, green: 0.26, blue: 0.76) // #6f42c1
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Screen content
            Group {
                switch data.currentScreen {
                case 1:
                    OnboardingScreen1_Hero(onNext: { nextScreen() })
                case 2:
                    OnboardingScreen2_Difference(onNext: { nextScreen() })
                case 3:
                    OnboardingScreen3_HowItWorks(onNext: { nextScreen() })
                case 4:
                    OnboardingScreen4_Gender(onNext: { nextScreen() })
                case 5:
                    OnboardingScreen5_AgeGroup(onNext: { nextScreen() })
                case 6:
                    OnboardingScreen6_BookCategories(onNext: { nextScreen() })
                case 7:
                    OnboardingScreen7_Permissions(onNext: { nextScreen() })
                case 8:
                    OnboardingScreen8_AppSelection(onNext: { nextScreen() })
                case 9:
                    OnboardingScreen9_UnlockExplanation(onNext: { nextScreen() })
                case 10:
                    OnboardingScreen10_SetupComplete(onNext: { nextScreen() })
                case 11:
                    OnboardingScreen11_TryItNow(
                        onComplete: { completeOnboarding() },
                        onSkip: { skipAndComplete() }
                    )
                default:
                    OnboardingScreen1_Hero(onNext: { nextScreen() })
                }
            }
            .transition(.opacity)
        }
    }

    private func nextScreen() {
        withAnimation(.easeInOut(duration: 0.3)) {
            data.currentScreen += 1
            data.saveCurrentStep()
        }
    }

    private func completeOnboarding() {
        data.completeOnboarding()
        withAnimation {
            showOnboarding = false
        }
    }

    private func skipAndComplete() {
        data.skipTryItNow()
        withAnimation {
            showOnboarding = false
        }
    }
}
