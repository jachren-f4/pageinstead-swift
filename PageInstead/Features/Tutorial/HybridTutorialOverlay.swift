import SwiftUI

// MARK: - Tutorial Overlay with Anchor-Based Positioning

struct HybridTutorialOverlay: View {
    @Binding var isPresented: Bool
    let anchors: [String: CGPoint]
    @Binding var currentStep: Int
    let onStepChange: (Int) -> Void

    private let steps: [TutorialStepData] = [
        TutorialStepData(
            anchorId: "quoteCard",
            text: "This is your current quote. It changes every 5 minutes to give you fresh inspiration.",
            tooltipPosition: .above,
            verticalOffset: 0,
            showCircle: true
        ),
        TutorialStepData(
            anchorId: "bookmarkButton",
            text: "Tap here to save quotes you love. Find them later in the Books tab.",
            tooltipPosition: .below,
            verticalOffset: -60,
            showCircle: true
        ),
        TutorialStepData(
            anchorId: "lockButton",
            text: "When you need to access a blocked app, tap here to temporarily unlock it.",
            tooltipPosition: .below,
            verticalOffset: -60,
            showCircle: true
        ),
        TutorialStepData(
            anchorId: "metricsSection",
            text: "Track your Health Score and Unlock Streak here. Build better habits!",
            tooltipPosition: .above,
            verticalOffset: 0,
            showCircle: false
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let center = anchors[steps[currentStep].anchorId] {
                    let _ = print("🎓 TutorialOverlay: Rendering tutorial at position: \(center)")
                    ZStack {
                        // Dimmed background (reduced opacity for better visibility)
                        Color.black.opacity(0.525)  // 25% more transparent (was 0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                nextStep()
                            }

                        // Only show circle if specified for this step
                        if steps[currentStep].showCircle {
                            let adjustedCenter = CGPoint(
                                x: center.x,
                                y: center.y + steps[currentStep].verticalOffset
                            )

                            // Pulsing purple glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.63, green: 0.50, blue: 0.88).opacity(0.4),
                                            Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .position(adjustedCenter)
                                .scaleEffect(1.1)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: currentStep)

                            // Bright purple ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.63, green: 0.50, blue: 0.88),
                                            Color(red: 0.44, green: 0.26, blue: 0.76)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 120, height: 120)
                                .position(adjustedCenter)
                                .shadow(color: Color(red: 0.63, green: 0.50, blue: 0.88).opacity(0.6), radius: 12)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }

                        // Tooltip
                        TutorialTooltip(
                            text: steps[currentStep].text,
                            progress: "\(currentStep + 1)/\(steps.count)",
                            onNext: nextStep
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: steps[currentStep].tooltipPosition == .below ? center.y + 140 : center.y - 140
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                } else {
                    let _ = print("🎓 TutorialOverlay: ERROR - Anchor '\(steps[currentStep].anchorId)' not found!")
                    let _ = print("🎓 TutorialOverlay: Available anchors: \(anchors.keys.joined(separator: ", "))")
                    let _ = print("🎓 TutorialOverlay: Step: \(currentStep)")
                    // Show error message with debug info
                    VStack(spacing: 16) {
                        Text("Tutorial Debug Info")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Looking for: '\(steps[currentStep].anchorId)'")
                            .font(.caption)
                            .foregroundColor(.white)

                        Text("Available anchors (\(anchors.count)):")
                            .font(.caption)
                            .foregroundColor(.white)

                        if anchors.isEmpty {
                            Text("⚠️ NO ANCHORS FOUND")
                                .font(.caption)
                                .foregroundColor(.red)
                                .bold()
                        } else {
                            ForEach(Array(anchors.keys), id: \.self) { key in
                                Text("✓ \(key)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }

                        Text("Step: \(currentStep + 1)/\(steps.count)")
                            .font(.caption)
                            .foregroundColor(.white)

                        Button("Skip Tutorial") {
                            UserDefaults.standard.set(true, forKey: "hasSeenQuoteTutorial")
                            isPresented = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.44, green: 0.26, blue: 0.76),
                                    Color(red: 0.63, green: 0.50, blue: 0.88)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                }
            }
        }
        .onAppear {
            print("🎓 TutorialOverlay: onAppear called with \(anchors.count) anchors")
            print("🎓 TutorialOverlay: Anchor IDs: \(anchors.keys.joined(separator: ", "))")
        }
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
            onStepChange(currentStep)
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenQuoteTutorial")
            isPresented = false
        }
    }
}

// MARK: - Tutorial Step Data

struct TutorialStepData {
    let anchorId: String
    let text: String
    let tooltipPosition: TooltipPosition
    let verticalOffset: CGFloat
    let showCircle: Bool

    enum TooltipPosition {
        case above, below
    }
}

// MARK: - Tutorial Tooltip

struct TutorialTooltip: View {
    let text: String
    let progress: String
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(progress)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Button(action: onNext) {
                    Text(progress.starts(with: "4") ? "Done" : "Next")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.25))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: 280)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.44, green: 0.26, blue: 0.76),
                            Color(red: 0.38, green: 0.22, blue: 0.65)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.4), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
