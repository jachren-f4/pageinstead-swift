import Foundation
import FamilyControls
import ManagedSettings
import Combine

/// Service that handles all Screen Time API interactions
@available(iOS 16.0, *)
class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()

    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    private var cancellables = Set<AnyCancellable>()

    @Published var isAuthorized = false
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection() // Deprecated - use App Groups

    private init() {
        checkAuthorizationStatus()
        subscribeToAppGroupChanges()
        startUnlockObserver()
    }

    // MARK: - Authorization

    /// Check current authorization status
    func checkAuthorizationStatus() {
        #if targetEnvironment(simulator)
        // Screen Time doesn't work in simulator - auto-approve for UI testing
        isAuthorized = true
        print("🔧 SIMULATOR: Auto-approving Screen Time authorization for UI testing")
        #else
        switch center.authorizationStatus {
        case .approved:
            isAuthorized = true
        default:
            isAuthorized = false
        }
        #endif
    }

    /// Request authorization from the user
    func requestAuthorization() async throws {
        #if targetEnvironment(simulator)
        // Screen Time doesn't work in simulator - skip authorization request
        print("🔧 SIMULATOR: Skipping Screen Time authorization request")
        await MainActor.run {
            isAuthorized = true
        }
        #else
        try await center.requestAuthorization(for: .individual)
        await MainActor.run {
            checkAuthorizationStatus()
        }
        #endif
    }

    // MARK: - App Groups Integration

    /// Subscribe to App Group changes and auto-apply shields
    private func subscribeToAppGroupChanges() {
        AppGroupManager.shared.$groups
            .sink { [weak self] groups in
                self?.applyShieldsForAllGroups(groups)
            }
            .store(in: &cancellables)
    }

    /// Apply shields for all app groups
    private func applyShieldsForAllGroups(_ groups: [AppGroup]) {
        // Collect all app tokens from all groups
        var allAppTokens = Set<ApplicationToken>()
        var allWebTokens = Set<WebDomainToken>()

        for group in groups {
            allAppTokens.formUnion(group.applicationTokens)
            allWebTokens.formUnion(group.webDomainTokens)
        }

        // Exclude temporarily unlocked apps
        let unlockedApps = getTemporarilyUnlockedApps()
        let filteredAppTokens = allAppTokens.filter { token in
            let tokenString = String(describing: token)
            return !unlockedApps.contains(tokenString)
        }

        let unlockedDomains = getTemporarilyUnlockedDomains()
        let filteredWebTokens = allWebTokens.filter { token in
            let tokenString = String(describing: token)
            return !unlockedDomains.contains(tokenString)
        }

        // Apply to ManagedSettings store
        store.shield.applications = filteredAppTokens.isEmpty ? nil : filteredAppTokens
        store.shield.webDomains = filteredWebTokens.isEmpty ? nil : filteredWebTokens

        // NOTE: Pause timers are NOT pre-created - they are created on first button press
        // in ShieldAction extension

        let excludedCount = allAppTokens.count - filteredAppTokens.count
        let excludedDomainsCount = allWebTokens.count - filteredWebTokens.count

        if excludedCount > 0 || excludedDomainsCount > 0 {
            print("✅ ScreenTimeService: Shields applied - \(filteredAppTokens.count) apps (\(excludedCount) unlocked), \(filteredWebTokens.count) domains (\(excludedDomainsCount) unlocked)")
            print("   Unlocked apps: \(unlockedApps)")
            print("   Unlocked domains: \(unlockedDomains)")
        } else {
            print("✅ ScreenTimeService: Shields applied for \(groups.count) group(s) - \(filteredAppTokens.count) apps, \(filteredWebTokens.count) domains")
        }
    }

    // REMOVED: Pre-creation of pause timers
    // Timers are now created on-demand when user first presses "Open" button in ShieldAction

    /// Get list of temporarily unlocked apps from App Groups
    private func getTemporarilyUnlockedApps() -> Set<String> {
        guard let defaults = UserDefaults(suiteName: "group.com.pageinstead"),
              let data = defaults.data(forKey: "temporarily_unlocked_apps"),
              let list = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(list)
    }

    /// Get list of temporarily unlocked domains from App Groups
    private func getTemporarilyUnlockedDomains() -> Set<String> {
        guard let defaults = UserDefaults(suiteName: "group.com.pageinstead"),
              let data = defaults.data(forKey: "temporarily_unlocked_domains"),
              let list = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(list)
    }

    /// Force refresh shields (can be called externally)
    func refreshShields() {
        let groups = AppGroupManager.shared.groups
        applyShieldsForAllGroups(groups)
        print("🔄 ScreenTimeService: Shields refreshed on demand")
    }

    // MARK: - Unlock Observer

    /// Start polling for unlock requests from ShieldAction extension
    private func startUnlockObserver() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForUnlockRequests()
        }
        print("🔓 ScreenTimeService: Unlock observer started (polling every 1s)")
    }

    /// Check App Groups for unlock request flags
    private func checkForUnlockRequests() {
        guard let defaults = UserDefaults(suiteName: "group.com.pageinstead") else {
            print("❌ Could not access App Groups defaults")
            return
        }
        guard let keys = defaults.dictionaryRepresentation().keys as? Set<String> else {
            print("❌ Could not get keys from App Groups")
            return
        }

        // Check for app unlock requests
        let unlockRequests = keys.filter { $0.hasPrefix("unlock_request_") && !$0.contains("domain") }

        if !unlockRequests.isEmpty {
            print("🔓🔓🔓 FOUND \(unlockRequests.count) unlock request(s)!")
        }

        for key in unlockRequests {
            let tokenString = key.replacingOccurrences(of: "unlock_request_", with: "")
            print("🔓 Processing unlock request for: \(tokenString)")

            removeAppFromShield(tokenString)
            defaults.removeObject(forKey: key)
            defaults.synchronize()
            print("🔓 Removed unlock_request key: \(key)")
        }

        // Check for domain unlock requests
        for key in keys where key.hasPrefix("unlock_request_domain_") {
            let tokenString = key.replacingOccurrences(of: "unlock_request_domain_", with: "")
            print("🔓 Detected unlock request for domain \(tokenString)")

            removeDomainFromShield(tokenString)
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }
    }

    /// Remove a specific app from shield by token string
    private func removeAppFromShield(_ tokenString: String) {
        print("🔓 removeAppFromShield() called for: \(tokenString)")

        guard var currentApps = store.shield.applications else {
            print("⚠️ No apps currently shielded - store.shield.applications is nil")
            return
        }

        print("🔓 Current shielded apps count: \(currentApps.count)")
        print("🔓 Current shielded tokens: \(currentApps.map { String(describing: $0) })")

        // Find matching token
        if let tokenToRemove = currentApps.first(where: { String(describing: $0) == tokenString }) {
            print("🔓 Found matching token! Removing...")
            currentApps.remove(tokenToRemove)
            store.shield.applications = currentApps.isEmpty ? nil : currentApps
            print("✅✅✅ App \(tokenString) unshielded successfully!")
            print("🔓 Remaining shielded apps: \(currentApps.count)")
        } else {
            print("⚠️⚠️⚠️ Token \(tokenString) NOT FOUND in current shields")
            print("⚠️ Looking for: \(tokenString)")
            print("⚠️ Available: \(currentApps.map { String(describing: $0) })")
        }
    }

    /// Remove a specific domain from shield by token string
    private func removeDomainFromShield(_ tokenString: String) {
        guard var currentDomains = store.shield.webDomains else {
            print("⚠️ No domains currently shielded")
            return
        }

        // Find matching token
        if let tokenToRemove = currentDomains.first(where: { String(describing: $0) == tokenString }) {
            currentDomains.remove(tokenToRemove)
            store.shield.webDomains = currentDomains.isEmpty ? nil : currentDomains
            print("✅ Domain \(tokenString) unshielded successfully")
        } else {
            print("⚠️ Domain token \(tokenString) not found in current shields")
        }
    }

    // MARK: - App Blocking (Legacy - for migration compatibility)

    /// Apply shields to selected apps (DEPRECATED - use App Groups instead)
    @available(*, deprecated, message: "Use App Groups instead of direct app selection")
    func applyShield(to selection: FamilyActivitySelection) {
        selectedApps = selection

        // Apply the shield to all selected apps
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        print("⚠️ ScreenTimeService: Using deprecated applyShield method - \(selection.applicationTokens.count) apps")
    }

    /// Remove all shields
    func removeAllShields() {
        store.clearAllSettings()
        selectedApps = FamilyActivitySelection()

        print("✅ ScreenTimeService: All shields removed")
    }

    /// Get count of currently blocked apps across all groups
    func getBlockedAppsCount() -> Int {
        let groups = AppGroupManager.shared.groups
        var totalApps = Set<ApplicationToken>()

        for group in groups {
            totalApps.formUnion(group.applicationTokens)
        }

        return totalApps.count
    }
}
