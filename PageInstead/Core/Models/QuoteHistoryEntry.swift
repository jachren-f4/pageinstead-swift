import Foundation

/// Represents a single quote viewing event in the user's history
struct QuoteHistoryEntry: Codable, Identifiable {
    let id: String
    let quoteId: Int
    let timestamp: TimeInterval
    let windowStart: Date

    init(quoteId: Int, timestamp: TimeInterval = Date().timeIntervalSince1970, windowStart: Date) {
        self.id = UUID().uuidString
        self.quoteId = quoteId
        self.timestamp = timestamp
        self.windowStart = windowStart
    }
}

// MARK: - Helper Extensions

extension QuoteHistoryEntry {
    /// Get relative time string (e.g., "5 min ago", "1h ago")
    var relativeTimeString: String {
        let now = Date().timeIntervalSince1970
        let diff = now - timestamp

        if diff < 300 { // < 5 min
            return "Just now"
        } else if diff < 3600 { // < 1 hour
            let minutes = Int(diff / 60)
            return "\(minutes) min ago"
        } else if diff < 86400 { // < 24 hours
            let hours = Int(diff / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(diff / 86400)
            return "\(days)d ago"
        }
    }

    /// Get Date object from timestamp
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }

    /// Check if this entry is from today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
