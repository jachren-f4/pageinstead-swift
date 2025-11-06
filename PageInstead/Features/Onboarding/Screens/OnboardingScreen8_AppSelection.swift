import SwiftUI
import FamilyControls

/// Screen 8: App Selection - Get user to block at least 1 app
struct OnboardingScreen8_AppSelection: View {
    let onNext: () -> Void
    @State private var selection = FamilyActivitySelection()
    @State private var showingPicker = false
    @State private var hasSelectedApps = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("Let's block a few apps")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Explanation
            Text("Choose apps you want to take a break from. You can change these anytime.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer().frame(height: 20)

            // Real app picker screenshot (tappable)
            Button(action: {
                showingPicker = true
            }) {
                Image("app_picker")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            }

            Spacer()

            // Selection count (shown above buttons)
            if hasSelectedApps {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(selection.applicationTokens.count) apps selected")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 8)
            }

            // Select Apps button (or Continue if apps selected)
            Button(action: {
                if hasSelectedApps {
                    continueToNext()
                } else {
                    showingPicker = true
                }
            }) {
                Text(hasSelectedApps ? "Continue" : "Select Apps")
            }
            .onboardingPrimaryButton()
            .padding(.horizontal, 30)

            // Change Apps button (only shown if apps already selected)
            if hasSelectedApps {
                Button(action: {
                    showingPicker = true
                }) {
                    Text("Change Apps")
                }
                .onboardingSecondaryButton()
                .padding(.horizontal, 30)
            }

            Spacer()
                .frame(height: 40)
        }
        .familyActivityPicker(
            isPresented: $showingPicker,
            selection: $selection
        )
        .onChange(of: selection) { newSelection in
            hasSelectedApps = !newSelection.applicationTokens.isEmpty || !newSelection.webDomainTokens.isEmpty
        }
    }

    private func continueToNext() {
        // If user selected apps, create the first app group
        if hasSelectedApps {
            createFirstAppGroup()
        }

        // Always proceed to next screen
        onNext()
    }

    private func createFirstAppGroup() {
        let manager = AppGroupManager.shared

        // Create first group with selected apps
        let firstGroup = AppGroup(
            id: UUID(),
            name: "My First Group",
            applicationTokens: selection.applicationTokens,
            webDomainTokens: selection.webDomainTokens,
            pauseForSeconds: 30,
            dailyOpenLimit: nil,
            blockAfterMaxUse: false,
            schedule: AppGroupSchedule(alwaysActive: true),
            lastUsedDate: nil,
            streakDays: 0
        )

        // Create group
        try? manager.createGroup(firstGroup)

        // Apply shields
        ScreenTimeService.shared.refreshShields()
    }
}
