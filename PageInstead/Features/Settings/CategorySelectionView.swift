import SwiftUI

/// Settings screen for selecting book category preferences
struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onboardingData = OnboardingData.shared
    @State private var selectedCategories: Set<String> = []

    private let categories = BookCategory.allCases.map { $0.rawValue }

    var body: some View {
        ZStack {
            // Background
            Color(red: 26/255, green: 0, blue: 51/255)
                .ignoresSafeArea()

            // Everything in one scrollable container
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Book Categories")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(-0.5)

                        Text("Choose the types of books you'd like to see quotes from")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)

                    // Category Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
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
                    .padding(.horizontal, 20)

                    // Save Button
                    Button(action: savePreferences) {
                        Text("Save Preferences")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.95),
                                                Color(red: 124/255, green: 58/255, blue: 237/255).opacity(0.9)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(red: 196/255, green: 181/255, blue: 253/255).opacity(0.4), lineWidth: 1)
                                    )
                                    .shadow(color: Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.45), radius: 8, x: 0, y: 4)
                                    .shadow(color: Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .disabled(selectedCategories.isEmpty)
                    .opacity(selectedCategories.isEmpty ? 0.4 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 140) // Space for tab bar
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Book Categories")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .onChange(of: selectedCategories) { newCategories in
            // Auto-save when selection changes
            onboardingData.bookCategories = newCategories
        }
        .onAppear {
            // Load existing preferences from onboarding data
            selectedCategories = onboardingData.bookCategories
        }
    }

    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func savePreferences() {
        // Save to the same UserDefaults location as onboarding
        onboardingData.saveBookCategories(selectedCategories)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CategorySelectionView()
    }
}
