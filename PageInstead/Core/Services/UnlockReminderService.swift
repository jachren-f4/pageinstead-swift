import Foundation
import UserNotifications

/// Schedules reminder notifications when apps are unlocked
/// Reminds user 1 hour after unlocking to re-block their apps
@available(iOS 16.0, *)
class UnlockReminderService {
    static let shared = UnlockReminderService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderNotificationID = "unlock_reminder_1hour"
    private let appGroupID = "group.com.pageinstead"
    private let permissionRequestedKey = "notification_permission_requested"

    private init() {}

    /// Schedule a reminder notification 1 hour after unlock
    /// Requests notification permission on first use
    func scheduleReminderAfterUnlock() {
        print("📬 UnlockReminder: Scheduling 1-hour reminder")

        // Check if we've already requested permission
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        let hasRequestedPermission = defaults.bool(forKey: permissionRequestedKey)

        if !hasRequestedPermission {
            // First time - request permission
            print("📬 UnlockReminder: First unlock - requesting notification permission")
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("⚠️ UnlockReminder: Permission request error: \(error)")
                } else if granted {
                    print("📬 UnlockReminder: Notification permission granted")
                    self.scheduleNotification()
                } else {
                    print("⚠️ UnlockReminder: Notification permission denied")
                }
            }
            defaults.set(true, forKey: permissionRequestedKey)
            defaults.synchronize()
        } else {
            // Already requested before - just schedule
            scheduleNotification()
        }
    }

    /// Actually schedule the notification (after permission check)
    private func scheduleNotification() {
        // Cancel any existing reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderNotificationID])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Apps Still Unblocked"
        content.body = "You left your apps unblocked. Come back and block them again."
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.userInfo = ["action": "reminder"]

        // Schedule for 1 hour (3600 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: reminderNotificationID, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ UnlockReminder: Failed to schedule reminder: \(error)")
            } else {
                print("📬 UnlockReminder: Successfully scheduled 1-hour reminder")
            }
        }
    }

    /// Cancel pending reminder notification
    func cancelReminder() {
        print("📬 UnlockReminder: Canceling pending reminder")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderNotificationID])
    }
}
