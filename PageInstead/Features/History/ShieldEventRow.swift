import SwiftUI

@available(iOS 16.0, *)
struct ShieldEventRow: View {
    let event: ShieldEvent
    let quote: BookQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote text with quotation marks
            Text("\"\(quote.text)\"")
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Author & Book title
            Text("— \(quote.author), \(quote.bookTitle)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Metadata: blocked app and timestamp
            HStack(spacing: 12) {
                Label(event.blockedApp, systemImage: "app.fill")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text(event.timestamp.relativeTime())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

@available(iOS 16.0, *)
struct ShieldEventRow_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuote = BookQuote(
            id: 1,
            text: "The man who does not read has no advantage over the man who cannot read.",
            author: "Mark Twain",
            bookTitle: "Collected Works",
            bookId: "twain_001",
            asin: "B00IWUKUVE",
            coverImageURL: nil,
            isActive: true,
            tags: ["reading", "education"],
            dateAdded: "2025-01-29"
        )

        let sampleEvent = ShieldEvent(
            quoteId: 1,
            timestamp: Date().timeIntervalSince1970 - 3600, // 1 hour ago
            blockedApp: "Instagram"
        )

        ShieldEventRow(event: sampleEvent, quote: sampleQuote)
            .previewLayout(.sizeThatFits)
    }
}
