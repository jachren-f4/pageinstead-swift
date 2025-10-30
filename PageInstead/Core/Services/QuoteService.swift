import Foundation

/// Root structure for quotes.json
struct QuotesData: Codable {
    let version: Int
    let lastUpdated: String
    let quotes: [BookQuote]
}

/// Service for loading and managing book quotes from JSON
/// Note: BookQuote is defined in QuoteData.swift (shared with ShieldConfiguration)
class QuoteService {
    static let shared = QuoteService()

    private var allQuotes: [BookQuote] = []
    private var quotesById: [Int: BookQuote] = [:]

    private init() {
        loadQuotes()
    }

    /// Load quotes from quotes.json in bundle
    private func loadQuotes() {
        print("🔍 QuoteService: Attempting to load quotes...")
        print("🔍 Bundle path: \(Bundle.main.bundlePath)")

        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
            print("❌ quotes.json not found in bundle")
            print("🔍 Available resources: \(Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil))")
            print("⚠️ Using fallback hardcoded quotes")
            useFallbackQuotes()
            return
        }

        print("✅ Found quotes.json at: \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            print("✅ Read \(data.count) bytes from quotes.json")

            let quotesData = try JSONDecoder().decode(QuotesData.self, from: data)
            print("✅ Decoded quotes data successfully")

            self.allQuotes = quotesData.quotes
            self.quotesById = Dictionary(uniqueKeysWithValues: allQuotes.map { ($0.id, $0) })

            print("✅ Loaded \(allQuotes.count) quotes (version \(quotesData.version))")

            // Validate no duplicate IDs
            let uniqueIds = Set(allQuotes.map { $0.id })
            if uniqueIds.count != allQuotes.count {
                print("⚠️ WARNING: Duplicate quote IDs detected!")
            }
        } catch {
            print("❌ Failed to load quotes.json: \(error)")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding error details: \(decodingError)")
            }
            print("⚠️ Using fallback hardcoded quotes")
            useFallbackQuotes()
        }
    }

    /// Use fallback quotes when JSON loading fails
    private func useFallbackQuotes() {
        self.allQuotes = BookQuote.fallbackQuotes
        self.quotesById = Dictionary(uniqueKeysWithValues: allQuotes.map { ($0.id, $0) })
        print("✅ Loaded \(allQuotes.count) fallback quotes")
    }

    // MARK: - Public Methods

    /// Get all quotes (including inactive)
    func getAllQuotes() -> [BookQuote] {
        return allQuotes
    }

    /// Get only active quotes (isActive = true)
    func getActiveQuotes() -> [BookQuote] {
        return allQuotes.filter { $0.isActive }
    }

    /// Get a specific quote by ID
    /// - Parameter id: The quote ID
    /// - Returns: The quote, or nil if not found
    func getQuote(byId id: Int) -> BookQuote? {
        return quotesById[id]
    }

    /// Get a random quote from active quotes
    /// - Returns: A random active quote, or nil if no active quotes available
    func getRandomQuote() -> BookQuote? {
        let activeQuotes = getActiveQuotes()
        return activeQuotes.randomElement()
    }

    /// Get recent quotes (by dateAdded)
    /// - Parameter limit: Maximum number of quotes to return
    /// - Returns: Array of quotes sorted by date added (newest first)
    func getRecentQuotes(limit: Int = 10) -> [BookQuote] {
        let sorted = allQuotes.sorted { $0.dateAdded > $1.dateAdded }
        return Array(sorted.prefix(limit))
    }

    /// Get quotes filtered by tag
    /// - Parameter tag: The tag to filter by
    /// - Returns: Array of quotes containing the specified tag
    func getQuotes(byTag tag: String) -> [BookQuote] {
        return allQuotes.filter { $0.tags.contains(tag) }
    }

    /// Get all unique tags across all quotes
    /// - Returns: Sorted array of unique tags
    func getAllTags() -> [String] {
        let allTags = allQuotes.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }

    /// Get quotes by book ID (multiple quotes from same book)
    /// - Parameter bookId: The book identifier
    /// - Returns: Array of quotes from the specified book
    func getQuotes(byBookId bookId: String) -> [BookQuote] {
        return allQuotes.filter { $0.bookId == bookId }
    }
}
