import SwiftUI

/// Category chip for book selection (multi-select)
struct OnboardingCategoryChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Checkmark icon for selected state
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.77, green: 0.71, blue: 0.99)) // Light purple #c4b5fd
                }

                Text(text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(red: 0.91, green: 0.84, blue: 1.0) : .white) // Brighter when selected
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        // Much brighter purple background
                        LinearGradient(
                            colors: [
                                Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.7), // #6f42c1
                                Color(red: 0.63, green: 0.50, blue: 0.88).opacity(0.6)  // #a17fe0
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                            ? Color(red: 0.77, green: 0.71, blue: 0.99) // Bright purple border #c4b5fd
                            : Color.white.opacity(0.15),
                        lineWidth: isSelected ? 3 : 1 // Thicker border when selected
                    )
            )
            .cornerRadius(16)
            .shadow(
                color: isSelected ? Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.4) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0) // Slightly larger when selected
            .contentShape(Rectangle()) // Makes entire area tappable
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
