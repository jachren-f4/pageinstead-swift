//
//  AppGroup.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import Foundation
import ManagedSettings
import FamilyControls

// Type aliases for token types (these are from ManagedSettings, not FamilyControls)
public typealias SafeApplicationToken = ApplicationToken
public typealias SafeWebDomainToken = WebDomainToken

/// Represents a collection of apps with shared blocking rules
@available(iOS 16.0, *)
struct AppGroup: Identifiable, Codable {
    var id: UUID
    var name: String

    // Apps (stored as tokens for Codable support)
    var applicationTokens: Set<SafeApplicationToken>
    var webDomainTokens: Set<SafeWebDomainToken>

    // Behavioral nudge
    var pauseForSeconds: Int

    // Daily limit (nil = unlimited)
    var dailyOpenLimit: Int?
    var blockAfterMaxUse: Bool

    // Scheduling
    var schedule: AppGroupSchedule

    // Metadata
    var createdAt: Date
    var lastUsedDate: Date?
    var streakDays: Int

    /// Initialize with default values
    init(
        id: UUID = UUID(),
        name: String,
        applicationTokens: Set<SafeApplicationToken> = [],
        webDomainTokens: Set<SafeWebDomainToken> = [],
        pauseForSeconds: Int = 10,
        dailyOpenLimit: Int? = nil,
        blockAfterMaxUse: Bool = false,
        schedule: AppGroupSchedule = AppGroupSchedule(),
        createdAt: Date = Date(),
        lastUsedDate: Date? = nil,
        streakDays: Int = 0
    ) {
        self.id = id
        self.name = name
        self.applicationTokens = applicationTokens
        self.webDomainTokens = webDomainTokens
        self.pauseForSeconds = pauseForSeconds
        self.dailyOpenLimit = dailyOpenLimit
        self.blockAfterMaxUse = blockAfterMaxUse
        self.schedule = schedule
        self.createdAt = createdAt
        self.lastUsedDate = lastUsedDate
        self.streakDays = streakDays
    }
}

// MARK: - Computed Properties

extension AppGroup {
    /// Convert to/from FamilyActivitySelection for UI binding
    var selection: FamilyActivitySelection {
        get {
            var sel = FamilyActivitySelection()
            sel.applicationTokens = applicationTokens
            sel.webDomainTokens = webDomainTokens
            return sel
        }
        set {
            applicationTokens = newValue.applicationTokens
            webDomainTokens = newValue.webDomainTokens
        }
    }

    /// Total count of apps and domains in this group
    var appCount: Int {
        applicationTokens.count + webDomainTokens.count
    }

    /// Check if group has any apps selected
    var hasApps: Bool {
        appCount > 0
    }
}

// MARK: - Schedule

/// Defines when an app group is active
struct AppGroupSchedule: Codable {
    var alwaysActive: Bool
    var startTime: DateComponents
    var endTime: DateComponents
    var activeDays: Set<Int> // 1=Sunday, 2=Monday, ..., 7=Saturday

    init(
        alwaysActive: Bool = true,
        startTime: DateComponents = DateComponents(hour: 0, minute: 0),
        endTime: DateComponents = DateComponents(hour: 23, minute: 59),
        activeDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    ) {
        self.alwaysActive = alwaysActive
        self.startTime = startTime
        self.endTime = endTime
        self.activeDays = activeDays
    }
}

// MARK: - Schedule Validation

extension AppGroupSchedule {
    /// Check if schedule is active at a given date/time
    func isActive(at date: Date = Date()) -> Bool {
        // If always active, no need to check schedule
        guard !alwaysActive else { return true }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        // Check if today is an active day
        guard activeDays.contains(weekday) else { return false }

        // Get current time components
        let currentTime = calendar.dateComponents([.hour, .minute], from: date)

        // Handle overnight schedules (e.g., 22:00 - 06:00)
        if isOvernightSchedule {
            return isTimeInOvernightRange(currentTime)
        } else {
            return isTimeInRange(currentTime)
        }
    }

    /// Check if this is an overnight schedule (start > end)
    private var isOvernightSchedule: Bool {
        let startHour = startTime.hour ?? 0
        let endHour = endTime.hour ?? 0
        return startHour > endHour
    }

    /// Check if time is in normal range (start <= time <= end)
    private func isTimeInRange(_ time: DateComponents) -> Bool {
        let hour = time.hour ?? 0
        let minute = time.minute ?? 0
        let startHour = startTime.hour ?? 0
        let startMinute = startTime.minute ?? 0
        let endHour = endTime.hour ?? 0
        let endMinute = endTime.minute ?? 0

        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        return currentMinutes >= startMinutes && currentMinutes <= endMinutes
    }

    /// Check if time is in overnight range (start <= time OR time <= end)
    private func isTimeInOvernightRange(_ time: DateComponents) -> Bool {
        let hour = time.hour ?? 0
        let minute = time.minute ?? 0
        let startHour = startTime.hour ?? 0
        let startMinute = startTime.minute ?? 0
        let endHour = endTime.hour ?? 0
        let endMinute = endTime.minute ?? 0

        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        // Time is either after start OR before end
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes
    }
}

// MARK: - Codable Implementation

@available(iOS 16.0, *)
extension AppGroup {
    enum CodingKeys: String, CodingKey {
        case id, name, pauseForSeconds, dailyOpenLimit, blockAfterMaxUse
        case schedule, createdAt, lastUsedDate, streakDays
        case applicationTokens, webDomainTokens
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pauseForSeconds = try container.decode(Int.self, forKey: .pauseForSeconds)
        dailyOpenLimit = try container.decodeIfPresent(Int.self, forKey: .dailyOpenLimit)
        blockAfterMaxUse = try container.decode(Bool.self, forKey: .blockAfterMaxUse)
        schedule = try container.decode(AppGroupSchedule.self, forKey: .schedule)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastUsedDate = try container.decodeIfPresent(Date.self, forKey: .lastUsedDate)
        streakDays = try container.decode(Int.self, forKey: .streakDays)

        // Decode tokens directly (Token<T> is Codable)
        applicationTokens = try container.decode(Set<SafeApplicationToken>.self, forKey: .applicationTokens)
        webDomainTokens = try container.decode(Set<SafeWebDomainToken>.self, forKey: .webDomainTokens)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(pauseForSeconds, forKey: .pauseForSeconds)
        try container.encodeIfPresent(dailyOpenLimit, forKey: .dailyOpenLimit)
        try container.encode(blockAfterMaxUse, forKey: .blockAfterMaxUse)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(lastUsedDate, forKey: .lastUsedDate)
        try container.encode(streakDays, forKey: .streakDays)

        // Encode tokens directly (Token<T> is Codable)
        try container.encode(applicationTokens, forKey: .applicationTokens)
        try container.encode(webDomainTokens, forKey: .webDomainTokens)
    }
}

// MARK: - Validation Result

enum ValidationResult {
    case success
    case failure(title: String, message: String)

    var isValid: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}
