import SwiftUI

// MARK: - Option 5: Hybrid Simplified (Anchors + Help Button)

/// Combines the best of both worlds:
/// 1. Optional one-time tutorial using anchor system (for new users)
/// 2. Always-available help button (for reference)
///
/// This is the RECOMMENDED approach for most apps

// MARK: - Simplified Anchor System

/// Minimal PreferenceKey system - just tracks center points
struct ElementAnchorKey: PreferenceKey {
    static var defaultValue: [String: CGPoint] = [:]

    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

// NOTE: tutorialAnchor extension commented out to avoid duplicate definition
// The active implementation is in TutorialAnchorSystem.swift
/*
extension View {
    /// Marks this view for tutorial highlighting
    func tutorialAnchor(id: String) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ElementAnchorKey.self,
                    value: [id: CGPoint(
                        x: geometry.frame(in: .global).midX,
                        y: geometry.frame(in: .global).midY
                    )]
                )
            }
        )
    }
}
*/

// MARK: - Simplified Tutorial Overlay

struct SimpleTutorialOverlay: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0

    private let steps: [HybridTutorialStep] = [
        HybridTutorialStep(
            anchorId: "quoteCard",
            text: "This is your current quote. It changes every 5 minutes.",
            arrowDirection: .down
        ),
        HybridTutorialStep(
            anchorId: "bookmarkButton",
            text: "Tap to save quotes. Find them in the Books tab.",
            arrowDirection: .up
        ),
        HybridTutorialStep(
            anchorId: "lockButton",
            text: "Unlock blocked apps temporarily when needed.",
            arrowDirection: .up
        ),
        HybridTutorialStep(
            anchorId: "metricsSection",
            text: "Track your Health Score and Unlock Streak here.",
            arrowDirection: .down
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .overlayPreferenceValue(ElementAnchorKey.self) { anchors in
                    if let center = anchors[steps[currentStep].anchorId] {
                        ZStack {
                            // Dimmed background
                            Color.black.opacity(0.7)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    nextStep()
                                }

                            // Spotlight circle
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 200, height: 200)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .blur(radius: 30)
                                )
                                .position(center)

                            // Tooltip
                            VStack(spacing: 0) {
                                if steps[currentStep].arrowDirection == .down {
                                    SimplifiedTooltip(
                                        text: steps[currentStep].text,
                                        progress: "\(currentStep + 1)/\(steps.count)",
                                        onNext: nextStep,
                                        arrowDirection: .down
                                    )
                                    .position(x: geometry.size.width / 2, y: center.y - 140)
                                } else {
                                    SimplifiedTooltip(
                                        text: steps[currentStep].text,
                                        progress: "\(currentStep + 1)/\(steps.count)",
                                        onNext: nextStep,
                                        arrowDirection: .up
                                    )
                                    .position(x: geometry.size.width / 2, y: center.y + 140)
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
        }
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
            isPresented = false
        }
    }
}

struct HybridTutorialStep {
    let anchorId: String
    let text: String
    let arrowDirection: ArrowDirection

    enum ArrowDirection {
        case up, down
    }
}

// MARK: - Simplified Tooltip

struct SimplifiedTooltip: View {
    let text: String
    let progress: String
    let onNext: () -> Void
    let arrowDirection: HybridTutorialStep.ArrowDirection

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .down {
                Triangle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 8)
                    .offset(y: 4)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(4)

                HStack {
                    Text(progress)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Button(action: onNext) {
                        Text("Next")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue)
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            )

            if arrowDirection == .up {
                Triangle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 8)
                    .rotationEffect(.degrees(180))
                    .offset(y: -4)
            }
        }
        .frame(maxWidth: 280)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mini Help Button

struct MiniHelpButton: View {
    @Binding var showHelp: Bool

    var body: some View {
        Button(action: {
            showHelp = true
        }) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Quick Help Sheet (Simplified)

struct QuickHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showFullTutorial: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Replay Tutorial Button
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
                            showFullTutorial = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Replay Tutorial")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("See the interactive walkthrough again")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    // Quick Reference
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Reference")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        QuickHelpItem(
                            icon: "quote.bubble.fill",
                            title: "Current Quote",
                            description: "Changes every 5 minutes"
                        )

                        QuickHelpItem(
                            icon: "bookmark.fill",
                            title: "Bookmark",
                            description: "Save quotes to Books tab"
                        )

                        QuickHelpItem(
                            icon: "lock.open.fill",
                            title: "Unlock",
                            description: "Temporary access to blocked apps"
                        )

                        QuickHelpItem(
                            icon: "heart.fill",
                            title: "Health Score",
                            description: "Focus tracking metric"
                        )

                        QuickHelpItem(
                            icon: "calendar.badge.checkmark",
                            title: "Unlock Streak",
                            description: "Consecutive days without unlocking"
                        )
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct QuickHelpItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Complete Implementation Example

struct CurrentQuoteView_Hybrid: View {
    @State private var showTutorial = true
    @State private var showHelp = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Quote Card
                        VStack(spacing: 16) {
                            Text("The only way to do great work is to love what you do.")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("— Steve Jobs")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(24)
                        .tutorialAnchor(id: "quoteCard")

                        // Action Buttons
                        HStack(spacing: 16) {
                            Button("Get this book") {}

                            Button("★") {}
                                .tutorialAnchor(id: "bookmarkButton")
                        }

                        // Lock Button
                        Button("🔒 Unlock Apps") {}
                            .tutorialAnchor(id: "lockButton")

                        // Metrics
                        HStack(spacing: 16) {
                            VStack {
                                Text("Health Score")
                                Text("85%")
                            }

                            VStack {
                                Text("Unlock Streak")
                                Text("7 days")
                            }
                        }
                        .tutorialAnchor(id: "metricsSection")
                    }
                    .padding(20)
                }

                // Tutorial overlay (first time only)
                if showTutorial {
                    SimpleTutorialOverlay(isPresented: $showTutorial)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    MiniHelpButton(showHelp: $showHelp)
                }
            }
            .sheet(isPresented: $showHelp) {
                QuickHelpSheet(showFullTutorial: $showTutorial)
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    CurrentQuoteView_Hybrid()
}

// MARK: - Pros & Cons

/*
 ✅ PROS:
 - Best of both worlds: guided + on-demand
 - Self-healing: anchors adapt to UI changes
 - Minimal maintenance: only 4-5 anchor points needed
 - Always accessible: help button for reference
 - User choice: skip tutorial, replay anytime
 - Cleaner than Option 1: simplified tooltip, fewer steps
 - More engaging than Option 4: interactive first time

 ❌ CONS:
 - Slightly more complex than pure text or pure help button
 - Still requires anchor IDs to be maintained (but only a few)
 - Tutorial can still be skipped/ignored

 BEST FOR:
 - Production apps that balance user onboarding with flexibility
 - Apps with UI that evolves over time
 - Teams that want low maintenance overhead
 - When you want both guided and self-service help

 IMPLEMENTATION STRATEGY:
 1. Start with 3-4 key features in tutorial (not all features)
 2. Add help button for comprehensive reference
 3. Use anchors only for tutorial, not help menu
 4. Keep tutorial short (< 30 seconds)
 5. Make tutorial replayable from help menu

 RECOMMENDED TUTORIAL STEPS (4 max):
 1. Main feature (quote card)
 2. Primary action (bookmark)
 3. Important control (unlock button)
 4. Key metric (health score/streak)

 Skip tutorial for:
 - Secondary features (history, settings)
 - Obvious UI (standard iOS patterns)
 - Features discovered through exploration
 */
