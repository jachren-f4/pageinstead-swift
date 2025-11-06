import Foundation

/// Manages unlock streak tracking - consecutive days without unlocking blocked apps
/// Uses App Group storage for sharing data between main app and extensions
class StreakService {
    static let shared = StreakService()

    private let defaults: UserDefaults?
    private let appGroupID = "group.com.pageinstead"

    // UserDefaults keys
    private let kCurrentStreak = "streak_current"
    private let kRecordStreak = "streak_record"
    private let kLastUnlockDate = "streak_last_unlock_date"
    private let kStreakStartedDate = "streak_started_date"
    private let kLastUpdateDate = "streak_last_update_date"

    private init() {
        defaults = UserDefaults(suiteName: appGroupID)

        // Initialize with 1-day streak if first launch
        if defaults?.object(forKey: kCurrentStreak) == nil {
            defaults?.set(1, forKey: kCurrentStreak)
            defaults?.set(1, forKey: kRecordStreak)
            defaults?.set(formatDate(Date()), forKey: kStreakStartedDate)
            defaults?.set(formatDate(Date()), forKey: kLastUpdateDate)
            print("🔥 StreakService: First launch - initialized with 1-day streak")
        }
    }

    // MARK: - Public API

    /// Get current streak (consecutive days without unlocking)
    func getCurrentStreak() -> Int {
        return defaults?.integer(forKey: kCurrentStreak) ?? 1
    }

    /// Get record streak (longest ever achieved)
    func getRecordStreak() -> Int {
        return defaults?.integer(forKey: kRecordStreak) ?? 1
    }

    /// Get streak progress (0.0 to 1.0) for display
    func getStreakProgress() -> Double {
        let current = Double(getCurrentStreak())
        let record = Double(getRecordStreak())

        // If on a record streak, show 100%
        if current >= record {
            return 1.0
        }

        // Otherwise show progress toward record (minimum 5%)
        return max(0.05, current / record)
    }

    /// Get last unlock date (nil if never unlocked)
    func getLastUnlockDate() -> Date? {
        guard let dateString = defaults?.string(forKey: kLastUnlockDate) else {
            return nil
        }
        return parseDate(dateString)
    }

    /// Get streak started date
    func getStreakStartedDate() -> Date? {
        guard let dateString = defaults?.string(forKey: kStreakStartedDate) else {
            return nil
        }
        return parseDate(dateString)
    }

    /// Record an unlock event (breaks the streak)
    func recordUnlock() {
        let current = getCurrentStreak()
        let record = getRecordStreak()
        let today = formatDate(Date())

        print("🔥 StreakService: UNLOCK RECORDED - breaking streak")
        print("   Previous: \(current) days, Record: \(record) days")

        // Reset streak to 1
        defaults?.set(1, forKey: kCurrentStreak)

        // Record unlock date
        defaults?.set(today, forKey: kLastUnlockDate)

        // Reset streak start date to today
        defaults?.set(today, forKey: kStreakStartedDate)

        // Update last check date to today
        defaults?.set(today, forKey: kLastUpdateDate)

        defaults?.synchronize()

        print("   New streak: 1 day (5% of \(record))")
    }

    /// Check daily progress (called at midnight or on app launch fallback)
    func checkDailyProgress() {
        let calendar = Calendar.current
        let today = formatDate(Date())

        guard let lastUpdateString = defaults?.string(forKey: kLastUpdateDate),
              let lastUpdateDate = parseDate(lastUpdateString) else {
            print("🔥 StreakService: No last update date, initializing")
            defaults?.set(today, forKey: kLastUpdateDate)
            return
        }

        let todayDate = calendar.startOfDay(for: Date())
        let lastUpdate = calendar.startOfDay(for: lastUpdateDate)
        let daysSinceUpdate = calendar.dateComponents([.day], from: lastUpdate, to: todayDate).day ?? 0

        print("🔥 StreakService: Daily check - days since last update: \(daysSinceUpdate)")

        if daysSinceUpdate == 0 {
            // Already checked today, skip
            print("   Already checked today, skipping")
            return
        }

        if daysSinceUpdate == 1 {
            // Yesterday was last check - increment streak (no unlock occurred)
            incrementStreak()
        } else if daysSinceUpdate > 1 {
            // Missed days - assume streak broken
            print("   Missed \(daysSinceUpdate) days - resetting streak")
            defaults?.set(1, forKey: kCurrentStreak)
            defaults?.set(today, forKey: kStreakStartedDate)
        }

        // Update last check date
        defaults?.set(today, forKey: kLastUpdateDate)
        defaults?.synchronize()
    }

    // MARK: - Private Helpers

    private func incrementStreak() {
        var current = getCurrentStreak()
        let record = getRecordStreak()

        current += 1
        defaults?.set(current, forKey: kCurrentStreak)

        // Update record if we beat it
        if current > record {
            defaults?.set(current, forKey: kRecordStreak)
            print("🔥 StreakService: NEW RECORD! \(current) days")
        } else {
            print("🔥 StreakService: Streak incremented to \(current) days (\(Int(Double(current) / Double(record) * 100))% of record)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}
