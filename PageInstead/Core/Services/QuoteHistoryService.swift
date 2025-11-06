import Foundation

/// Service for tracking user's quote viewing history
/// Maintains a FIFO queue of the last 10 quotes seen
class QuoteHistoryService {
    static let shared = QuoteHistoryService()

    private let maxHistorySize = 10
    private let appGroupDefaults = UserDefaults(suiteName: "group.com.pageinstead")
    private let historyKey = "quote_history_last_10"
    private let allDatesKey = "quote_history_all_dates"

    private init() {}

    // MARK: - Public Methods

    /// Record that user viewed a quote
    /// - Parameter quote: The quote that was viewed
    func addQuoteView(_ quote: BookQuote) {
        print("📝 QuoteHistoryService: Recording view for quote #\(quote.id)")

        // 1. Load existing history
        var history = loadHistory()

        // 2. Check if it's duplicate of most recent (within 5 minutes)
        if let lastEntry = history.first,
           lastEntry.quoteId == quote.id,
           Date().timeIntervalSince1970 - lastEntry.timestamp < 300 {
            print("⏭️  QuoteHistoryService: Skipping duplicate quote within 5 min")
            return
        }

        // 3. Create new entry
        let windowInfo = QuoteScheduler.shared.getCurrentWindowInfo()
        let newEntry = QuoteHistoryEntry(
            quoteId: quote.id,
            timestamp: Date().timeIntervalSince1970,
            windowStart: windowInfo.currentWindowStart
        )

        // 4. Add to front (newest first)
        history.insert(newEntry, at: 0)

        // 5. Trim to max size (FIFO - oldest drops off)
        if history.count > maxHistorySize {
            history = Array(history.prefix(maxHistorySize))
        }

        // 6. Save back to UserDefaults
        saveHistory(history)

        // 7. Also record date for streak calculation
        recordViewDate()

        print("✅ QuoteHistoryService: Saved history (\(history.count) entries)")
    }

    /// Get the last 10 quotes viewed
    /// - Returns: Array of history entries (newest first)
    func loadHistory() -> [QuoteHistoryEntry] {
        guard let data = appGroupDefaults?.data(forKey: historyKey) else {
            print("📂 QuoteHistoryService: No history found")
            return []
        }

        do {
            let history = try JSONDecoder().decode([QuoteHistoryEntry].self, from: data)
            print("📖 QuoteHistoryService: Loaded \(history.count) history entries")
            return history
        } catch {
            print("⚠️ QuoteHistoryService: Failed to decode history: \(error)")
            return []
        }
    }

    /// Get quotes seen today count
    /// - Returns: Number of unique quotes viewed today
    func getQuotesSeenToday() -> Int {
        let history = loadHistory()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todayEntries = history.filter { entry in
            let entryDate = Date(timeIntervalSince1970: entry.timestamp)
            return calendar.startOfDay(for: entryDate) == today
        }

        print("📊 QuoteHistoryService: \(todayEntries.count) quotes seen today")
        return todayEntries.count
    }

    /// Calculate the current streak (consecutive days with at least 1 quote view)
    /// - Returns: Number of consecutive days
    func calculateStreak() -> Int {
        guard let allDatesData = appGroupDefaults?.data(forKey: allDatesKey),
              let allTimestamps = try? JSONDecoder().decode([TimeInterval].self, from: allDatesData) else {
            print("📊 QuoteHistoryService: No date history, streak = 0")
            return 0
        }

        let calendar = Calendar.current

        // Convert timestamps to unique dates (start of day)
        let uniqueDates = Set(allTimestamps.map { timestamp in
            calendar.startOfDay(for: Date(timeIntervalSince1970: timestamp))
        }).sorted(by: >)

        guard !uniqueDates.isEmpty else {
            return 0
        }

        // Count consecutive days from today
        var streak = 0
        let today = calendar.startOfDay(for: Date())

        for i in 0..<uniqueDates.count {
            let expectedDate = calendar.date(byAdding: .day, value: -i, to: today)!

            if uniqueDates.indices.contains(i) && uniqueDates[i] == expectedDate {
                streak += 1
            } else {
                break
            }
        }

        print("📊 QuoteHistoryService: Calculated streak = \(streak) days")
        return streak
    }

    /// Clear all history (for testing/reset)
    func clearHistory() {
        appGroupDefaults?.removeObject(forKey: historyKey)
        appGroupDefaults?.removeObject(forKey: allDatesKey)
        print("🗑️  QuoteHistoryService: Cleared all history")
    }

    // MARK: - Private Methods

    /// Save history to UserDefaults
    private func saveHistory(_ history: [QuoteHistoryEntry]) {
        do {
            let data = try JSONEncoder().encode(history)
            appGroupDefaults?.set(data, forKey: historyKey)
            print("💾 QuoteHistoryService: Saved \(history.count) entries")
        } catch {
            print("⚠️ QuoteHistoryService: Failed to save history: \(error)")
        }
    }

    /// Record today's date for streak tracking
    private func recordViewDate() {
        // Load existing dates
        var allTimestamps: [TimeInterval] = []
        if let data = appGroupDefaults?.data(forKey: allDatesKey),
           let decoded = try? JSONDecoder().decode([TimeInterval].self, from: data) {
            allTimestamps = decoded
        }

        // Add current timestamp
        let now = Date().timeIntervalSince1970
        allTimestamps.append(now)

        // Cleanup: Keep only last 90 days
        let ninetyDaysAgo = Date().addingTimeInterval(-90 * 24 * 60 * 60).timeIntervalSince1970
        allTimestamps = allTimestamps.filter { $0 >= ninetyDaysAgo }

        // Save back
        if let data = try? JSONEncoder().encode(allTimestamps) {
            appGroupDefaults?.set(data, forKey: allDatesKey)
        }
    }
}
