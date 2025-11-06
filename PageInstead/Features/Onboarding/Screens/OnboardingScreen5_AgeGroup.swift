import SwiftUI

/// Screen 5: Age Group Selection
struct OnboardingScreen5_AgeGroup: View {
    let onNext: () -> Void
    @StateObject private var data = OnboardingData.shared
    @State private var selectedAgeGroup: String = ""

    private let options = ["Under 18", "18–24", "25–34", "35–44", "45–54", "55+"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            Text("What's your age group?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 8)

            // Subtitle
            Text("This helps us personalize your\nexperience")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            // Options
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    OnboardingOptionButton(
                        text: option,
                        isSelected: selectedAgeGroup == option
                    ) {
                        selectedAgeGroup = option
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Next button
            Button(action: {
                data.saveAgeGroup(selectedAgeGroup)
                onNext()
            }) {
                Text("Next")
            }
            .onboardingPrimaryButton(isEnabled: !selectedAgeGroup.isEmpty)
            .disabled(selectedAgeGroup.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            selectedAgeGroup = data.ageGroup
        }
    }
}
