import SwiftUI
import ManagedSettings
import FamilyControls

/// View that allows users to unlock blocked apps after waiting 5 seconds
/// Implements the "Stryde approach" - unlock happens in main app, not shield
@available(iOS 16.0, *)
struct UnlockAppsView: View {
    @StateObject private var unlockManager = UnlockManager.shared
    @State private var countdown: Int = 5
    @State private var isCountingDown = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: unlockManager.isUnlocked ? "lock.open.fill" : "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(unlockManager.isUnlocked ? .green : .blue)

            // Title
            Text(unlockManager.isUnlocked ? "Apps Unlocked!" : "Unlock Blocked Apps")
                .font(.title2)
                .fontWeight(.bold)

            if unlockManager.isUnlocked {
                // Unlocked state
                VStack(spacing: 12) {
                    Text("Apps unlocked for 30 seconds")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Go to your app now!")
                        .font(.headline)
                        .foregroundColor(.green)

                    Button("Lock Again") {
                        unlockManager.lockApps()
                        countdown = 5
                        isCountingDown = false
                    }
                    .liquidGlassDestructiveButton()
                    .padding(.top, 8)
                }
            } else {
                // Locked state
                VStack(spacing: 16) {
                    if isCountingDown {
                        // Countdown display
                        Text("\(countdown)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)

                        Text("seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap the button below to start the countdown")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(isCountingDown ? "Counting..." : "Start Unlock Timer") {
                        startCountdown()
                    }
                    .liquidGlassPrimaryButton()
                    .disabled(isCountingDown)
                    .opacity(isCountingDown ? 0.6 : 1.0)
                }
            }
        }
        .padding(24)
        .liquidGlassCard()
        .padding(.horizontal)
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

/// Manages the unlock state and shield removal
@available(iOS 16.0, *)
class UnlockManager: ObservableObject {
    static let shared = UnlockManager()

    @Published var isUnlocked: Bool = false
    private let store = ManagedSettingsStore()
    private let appGroupID = "group.com.pageinstead"
    private var relockTimer: Timer?

    private init() {}

    func unlockApps() {
        print("🔓 UnlockManager: Unlocking all blocked apps for 30 seconds")

        // Record unlock event (breaks streak)
        StreakService.shared.recordUnlock()

        // Schedule 1-hour reminder notification
        UnlockReminderService.shared.scheduleReminderAfterUnlock()

        // Remove all shields
        store.shield.applications = nil
        store.shield.webDomains = nil

        isUnlocked = true

        // Automatically re-lock after 30 seconds
        relockTimer?.invalidate()
        relockTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            self?.lockApps()
        }
    }

    func lockApps() {
        print("🔒 UnlockManager: Re-applying shields")

        // Reapply shields by refreshing from ScreenTimeService
        ScreenTimeService.shared.refreshShields()

        isUnlocked = false
        relockTimer?.invalidate()
        relockTimer = nil
    }
}

#Preview {
    UnlockAppsView()
}
