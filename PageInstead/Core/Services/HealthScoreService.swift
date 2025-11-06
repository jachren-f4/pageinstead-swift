import Foundation

/// Manages Screen Health Score based on blocked app attempts
/// Uses App Group storage for sharing data between main app and Shield Extension
class HealthScoreService {
    static let shared = HealthScoreService()

    private let defaults: UserDefaults?
    private let appGroupID = "group.com.pageinstead"

    // UserDefaults keys
    private let kInstallDate = "install_date"
    private let kLastAttemptDate = "last_attempt_date"
    private let kBlockedAttemptsToday = "blocked_attempts_today"
    private let kBaselineAttempts = "baseline_attempts"
    private let kCalibrationDays = "calibration_days_data"
    private let kIsCalibrated = "is_calibrated"
    private let kScreenHealthScore = "screen_health_score"

    // Constants
    private let defaultHealthScore: Double = 75.0
    private let calibrationPeriodDays = 3

    private init() {
        defaults = UserDefaults(suiteName: appGroupID)

        // Set install date if first launch
        if defaults?.object(forKey: kInstallDate) == nil {
            defaults?.set(Date(), forKey: kInstallDate)
            print("🏥 HealthScoreService: First install recorded")
        }
    }

    // MARK: - Public API

    /// Get current Screen Health Score (0-100%)
    func getCurrentHealthScore() -> Double {
        checkAndResetDaily()

        // First 24 hours: return default score
        if !hasCompletedFirstDay() {
            return defaultHealthScore
        }

        // Not yet calibrated: return default score
        guard isCalibrated() else {
            return defaultHealthScore
        }

        // Calculate real score
        let attempts = getBlockedAttemptsToday()
        let baseline = getBaselineAttempts()
        return calculateHealthScore(attempts: attempts, baseline: baseline)
    }

    /// Get today's blocked attempts count
    func getBlockedAttemptsToday() -> Int {
        checkAndResetDaily()
        return defaults?.integer(forKey: kBlockedAttemptsToday) ?? 0
    }

    /// Get baseline attempts (average during calibration)
    func getBaselineAttempts() -> Int {
        return defaults?.integer(forKey: kBaselineAttempts) ?? 15 // Default to 15 if not calibrated
    }

    /// Increment blocked attempts counter (called from Shield Extension)
    func incrementBlockedAttempts() {
        checkAndResetDaily()

        let current = getBlockedAttemptsToday()
        defaults?.set(current + 1, forKey: kBlockedAttemptsToday)

        print("🏥 HealthScoreService: Blocked attempts incremented to \(current + 1)")

        // Recalculate score
        updateHealthScore()
    }

    /// Record today's data for calibration (called from DeviceActivityMonitor)
    func recordDailyData(totalAttempts: Int) {
        checkAndResetDaily()

        // Update today's counter if monitor has higher count
        let currentCount = getBlockedAttemptsToday()
        if totalAttempts > currentCount {
            defaults?.set(totalAttempts, forKey: kBlockedAttemptsToday)
            print("🏥 HealthScoreService: Daily reconciliation - updated to \(totalAttempts) attempts")
        }

        // Add to calibration data if not yet calibrated
        if !isCalibrated() {
            addCalibrationDay(attempts: totalAttempts)
        }

        // Save to history
        saveDailySummary()

        // Recalculate score
        updateHealthScore()
    }

    /// Check if calibration is complete
    func isCalibrated() -> Bool {
        return defaults?.bool(forKey: kIsCalibrated) ?? false
    }

    /// Get calibration progress (0-3 days)
    func getCalibrationProgress() -> Int {
        guard let calibrationData = defaults?.array(forKey: kCalibrationDays) as? [[String: Any]] else {
            return 0
        }
        return calibrationData.count
    }

    /// Get historical data (last 180 days)
    func getHistory() -> [DaySummary] {
        guard let data = try? loadHistoryData() else { return [] }
        return data
    }

    // MARK: - Private Helpers

    private func hasCompletedFirstDay() -> Bool {
        guard let installDate = defaults?.object(forKey: kInstallDate) as? Date else {
            return false
        }
        let hoursSinceInstall = Date().timeIntervalSince(installDate) / 3600
        return hoursSinceInstall >= 24
    }

    private func checkAndResetDaily() {
        let lastDate = defaults?.object(forKey: kLastAttemptDate) as? Date ?? Date.distantPast

        if !Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
            // New day - reset counter
            print("🏥 HealthScoreService: New day detected - resetting counter")
            defaults?.set(0, forKey: kBlockedAttemptsToday)
            defaults?.set(Date(), forKey: kLastAttemptDate)
        }
    }

    private func calculateHealthScore(attempts: Int, baseline: Int) -> Double {
        guard baseline > 0 else { return defaultHealthScore }

        // Formula: SHS = 100 - ((attempts / baseline) * 100)
        let rawScore = 100.0 - (Double(attempts) / Double(baseline) * 100.0)

        // Clamp between 0 and 100
        return max(0, min(100, rawScore))
    }

    private func updateHealthScore() {
        let score = getCurrentHealthScore()
        defaults?.set(score, forKey: kScreenHealthScore)
    }

    // MARK: - Calibration Logic

    private func addCalibrationDay(attempts: Int) {
        var calibrationData = defaults?.array(forKey: kCalibrationDays) as? [[String: Any]] ?? []

        let todayString = ISO8601DateFormatter().string(from: Date())
        let dayData: [String: Any] = ["date": todayString, "attempts": attempts]

        // Check if today already recorded
        if let lastEntry = calibrationData.last as? [String: Any],
           let lastDate = lastEntry["date"] as? String,
           lastDate == todayString {
            // Update today's data
            calibrationData[calibrationData.count - 1] = dayData
        } else {
            // Add new day
            calibrationData.append(dayData)
        }

        defaults?.set(calibrationData, forKey: kCalibrationDays)

        print("🏥 HealthScoreService: Calibration day \(calibrationData.count)/\(calibrationPeriodDays) recorded")

        // Check if calibration complete
        if calibrationData.count >= calibrationPeriodDays {
            completeCalibration(data: calibrationData)
        }
    }

    private func completeCalibration(data: [[String: Any]]) {
        // Calculate average attempts from calibration period
        let totalAttempts = data.compactMap { $0["attempts"] as? Int }.reduce(0, +)
        let avgAttempts = totalAttempts / data.count

        defaults?.set(avgAttempts, forKey: kBaselineAttempts)
        defaults?.set(true, forKey: kIsCalibrated)

        print("🏥 HealthScoreService: Calibration complete! Baseline set to \(avgAttempts) attempts/day")
    }

    // MARK: - Historical Data

    private func saveDailySummary() {
        var history = getHistory()

        let todayString = formatDate(Date())
        let attempts = getBlockedAttemptsToday()
        let score = getCurrentHealthScore()

        let summary = DaySummary(date: todayString, blockedAttempts: attempts, healthScore: score)

        // Update or append
        if let lastIndex = history.lastIndex(where: { $0.date == todayString }) {
            history[lastIndex] = summary
        } else {
            history.append(summary)
        }

        // Keep only last 180 days
        if history.count > 180 {
            history.removeFirst(history.count - 180)
        }

        saveHistoryData(history)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func loadHistoryData() throws -> [DaySummary] {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return []
        }

        let fileURL = containerURL.appendingPathComponent("BlockedAttemptsHistory.json")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([DaySummary].self, from: data)
    }

    private func saveHistoryData(_ history: [DaySummary]) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            print("⚠️ HealthScoreService: Could not access App Group container")
            return
        }

        let fileURL = containerURL.appendingPathComponent("BlockedAttemptsHistory.json")

        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
            print("🏥 HealthScoreService: History saved (\(history.count) days)")
        } catch {
            print("⚠️ HealthScoreService: Failed to save history: \(error)")
        }
    }
}

// MARK: - Data Models

struct DaySummary: Codable {
    let date: String           // "2025-10-31"
    let blockedAttempts: Int   // Number of times user opened blocked apps
    let healthScore: Double    // 0-100%
}
