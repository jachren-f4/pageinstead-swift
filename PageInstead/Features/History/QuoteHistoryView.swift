import SwiftUI

/// Shows recent time windows and their quotes
/// No event tracking needed - calculates quotes from time
@available(iOS 16.0, *)
struct QuoteHistoryView: View {
    @State private var recentWindows: [(time: Date, quote: BookQuote)] = []
    @State private var windowCount: Int = 50 // Show last ~4 hours

    var body: some View {
        NavigationView {
            ZStack {
                if recentWindows.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("Recent Quotes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadRecentQuotes) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                loadRecentQuotes()
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Recent Quote Schedule")
                .font(.title2)
                .fontWeight(.semibold)

            Text("See which quotes appeared in recent time windows. Every quote changes every 5 minutes.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Load Recent Quotes") {
                loadRecentQuotes()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - History List
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Info header
                infoHeaderView
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                // Window list
                ForEach(Array(groupedByDay.keys.sorted(by: >)), id: \.self) { dateString in
                    Section {
                        ForEach(groupedByDay[dateString] ?? [], id: \.time) { window in
                            WindowRow(time: window.time, quote: window.quote)

                            if window.time != (groupedByDay[dateString]?.last?.time) {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    } header: {
                        HStack {
                            Text(dateString)
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .background(.ultraThinMaterial)
                    }
                }
            }
        }
        .refreshable {
            loadRecentQuotes()
        }
    }

    // MARK: - Info Header
    private var infoHeaderView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Windows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(recentWindows.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Showing last")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("~\(windowCount * 5) minutes")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            Text("Quotes change every 5 minutes. This shows which quote appeared in each recent time window.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .liquidGlassCard(cornerRadius: 16)
    }

    // MARK: - Grouped by day
    private var groupedByDay: [String: [(time: Date, quote: BookQuote)]] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        var grouped: [String: [(time: Date, quote: BookQuote)]] = [:]

        for window in recentWindows {
            let dateString: String
            if calendar.isDateInToday(window.time) {
                dateString = "Today"
            } else if calendar.isDateInYesterday(window.time) {
                dateString = "Yesterday"
            } else {
                dateString = dateFormatter.string(from: window.time)
            }

            if grouped[dateString] == nil {
                grouped[dateString] = []
            }
            grouped[dateString]?.append(window)
        }

        return grouped
    }

    // MARK: - Load Recent Quotes
    private func loadRecentQuotes() {
        recentWindows = QuoteScheduler.shared.getRecentWindows(count: windowCount)
    }
}

// MARK: - Window Row

struct WindowRow: View {
    let time: Date
    let quote: BookQuote

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(time, style: .time)
                    .font(.headline)
                    .foregroundColor(.blue)

                Text("5 min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70, alignment: .leading)

            // Quote Preview
            VStack(alignment: .leading, spacing: 6) {
                Text(quote.text)
                    .font(.body)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text("— \(quote.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !quote.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(quote.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .liquidGlassPill(tintColor: .blue)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Book cover thumbnail
            if let coverURL = quote.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 45)
                            .cornerRadius(4)
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 30, height: 45)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

@available(iOS 16.0, *)
struct QuoteHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteHistoryView()
    }
}
