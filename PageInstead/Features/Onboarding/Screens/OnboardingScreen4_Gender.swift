import SwiftUI

/// Screen 4: Gender Selection
struct OnboardingScreen4_Gender: View {
    let onNext: () -> Void
    @StateObject private var data = OnboardingData.shared
    @State private var selectedGender: String = ""

    private let options = ["Female", "Male", "Non-binary / Prefer not to say"]

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            Text("How do you identify?")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Subtitle
            Text("This helps us personalize your\nexperience")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Spacer().frame(height: 20)

            // Options
            VStack(spacing: 16) {
                ForEach(options, id: \.self) { option in
                    OnboardingOptionButton(
                        text: option,
                        isSelected: selectedGender == option
                    ) {
                        selectedGender = option
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Next button
            Button(action: {
                data.saveGender(selectedGender)
                onNext()
            }) {
                Text("Next")
            }
            .onboardingPrimaryButton(isEnabled: !selectedGender.isEmpty)
            .disabled(selectedGender.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            selectedGender = data.gender
        }
    }
}
