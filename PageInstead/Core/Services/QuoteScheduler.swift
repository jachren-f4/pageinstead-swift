import Foundation

/// Time-based quote scheduler that ensures Shield Extension and main app show the same quote
/// Uses deterministic calculation based on 5-minute time windows
class QuoteScheduler {
    static let shared = QuoteScheduler()

    /// Duration of each time window in minutes
    private let windowDurationMinutes = 5

    /// Grace period in seconds after window transition to show previous quote
    private let gracePeriodSeconds: TimeInterval = 30

    private init() {}

    // MARK: - Public Methods

    /// Get the current quote based on the current time
    /// Uses grace period to handle edge cases when user sees quote at end of window
    /// - Returns: The quote for the current time window
    func getCurrentQuote() -> BookQuote {
        let now = Date()

        // Check if we're within grace period of a window transition
        let secondsSinceWindowStart = getSecondsSinceWindowStart(at: now)

        if secondsSinceWindowStart < gracePeriodSeconds {
            // We just transitioned to a new window, show previous quote
            print("🕐 QuoteScheduler: Within grace period (\(Int(secondsSinceWindowStart))s), showing previous quote")
            return getPreviousWindowQuote(at: now)
        }

        return getQuote(at: now)
    }

    /// Get the quote for a specific time (used for history)
    /// - Parameter date: The time to get the quote for
    /// - Returns: The quote for that time window
    func getQuote(at date: Date) -> BookQuote {
        let windowIndex = calculateWindowIndex(at: date)
        let allQuotes = QuoteService.shared.getActiveQuotes()

        guard !allQuotes.isEmpty else {
            print("⚠️ QuoteScheduler: No active quotes available, using fallback")
            return BookQuote.fallbackQuotes.first!
        }

        // Add date-based offset so same time each day shows different quotes
        // Use day-of-year multiplied by coprime number for good distribution
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        // 37 is coprime with most quote counts, ensures good distribution
        let dailyOffset = (dayOfYear * 37) % allQuotes.count
        let quoteIndex = (windowIndex + dailyOffset) % allQuotes.count
        let quote = allQuotes[quoteIndex]

        print("📅 QuoteScheduler: Window \(windowIndex) + Day \(dayOfYear) offset → Quote #\(quote.id) from \(quote.author)")

        return quote
    }

    /// Get the quote from the previous time window
    /// - Parameter date: Current time
    /// - Returns: The quote from the previous 5-minute window
    func getPreviousWindowQuote(at date: Date = Date()) -> BookQuote {
        let previousDate = date.addingTimeInterval(-TimeInterval(windowDurationMinutes * 60))
        return getQuote(at: previousDate)
    }

    /// Get information about the current time window
    /// - Returns: Tuple containing window index and next window start time
    func getCurrentWindowInfo() -> (windowIndex: Int, nextWindowAt: Date, currentWindowStart: Date) {
        let now = Date()
        let windowIndex = calculateWindowIndex(at: now)
        let nextWindowAt = getNextWindowStart(at: now)
        let currentWindowStart = getCurrentWindowStart(at: now)

        return (windowIndex, nextWindowAt, currentWindowStart)
    }

    /// Get a list of recent time windows with their quotes
    /// - Parameters:
    ///   - count: Number of windows to return (default 50, approximately 4 hours)
    ///   - from: Starting date (default now)
    /// - Returns: Array of (time, quote) tuples for recent windows
    func getRecentWindows(count: Int = 50, from date: Date = Date()) -> [(time: Date, quote: BookQuote)] {
        var windows: [(Date, BookQuote)] = []

        for i in 0..<count {
            let windowTime = date.addingTimeInterval(-TimeInterval(i * windowDurationMinutes * 60))
            let windowStart = getCurrentWindowStart(at: windowTime)
            let quote = getQuote(at: windowTime)
            windows.append((windowStart, quote))
        }

        return windows
    }

    // MARK: - Private Calculation Methods

    /// Calculate the window index for a given time
    /// Window 0 = 00:00-00:05, Window 1 = 00:05-00:10, etc.
    /// - Parameter date: The date/time to calculate for
    /// - Returns: Window index (0-287 for a 24-hour period)
    private func calculateWindowIndex(at date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        let minutesSinceMidnight = (hour * 60) + minute
        let windowIndex = minutesSinceMidnight / windowDurationMinutes

        return windowIndex
    }

    /// Get the start time of the current window
    /// - Parameter date: The date/time to calculate for
    /// - Returns: Date representing the start of the current window
    private func getCurrentWindowStart(at date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        // Round down to nearest 5-minute interval
        let windowMinute = (minute / windowDurationMinutes) * windowDurationMinutes

        var windowComponents = DateComponents()
        windowComponents.year = components.year
        windowComponents.month = components.month
        windowComponents.day = components.day
        windowComponents.hour = hour
        windowComponents.minute = windowMinute
        windowComponents.second = 0

        return calendar.date(from: windowComponents) ?? date
    }

    /// Get the start time of the next window
    /// - Parameter date: The date/time to calculate for
    /// - Returns: Date representing the start of the next window
    private func getNextWindowStart(at date: Date) -> Date {
        let currentWindowStart = getCurrentWindowStart(at: date)
        return currentWindowStart.addingTimeInterval(TimeInterval(windowDurationMinutes * 60))
    }

    /// Get seconds elapsed since the current window started
    /// - Parameter date: The date/time to calculate for
    /// - Returns: Seconds since window start
    private func getSecondsSinceWindowStart(at date: Date) -> TimeInterval {
        let windowStart = getCurrentWindowStart(at: date)
        return date.timeIntervalSince(windowStart)
    }

    // MARK: - Debug/Testing Methods

    /// Get debug information about the current scheduling state
    /// - Returns: Human-readable debug string
    func getDebugInfo() -> String {
        let info = getCurrentWindowInfo()
        let secondsSinceStart = getSecondsSinceWindowStart(at: Date())
        let quote = getCurrentQuote()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        var debug = """
        📊 QuoteScheduler Debug Info

        Current Time: \(dateFormatter.string(from: Date()))
        Window Index: \(info.windowIndex) of 288 daily windows
        Window Start: \(dateFormatter.string(from: info.currentWindowStart))
        Next Window:  \(dateFormatter.string(from: info.nextWindowAt))
        Time in Window: \(Int(secondsSinceStart))s / \(windowDurationMinutes * 60)s

        Current Quote:
        ID: \(quote.id)
        Text: "\(quote.text)"
        Author: \(quote.author)
        Book: \(quote.bookTitle)

        Total Active Quotes: \(QuoteService.shared.getActiveQuotes().count)
        Daily Repetitions: ~\(String(format: "%.2f", 288.0 / Double(QuoteService.shared.getActiveQuotes().count)))
        """

        return debug
    }
}
