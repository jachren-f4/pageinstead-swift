import Foundation

// MARK: - Book Quote Model

struct BookQuote: Codable {
    let id: Int
    let text: String
    let author: String
    let bookTitle: String
    let bookId: String
    let asin: String?
    let coverImageURL: String?
    let isActive: Bool
    let tags: [String]
    let dateAdded: String

    // MARK: - Fallback Quotes (if JSON fails to load)
    static let fallbackQuotes: [BookQuote] = [
        BookQuote(
            id: 1,
            text: "The man who does not read has no advantage over the man who cannot read.",
            author: "Mark Twain",
            bookTitle: "Collected Works",
            bookId: "twain_001",
            asin: "B00IWUKUVE",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "education", "wisdom"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 2,
            text: "A reader lives a thousand lives before he dies. The man who never reads lives only one.",
            author: "George R.R. Martin",
            bookTitle: "A Dance with Dragons",
            bookId: "martin_001",
            asin: "B004XISI4A",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "life", "imagination"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 3,
            text: "There is no friend as loyal as a book.",
            author: "Ernest Hemingway",
            bookTitle: "Green Hills of Africa",
            bookId: "hemingway_001",
            asin: "B00P42WY5S",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "friendship", "wisdom"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 4,
            text: "Books are a uniquely portable magic.",
            author: "Stephen King",
            bookTitle: "On Writing",
            bookId: "king_001",
            asin: "B000FC0SIM",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "magic", "inspiration"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 5,
            text: "Reading is essential for those who seek to rise above the ordinary.",
            author: "Jim Rohn",
            bookTitle: "The Art of Exceptional Living",
            bookId: "rohn_001",
            asin: "B09N1191LJ",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "motivation", "success"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 6,
            text: "The more that you read, the more things you will know. The more that you learn, the more places you'll go.",
            author: "Dr. Seuss",
            bookTitle: "I Can Read With My Eyes Shut!",
            bookId: "seuss_001",
            asin: "0394839129",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "learning", "education"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 7,
            text: "Today a reader, tomorrow a leader.",
            author: "Margaret Fuller",
            bookTitle: "Woman in the Nineteenth Century",
            bookId: "fuller_001",
            asin: "B00A62Y8QO",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "leadership", "motivation"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 8,
            text: "Reading is to the mind what exercise is to the body.",
            author: "Joseph Addison",
            bookTitle: "The Tatler",
            bookId: "addison_001",
            asin: "B09QBSS8NB",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "mind", "health"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 9,
            text: "You can find magic wherever you look. Sit back and relax, all you need is a book.",
            author: "Dr. Seuss",
            bookTitle: "The Cat in the Hat",
            bookId: "seuss_002",
            asin: "B077BLF2QW",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "magic", "relaxation"],
            dateAdded: "2025-01-29"
        ),
        BookQuote(
            id: 10,
            text: "Think before you speak. Read before you think.",
            author: "Fran Lebowitz",
            bookTitle: "Social Studies",
            bookId: "lebowitz_001",
            asin: "B004C43ETY",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "wisdom", "thinking"],
            dateAdded: "2025-01-29"
        )
    ]
}

// MARK: - Shield Event Model

struct ShieldEvent: Codable {
    let quoteId: Int
    let timestamp: TimeInterval
    let blockedApp: String
}

// MARK: - Shared Data Store

class ShieldDataStore {
    static let shared = ShieldDataStore()
    private let suiteName = "group.com.pageinstead"
    private let fileName = "shieldEvents.json"
    private let currentQuoteFileName = "currentQuote.json"
    private let maxEvents = 500  // Limit storage
    private let lock = NSLock()  // Thread safety

    private init() {}

    /// Get the file URL in the App Group container
    private var fileURL: URL? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .appendingPathComponent(fileName)
        print("📁 ShieldDataStore: File URL = \(url?.path ?? "nil")")
        return url
    }

    // MARK: - Shield Event History

    /// Save a shield event to history (appends to array)
    func saveShieldEvent(_ event: ShieldEvent) {
        print("📝 ShieldDataStore: saveShieldEvent called for quote \(event.quoteId), app: \(event.blockedApp)")

        lock.lock()
        defer { lock.unlock() }

        guard let fileURL = fileURL else {
            print("⚠️ ShieldDataStore: FAILED to get App Group file URL")
            return
        }

        print("✅ ShieldDataStore: File URL resolved: \(fileURL.path)")

        // Get existing events
        var events = _getAllShieldEventsFromFile(fileURL: fileURL)
        print("📊 ShieldDataStore: Current event count: \(events.count)")

        events.append(event)
        print("📊 ShieldDataStore: New event count: \(events.count)")

        // Cleanup old events if exceeding max
        if events.count > maxEvents {
            events = Array(events.suffix(maxEvents))
            print("🧹 ShieldDataStore: Cleaned up to \(events.count) events")
        }

        // Write to file
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: .atomic)
            print("✅ ShieldDataStore: Saved shield event (quote ID: \(event.quoteId), total events: \(events.count))")

            // Verify it was saved
            if let verifyData = try? Data(contentsOf: fileURL) {
                print("✅ ShieldDataStore: Verified data exists in file (\(verifyData.count) bytes)")
            } else {
                print("⚠️ ShieldDataStore: WARNING - File not found after save!")
            }
        } catch {
            print("⚠️ ShieldDataStore: Failed to save events to file: \(error)")
        }
    }

    /// Get all shield events from history
    func getAllShieldEvents() -> [ShieldEvent] {
        print("📖 ShieldDataStore: getAllShieldEvents called")

        lock.lock()
        defer { lock.unlock() }

        guard let fileURL = fileURL else {
            print("⚠️ ShieldDataStore: FAILED to get App Group file URL for reading")
            return []
        }

        print("✅ ShieldDataStore: File URL resolved for reading")

        let events = _getAllShieldEventsFromFile(fileURL: fileURL)
        print("📊 ShieldDataStore: Retrieved \(events.count) events from file")

        return events
    }

    /// Private helper: Get all shield events from file without locking (caller must hold lock)
    private func _getAllShieldEventsFromFile(fileURL: URL) -> [ShieldEvent] {
        guard let data = try? Data(contentsOf: fileURL) else {
            print("📂 ShieldDataStore: No file found (or empty), returning empty array")
            return []  // No history yet
        }

        do {
            let events = try JSONDecoder().decode([ShieldEvent].self, from: data)
            return events
        } catch {
            print("⚠️ ShieldDataStore: Failed to decode file: \(error)")
            // Try to remove corrupted file
            try? FileManager.default.removeItem(at: fileURL)
            return []
        }
    }

    /// Get recent shield events (newest first)
    func getRecentShieldEvents(limit: Int = 50) -> [ShieldEvent] {
        let events = getAllShieldEvents()
        let sorted = events.sorted { $0.timestamp > $1.timestamp }
        return Array(sorted.prefix(limit))
    }

    /// Clear all history
    func clearAllHistory() {
        lock.lock()
        defer { lock.unlock() }

        guard let fileURL = fileURL else {
            print("⚠️ ShieldDataStore: Cannot get file URL for clearing")
            return
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ ShieldDataStore: Cleared all shield event history")
        } catch {
            print("⚠️ ShieldDataStore: Failed to clear history: \(error)")
        }
    }

    /// Clean up old events (older than specified timestamp)
    func clearOldEvents(olderThan timestamp: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }

        guard let fileURL = fileURL else {
            print("⚠️ ShieldDataStore: Cannot get file URL for cleanup")
            return
        }

        let events = _getAllShieldEventsFromFile(fileURL: fileURL)
        let filtered = events.filter { $0.timestamp >= timestamp }

        do {
            let data = try JSONEncoder().encode(filtered)
            try data.write(to: fileURL, options: .atomic)
            print("✅ ShieldDataStore: Cleaned up \(events.count - filtered.count) old events")
        } catch {
            print("⚠️ ShieldDataStore: Failed to clean up old events: \(error)")
        }
    }

    // MARK: - Compatibility (Legacy)

    /// Get last shield event (for backward compatibility)
    func getLastShieldEvent() -> ShieldEvent? {
        return getRecentShieldEvents(limit: 1).first
    }

    // MARK: - Current Quote Management

    /// Save the current quote being displayed (so Shield and Monitor can use the same quote)
    func saveCurrentQuote(_ quote: BookQuote) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) else {
            print("⚠️ ShieldDataStore: Cannot access App Group for current quote")
            return
        }

        let quoteFileURL = containerURL.appendingPathComponent(currentQuoteFileName)

        do {
            let data = try JSONEncoder().encode(quote)
            try data.write(to: quoteFileURL, options: .atomic)
            print("✅ ShieldDataStore: Saved current quote (ID: \(quote.id)) by \(quote.author)")
        } catch {
            print("⚠️ ShieldDataStore: Failed to save current quote: \(error)")
        }
    }

    /// Get the current quote (returns nil if not set)
    func getCurrentQuote() -> BookQuote? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) else {
            print("⚠️ ShieldDataStore: Cannot access App Group for current quote")
            return nil
        }

        let quoteFileURL = containerURL.appendingPathComponent(currentQuoteFileName)

        guard let data = try? Data(contentsOf: quoteFileURL) else {
            print("📂 ShieldDataStore: No current quote file found")
            return nil
        }

        do {
            let quote = try JSONDecoder().decode(BookQuote.self, from: data)
            print("✅ ShieldDataStore: Retrieved current quote (ID: \(quote.id)) by \(quote.author)")
            return quote
        } catch {
            print("⚠️ ShieldDataStore: Failed to decode current quote: \(error)")
            return nil
        }
    }
}
