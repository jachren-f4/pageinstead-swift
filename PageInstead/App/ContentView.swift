import SwiftUI
import FamilyControls

struct ContentView: View {
    @ObservedObject private var screenTimeService = ScreenTimeService.shared
    @State private var isAuthorizing = false

    var body: some View {
        if #available(iOS 16.0, *) {
            if screenTimeService.isAuthorized {
                // Show main app interface
                TabView {
                    // Current Quote - The hero feature
                    CurrentQuoteView()
                        .tabItem {
                            Label("Current Quote", systemImage: "quote.bubble.fill")
                        }
                        .toolbarBackground(.ultraThinMaterial, for: .tabBar)

                    AppSelectionView()
                        .tabItem {
                            Label("Block Apps", systemImage: "shield")
                        }
                        .toolbarBackground(.ultraThinMaterial, for: .tabBar)

                    BooksPlaceholderView()
                        .tabItem {
                            Label("Books", systemImage: "book")
                        }
                        .toolbarBackground(.ultraThinMaterial, for: .tabBar)

                    QuoteHistoryView()
                        .tabItem {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                }
                .tint(.blue)
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
