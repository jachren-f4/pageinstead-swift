//
//  AppGroupManager.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import Foundation
import FamilyControls
import Combine

/// Manages CRUD operations for App Groups with conflict detection and persistence
@available(iOS 16.0, *)
class AppGroupManager: ObservableObject {
    static let shared = AppGroupManager()

    @Published private(set) var groups: [AppGroup] = []

    private let defaults: UserDefaults
    private let groupsKey = "app_groups"
    private let migrationKey = "app_groups_migration_complete"

    private init() {
        // Use App Group suite for shared storage
        self.defaults = UserDefaults(suiteName: "group.com.pageinstead") ?? .standard
        loadGroups()
    }

    // MARK: - CRUD Operations

    /// Get all app groups
    func getAllGroups() -> [AppGroup] {
        return groups
    }

    /// Get group by ID
    func getGroup(by id: UUID) -> AppGroup? {
        return groups.first { $0.id == id }
    }

    /// Get group for a specific app token
    func getGroup(for token: SafeApplicationToken) -> AppGroup? {
        return groups.first { $0.applicationTokens.contains(token) }
    }

    /// Get group for a specific web domain token
    func getGroup(for token: SafeWebDomainToken) -> AppGroup? {
        return groups.first { $0.webDomainTokens.contains(token) }
    }

    /// Create a new app group
    func createGroup(_ group: AppGroup) throws {
        // Validate no conflicts
        let validation = validateGroup(group, excluding: nil)
        guard validation.isValid else {
            if case .failure(let title, let message) = validation {
                throw AppGroupError.validationFailed(title: title, message: message)
            }
            throw AppGroupError.unknown
        }

        groups.append(group)
        saveGroups()
    }

    /// Update an existing app group
    func updateGroup(_ group: AppGroup) throws {
        // Validate no conflicts (excluding current group)
        let validation = validateGroup(group, excluding: group.id)
        guard validation.isValid else {
            if case .failure(let title, let message) = validation {
                throw AppGroupError.validationFailed(title: title, message: message)
            }
            throw AppGroupError.unknown
        }

        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            throw AppGroupError.groupNotFound
        }

        groups[index] = group
        saveGroups()
    }

    /// Delete an app group
    func deleteGroup(id: UUID) throws {
        guard let index = groups.firstIndex(where: { $0.id == id }) else {
            throw AppGroupError.groupNotFound
        }

        groups.remove(at: index)
        saveGroups()
    }

    // MARK: - Conflict Detection

    /// Validate that a group doesn't conflict with existing groups
    func validateGroup(_ group: AppGroup, excluding excludeId: UUID?) -> ValidationResult {
        let otherGroups = groups.filter { $0.id != excludeId }

        for existingGroup in otherGroups {
            // Check for application token conflicts
            let conflictingApps = group.applicationTokens.intersection(existingGroup.applicationTokens)
            if !conflictingApps.isEmpty {
                return .failure(
                    title: "Conflict Detected",
                    message: "An app is already in '\(existingGroup.name)'. An app can only be in one group at a time."
                )
            }

            // Check for web domain token conflicts
            let conflictingDomains = group.webDomainTokens.intersection(existingGroup.webDomainTokens)
            if !conflictingDomains.isEmpty {
                return .failure(
                    title: "Conflict Detected",
                    message: "A website is already in '\(existingGroup.name)'. A website can only be in one group at a time."
                )
            }
        }

        return .success
    }

    // MARK: - Group Name Generation

    /// Generate next group name (e.g., "Group #1", "Group #2")
    func generateGroupName() -> String {
        let existingNumbers = groups.compactMap { group -> Int? in
            // Extract number from "Group #X" format
            let components = group.name.components(separatedBy: "#")
            guard components.count == 2,
                  let number = Int(components[1].trimmingCharacters(in: .whitespaces)) else {
                return nil
            }
            return number
        }

        let nextNumber = (existingNumbers.max() ?? 0) + 1
        return "Group #\(nextNumber)"
    }

    // MARK: - Persistence

    private func loadGroups() {
        guard let data = defaults.data(forKey: groupsKey) else {
            groups = []
            return
        }

        do {
            groups = try JSONDecoder().decode([AppGroup].self, from: data)
        } catch {
            print("Error loading app groups: \(error)")
            groups = []
        }
    }

    private func saveGroups() {
        do {
            let data = try JSONEncoder().encode(groups)
            defaults.set(data, forKey: groupsKey)
            defaults.synchronize()
        } catch {
            print("Error saving app groups: \(error)")
        }
    }

    // MARK: - Migration

    #if !APPEX
    /// Migrate from old ScreenTimeService.selectedApps to App Groups
    /// Note: This method is only available in the main app, not in extensions
    func performMigrationIfNeeded() {
        // Check if migration already completed
        guard !defaults.bool(forKey: migrationKey) else { return }

        // Check if there are already groups (skip migration)
        guard groups.isEmpty else {
            defaults.set(true, forKey: migrationKey)
            return
        }

        // Try to get old selected apps from ScreenTimeService
        let screenTimeService = ScreenTimeService.shared
        let selection = screenTimeService.selectedApps

        // Only migrate if there were apps selected
        guard !selection.applicationTokens.isEmpty || !selection.webDomainTokens.isEmpty else {
            defaults.set(true, forKey: migrationKey)
            return
        }

        // Create default "Group #1" with old selection
        let defaultGroup = AppGroup(
            name: "Group #1",
            applicationTokens: selection.applicationTokens,
            webDomainTokens: selection.webDomainTokens,
            pauseForSeconds: 10,
            dailyOpenLimit: nil,
            blockAfterMaxUse: false
        )

        do {
            try createGroup(defaultGroup)
            print("✅ Successfully migrated \(defaultGroup.appCount) apps to App Groups")
        } catch {
            print("❌ Migration failed: \(error)")
        }

        // Mark migration as complete
        defaults.set(true, forKey: migrationKey)
    }
    #endif
}

// MARK: - Errors

enum AppGroupError: LocalizedError {
    case groupNotFound
    case validationFailed(title: String, message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .groupNotFound:
            return "App group not found"
        case .validationFailed(_, let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
