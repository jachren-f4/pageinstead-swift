import SwiftUI
import Combine

/// Main view showing the current time-based quote with Opus Liquid Glass design
struct CurrentQuoteView: View {
    @StateObject private var viewModel = CurrentQuoteViewModel()
    @State private var currentTime = Date()

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Current Quote")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 60)

                    // Hero quote card with shimmer
                    VStack(spacing: 24) {
                        // Quote text
                        Text(viewModel.currentQuote.text)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(8)

                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 20)

                        // Book attribution
                        HStack(spacing: 16) {
                            // Book cover
                            if let coverURL = viewModel.currentQuote.coverImageURL, let url = URL(string: coverURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        bookCoverPlaceholder
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 90)
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

                            // Book details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.currentQuote.bookTitle)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.95))

                                Text(viewModel.currentQuote.author)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()
                        }
                    }
                    .padding(40)
                    .liquidGlassHeroCard()
                    .shimmerEffect()
                    .padding(.horizontal)

                    // Stats cards grid
                    HStack(spacing: 16) {
                        // Focus Time card
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Focus Time")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                CircularProgressRing.focus(
                                    progress: viewModel.mockFocusProgress,
                                    size: 90
                                )
                            }

                            // Mock activity bars for focus time (last 7 hours)
                            ActivityBarChart.hourly(
                                hours: viewModel.mockFocusActivityData,
                                height: 35
                            )

                            Text("\(viewModel.mockFocusMinutes) min today")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.06))
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // Quotes Seen card
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Quotes Seen")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                CircularProgressRing.primary(
                                    progress: viewModel.mockQuotesProgress,
                                    size: 90
                                )
                            }

                            // Mock activity bars for quotes (last 7 windows)
                            ActivityBarChart.hourly(
                                hours: viewModel.mockQuotesActivityData,
                                height: 35
                            )

                            Text("\(viewModel.mockQuotesCount) of \(viewModel.mockQuotesGoal) today")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.06))
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    // Get This Book button
                    Button(action: viewModel.openAffiliateLink) {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                            Text("Get This Book")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "6CC8FF"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .background(Color(hex: "6CC8FF").opacity(0.2))
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "6CC8FF").opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // Window info
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(.white.opacity(0.5))
                            Text("Next quote at")
                                .foregroundColor(.white.opacity(0.5))
                            Text(viewModel.nextWindowTime, style: .time)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .font(.system(size: 14))

                        Text("Window \(viewModel.windowIndex) of 288 • \(viewModel.totalActiveQuotes) quotes available")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 80)
                }
            }
        }
        .onAppear {
            viewModel.refreshQuote()
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { time in
            currentTime = time
            viewModel.checkAndRefreshQuote()
        }
    }

    private var bookCoverPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 60, height: 90)

            Image(systemName: "book.fill")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

// MARK: - ViewModel

@MainActor
class CurrentQuoteViewModel: ObservableObject {
    @Published var currentQuote: BookQuote
    @Published var windowIndex: Int = 0
    @Published var nextWindowTime: Date = Date()
    @Published var currentWindowStart: Date = Date()

    // Mock data for stats (TODO: Replace with real tracking)
    @Published var mockFocusProgress: Double = 0.75 // 75%
    @Published var mockFocusMinutes: Int = 127
    @Published var mockFocusActivityData: [Double] = [0.5, 0.6, 0.7, 0.4, 0.8, 0.6, 0.9]

    @Published var mockQuotesProgress: Double = 0.60 // 60%
    @Published var mockQuotesCount: Int = 18
    @Published var mockQuotesGoal: Int = 30
    @Published var mockQuotesActivityData: [Double] = [0.4, 0.5, 0.6, 0.5, 0.7, 0.8, 0.9]

    private var lastWindowIndex: Int = -1

    var totalActiveQuotes: Int {
        QuoteService.shared.getActiveQuotes().count
    }

    var timeWindowText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.string(from: currentWindowStart)
        let endTime = formatter.string(from: nextWindowTime)
        return "\(startTime) - \(endTime)"
    }

    init() {
        // Initialize with current quote
        self.currentQuote = QuoteScheduler.shared.getCurrentQuote()
        updateWindowInfo()
        self.lastWindowIndex = windowIndex

        // Randomize mock data slightly for demo purposes
        randomizeMockData()
    }

    func checkAndRefreshQuote() {
        let info = QuoteScheduler.shared.getCurrentWindowInfo()

        // Only refresh if the window has changed
        if info.windowIndex != lastWindowIndex {
            print("📱 CurrentQuoteView: Window changed from \(lastWindowIndex) to \(info.windowIndex) - refreshing quote")
            refreshQuote()
            lastWindowIndex = info.windowIndex

            // Update mock data when quote changes
            randomizeMockData()
        }
    }

    func refreshQuote() {
        currentQuote = QuoteScheduler.shared.getCurrentQuote()
        updateWindowInfo()
        print("📱 CurrentQuoteView: Refreshed quote #\(currentQuote.id) from \(currentQuote.author)")
    }

    private func updateWindowInfo() {
        let info = QuoteScheduler.shared.getCurrentWindowInfo()
        windowIndex = info.windowIndex
        nextWindowTime = info.nextWindowAt
        currentWindowStart = info.currentWindowStart
    }

    private func randomizeMockData() {
        // Randomize slightly to simulate real data changes
        // TODO: Replace with real tracking data

        // Focus time (50-95%)
        mockFocusProgress = Double.random(in: 0.50...0.95)
        mockFocusMinutes = Int(mockFocusProgress * 180) // Up to 180 min per day

        // Quotes seen (40-100%)
        mockQuotesProgress = Double.random(in: 0.40...1.0)
        mockQuotesCount = Int(mockQuotesProgress * Double(mockQuotesGoal))

        // Activity data (randomize last 7 data points)
        mockFocusActivityData = (0..<7).map { _ in Double.random(in: 0.3...1.0) }
        mockQuotesActivityData = (0..<7).map { _ in Double.random(in: 0.2...1.0) }
    }

    func openAffiliateLink() {
        guard let asin = currentQuote.asin,
              let url = AffiliateService.shared.getAmazonLink(asin: asin) else {
            print("⚠️ Cannot open affiliate link: missing ASIN or invalid URL")
            return
        }

        print("🔗 Opening affiliate link for \(currentQuote.bookTitle): \(url)")
        UIApplication.shared.open(url)

        // Log the conversion for analytics (optional)
        logConversion()
    }

    private func logConversion() {
        // TODO: Add analytics tracking here
        print("📊 Conversion: User clicked affiliate link for quote #\(currentQuote.id)")
    }
}

// MARK: - Preview

#Preview {
    CurrentQuoteView()
}
