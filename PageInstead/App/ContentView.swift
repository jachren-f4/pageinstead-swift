import SwiftUI
import FamilyControls

struct ContentView: View {
    @ObservedObject private var screenTimeService = ScreenTimeService.shared
    @ObservedObject private var restrictionManager = SelfRestrictionManager.shared
    @State private var isAuthorizing = false
    @State private var selectedTab = 0
    @State private var showingLockedAlert = false
    @State private var showingPasscodeEntry = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        if #available(iOS 16.0, *) {
            if showOnboarding {
                // Show onboarding flow
                OnboardingCoordinator(showOnboarding: $showOnboarding)
            } else if screenTimeService.isAuthorized {
                // Show main app interface with custom Liquid Glass tab bar
                LiquidGlassTabContainer(
                    selectedTab: $selectedTab,
                    items: [
                        TabBarItem(id: 0, icon: "quote.bubble.fill", label: "Quote"),
                        TabBarItem(id: 1, icon: "shield.fill", label: "Groups"),
                        TabBarItem(id: 2, icon: "book.fill", label: "Books"),
                        TabBarItem(id: 3, icon: "clock.arrow.circlepath", label: "History"),
                        TabBarItem(id: 4, icon: "gearshape.fill", label: "Settings")
                    ]
                ) { tab in
                    // Display content based on selected tab
                    Group {
                        switch tab {
                        case 0:
                            CurrentQuoteView()
                        case 1:
                            AppGroupsListView()
                        case 2:
                            BooksView()
                        case 3:
                            QuoteHistoryView()
                        case 4:
                            SettingsView(showOnboarding: $showOnboarding)
                        default:
                            CurrentQuoteView()
                        }
                    }
                }
                .onChange(of: selectedTab) { newValue in
                    // Check if tabs are locked and trying to navigate away from Current Quote
                    if newValue != 0 {
                        // Check timer lock first
                        if restrictionManager.areTabsLocked() {
                            selectedTab = 0
                            showingLockedAlert = true
                            return
                        }

                        // Check passcode lock
                        if restrictionManager.isNavigationLockedByPasscode() {
                            selectedTab = 0
                            showingPasscodeEntry = true
                            return
                        }
                    }
                }
                .alert("Lock Timer Enabled", isPresented: $showingLockedAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Navigation is locked. Time remaining: \(restrictionManager.formattedTimeRemaining())")
                }
                .sheet(isPresented: $showingPasscodeEntry) {
                    PasscodeEntryView(isPresented: $showingPasscodeEntry) {
                        // Passcode verified successfully
                        // Navigation is now unlocked for this session
                    }
                }
                .onAppear {
                    restrictionManager.onAppLaunch()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        // Refresh shields when app becomes active
                        // This picks up any unlocks that happened in ShieldAction extension
                        screenTimeService.refreshShields()
                    }
                }
            } else {
                // Show authorization screen
                AuthorizationView(isAuthorizing: $isAuthorizing)
            }
        } else {
            // iOS 15 and below not supported
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)

                Text("iOS 16.0 or later required")
                    .font(.title)
                    .fontWeight(.bold)

                Text("PageInstead requires iOS 16.0 or later to use Screen Time features")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
    }
}

@available(iOS 16.0, *)
struct AuthorizationView: View {
    @Binding var isAuthorizing: Bool
    @ObservedObject private var screenTimeService = ScreenTimeService.shared

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "book.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("PageInstead")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Replace distracting apps with inspiring books")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                FeatureRow(icon: "shield.fill", title: "Block Apps", description: "Choose apps to replace with book recommendations")
                FeatureRow(icon: "book.fill", title: "Discover Books", description: "Get personalized book suggestions")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "See how reading replaces scrolling")
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                Task {
                    isAuthorizing = true
                    do {
                        try await screenTimeService.requestAuthorization()
                    } catch {
                        print("Authorization error: \(error)")
                    }
                    isAuthorizing = false
                }
            }) {
                if isAuthorizing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                }
            }
            .liquidGlassPrimaryButton()
            .padding(.horizontal)
            .disabled(isAuthorizing)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .liquidGlassCard(cornerRadius: 16)
    }
}

struct BooksPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Books feature coming soon!")
                .font(.title2)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
