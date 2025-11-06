import SwiftUI

/// Overlay that displays a countdown timer preventing settings access
struct TimerLockOverlay: View {
    @Binding var remainingTime: TimeInterval
    let onComplete: () -> Void

    // Get a random quote for motivation
    @State private var motivationalQuote: String = ""

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Timer display with circular progress
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 12)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: remainingTime)

                    // Time remaining
                    VStack(spacing: 8) {
                        Text("\(Int(remainingTime))")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)

                        Text("seconds")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                // Title
                VStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Take a moment...")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("Settings will unlock in a moment. Use this time to reflect on why you're here.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Motivational quote
                if !motivationalQuote.isEmpty {
                    VStack(spacing: 8) {
                        Text("\"\(motivationalQuote)\"")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .italic()
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                }

                Spacer()

                #if targetEnvironment(simulator)
                // Skip button for simulator testing
                Button(action: onComplete) {
                    Text("Skip (Simulator Only)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 20)
                #endif
            }
        }
        .onAppear {
            loadMotivationalQuote()
        }
    }

    private var progress: CGFloat {
        let manager = SelfRestrictionManager.shared
        let total = manager.settings.timerDuration
        guard total > 0 else { return 0 }
        return CGFloat(remainingTime / total)
    }

    private func loadMotivationalQuote() {
        // Load quotes from quotes.json
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            motivationalQuote = "Stay focused on your goals."
            return
        }

        // Decode quotes (using existing BookQuote struct from QuoteData.swift)
        do {
            let quotes = try JSONDecoder().decode([BookQuote].self, from: data)
            if let randomQuote = quotes.randomElement() {
                motivationalQuote = randomQuote.text
            } else {
                motivationalQuote = "Stay focused on your goals."
            }
        } catch {
            motivationalQuote = "Stay focused on your goals."
        }
    }
}

#Preview {
    TimerLockOverlay(remainingTime: .constant(15)) {
        print("Timer complete")
    }
}
