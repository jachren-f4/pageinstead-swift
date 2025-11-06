import SwiftUI

/// Detail sheet showing full quote information
@available(iOS 16.0, *)
struct QuoteDetailSheet: View {
    let quote: BookQuote
    @Environment(\.dismiss) private var dismiss
    @State private var isBookmarked: Bool = false
    @State private var bookmarkAnimationScale: CGFloat = 1.0

    private let bookmarksKey = "bookmarked_quotes"

    /// Format quote text with proper punctuation (matching CurrentQuoteView)
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
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Top spacing
                    Spacer()
                        .frame(height: 20)

                    // Close button and bookmark button
                    HStack {
                        // Bookmark button (left side)
                        Button(action: toggleBookmark) {
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

                        Spacer()

                        // Close button (right side)
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)

                    // Book cover
                    if let coverURL = quote.coverImageURL, let url = URL(string: coverURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                            default:
                                bookCoverPlaceholder
                            }
                        }
                    } else {
                        bookCoverPlaceholder
                    }

                    // Quote card
                    VStack(spacing: 16) {
                        // Quote text
                        Text(formattedQuoteText)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)

                        // Author
                        Text("— \(quote.author)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 20)

                        // Book title
                        Text(quote.bookTitle)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 20)

                        // Categories
                        if !quote.categories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(quote.categories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(red: 196/255, green: 181/255, blue: 253/255))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15))
                                            )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 4)
                        }

                        // Amazon button
                        if let asin = quote.asin {
                            Button(action: {
                                if let url = URL(string: "https://www.amazon.com/dp/\(asin)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("View on Amazon")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    ZStack {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.8),
                                                Color(red: 192/255, green: 132/255, blue: 252/255).opacity(0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.4), radius: 10, y: 5)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

                        Spacer()
                            .frame(height: 16)
                    }
                    .background(
                        ZStack {
                            Color.white.opacity(0.08)
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                                .blur(radius: 40)
                                .opacity(0.33)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            checkBookmarkStatus()
        }
    }

    // MARK: - Bookmark Management

    private func toggleBookmark() {
        isBookmarked.toggle()

        // Animate the bookmark button
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            bookmarkAnimationScale = 1.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.bookmarkAnimationScale = 1.0
            }
        }

        // Save to UserDefaults
        if isBookmarked {
            addBookmark(quoteId: quote.id)
            print("🔖 Bookmarked quote #\(quote.id) from QuoteDetailSheet")
        } else {
            removeBookmark(quoteId: quote.id)
            print("🔖 Removed bookmark for quote #\(quote.id) from QuoteDetailSheet")
        }
    }

    private func checkBookmarkStatus() {
        let bookmarks = getBookmarkedQuoteIds()
        isBookmarked = bookmarks.contains(quote.id)
    }

    private func getBookmarkedQuoteIds() -> Set<Int> {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let bookmarks = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            return bookmarks
        }
        return []
    }

    private func addBookmark(quoteId: Int) {
        var bookmarks = getBookmarkedQuoteIds()
        bookmarks.insert(quoteId)
        saveBookmarks(bookmarks)
    }

    private func removeBookmark(quoteId: Int) {
        var bookmarks = getBookmarkedQuoteIds()
        bookmarks.remove(quoteId)
        saveBookmarks(bookmarks)
    }

    private func saveBookmarks(_ bookmarks: Set<Int>) {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }
    }

    private var bookCoverPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 102/255, green: 126/255, blue: 234/255),
                        Color(red: 118/255, green: 75/255, blue: 162/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 180)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
    }
}

#Preview {
    QuoteDetailSheet(
        quote: BookQuote(
            id: 1,
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs",
            bookTitle: "Steve Jobs",
            bookId: "steve-jobs",
            asin: "B004W2UBYW",
            coverImageURL: nil,
            bookDescription: nil,
            isActive: true,
            tags: ["inspiration"],
            dateAdded: "2024-01-01",
            categories: ["Business & Leadership", "Self-help & Growth"]
        )
    )
}
