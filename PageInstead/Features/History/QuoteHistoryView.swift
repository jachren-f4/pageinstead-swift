import SwiftUI

/// Shows recent time windows and their quotes
/// No event tracking needed - calculates quotes from time
@available(iOS 16.0, *)
struct QuoteHistoryView: View {
    @State private var recentWindows: [(time: Date, quote: BookQuote)] = []
    @State private var windowCount: Int = 50 // Show last ~4 hours

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()

            if recentWindows.isEmpty {
                emptyStateView
            } else {
                historyListView
            }
        }
        .onAppear {
            loadRecentQuotes()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "6CC8FF").opacity(0.8))

            VStack(spacing: 12) {
                Text("Recent Quote Schedule")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("See which quotes appeared in recent time windows. Every quote changes every 5 minutes.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button("Load Recent Quotes") {
                loadRecentQuotes()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color(hex: "6CC8FF"))
            .frame(maxWidth: 200)
            .padding(.vertical, 18)
            .background(Color(hex: "6CC8FF").opacity(0.2))
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: "6CC8FF").opacity(0.4), lineWidth: 1)
            )
        }
        .padding()
    }

    // MARK: - History List
    private var historyListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Quote History")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: loadRecentQuotes) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "6CC8FF"))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "6CC8FF").opacity(0.2))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "6CC8FF").opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60)

                // Info header
                infoHeaderView
                    .padding(.horizontal)

                // Window list
                VStack(spacing: 20) {
                    ForEach(Array(groupedByDay.keys.sorted(by: >)), id: \.self) { dateString in
                        VStack(alignment: .leading, spacing: 12) {
                            // Day header
                            Text(dateString)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            // Quotes for this day
                            VStack(spacing: 1) {
                                ForEach(groupedByDay[dateString] ?? [], id: \.time) { window in
                                    WindowRow(time: window.time, quote: window.quote)
                                }
                            }
                            .background(Color.white.opacity(0.04))
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 80)
            }
        }
    }

    // MARK: - Info Header
    private var infoHeaderView: some View {
        HStack(spacing: 16) {
            // Recent Windows count
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "6CC8FF"))

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(recentWindows.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("windows")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white.opacity(0.06))
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )

            // Time Duration
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "6CC8FF"))

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("~\(windowCount * 5)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("minutes")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white.opacity(0.06))
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
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
        HStack(alignment: .center, spacing: 16) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(time, style: .time)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "6CC8FF"))

                Text("5 min")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 60, alignment: .leading)

            // Book cover thumbnail
            if let coverURL = quote.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 42)
                            .cornerRadius(4)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 28, height: 42)

                            Image(systemName: "book.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
            }

            // Quote Preview
            VStack(alignment: .leading, spacing: 6) {
                Text(quote.text)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)

                Text(quote.author)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}

@available(iOS 16.0, *)
struct QuoteHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteHistoryView()
    }
}
