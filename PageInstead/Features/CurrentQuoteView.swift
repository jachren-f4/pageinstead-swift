import SwiftUI
import Combine

/// Main view showing the current time-based quote with Opus Liquid Glass design
struct CurrentQuoteView: View {
    @StateObject private var viewModel = CurrentQuoteViewModel()
    @StateObject private var unlockManager = UnlockManager.shared
    @ObservedObject private var restrictionManager = SelfRestrictionManager.shared
    @State private var currentTime = Date()
    @State private var showUnlockScreen = false
    @State private var showHealthScoreDetail = false
    @State private var showStreakDetail = false
    @State private var showTimerLockSheet = false
    @State private var showPasscodeEntry = false

    // Tutorial state
    @State private var showTutorial: Bool = false
    @State private var showHelp = false

    // Particle Dissolve animation state
    @State private var animationOpacity: Double = 1.0
    @State private var animationScale: CGFloat = 1.0
    @State private var animationBlur: CGFloat = 0
    @State private var animationBrightness: Double = 0

    /// Format quote text with proper punctuation
    private var formattedQuoteText: String {
        let text = viewModel.currentQuote.text

        // Check if quote already has opening quote marks (straight quotes, left double quotes, right double quotes)
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
            // Animated gradient background - extends behind tab bar for iOS 18 liquid glass effect
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Top spacing to account for fixed lock button
                    Spacer()
                        .frame(height: 60)

                    // Scrollable header: "Quote" title and action buttons
                    HStack(alignment: .center) {
                        Text("Quote")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        HStack(spacing: 12) {
                            // Bookmark button
                            Button(action: viewModel.toggleBookmark) {
                                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(viewModel.isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0) : .white.opacity(0.7))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewModel.isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15) : Color.white.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(viewModel.isBookmarked ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            }
                            .scaleEffect(viewModel.bookmarkAnimationScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isBookmarked)
                            .tutorialAnchor(id: "bookmarkButton")

                            // Get this book button
                            Button(action: viewModel.openAffiliateLink) {
                                Text("Get this book")
                                    .font(.system(size: 17.5, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 19.2)
                                    .padding(.vertical, 12)
                                    .liquidGlassSoftGhostButton()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Hero quote card with Particle Dissolve animation
                    GlassCard(standard: {
                        VStack(spacing: 24) {
                            // Quote text
                            Text(formattedQuoteText)
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineSpacing(8)

                            // Book attribution
                            HStack(spacing: 16) {
                                // Book cover (tap to preview animation)
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
                                    .onTapGesture {
                                        triggerAnimationPreview()
                                    }
                                } else {
                                    bookCoverPlaceholder
                                        .onTapGesture {
                                            triggerAnimationPreview()
                                        }
                                }

                                // Book details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.currentQuote.bookTitle)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(viewModel.currentQuote.author)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.85))

                                    if let description = viewModel.currentQuote.bookDescription {
                                        Text(description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.65))
                                            .padding(.top, 2)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .id(viewModel.currentQuote.id)
                        .opacity(animationOpacity)
                        .scaleEffect(animationScale)
                        .blur(radius: animationBlur)
                        .brightness(animationBrightness)
                    })
                    .padding(.horizontal)
                    .tutorialAnchor(id: "quoteCard")

                    // Stats cards grid
                    HStack(spacing: 16) {
                        // Health Score card
                        GlassCard(small: {
                            VStack(spacing: 16) {
                                Button(action: { showHealthScoreDetail = true }) {
                                    HStack(spacing: 4) {
                                        Text("Health Score")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                CircularProgressRing.success(
                                    progress: viewModel.healthScoreProgress,
                                    showPercentage: true,
                                    size: 90
                                )
                            }
                        })

                        // Unlock Streak card
                        GlassCard(small: {
                            VStack(spacing: 16) {
                                Button(action: { showStreakDetail = true }) {
                                    HStack(spacing: 4) {
                                        Text("Unlock Streak")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                // Custom streak display with days count
                                ZStack {
                                    CircularProgressRing.streak(
                                        progress: viewModel.unlockStreakProgress,
                                        showPercentage: false,
                                        size: 90
                                    )

                                    VStack(spacing: 2) {
                                        Text("\(viewModel.currentStreak)")
                                            .font(.system(size: streakNumberFontSize(for: viewModel.currentStreak), weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)

                                        Text(viewModel.currentStreak == 1 ? "day" : "days")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                            .lineLimit(1)
                                    }
                                }
                            }
                        })
                    }
                    .padding(.horizontal)
                    .tutorialAnchor(id: "metricsSection")

                    // Bottom spacing to allow stats cards to be visible above floating tab bar
                    Spacer(minLength: 120)
                }
            }
            .scrollFadeOverlay()

            // Fixed lock button and help button overlay (top corners)
            VStack {
                HStack {
                    // Help button (top-left)
                    Button(action: {
                        showHelp = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Lock button (top-right)
                    LockButton(isUnlocked: unlockManager.isUnlocked) {
                        handleLockButtonTap()
                    }
                    .tutorialAnchor(id: "lockButton")
                }
                .padding(.horizontal)
                .padding(.top, 5)

                Spacer()
            }
        }
        .overlayPreferenceValue(TutorialAnchorKey.self) { anchors in
            // Tutorial overlay reads preference values here
            if showTutorial {
                HybridTutorialOverlay(isPresented: $showTutorial, anchors: anchors)
            }
        }
        .onAppear {
            viewModel.refreshQuote()
            // Record that user viewed this quote
            QuoteHistoryService.shared.addQuoteView(viewModel.currentQuote)
            // Fallback: Check if date changed (in case monitor didn't fire)
            viewModel.checkStreakDailyFallback()

            // Check if tutorial should be shown
            checkAndShowTutorial()
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { time in
            currentTime = time
            checkAndRefreshQuoteWithAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReplayQuoteTutorial"))) { _ in
            print("🎓 CurrentQuoteView: Received ReplayQuoteTutorial notification")
            showTutorial = true
        }
        .sheet(isPresented: $showUnlockScreen) {
            UnlockScreen()
        }
        .sheet(isPresented: $showHelp) {
            QuoteHelpSheet(showTutorial: $showTutorial)
        }
        .sheet(isPresented: $showHealthScoreDetail) {
            HealthScoreDetailSheet(
                currentScore: viewModel.healthScoreProgress * 100,
                blockedToday: viewModel.blockedAttemptsToday,
                baseline: viewModel.baselineAttempts,
                isCalibrated: HealthScoreService.shared.isCalibrated(),
                calibrationProgress: HealthScoreService.shared.getCalibrationProgress()
            )
        }
        .sheet(isPresented: $showStreakDetail) {
            StreakDetailSheet(
                currentStreak: viewModel.currentStreak,
                recordStreak: viewModel.recordStreak,
                lastUnlockDate: StreakService.shared.getLastUnlockDate(),
                streakStartedDate: StreakService.shared.getStreakStartedDate()
            )
        }
        .fullScreenCover(isPresented: $showTimerLockSheet) {
            TimerLockSheet(
                isPresented: $showTimerLockSheet,
                targetName: "Unlock Screen",
                onTimerComplete: {
                    // Timer completed, now check passcode and proceed to unlock screen
                    if restrictionManager.isNavigationLockedByPasscode() {
                        showPasscodeEntry = true
                    } else {
                        showUnlockScreen = true
                    }
                }
            )
        }
        .sheet(isPresented: $showPasscodeEntry) {
            PasscodeEntryView(isPresented: $showPasscodeEntry) {
                // Passcode verified successfully, show unlock screen
                showUnlockScreen = true
            }
        }
    }

    /// Calculate font size for streak number based on digit count
    private func streakNumberFontSize(for days: Int) -> CGFloat {
        let digitCount = String(days).count
        switch digitCount {
        case 1...2:
            return 28 // 1-99 days
        case 3:
            return 24 // 100-999 days
        case 4:
            return 20 // 1000-9999 days
        default:
            return 16 // 10000+ days (very long streaks)
        }
    }

    /// Check if quote window changed and trigger particle dissolve animation
    private func checkAndRefreshQuoteWithAnimation() {
        let info = QuoteScheduler.shared.getCurrentWindowInfo()

        // Only refresh if the window has changed
        if info.windowIndex != viewModel.lastWindowIndex {
            print("📱 CurrentQuoteView: Window changed from \(viewModel.lastWindowIndex) to \(info.windowIndex) - triggering Particle Dissolve animation")

            // Update lastWindowIndex immediately to prevent multiple triggers
            viewModel.lastWindowIndex = info.windowIndex

            triggerParticleDissolveAnimation()
        }
    }

    /// Particle Dissolve animation: brightness bloom with blur transition
    private func triggerParticleDissolveAnimation() {
        // Exit animation (0 -> 50%): fade out with blur and brightness increase
        withAnimation(.easeInOut(duration: 0.6)) {
            animationOpacity = 0
            animationScale = 0.95
            animationBlur = 6
            animationBrightness = 0.3
        }

        // Wait for exit to complete, then update quote and enter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Update quote at midpoint
            viewModel.refreshQuoteWithAnimation()

            // Reset for entry (51%): slightly larger scale for smooth transition
            animationScale = 1.05

            // Entry animation (51% -> 100%): fade in with blur decrease
            withAnimation(.easeInOut(duration: 0.6)) {
                animationOpacity = 1.0
                animationScale = 1.0
                animationBlur = 0
                animationBrightness = 0
            }
        }
    }

    /// Preview animation without changing quote (for testing)
    private func triggerAnimationPreview() {
        print("🎬 Triggering Particle Dissolve animation preview (tap on book cover)")

        // Exit animation (0 -> 50%): fade out with blur and brightness increase
        withAnimation(.easeInOut(duration: 0.6)) {
            animationOpacity = 0
            animationScale = 0.95
            animationBlur = 6
            animationBrightness = 0.3
        }

        // Wait for exit to complete, then enter without changing quote
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Reset for entry (51%): slightly larger scale for smooth transition
            animationScale = 1.05

            // Entry animation (51% -> 100%): fade in with blur decrease
            withAnimation(.easeInOut(duration: 0.6)) {
                animationOpacity = 1.0
                animationScale = 1.0
                animationBlur = 0
                animationBrightness = 0
            }
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

    // MARK: - Lock Button Handler

    private func handleLockButtonTap() {
        // Check timer lock first - this will start timer if needed
        if restrictionManager.shouldActivateTimer() {
            showTimerLockSheet = true
            return
        }

        // Check passcode lock
        if restrictionManager.isNavigationLockedByPasscode() {
            showPasscodeEntry = true
            return
        }

        // No locks active, show unlock screen
        showUnlockScreen = true
    }

    // MARK: - Tutorial Functions

    private func checkAndShowTutorial() {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenQuoteTutorial")
        print("🎓 CurrentQuoteView: Checking tutorial status - hasSeenTutorial: \(hasSeenTutorial)")

        if !hasSeenTutorial {
            print("🎓 CurrentQuoteView: Tutorial not seen yet, scheduling to show in 1 second")
            // Show tutorial after a delay to let the view and anchors settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🎓 CurrentQuoteView: Setting showTutorial = true")
                self.showTutorial = true
            }
        } else {
            print("🎓 CurrentQuoteView: Tutorial already seen, skipping")
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

    // Bookmark state
    @Published var isBookmarked: Bool = false
    @Published var bookmarkAnimationScale: CGFloat = 1.0

    // Health Score data (real tracking)
    @Published var healthScoreProgress: Double = 0.75 // 0-1 scale
    @Published var blockedAttemptsToday: Int = 0
    @Published var baselineAttempts: Int = 15

    // Unlock Streak data (real tracking)
    @Published var unlockStreakProgress: Double = 1.0 // 0-1 scale
    @Published var currentStreak: Int = 1
    @Published var recordStreak: Int = 1

    var lastWindowIndex: Int = -1
    private let bookmarksKey = "bookmarked_quotes"
    private var lastStreakCheckDate: Date?

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

        // Check if current quote is bookmarked
        checkBookmarkStatus()

        // Load health score data
        updateHealthScore()

        // Load streak data
        updateStreakData()
    }

    func refreshQuote() {
        currentQuote = QuoteScheduler.shared.getCurrentQuote()
        updateWindowInfo()
        checkBookmarkStatus()
        print("📱 CurrentQuoteView: Refreshed quote #\(currentQuote.id) from \(currentQuote.author)")
    }

    func refreshQuoteWithAnimation() {
        // Explicitly signal that the object will change
        objectWillChange.send()

        currentQuote = QuoteScheduler.shared.getCurrentQuote()
        updateWindowInfo()
        checkBookmarkStatus()
        // Note: lastWindowIndex is already updated before animation starts
        updateHealthScore()
        updateStreakData()
        print("📱 CurrentQuoteView: Refreshed quote #\(currentQuote.id) with animation")
    }

    private func updateWindowInfo() {
        let info = QuoteScheduler.shared.getCurrentWindowInfo()
        windowIndex = info.windowIndex
        nextWindowTime = info.nextWindowAt
        currentWindowStart = info.currentWindowStart
    }

    private func updateHealthScore() {
        // Get real health score data from HealthScoreService
        let score = HealthScoreService.shared.getCurrentHealthScore()
        healthScoreProgress = score / 100.0 // Convert to 0-1 scale for progress ring

        blockedAttemptsToday = HealthScoreService.shared.getBlockedAttemptsToday()
        baselineAttempts = HealthScoreService.shared.getBaselineAttempts()

        print("📱 CurrentQuoteView: Health Score updated - \(Int(score))% (Attempts: \(blockedAttemptsToday)/\(baselineAttempts))")
    }

    private func updateStreakData() {
        // Get real streak data from StreakService
        currentStreak = StreakService.shared.getCurrentStreak()
        recordStreak = StreakService.shared.getRecordStreak()
        unlockStreakProgress = StreakService.shared.getStreakProgress()

        print("📱 CurrentQuoteView: Streak updated - \(currentStreak) days (Record: \(recordStreak), Progress: \(Int(unlockStreakProgress * 100))%)")
    }

    func checkStreakDailyFallback() {
        // Defensive fallback in case DeviceActivityMonitor doesn't fire
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastCheck = lastStreakCheckDate {
            let lastCheckDay = calendar.startOfDay(for: lastCheck)
            if today != lastCheckDay {
                // Date changed - check streak progress
                print("📱 CurrentQuoteView: Fallback - date changed, checking streak")
                StreakService.shared.checkDailyProgress()
                updateStreakData()
            }
        }

        lastStreakCheckDate = Date()
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

    // MARK: - Bookmark Management

    func toggleBookmark() {
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
            addBookmark(quoteId: currentQuote.id)
            print("🔖 Bookmarked quote #\(currentQuote.id): \"\(currentQuote.text.prefix(50))...\"")
        } else {
            removeBookmark(quoteId: currentQuote.id)
            print("🔖 Removed bookmark for quote #\(currentQuote.id)")
        }
    }

    private func checkBookmarkStatus() {
        let bookmarks = getBookmarkedQuoteIds()
        isBookmarked = bookmarks.contains(currentQuote.id)
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
}

// MARK: - Preview

#Preview {
    CurrentQuoteView()
}
