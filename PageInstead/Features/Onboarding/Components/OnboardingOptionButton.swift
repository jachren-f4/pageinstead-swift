import SwiftUI

/// Option button with selection state (for gender/age group selection)
struct OnboardingOptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.29, green: 0.87, blue: 0.5)) // Success green #4ade80
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isSelected {
                        // Selected: Purple gradient background
                        LinearGradient(
                            colors: [
                                Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.5), // #6f42c1
                                Color(red: 0.63, green: 0.50, blue: 0.88).opacity(0.5)  // #a17fe0
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        // Default: White 8% background
                        Color.white.opacity(0.08)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                            ? Color(red: 0.44, green: 0.26, blue: 0.76) // Purple border
                            : Color.white.opacity(0.15),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
