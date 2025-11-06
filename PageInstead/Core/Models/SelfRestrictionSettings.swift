import Foundation

/// Settings for self-restriction features that add friction to prevent impulsive changes
struct SelfRestrictionSettings: Codable {
    // MARK: - Timer Lock
    var isTimerLockEnabled: Bool = false
    var timerDuration: TimeInterval = 15 // seconds

    // MARK: - Passcode Lock
    var isPasscodeLockEnabled: Bool = false
    var useBiometrics: Bool = false

    // MARK: - Emergency Unlock
    var emergencyUnlockHistory: [Date] = []
    var hasActiveEmergencyUnlock: Bool = false
    var emergencyUnlockExpiry: Date?

    // MARK: - App Protection
    var isAppUninstallPreventionEnabled: Bool = false
    var protectedAppIdentifiers: Set<String> = []

    // MARK: - Time Protection
    var isTimeChangePreventionEnabled: Bool = false
    var lastKnownSystemTime: Date = Date()
    var timeManipulationAttempts: [Date] = []

    // MARK: - Initialization
    init() {}

    // MARK: - Validation
    mutating func validate() {
        // Ensure timer duration is within valid range
        if timerDuration < 5 {
            timerDuration = 5
        } else if timerDuration > 120 {
            timerDuration = 120
        }
    }
}
