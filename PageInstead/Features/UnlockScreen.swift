import SwiftUI

/// Full-screen unlock view accessed via lock button
/// Replaces the UnlockAppsView card that was on CurrentQuoteView
struct UnlockScreen: View {
    @StateObject private var unlockManager = UnlockManager.shared
    @State private var countdown: Int = 5
    @State private var isCountingDown = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()

            VStack(spacing: 32) {
                Spacer()

                // Lock icon
                Image(systemName: unlockManager.isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(unlockManager.isUnlocked ? Color(hex: "4CD964") : .white)
                    .padding(.bottom, 16)

                // Title
                Text(unlockManager.isUnlocked ? "Apps Unlocked!" : "Unlock Blocked Apps")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                if unlockManager.isUnlocked {
                    // Unlocked state
                    VStack(spacing: 20) {
                        Text("Apps unlocked for 30 seconds")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Go to your app now!")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "4CD964"))

                        Button("Lock Again") {
                            unlockManager.lockApps()
                            countdown = 5
                            isCountingDown = false
                            dismiss()
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .liquidGlassDestructiveButton()
                        .padding(.top, 16)
                    }
                } else {
                    // Locked state
                    VStack(spacing: 24) {
                        if isCountingDown {
                            // Countdown display
                            Text("\(countdown)")
                                .font(.system(size: 96, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "4CD964"))

                            Text("seconds")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("Tap the button below to start the countdown")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .frame(height: 120)
                        }

                        Button(isCountingDown ? "Counting..." : "Start Unlock Timer") {
                            startCountdown()
                        }
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .liquidGlassSoftGhostButton()
                        .disabled(isCountingDown)
                        .opacity(isCountingDown ? 0.5 : 1.0)
                    }
                }

                Spacer()

                // Close button
                Button("Close") {
                    dismiss()
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .onDisappear {
            stopCountdown()
        }
    }

    private func startCountdown() {
        guard !isCountingDown else { return }

        isCountingDown = true
        countdown = 5

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                stopCountdown()
                unlockManager.unlockApps()
            }
        }
    }

    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
        isCountingDown = false
    }
}

// MARK: - Preview

#Preview {
    UnlockScreen()
}
