import SwiftUI

/// Books screen showing all bookmarked quotes grouped by book
struct BooksView: View {
    @StateObject private var viewModel = BooksViewModel()

    var body: some View {
        ZStack {
            // Animated gradient background - extends behind tab bar for iOS 18+ liquid glass effect
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            if viewModel.bookmarkedBooks.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Bookmarks content
                ScrollView {
                    VStack(spacing: 24) {
                        // Top spacing
                        Spacer()
                            .frame(height: 20)

                        // Header - scrollable
                        VStack(spacing: 12) {
                            Text("Books")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(viewModel.bookmarkedBooks.isEmpty
                                 ? "Your bookmarked quotes organized by book"
                                 : "\(viewModel.bookmarkedBooks.count) book\(viewModel.bookmarkedBooks.count == 1 ? "" : "s") bookmarked")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)

                        // Book groups
                        ForEach(viewModel.bookmarkedBooks) { book in
                            BookGroupCard(book: book)
                                .padding(.horizontal)
                        }

                        // Bottom spacing to allow content to be visible above floating tab bar
                        Spacer(minLength: 120)
                    }
                }
                .scrollFadeOverlay()
            }
        }
        .onAppear {
            viewModel.loadBookmarks()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarksChanged"))) { _ in
            viewModel.loadBookmarks()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            GlassCard(standard: {
                VStack(spacing: 20) {
                    // Bookmark icon
                    Image(systemName: "bookmark")
                        .font(.system(size: 64))
                        .foregroundColor(.white.opacity(0.3))

                    // Title
                    Text("No bookmarks yet")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    // Description
                    Text("Tap the bookmark icon on any quote to save it here.\nYour collection of inspiring wisdom will appear on this page.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.vertical, 40)
            })
            .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Book Group Card

struct BookGroupCard: View {
    let book: BookmarkedBook
    @State private var showingRemoveConfirmation = false

    var body: some View {
        GlassCard(standard: {
            VStack(spacing: 20) {
                // Book header with bookmark button
                HStack(alignment: .top, spacing: 12) {
                    bookHeader

                    // Bookmark button
                    Button(action: {
                        showingRemoveConfirmation = true
                    }) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4), lineWidth: 1)
                            )
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Quote items
                ForEach(Array(book.quotes.enumerated()), id: \.element.id) { index, quote in
                    QuoteItem(
                        quote: quote,
                        index: index + 1,
                        total: book.quotes.count
                    )

                    if index < book.quotes.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.vertical, 4)
                    }
                }

                // Get this book button
                Button(action: {
                    openAffiliateLink(for: book)
                }) {
                    Text("Get this book")
                        .font(.system(size: 17.5, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .liquidGlassSoftGhostButton()
                }
            }
        })
        .alert("Remove Bookmarks", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeAllBookmarks()
            }
        } message: {
            Text("Remove all \(book.quotes.count) bookmark\(book.quotes.count == 1 ? "" : "s") from \"\(book.title)\"?")
        }
    }

    private var bookHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            // Book cover
            if let coverURL = book.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        bookCoverPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.4), radius: 8)
                    case .failure:
                        bookCoverPlaceholder
                    @unknown default:
                        bookCoverPlaceholder
                    }
                }
            } else {
                bookCoverPlaceholder
            }

            // Book info
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(book.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Author
                Text(book.author)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)

                // Book description
                if let description = book.bookDescription {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.65))
                        .lineSpacing(2)
                        .lineLimit(4)
                        .padding(.top, 2)
                }

                // Category tag (similar to Quote History style)
                if let category = book.categories.first {
                    Text(category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 196/255, green: 181/255, blue: 253/255))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15))
                        )
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var bookCoverPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 80, height: 120)

            Image(systemName: "book.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.3))
        }
    }

    private func openAffiliateLink(for book: BookmarkedBook) {
        guard let asin = book.asin,
              let url = AffiliateService.shared.getAmazonLink(asin: asin) else {
            print("⚠️ Cannot open affiliate link: missing ASIN or invalid URL")
            return
        }

        print("🔗 Opening affiliate link for \(book.title): \(url)")
        UIApplication.shared.open(url)
    }

    private func removeAllBookmarks() {
        // Get all quote IDs for this book
        let quoteIds = book.quotes.map { $0.id }

        // Load existing bookmarks
        guard let data = UserDefaults.standard.data(forKey: "bookmarked_quotes"),
              var bookmarks = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
            return
        }

        // Remove all quote IDs for this book
        quoteIds.forEach { bookmarks.remove($0) }

        // Save updated bookmarks
        if let updatedData = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(updatedData, forKey: "bookmarked_quotes")
            print("🔖 Removed \(quoteIds.count) bookmark(s) from \"\(book.title)\"")

            // Notify BooksView to reload
            NotificationCenter.default.post(name: NSNotification.Name("BookmarksChanged"), object: nil)
        }
    }
}

// MARK: - Quote Item

struct QuoteItem: View {
    let quote: BookQuote
    let index: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quote header - only show if more than 1 quote
            if total > 1 {
                Text("QUOTE \(index) OF \(total)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }

            // Quote text
            Text(formattedQuoteText)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    /// Format quote text with proper punctuation
    private var formattedQuoteText: String {
        let text = quote.text

        // Check if quote already has opening quote marks
        let hasOpeningQuotes = text.hasPrefix("\"") || text.hasPrefix("\u{201C}") || text.hasPrefix("\u{201D}")

        // Check if quote already has closing quote marks
        let hasClosingQuotes = text.hasSuffix("\"") || text.hasSuffix("\u{201C}") || text.hasSuffix("\u{201D}")

        // If both opening and closing quotes exist, return as-is
        if hasOpeningQuotes && hasClosingQuotes {
            return text
        }

        var result = text

        // Check if first character is lowercase (indicates mid-sentence quote)
        if let firstChar = text.first, firstChar.isLowercase {
            result = "..." + result
        }

        // Add quotes if not present
        if !hasOpeningQuotes && !hasClosingQuotes {
            result = "\"\(result)\""
        } else if !hasOpeningQuotes {
            result = "\"\(result)"
        } else if !hasClosingQuotes {
            result = "\(result)\""
        }

        return result
    }
}

// MARK: - View Model

@MainActor
class BooksViewModel: ObservableObject {
    @Published var bookmarkedBooks: [BookmarkedBook] = []
    @Published var totalBookmarks: Int = 0

    private let bookmarksKey = "bookmarked_quotes"

    func loadBookmarks() {
        // Get bookmarked quote IDs
        let bookmarkedIds = getBookmarkedQuoteIds()
        totalBookmarks = bookmarkedIds.count

        guard !bookmarkedIds.isEmpty else {
            bookmarkedBooks = []
            return
        }

        // Get full quote objects
        let quotes = bookmarkedIds.compactMap { QuoteService.shared.getQuote(byId: $0) }

        // Group by bookId
        let grouped = Dictionary(grouping: quotes, by: { $0.bookId })

        // Convert to BookmarkedBook objects
        var books: [BookmarkedBook] = []

        for (bookId, bookQuotes) in grouped {
            guard let firstQuote = bookQuotes.first else { continue }

            let book = BookmarkedBook(
                id: bookId,
                title: firstQuote.bookTitle,
                author: firstQuote.author,
                asin: firstQuote.asin,
                coverImageURL: firstQuote.coverImageURL,
                bookDescription: firstQuote.bookDescription,
                categories: firstQuote.categories,
                tags: Array(Set(bookQuotes.flatMap { $0.tags })),
                quotes: bookQuotes.sorted { $0.id < $1.id }
            )

            books.append(book)
        }

        // Sort by number of bookmarks (most bookmarked first)
        bookmarkedBooks = books.sorted { $0.quotes.count > $1.quotes.count }

        print("📚 BooksView: Loaded \(bookmarkedBooks.count) books with \(totalBookmarks) total bookmarks")
    }

    private func getBookmarkedQuoteIds() -> Set<Int> {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let bookmarks = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            return bookmarks
        }
        return []
    }
}

// MARK: - Models

struct BookmarkedBook: Identifiable {
    let id: String // bookId
    let title: String
    let author: String
    let asin: String?
    let coverImageURL: String?
    let bookDescription: String?
    let categories: [String]
    let tags: [String]
    let quotes: [BookQuote]
}

// MARK: - Preview

#Preview {
    BooksView()
}
