import SwiftUI

@main
struct PageInsteadApp: App {
    init() {
        // Perform migration from old ScreenTimeService to App Groups
        AppGroupManager.shared.performMigrationIfNeeded()

        // Start auto-unlock monitoring
        UnlockMonitorService.shared.startMonitoring()
        print("🔓 Started UnlockMonitorService - will auto-remove shields when timers expire")

        // Test App Groups access (from expert's paid_account.md)
        print("🧪 TESTING APP GROUPS ACCESS FROM MAIN APP...")
        if let defaults = UserDefaults(suiteName: "group.com.pageinstead") {
            defaults.set(Date(), forKey: "test_write_from_main_app")
            defaults.synchronize()
            print("✅ MAIN APP: Successfully wrote to App Group!")

            if let value = defaults.object(forKey: "test_write_from_main_app") {
                print("✅ MAIN APP: Successfully read from App Group: \(value)")
            }
        } else {
            print("❌ MAIN APP: Failed to access App Groups - UserDefaults(suiteName:) returned nil!")
            print("❌ This means the App Group container was not created!")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
