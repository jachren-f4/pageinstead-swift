import Foundation
import Combine
import ManagedSettings
import FamilyControls
import UserNotifications

/// Monitors pause timers and automatically unlocks apps when timers expire
/// Uses background notifications to wake app when timers expire
class UnlockMonitorService: ObservableObject {
    static let shared = UnlockMonitorService()

    private let appGroupID = "group.com.pageinstead"
    private var timer: Timer?
    private let store = ManagedSettingsStore()
    private var temporarilyUnlockedTokens: Set<ApplicationToken> = []
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        // Set up notification delegate to handle background notifications
        notificationCenter.delegate = UnlockNotificationDelegate.shared

        // Note: Notification permissions are now requested just-in-time when user first unlocks apps
        // See UnlockReminderService.shared.scheduleReminderAfterUnlock()
    }

    /// Start monitoring for expired pause timers
    func startMonitoring() {
        print("🔓 UnlockMonitor: Starting ENHANCED timer monitoring with background notifications")

        // Check every 2 seconds for expired timers (when app is in foreground)
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkExpiredTimers()
        }

        // Make timer work in background (not guaranteed, but helps)
        RunLoop.current.add(timer!, forMode: .common)

        // Run immediately on start
        checkExpiredTimers()

        // Also schedule notifications for any existing timers
        scheduleNotificationsForExistingTimers()
    }

    /// Stop monitoring
    func stopMonitoring() {
        print("🔓 UnlockMonitor: Stopping timer monitoring")
        timer?.invalidate()
        timer = nil
    }

    /// Schedule background notifications for existing pause timers
    private func scheduleNotificationsForExistingTimers() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        let allKeys = defaults.dictionaryRepresentation().keys
        let pauseKeys = allKeys.filter { $0.hasPrefix("pause_") }

        print("🔓 UnlockMonitor: Found \(pauseKeys.count) existing pause timers to schedule notifications for")

        for pauseKey in pauseKeys {
            guard let pauseStart = defaults.object(forKey: pauseKey) as? Date else { continue }

            let components = pauseKey.components(separatedBy: "_")
            guard components.count >= 3 else { continue }

            let groupIDString = components[1]
            guard let groupID = UUID(uuidString: groupIDString) else { continue }
            guard let group = lookupGroup(withID: groupID) else { continue }

            let elapsed = Date().timeIntervalSince(pauseStart)
            let remaining = Double(group.pauseForSeconds) - elapsed

            if remaining > 0 {
                // Schedule notification to wake app when timer expires
                scheduleUnlockNotification(for: pauseKey, in: remaining)
            } else {
                // Already expired, unlock immediately
                print("🔓 UnlockMonitor: Timer already expired for \(pauseKey)")
                temporarilyUnlockGroup(group)
                defaults.removeObject(forKey: pauseKey)
            }
        }
    }

    /// Schedule a notification to wake the app when a timer expires
    private func scheduleUnlockNotification(for pauseKey: String, in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Expired"
        content.body = "You can now access your app"
        content.sound = nil  // Silent notification
        content.userInfo = ["pauseKey": pauseKey, "action": "unlock"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "unlock_\(pauseKey)", content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ UnlockMonitor: Failed to schedule notification: \(error)")
            } else {
                print("🔓 UnlockMonitor: Scheduled notification for \(pauseKey) in \(Int(seconds))s")
            }
        }
    }

    /// Called by notification delegate when timer notification fires
    func handleTimerExpired(pauseKey: String) {
        print("🔓 UnlockMonitor: Notification fired for \(pauseKey)")

        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // Extract group ID
        let components = pauseKey.components(separatedBy: "_")
        guard components.count >= 3 else { return }

        let groupIDString = components[1]
        guard let groupID = UUID(uuidString: groupIDString),
              let group = lookupGroup(withID: groupID) else { return }

        // Clear the pause timer
        defaults.removeObject(forKey: pauseKey)
        defaults.synchronize()

        // Unlock the apps
        temporarilyUnlockGroup(group)
    }

    private func checkExpiredTimers() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        // Get all keys from App Groups
        let allKeys = defaults.dictionaryRepresentation().keys

        // Find all pause timer keys (format: pause_{groupID}_{token})
        let pauseKeys = allKeys.filter { $0.hasPrefix("pause_") }

        for pauseKey in pauseKeys {
            guard let pauseStart = defaults.object(forKey: pauseKey) as? Date else {
                continue
            }

            // Extract group ID and token from key
            let components = pauseKey.components(separatedBy: "_")
            guard components.count >= 3 else { continue }

            let groupIDString = components[1]
            guard let groupID = UUID(uuidString: groupIDString) else { continue }

            // Look up the group to get pause duration
            guard let group = lookupGroup(withID: groupID) else { continue }

            let elapsed = Date().timeIntervalSince(pauseStart)

            // If timer has expired, clear it and remove shields (ScreenZen approach)
            if elapsed >= Double(group.pauseForSeconds) {
                print("🔓 UnlockMonitor: Timer expired for group '\(group.name)' (\(Int(elapsed))s >= \(group.pauseForSeconds)s)")

                // Clear the pause timer
                defaults.removeObject(forKey: pauseKey)
                defaults.synchronize()

                // Remove shields for this specific token so app opens without shield
                let tokenString = components.dropFirst(2).joined(separator: "_")
                print("🔓 UnlockMonitor: Removing shields for token: \(tokenString)")
                temporarilyUnlockToken(tokenString, from: group)
            }
        }
    }

    // Unlock a specific app token (when its individual timer expires)
    private func temporarilyUnlockToken(_ tokenString: String, from group: AppGroup) {
        print("🔓 UnlockMonitor: Unlocking single token: \(tokenString)")

        // Record unlock event (breaks streak)
        StreakService.shared.recordUnlock()

        // Schedule 1-hour reminder notification
        UnlockReminderService.shared.scheduleReminderAfterUnlock()

        // Find the matching token in the group
        guard let tokenToRemove = group.applicationTokens.first(where: { String(describing: $0) == tokenString }) else {
            print("⚠️ UnlockMonitor: Token not found in group")
            return
        }

        // Get all currently shielded apps
        guard let allGroups = loadAllGroups() else {
            print("⚠️ UnlockMonitor: Could not load groups")
            return
        }

        var allShieldedApps: Set<ApplicationToken> = []
        for g in allGroups {
            allShieldedApps.formUnion(g.applicationTokens)
        }

        // Remove this specific token
        allShieldedApps.remove(tokenToRemove)

        print("🔓 UnlockMonitor: Removed 1 token, \(allShieldedApps.count) apps remain shielded")

        // Update ManagedSettings
        store.shield.applications = allShieldedApps.isEmpty ? nil : allShieldedApps

        // Store that we unlocked this token
        temporarilyUnlockedTokens.insert(tokenToRemove)

        // Re-shield after 30 seconds (user has 30s window to open app)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            self?.reshieldToken(tokenToRemove, in: group)
        }
    }

    private func temporarilyUnlockGroup(_ group: AppGroup) {
        print("🔓 UnlockMonitor: Temporarily unlocking \(group.applicationTokens.count) app(s) in group '\(group.name)'")

        // Record unlock event (breaks streak)
        StreakService.shared.recordUnlock()

        // Schedule 1-hour reminder notification
        UnlockReminderService.shared.scheduleReminderAfterUnlock()

        // Get all currently shielded apps from all groups
        guard let allGroups = loadAllGroups() else {
            print("⚠️ UnlockMonitor: Could not load groups")
            return
        }

        var allShieldedApps: Set<ApplicationToken> = []
        for g in allGroups {
            allShieldedApps.formUnion(g.applicationTokens)
        }

        // Remove this group's apps temporarily
        let remainingApps = allShieldedApps.subtracting(group.applicationTokens)

        print("🔓 UnlockMonitor: Updating shields - removing \(group.applicationTokens.count) tokens, \(remainingApps.count) remain")

        // Update ManagedSettings to exclude this group's apps
        store.shield.applications = remainingApps.isEmpty ? nil : remainingApps

        // Store which tokens we unlocked
        temporarilyUnlockedTokens.formUnion(group.applicationTokens)

        // Re-shield after 30 seconds to prevent abuse
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            self?.reshieldGroup(group)
        }
    }

    private func reshieldToken(_ token: ApplicationToken, in group: AppGroup) {
        print("🔓 UnlockMonitor: Re-shielding single token")

        // Get all groups and rebuild shield set
        guard let allGroups = loadAllGroups() else {
            return
        }

        var allShieldedApps: Set<ApplicationToken> = []
        for g in allGroups {
            allShieldedApps.formUnion(g.applicationTokens)
        }

        // Apply all shields again (including the one we temporarily removed)
        store.shield.applications = allShieldedApps.isEmpty ? nil : allShieldedApps

        // Clear temporary unlock tracking for this token
        temporarilyUnlockedTokens.remove(token)

        print("🔓 UnlockMonitor: Re-shielding complete - \(allShieldedApps.count) total app(s) shielded")
    }

    private func reshieldGroup(_ group: AppGroup) {
        print("🔓 UnlockMonitor: Re-shielding group '\(group.name)'")

        // Get all groups and rebuild shield set
        guard let allGroups = loadAllGroups() else {
            return
        }

        var allShieldedApps: Set<ApplicationToken> = []
        for g in allGroups {
            allShieldedApps.formUnion(g.applicationTokens)
        }

        // Apply all shields again
        store.shield.applications = allShieldedApps.isEmpty ? nil : allShieldedApps

        // Clear temporary unlock tracking
        temporarilyUnlockedTokens.subtract(group.applicationTokens)

        print("🔓 UnlockMonitor: Re-shielding complete - \(allShieldedApps.count) total app(s) shielded")
    }

    // MARK: - Helper Methods

    private func lookupGroup(withID id: UUID) -> AppGroup? {
        guard let allGroups = loadAllGroups() else {
            return nil
        }

        return allGroups.first { $0.id == id }
    }

    private func loadAllGroups() -> [AppGroup]? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "app_groups") else {
            return nil
        }

        do {
            let groups = try JSONDecoder().decode([AppGroup].self, from: data)
            return groups
        } catch {
            print("⚠️ UnlockMonitor: Error decoding groups: \(error)")
            return nil
        }
    }
}

// MARK: - Notification Delegate

/// Handles background notifications for timer expiry
class UnlockNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = UnlockNotificationDelegate()

    private override init() {
        super.init()
    }

    /// Called when notification is delivered while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔓 Notification: Delivered in foreground")

        // Handle the unlock action
        if let pauseKey = notification.request.content.userInfo["pauseKey"] as? String {
            UnlockMonitorService.shared.handleTimerExpired(pauseKey: pauseKey)
        }

        // Don't show notification banner (silent)
        completionHandler([])
    }

    /// Called when user taps notification or when it's delivered in background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔓 Notification: User responded or background delivery")

        // Handle the unlock action
        if let pauseKey = response.notification.request.content.userInfo["pauseKey"] as? String {
            UnlockMonitorService.shared.handleTimerExpired(pauseKey: pauseKey)
        }

        completionHandler()
    }
}
