import Foundation
import FamilyControls
import ManagedSettings

/// Service that handles all Screen Time API interactions
@available(iOS 16.0, *)
class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()

    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()

    @Published var isAuthorized = false
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()

    private init() {
        checkAuthorizationStatus()
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

    // MARK: - App Blocking

    /// Apply shields to selected apps
    func applyShield(to selection: FamilyActivitySelection) {
        selectedApps = selection

        // Apply the shield to all selected apps
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        print("✅ ScreenTimeService: Shield applied to \(selection.applicationTokens.count) apps")
    }

    /// Remove all shields
    func removeAllShields() {
        store.clearAllSettings()
        selectedApps = FamilyActivitySelection()

        print("✅ ScreenTimeService: All shields removed")
    }

    /// Get count of currently blocked apps
    func getBlockedAppsCount() -> Int {
        return selectedApps.applicationTokens.count
    }
}
