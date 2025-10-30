import DeviceActivity
import Foundation
import ManagedSettings

@available(iOS 16.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    // MARK: - Monitoring Lifecycle

    /// Called when a monitoring interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("📊 DeviceActivityMonitor: Interval started for \(activity)")

        // Save a test event to verify monitor is working
        // This helps us know the monitor is active even if threshold events don't fire
        print("📊 DeviceActivityMonitor: Monitoring is active, saving interval start event")
        saveBlockingEvent(eventName: "intervalStart", activityName: activity.rawValue)
    }

    /// Called when a monitoring interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("📊 DeviceActivityMonitor: Interval ended for \(activity)")
    }

    // MARK: - Event Detection

    /// Called when an event threshold is reached (e.g., app is blocked)
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        print("🚨 DeviceActivityMonitor: Event threshold reached!")
        print("   Event: \(event)")
        print("   Activity: \(activity)")

        // Save the shield event
        // Note: We need to determine which app was blocked and which quote to show
        // For now, we'll log a generic event
        saveBlockingEvent(eventName: event.rawValue, activityName: activity.rawValue)
    }

    /// Called when warning threshold is reached (before full blocking)
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("⚠️ DeviceActivityMonitor: Warning interval starting for \(activity)")
    }

    /// Called when warning ends
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("⚠️ DeviceActivityMonitor: Warning interval ending for \(activity)")
    }

    // MARK: - Helper Methods

    /// Save a blocking event to App Group storage
    private func saveBlockingEvent(eventName: String, activityName: String) {
        print("📝 DeviceActivityMonitor: Saving blocking event...")

        // Try to get the quote that the Shield Extension displayed
        // If not available, pick a new random quote
        let quote: BookQuote
        if let currentQuote = ShieldDataStore.shared.getCurrentQuote() {
            quote = currentQuote
            print("📝 DeviceActivityMonitor: Using saved current quote from \(quote.author)")
        } else if let serviceQuote = QuoteService.shared.getRandomQuote() {
            quote = serviceQuote
            print("📝 DeviceActivityMonitor: Using new quote from \(quote.author)")
        } else {
            quote = BookQuote.fallbackQuotes.randomElement()!
            print("📝 DeviceActivityMonitor: Using fallback quote from \(quote.author)")
        }

        // Create the event
        let event = ShieldEvent(
            quoteId: quote.id,
            timestamp: Date().timeIntervalSince1970,
            blockedApp: "Blocked App" // TODO: Get actual app name from event
        )

        // Save to App Group
        ShieldDataStore.shared.saveShieldEvent(event)

        print("✅ DeviceActivityMonitor: Event saved successfully")
        print("   Quote ID: \(quote.id)")
        print("   Quote: \(quote.text)")
        print("   Author: \(quote.author)")
    }
}
