import Foundation
import SwiftUI

@available(iOS 16.0, *)
class HistoryViewModel: ObservableObject {
    @Published var events: [ShieldEvent] = []
    @Published var isLoading = false

    private let dataStore = ShieldDataStore.shared

    /// Load all shield events from storage, sorted by newest first
    func loadHistory() {
        print("🔄 HistoryViewModel: loadHistory called")
        isLoading = true

        // Get events from data store
        let allEvents = dataStore.getAllShieldEvents()
        print("📥 HistoryViewModel: Received \(allEvents.count) events from dataStore")

        // Sort by timestamp (newest first)
        events = allEvents.sorted { $0.timestamp > $1.timestamp }

        isLoading = false

        print("📊 HistoryViewModel: Loaded \(events.count) events (sorted)")

        if events.isEmpty {
            print("⚠️ HistoryViewModel: No events found in history!")
        } else {
            print("✅ HistoryViewModel: First event - Quote #\(events[0].quoteId), App: \(events[0].blockedApp)")
        }
    }

    /// Clear all history
    func clearHistory() {
        dataStore.clearAllHistory()
        events = []
        print("🗑️ HistoryViewModel: Cleared all history")
    }

    /// Filter events by app name
    func filterByApp(_ appName: String) -> [ShieldEvent] {
        return events.filter { $0.blockedApp == appName }
    }

    /// Get unique list of blocked apps
    func getUniqueApps() -> [String] {
        let apps = Set(events.map { $0.blockedApp })
        return Array(apps).sorted()
    }

    /// Get count of events for today
    func getTodayCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return events.filter { event in
            let eventDate = Date(timeIntervalSince1970: event.timestamp)
            return calendar.isDate(eventDate, inSameDayAs: today)
        }.count
    }
}
