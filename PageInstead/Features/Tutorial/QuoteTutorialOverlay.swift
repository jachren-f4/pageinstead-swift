import SwiftUI

/// Tutorial overlay for the Quote screen with 5 steps
struct QuoteTutorialOverlay: View {
    @Binding var currentStep: Int
    let onComplete: () -> Void

    private let steps: [TutorialStep] = [
        TutorialStep(
            text: "This is your current quote. It changes every 5 minutes to give you fresh inspiration throughout the day.",
            arrowDirection: .up,
            highlightFrame: CGRect(x: 20, y: 150, width: 350, height: 280),
            tooltipOffset: CGPoint(x: 0, y: -300)
        ),
        TutorialStep(
            text: "Tap here to save quotes you love. Find them later in the Books tab.",
            arrowDirection: .down,
            highlightFrame: CGRect(x: 254, y: 60, width: 44, height: 44),
            tooltipOffset: CGPoint(x: 80, y: 120)
        ),
        TutorialStep(
            text: "Tap here to purchase the full book on Amazon if a quote resonates with you.",
            arrowDirection: .down,
            highlightFrame: CGRect(x: 210, y: 60, width: 160, height: 44),
            tooltipOffset: CGPoint(x: 0, y: 120)
        ),
        TutorialStep(
            text: "When you absolutely need to access a blocked app, tap here to temporarily unlock it.",
            arrowDirection: .down,
            highlightFrame: CGRect(x: 326, y: 60, width: 44, height: 44),
            tooltipOffset: CGPoint(x: 110, y: 120)
        ),
        TutorialStep(
            text: "These metrics show your progress. Health Score tracks your focus, and Unlock Streak shows consecutive days without unlocking.",
            arrowDirection: .up,
            highlightFrame: CGRect(x: 20, y: 520, width: 350, height: 180),
            tooltipOffset: CGPoint(x: 0, y: -240)
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed overlay with cutout for focused element
                ZStack {
                    // Full screen overlay
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .background(.ultraThinMaterial.opacity(0.5))
                        .ignoresSafeArea()

                    // Cutout for the focused element (reverse mask)
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: steps[currentStep].highlightFrame.width,
                               height: steps[currentStep].highlightFrame.height)
                        .position(x: steps[currentStep].highlightFrame.midX,
                                 y: steps[currentStep].highlightFrame.midY)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Tooltip
                VStack {
                    if steps[currentStep].arrowDirection == .up {
                        Spacer()
                            .frame(height: steps[currentStep].highlightFrame.maxY + 30)

                        FrostedTooltip(
                            text: steps[currentStep].text,
                            progress: "\(currentStep + 1)/5",
                            arrowDirection: steps[currentStep].arrowDirection,
                            onNext: nextStep
                        )
                        .padding(.horizontal, 20)

                        Spacer()
                    } else {
                        Spacer()
                            .frame(height: 80)

                        FrostedTooltip(
                            text: steps[currentStep].text,
                            progress: "\(currentStep + 1)/5",
                            arrowDirection: steps[currentStep].arrowDirection,
                            onNext: nextStep
                        )
                        .padding(.horizontal, 20)

                        Spacer()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            onComplete()
        }
    }
}

// MARK: - Tutorial Step Model

struct TutorialStep {
    let text: String
    let arrowDirection: FrostedTooltip.ArrowDirection
    let highlightFrame: CGRect
    let tooltipOffset: CGPoint
}
