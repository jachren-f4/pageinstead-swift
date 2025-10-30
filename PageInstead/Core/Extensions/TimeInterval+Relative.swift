import Foundation

extension TimeInterval {
    /// Convert timestamp to relative time string (e.g., "2 hours ago", "Yesterday")
    func relativeTime() -> String {
        let date = Date(timeIntervalSince1970: self)
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.minute, .hour, .day, .weekOfYear],
            from: date,
            to: now
        )

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}
