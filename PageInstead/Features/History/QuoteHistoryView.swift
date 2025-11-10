import SwiftUI

/// Shows recent quotes from the last hour (12 quotes, one per 5-minute window)
/// No event tracking needed - calculates quotes from time
@available(iOS 16.0, *)
struct QuoteHistoryView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var recentQuotes: [BookQuote] = []
    @State private var selectedQuote: BookQuote?
    @State private var bookmarkedQuoteIds: Set<Int> = []

    private let bookmarksKey = "bookmarked_quotes"

    var body: some View {
        ZStack {
            // Animated gradient background - extends behind tab bar for iOS 18+ liquid glass effect
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            if recentQuotes.isEmpty {
                emptyStateView
            } else {
                historyListView
            }
        }
        .sheet(item: $selectedQuote) { quote in
            QuoteDetailSheet(quote: quote)
        }
        .onAppear {
            loadRecentQuotes()
            loadBookmarks()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarksChanged"))) { _ in
            loadBookmarks()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            GlassCard(standard: {
                VStack(spacing: 20) {
                    // Clock icon
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64))
                        .foregroundColor(.white.opacity(0.3))

                    // Title
                    Text("No recent quotes yet")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    // Description
                    Text("Your recent quotes from the last hour will appear here.\nCome back after the app blocks some distractions.")
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

    // MARK: - History List
    private var historyListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top spacing
                Spacer()
                    .frame(height: 20)

                // Header - scrollable
                VStack(spacing: 12) {
                    Text("Recent Quotes")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(recentQuotes.count) quotes from the last hour")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                // Quote cards
                ForEach(recentQuotes, id: \.id) { quote in
                    QuoteCard(
                        quote: quote,
                        isBookmarked: bookmarkedQuoteIds.contains(quote.id),
                        scenePhase: scenePhase,
                        onTap: {
                            selectedQuote = quote
                        },
                        onBookmark: {
                            toggleBookmark(quote: quote)
                        }
                    )
                    .padding(.horizontal)
                }

                // Bottom spacing to allow content to be visible above floating tab bar
                Spacer(minLength: 120)
            }
        }
        .scrollFadeOverlay()
    }

    // MARK: - Data Loading

    private func loadRecentQuotes() {
        // Get last 12 windows (1 hour: 12 × 5 minutes = 60 minutes)
        let windows = QuoteScheduler.shared.getRecentWindows(count: 12)

        // Extract unique quotes (one per window)
        recentQuotes = windows.map { $0.quote }

        print("📚 QuoteHistoryView: Loaded \(recentQuotes.count) recent quotes")
    }

    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let bookmarks = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            bookmarkedQuoteIds = bookmarks
        }
    }

    private func toggleBookmark(quote: BookQuote) {
        var bookmarks = bookmarkedQuoteIds

        if bookmarks.contains(quote.id) {
            bookmarks.remove(quote.id)
            print("🔖 Removed bookmark for quote #\(quote.id) from History")
        } else {
            bookmarks.insert(quote.id)
            print("🔖 Bookmarked quote #\(quote.id) from History")
        }

        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }

        // Update local state
        bookmarkedQuoteIds = bookmarks

        // Notify other views (Books tab)
        NotificationCenter.default.post(name: NSNotification.Name("BookmarksChanged"), object: nil)
    }
}

// MARK: - Quote Card

struct QuoteCard: View {
    let quote: BookQuote
    let isBookmarked: Bool
    let scenePhase: ScenePhase
    let onTap: () -> Void
    let onBookmark: () -> Void

    @State private var bookmarkAnimationScale: CGFloat = 1.0

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

    var body: some View {
        Button(action: onTap) {
            GlassCard(standard: {
                HStack(alignment: .top, spacing: 16) {
                    // Book cover
                    CachedAsyncImage(
                        url: quote.coverImageURL.flatMap { URL(string: $0) },
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 150)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.4), radius: 8)
                        },
                        placeholder: {
                            bookCoverPlaceholder
                        }
                    )
                    .reloadOnAppear(scenePhase: scenePhase)

                    // Quote content
                    VStack(alignment: .leading, spacing: 8) {
                        // Quote text
                        Text(formattedQuoteText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        // Author
                        Text(quote.author)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))

                        // Book title
                        Text(quote.bookTitle)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.65))

                        // Category tag
                        if let category = quote.categories.first {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .overlay(alignment: .topTrailing) {
                    // Bookmark button
                    Button(action: handleBookmarkTap) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0) : .white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15) : Color.white.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .scaleEffect(bookmarkAnimationScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBookmarked)
                    .contentShape(Rectangle())
                }
            })
        }
        .buttonStyle(.plain)
    }

    private var bookCoverPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 100, height: 150)

            Image(systemName: "book.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
        }
    }

    private func handleBookmarkTap() {
        // Animate the bookmark button
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            bookmarkAnimationScale = 1.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bookmarkAnimationScale = 1.0
            }
        }

        // Call the bookmark handler
        onBookmark()
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct QuoteHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteHistoryView()
    }
}
