import SwiftUI

/// Screen 6: Book Categories Selection (up to 3+)
struct OnboardingScreen6_BookCategories: View {
    let onNext: () -> Void
    @StateObject private var data = OnboardingData.shared
    @State private var selectedCategories: Set<String> = []

    private let categories = BookCategory.allCases.map { $0.rawValue }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            Text("What kinds of books\ninspire you most?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .tracking(-1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 8)

            // Subtitle
            Text("Pick at least three")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .padding(.bottom, 24)

            // Category chips in 2-column grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(categories, id: \.self) { category in
                    OnboardingCategoryChip(
                        text: category,
                        isSelected: selectedCategories.contains(category)
                    ) {
                        toggleCategory(category)
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Next button
            Button(action: {
                data.saveBookCategories(selectedCategories)
                onNext()
            }) {
                Text("Next")
            }
            .onboardingPrimaryButton(isEnabled: !selectedCategories.isEmpty)
            .disabled(selectedCategories.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            selectedCategories = data.bookCategories
        }
    }

    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
