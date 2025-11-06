import SwiftUI

/// Frosted modern style tooltip component
struct FrostedTooltip: View {
    enum ArrowDirection {
        case up, down
    }

    let text: String
    let progress: String
    let arrowDirection: ArrowDirection
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .up {
                TooltipArrow(direction: .up, color: tooltipBackgroundColor)
                    .frame(height: 6)
                    .offset(y: 6)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.98))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text(progress)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    Button(action: onNext) {
                        Text("Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(tooltipBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 15, y: 8)
            )

            if arrowDirection == .down {
                TooltipArrow(direction: .down, color: tooltipBackgroundColor)
                    .frame(height: 6)
                    .offset(y: -6)
            }
        }
        .frame(maxWidth: 320)
    }

    private var tooltipBackgroundColor: Color {
        Color.white.opacity(0.12)
    }
}
