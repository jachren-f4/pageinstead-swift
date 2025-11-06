import SwiftUI

/// Custom purple-themed sheet showing timer lock countdown
struct TimerLockSheet: View {
    @Binding var isPresented: Bool
    let targetName: String  // "Unlock Screen" or "Settings"
    @ObservedObject private var restrictionManager = SelfRestrictionManager.shared

    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Main card
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    // Lock icon
                    ZStack {
                        // Purple glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.63, green: 0.50, blue: 0.88).opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }

                    // Title
                    Text("\(targetName) Locked")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    // Countdown timer
                    VStack(spacing: 8) {
                        Text(formattedTime(timeRemaining))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()

                        Text("seconds remaining")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    // Helpful message
                    Text("Take a moment to reflect on the current quote")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Dismiss button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("OK")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.vertical, 48)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
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
                        .shadow(color: Color(red: 0.44, green: 0.26, blue: 0.76).opacity(0.5), radius: 30, y: 15)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let secs = Int(ceil(seconds))
        return "\(secs)"
    }

    private func updateTimeRemaining() {
        timeRemaining = restrictionManager.getTimeRemaining()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateTimeRemaining()

            // Auto-dismiss when timer expires
            if timeRemaining <= 0 {
                isPresented = false
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    TimerLockSheet(
        isPresented: .constant(true),
        targetName: "Unlock Screen"
    )
}
