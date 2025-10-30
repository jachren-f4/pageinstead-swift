import ManagedSettings
import ManagedSettingsUI
import UIKit

@available(iOS 16.0, *)
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        print("🛡️ Shield: Displaying quote for blocked app")

        // Get quote using time-based scheduler
        // This ensures Shield and main app always show the same quote at the same time
        let quote = QuoteScheduler.shared.getCurrentQuote()

        let windowInfo = QuoteScheduler.shared.getCurrentWindowInfo()
        print("🛡️ Shield: Window \(windowInfo.windowIndex) → Quote #\(quote.id) from \(quote.author)")
        print("🛡️ Shield: Next quote at \(windowInfo.nextWindowAt)")

        // No need to save quote - main app will independently calculate the same quote
        // No IPC needed thanks to deterministic time-based selection!

        // Create the shield configuration with Liquid Glass aesthetics
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(white: 0.0, alpha: 0.3),
            icon: UIImage(systemName: "book.fill"),
            title: ShieldConfiguration.Label(
                text: "\"\(quote.text)\"",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "— \(quote.author), \(quote.bookTitle)",
                color: UIColor(white: 0.8, alpha: 1.0)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open PageInstead to discover this book",
                color: UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: UIColor.clear
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        print("🛡️ Shield: Displaying quote for blocked website")

        // Get quote using time-based scheduler
        let quote = QuoteScheduler.shared.getCurrentQuote()

        let windowInfo = QuoteScheduler.shared.getCurrentWindowInfo()
        print("🛡️ Shield: Window \(windowInfo.windowIndex) → Quote #\(quote.id) from \(quote.author)")

        // No need to save quote - main app will independently calculate the same quote

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(white: 0.0, alpha: 0.3),
            icon: UIImage(systemName: "book.fill"),
            title: ShieldConfiguration.Label(
                text: "\"\(quote.text)\"",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "— \(quote.author), \(quote.bookTitle)",
                color: UIColor(white: 0.8, alpha: 1.0)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open PageInstead to discover this book",
                color: UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: UIColor.clear
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: webDomain)
    }

    // MARK: - Helper Methods (unused, kept for reference)

    /// Fallback configuration when no quotes are available
    private func createFallbackConfiguration() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(white: 0.0, alpha: 0.3),
            icon: UIImage(systemName: "book.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to read instead",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open PageInstead to discover great books",
                color: UIColor(white: 0.8, alpha: 1.0)
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: UIColor.clear
        )
    }
}
