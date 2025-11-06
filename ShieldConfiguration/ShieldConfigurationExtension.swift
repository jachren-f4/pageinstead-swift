import ManagedSettings
import ManagedSettingsUI
import UIKit
import FamilyControls

@available(iOS 16.0, *)
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let appGroupID = "group.com.pageinstead"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Main Configuration Methods

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        print("🛡️ Shield: Displaying shield for blocked app")

        // Set flag for onboarding detection
        setFirstShieldSeenFlag()

        // DEBUG: Test if new code is running
        let debugInfo = "DEBUG: Code version 2.0"

        // Get the application token
        guard let token = application.token else {
            print("⚠️ Shield: No token available")
            return createDebugConfiguration(message: "ERROR: No token - \(debugInfo)")
        }

        // Look up which group this app belongs to
        guard let group = lookupGroup(for: token) else {
            print("⚠️ Shield: App not in any group")
            return createDebugConfiguration(message: "ERROR: No group found - \(debugInfo)")
        }

        print("🛡️ Shield: App belongs to group '\(group.name)'")

        // Check if group is currently active (schedule)
        guard isGroupActive(group) else {
            print("🛡️ Shield: Group '\(group.name)' is not active (outside schedule)")
            // Return nil to allow access when outside schedule
            return createFallbackConfiguration()
        }

        // Get today's usage data
        let todayString = dateFormatter.string(from: Date())
        let tokenString = String(describing: token)
        let usageKey = "usage_\(group.id.uuidString)_\(token)_\(todayString)"
        var opensToday = getUserDefaults().integer(forKey: usageKey)

        // Check if daily limit exceeded
        if let limit = group.dailyOpenLimit, opensToday >= limit {
            if group.blockAfterMaxUse {
                // HARD BLOCK - no button
                print("🛡️ Shield: Daily limit reached (\(opensToday)/\(limit)) - HARD BLOCK")
                return createHardBlockConfiguration(opensToday: opensToday, limit: limit)
            }
        }

        // Get current quote
        let quote = QuoteScheduler.shared.getCurrentQuote()
        let windowInfo = QuoteScheduler.shared.getCurrentWindowInfo()
        print("🛡️ Shield: Window \(windowInfo.windowIndex) → Quote #\(quote.id) from \(quote.author)")

        // Return shield with quote (no unlock button - unlock via main app)
        return createQuoteConfiguration(
            quote: quote,
            opensToday: opensToday,
            limit: group.dailyOpenLimit
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        print("🛡️ Shield: Displaying shield for blocked website")

        // Set flag for onboarding detection
        setFirstShieldSeenFlag()

        // Get the web domain token
        guard let token = webDomain.token else {
            print("⚠️ Shield: No token available for domain")
            return createFallbackConfiguration()
        }

        // Look up which group this domain belongs to
        guard let group = lookupGroup(forDomain: token) else {
            print("⚠️ Shield: Domain not in any group")
            return createFallbackConfiguration()
        }

        print("🛡️ Shield: Domain belongs to group '\(group.name)'")

        // Check if group is currently active
        guard isGroupActive(group) else {
            print("🛡️ Shield: Group '\(group.name)' is not active (outside schedule)")
            return createFallbackConfiguration()
        }

        // Similar logic as for apps
        let todayString = dateFormatter.string(from: Date())
        let usageKey = "usage_\(group.id.uuidString)_\(token)_\(todayString)"
        var opensToday = getUserDefaults().integer(forKey: usageKey)

        if let limit = group.dailyOpenLimit, opensToday >= limit {
            if group.blockAfterMaxUse {
                print("🛡️ Shield: Daily limit reached - HARD BLOCK")
                return createHardBlockConfiguration(opensToday: opensToday, limit: limit)
            }
        }

        // Get current quote
        let quote = QuoteScheduler.shared.getCurrentQuote()

        // Return shield with quote (no unlock button - unlock via main app)
        return createQuoteConfiguration(
            quote: quote,
            opensToday: opensToday,
            limit: group.dailyOpenLimit
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: webDomain)
    }

    // MARK: - Group Lookup

    private func lookupGroup(for token: SafeApplicationToken) -> AppGroup? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "app_groups") else {
            return nil
        }

        do {
            let groups = try JSONDecoder().decode([AppGroup].self, from: data)
            return groups.first { $0.applicationTokens.contains(token) }
        } catch {
            print("⚠️ Shield: Error decoding groups: \(error)")
            return nil
        }
    }

    private func lookupGroup(forDomain token: SafeWebDomainToken) -> AppGroup? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "app_groups") else {
            return nil
        }

        do {
            let groups = try JSONDecoder().decode([AppGroup].self, from: data)
            return groups.first { $0.webDomainTokens.contains(token) }
        } catch {
            print("⚠️ Shield: Error decoding groups: \(error)")
            return nil
        }
    }

    // MARK: - Schedule Checking

    private func isGroupActive(_ group: AppGroup) -> Bool {
        let schedule = group.schedule

        // If always active, no need to check schedule
        guard !schedule.alwaysActive else { return true }

        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)

        // Check if today is an active day
        guard schedule.activeDays.contains(weekday) else {
            return false
        }

        // Get current time components
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        let currentHour = currentTime.hour ?? 0
        let currentMinute = currentTime.minute ?? 0
        let currentMinutes = currentHour * 60 + currentMinute

        let startHour = schedule.startTime.hour ?? 0
        let startMinute = schedule.startTime.minute ?? 0
        let startMinutes = startHour * 60 + startMinute

        let endHour = schedule.endTime.hour ?? 0
        let endMinute = schedule.endTime.minute ?? 0
        let endMinutes = endHour * 60 + endMinute

        // Handle overnight schedules (e.g., 22:00 - 06:00)
        if startMinutes > endMinutes {
            // Time is either after start OR before end
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            // Normal schedule
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }
    }

    // MARK: - Shield Configurations

    private func createQuoteConfiguration(
        quote: BookQuote,
        opensToday: Int,
        limit: Int?
    ) -> ShieldConfiguration {
        // Build subtitle with author, book, and unlock instruction
        var subtitleText = "\(quote.author) • \(quote.bookTitle)"

        // Add unlock instruction
        subtitleText += "\n\nVisit PageInstead to unlock app."

        // Add usage info if limit exists
        if let limit = limit {
            subtitleText += "\n\(opensToday)/\(limit) opens today"
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.102, green: 0.0, blue: 0.2, alpha: 0.85),
            icon: UIImage(systemName: "quote.bubble.fill"),
            title: ShieldConfiguration.Label(
                text: formatQuoteText(quote.text),
                color: UIColor(white: 1.0, alpha: 0.95)
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: UIColor(white: 1.0, alpha: 0.7)
            ),
            primaryButtonLabel: nil,  // No button - unlock in main app
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }

    private func createHardBlockConfiguration(opensToday: Int, limit: Int) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.102, green: 0.0, blue: 0.2, alpha: 0.85),
            icon: UIImage(systemName: "hourglass.circle.fill"),
            title: ShieldConfiguration.Label(
                text: "Daily Limit Reached",
                color: UIColor(white: 1.0, alpha: 0.95)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "You've opened this app \(opensToday) times today. Try again tomorrow.",
                color: UIColor(white: 1.0, alpha: 0.7)
            ),
            primaryButtonLabel: nil, // No button in hard block mode
            primaryButtonBackgroundColor: nil
        )
    }

    private func createFallbackConfiguration() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.102, green: 0.0, blue: 0.2, alpha: 0.85),
            icon: UIImage(systemName: "book.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to read instead",
                color: UIColor(white: 1.0, alpha: 0.95)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open PageInstead to discover great books",
                color: UIColor(white: 1.0, alpha: 0.6)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open PageInstead",
                color: UIColor(red: 0.424, green: 0.784, blue: 1.0, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.424, green: 0.784, blue: 1.0, alpha: 0.15)
        )
    }

    // MARK: - Helpers

    private func setFirstShieldSeenFlag() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("⚠️ Shield: Could not access App Group defaults")
            return
        }

        // Set flag that shield was seen (for onboarding Screen 11)
        defaults.set(true, forKey: "firstShieldSeen")
        defaults.set(Date(), forKey: "firstShieldSeenDate")
        defaults.synchronize()

        print("✅ Shield: Set firstShieldSeen flag for onboarding detection")
    }

    private func formatQuoteText(_ text: String) -> String {
        let hasOpeningQuotes = text.hasPrefix("\"") || text.hasPrefix("\u{201C}") || text.hasPrefix("\u{201D}")
        let hasClosingQuotes = text.hasSuffix("\"") || text.hasSuffix("\u{201C}") || text.hasSuffix("\u{201D}")

        if hasOpeningQuotes && hasClosingQuotes {
            return text
        }

        var result = text

        if let firstChar = text.first, firstChar.isLowercase {
            result = "..." + result
        }

        if !hasOpeningQuotes && !hasClosingQuotes {
            result = "\"\(result)\""
        } else if !hasOpeningQuotes {
            result = "\"\(result)"
        } else if !hasClosingQuotes {
            result = "\(result)\""
        }

        return result
    }

    private func getUserDefaults() -> UserDefaults {
        return UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private func createDebugConfiguration(message: String) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor.red.withAlphaComponent(0.3),
            icon: UIImage(systemName: "exclamationmark.triangle.fill"),
            title: ShieldConfiguration.Label(
                text: message,
                color: UIColor.white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Debug Mode - Check this message",
                color: UIColor.yellow
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil
        )
    }
}
