import SwiftUI

// MARK: - Option 3: Feature Discovery Tips (Contextual Tooltips)

/// Small tooltips appear on first use of a feature
/// Progressive disclosure - learn as you go
/// No upfront tutorial needed

// MARK: - Tip View Component

struct FeatureTip: View {
    let text: String
    let position: TipPosition
    let onDismiss: () -> Void

    enum TipPosition {
        case aboveCenter
        case belowRight
        case belowLeft
    }

    var body: some View {
        VStack(spacing: 0) {
            if position == .aboveCenter {
                arrow
                    .rotationEffect(.degrees(180))
                    .offset(y: 6)
            }

            HStack(alignment: .top, spacing: 12) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            )

            if position == .belowRight || position == .belowLeft {
                arrow
                    .offset(y: -6)
            }
        }
        .frame(maxWidth: 260)
    }

    private var arrow: some View {
        Triangle()
            .fill(Color.blue.opacity(0.95))
            .frame(width: 16, height: 8)
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

// MARK: - Tip Manager (State Management)

class TipManager: ObservableObject {
    @Published var activeTips: Set<TipID> = []

    enum TipID: String, CaseIterable {
        case bookmark
        case getBook
        case lockButton
        case healthScore
        case unlockStreak
    }

    init() {
        // Load which tips have been shown
        let shown = UserDefaults.standard.stringArray(forKey: "shownTips") ?? []
        let allTips = Set(TipID.allCases.map { $0.rawValue })
        let unshownTips = allTips.subtracting(shown)
        activeTips = Set(unshownTips.compactMap { TipID(rawValue: $0) })
    }

    func shouldShow(_ tip: TipID) -> Bool {
        activeTips.contains(tip)
    }

    func dismiss(_ tip: TipID) {
        activeTips.remove(tip)
        var shown = UserDefaults.standard.stringArray(forKey: "shownTips") ?? []
        shown.append(tip.rawValue)
        UserDefaults.standard.set(shown, forKey: "shownTips")
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: "shownTips")
        activeTips = Set(TipID.allCases)
    }
}

// MARK: - How to Use in CurrentQuoteView

struct CurrentQuoteView_WithTips: View {
    @StateObject private var tipManager = TipManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Quote Card
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

                    // Action Buttons
                    HStack(spacing: 16) {
                        // Get Book Button with tip
                        Button("Get this book") {}
                            .overlay(alignment: .top) {
                                if tipManager.shouldShow(.getBook) {
                                    FeatureTip(
                                        text: "Tap to purchase the full book on Amazon",
                                        position: .aboveCenter,
                                        onDismiss: { tipManager.dismiss(.getBook) }
                                    )
                                    .offset(y: -80)
                                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                }
                            }

                        // Bookmark Button with tip
                        Button("★") {}
                            .overlay(alignment: .top) {
                                if tipManager.shouldShow(.bookmark) {
                                    FeatureTip(
                                        text: "Save quotes you love. Find them in Books tab.",
                                        position: .aboveCenter,
                                        onDismiss: { tipManager.dismiss(.bookmark) }
                                    )
                                    .offset(y: -80)
                                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                }
                            }
                    }

                    // Lock Button with tip
                    Button("Lock") {}
                        .overlay(alignment: .top) {
                            if tipManager.shouldShow(.lockButton) {
                                FeatureTip(
                                    text: "Temporarily unlock blocked apps when needed",
                                    position: .aboveCenter,
                                    onDismiss: { tipManager.dismiss(.lockButton) }
                                )
                                .offset(y: -80)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            }
                        }

                    // Metrics Section
                    HStack(spacing: 16) {
                        // Health Score with tip
                        VStack {
                            Text("Health Score")
                            Text("85%")
                        }
                        .overlay(alignment: .bottom) {
                            if tipManager.shouldShow(.healthScore) {
                                FeatureTip(
                                    text: "Tracks your focus based on blocking attempts",
                                    position: .belowLeft,
                                    onDismiss: { tipManager.dismiss(.healthScore) }
                                )
                                .offset(y: 100)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            }
                        }

                        // Unlock Streak with tip
                        VStack {
                            Text("Unlock Streak")
                            Text("7 days")
                        }
                        .overlay(alignment: .bottom) {
                            if tipManager.shouldShow(.unlockStreak) {
                                FeatureTip(
                                    text: "Consecutive days without unlocking apps",
                                    position: .belowRight,
                                    onDismiss: { tipManager.dismiss(.unlockStreak) }
                                )
                                .offset(y: 100)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: tipManager.activeTips)
    }
}

// MARK: - Preview Provider

#Preview {
    CurrentQuoteView_WithTips()
}

// MARK: - Alternative: Delayed Tips (Show After First Interaction)

/// Instead of showing all tips at once, show them after user interacts with the screen
extension View {
    func tipOnFirstAppear(_ tip: TipManager.TipID, tipManager: TipManager, delay: Double = 1.0) -> some View {
        self.onAppear {
            if tipManager.shouldShow(tip) {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation {
                        // Tip already visible via overlay
                    }
                }
            }
        }
    }
}

// MARK: - Pros & Cons

/*
 ✅ PROS:
 - Zero upfront commitment - users learn as they explore
 - Contextual - tips appear exactly where they're relevant
 - Non-blocking - doesn't interrupt user flow
 - Progressive disclosure - not overwhelming
 - Easier to maintain - each tip is independent
 - Can trigger based on usage patterns (e.g., show bookmark tip after 3 quotes viewed)

 ❌ CONS:
 - Users might miss tips if they don't explore
 - Less structured - no guaranteed learning path
 - Can feel cluttered if multiple tips show at once
 - Need to manage when tips appear (timing, triggers)

 BEST FOR:
 - Apps with many features to discover
 - Power users who prefer to explore
 - Features that aren't critical to understand immediately
 - Apps with complex or evolving UI

 IMPLEMENTATION TIPS:
 - Show only 1-2 tips at a time (not all at once)
 - Trigger tips based on context (e.g., show bookmark tip when viewing a quote for 5+ seconds)
 - Add a "Show Tips" button in settings to reset and review all tips
 - Use analytics to see which tips are most helpful
 */
