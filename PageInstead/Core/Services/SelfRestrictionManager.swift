import Foundation
import SwiftUI
import Combine

/// Manager for self-restriction features that add friction to prevent impulsive changes
class SelfRestrictionManager: ObservableObject {
    static let shared = SelfRestrictionManager()

    // MARK: - Published Properties
    @Published var settings: SelfRestrictionSettings
    @Published var showTimerOverlay = false
    @Published var timerRemainingSeconds: TimeInterval = 0
    @Published var isPasscodeUnlocked = false // Tracks if passcode has been entered this session

    // MARK: - Private Properties
    private let userDefaultsKey = "selfRestrictionSettings"
    private var timerCancellable: AnyCancellable?
    private let keychainHelper = KeychainHelper.shared
    private let passcodeHasher = PasscodeHasher.shared
    private var lastTimerInteractionTime: Date?
    private let timerResetThresholdMinutes: TimeInterval = 30 // Reset timer if no interaction for 30 min

    // MARK: - Initialization
    private init() {
        self.settings = SelfRestrictionSettings()
        loadSettings()
    }

    // MARK: - Settings Persistence
    func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              var loadedSettings = try? JSONDecoder().decode(SelfRestrictionSettings.self, from: data) else {
            return
        }
        loadedSettings.validate()
        self.settings = loadedSettings
    }

    func saveSettings() {
        settings.validate()
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    func resetSettings() {
        settings = SelfRestrictionSettings()
        saveSettings()
        _ = keychainHelper.deletePasscode()
    }

    // MARK: - Timer Lock

    /// Called when app launches - no longer auto-starts timer
    func onAppLaunch() {
        // Timer now only starts when user tries to access lock button or settings
        // Just ensure overlay is cleared if feature is disabled
        if !settings.isTimerLockEnabled {
            showTimerOverlay = false
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    }

    private func startTimer() {
        showTimerOverlay = true
        timerRemainingSeconds = settings.timerDuration

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerRemainingSeconds > 0 {
                    self.timerRemainingSeconds -= 1
                } else {
                    self.completeTimer()
                }
            }
    }

    func completeTimer() {
        showTimerOverlay = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    /// Check if timer should be active when user tries to access lock/settings
    /// Returns true if timer should block access
    func shouldActivateTimer() -> Bool {
        guard settings.isTimerLockEnabled else {
            return false
        }

        // Check if timer is already running
        if showTimerOverlay && timerRemainingSeconds > 0 {
            // Timer is active, update last interaction time
            lastTimerInteractionTime = Date()
            return true
        }

        // Check if enough time has passed since last interaction
        if let lastInteraction = lastTimerInteractionTime {
            let timeSinceLastInteraction = Date().timeIntervalSince(lastInteraction)
            let thresholdSeconds = timerResetThresholdMinutes * 60

            if timeSinceLastInteraction < thresholdSeconds {
                // Still within 30-minute window, timer should remain active or completed
                return showTimerOverlay
            }
        }

        // Need to start a new timer
        lastTimerInteractionTime = Date()
        startTimer()
        return true
    }

    /// Check if tabs should be locked
    func areTabsLocked() -> Bool {
        return showTimerOverlay
    }

    /// Get time remaining in seconds
    func getTimeRemaining() -> TimeInterval {
        return timerRemainingSeconds
    }

    /// Get formatted time remaining for alert
    func formattedTimeRemaining() -> String {
        let seconds = Int(timerRemainingSeconds)
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    // MARK: - Passcode Management
    func hasPasscode() -> Bool {
        return keychainHelper.hasPasscode()
    }

    func setPasscode(_ passcode: String) -> Bool {
        let hash = passcodeHasher.hash(passcode: passcode)
        return keychainHelper.savePasscode(hash: hash)
    }

    func verifyPasscode(_ passcode: String) -> Bool {
        guard let storedHash = keychainHelper.getPasscode() else {
            return false
        }
        let isValid = passcodeHasher.verify(passcode: passcode, storedHash: storedHash)
        if isValid {
            isPasscodeUnlocked = true
        }
        return isValid
    }

    func deletePasscode() -> Bool {
        settings.isPasscodeLockEnabled = false
        isPasscodeUnlocked = false
        saveSettings()
        return keychainHelper.deletePasscode()
    }

    /// Check if navigation is locked by passcode
    func isNavigationLockedByPasscode() -> Bool {
        return settings.isPasscodeLockEnabled && !isPasscodeUnlocked
    }

    /// Reset passcode unlock state (call when app backgrounds)
    func lockPasscode() {
        isPasscodeUnlocked = false
    }

    // MARK: - Emergency Unlock
    func activateEmergencyUnlock(duration: TimeInterval = 86400) { // 24 hours default
        settings.hasActiveEmergencyUnlock = true
        settings.emergencyUnlockExpiry = Date().addingTimeInterval(duration)
        settings.emergencyUnlockHistory.append(Date())
        saveSettings()
    }

    func deactivateEmergencyUnlock() {
        settings.hasActiveEmergencyUnlock = false
        settings.emergencyUnlockExpiry = nil
        saveSettings()
    }

    func isEmergencyUnlockActive() -> Bool {
        guard settings.hasActiveEmergencyUnlock,
              let expiry = settings.emergencyUnlockExpiry else {
            return false
        }

        if Date() > expiry {
            deactivateEmergencyUnlock()
            return false
        }

        return true
    }
}
