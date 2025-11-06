import SwiftUI

// MARK: - Preference Key System

struct TutorialAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]

    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - View Extension for Easy Anchoring

extension View {
    func tutorialAnchor(id: String) -> some View {
        self.anchorPreference(key: TutorialAnchorPreferenceKey.self, value: .bounds) { anchor in
            [id: anchor]
        }
    }
}

// MARK: - Tutorial Overlay (Auto-positioning)

struct SmartTutorialOverlay: View {
    @Binding var currentStep: Int
    let onComplete: () -> Void

    private let steps: [TutorialStep] = [
        TutorialStep(
            anchorId: "quoteCard",
            text: "This is your current quote. It changes every 5 minutes to give you fresh inspiration throughout the day.",
            arrowDirection: .up
        ),
        TutorialStep(
            anchorId: "bookmarkButton",
            text: "Tap here to save quotes you love. Find them later in the Books tab.",
            arrowDirection: .down
        ),
        TutorialStep(
            anchorId: "getBookButton",
            text: "Tap here to purchase the full book on Amazon if a quote resonates with you.",
            arrowDirection: .down
        ),
        TutorialStep(
            anchorId: "lockButton",
            text: "When you absolutely need to access a blocked app, tap here to temporarily unlock it.",
            arrowDirection: .down
        ),
        TutorialStep(
            anchorId: "metricsSection",
            text: "These metrics show your progress. Health Score tracks your focus, and Unlock Streak shows consecutive days without unlocking.",
            arrowDirection: .up
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .overlayPreferenceValue(TutorialAnchorPreferenceKey.self) { anchors in
                    if let anchor = anchors[steps[currentStep].anchorId] {
                        let rect = geometry[anchor]

                        ZStack {
                            // Spotlight overlay
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                    .ignoresSafeArea()

                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: rect.width, height: rect.height)
                                    .position(x: rect.midX, y: rect.midY)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()

                            // Tooltip positioned automatically
                            VStack {
                                if steps[currentStep].arrowDirection == .up {
                                    Spacer().frame(height: rect.maxY + 30)
                                    tooltip
                                    Spacer()
                                } else {
                                    Spacer().frame(height: 80)
                                    tooltip
                                    Spacer()
                                }
                            }
                        }
                    }
                }
        }
    }

    private var tooltip: some View {
        FrostedTooltip(
            text: steps[currentStep].text,
            progress: "\(currentStep + 1)/\(steps.count)",
            arrowDirection: steps[currentStep].arrowDirection,
            onNext: nextStep
        )
        .padding(.horizontal, 20)
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            onComplete()
        }
    }
}

struct TutorialStep {
    let anchorId: String  // References the anchor, not hard-coded position
    let text: String
    let arrowDirection: FrostedTooltip.ArrowDirection
}

// MARK: - How to Use in CurrentQuoteView

struct CurrentQuoteView_WithAnchors: View {
    @State private var showTutorial = true
    @State private var tutorialStep = 0

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Quote Card - just add .tutorialAnchor()
                    VStack(spacing: 16) {
                        Text("The only way to do great work is to love what you do.")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("— Steve Jobs")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(20)
                    .tutorialAnchor(id: "quoteCard")  // ← That's it!

                    HStack(spacing: 16) {
                        Button("Get this book") {
                            print("Get book tapped")
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .tutorialAnchor(id: "getBookButton")  // ← Auto-positioned

                        Button("★") {
                            print("Bookmark tapped")
                        }
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .tutorialAnchor(id: "bookmarkButton")  // ← Auto-positioned
                    }

                    Button("🔒 Unlock Apps") {
                        print("Lock tapped")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(12)
                    .tutorialAnchor(id: "lockButton")  // ← Auto-positioned

                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Health Score")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Text("85%")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Unlock Streak")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Text("7 days")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(20)
                    .tutorialAnchor(id: "metricsSection")  // ← Auto-positioned
                }
                .padding(20)
            }

            if showTutorial {
                SmartTutorialOverlay(
                    currentStep: $tutorialStep,
                    onComplete: { showTutorial = false }
                )
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    CurrentQuoteView_WithAnchors()
}
