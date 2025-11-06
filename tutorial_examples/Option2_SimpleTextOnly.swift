import SwiftUI

// MARK: - Option 2: Simple Text-Only Tutorial (Carousel)

/// No spotlight, no positioning - just slides with text and images
/// Zero fragility, works regardless of UI changes

struct SimpleTextTutorial: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [TutorialPage] = [
        TutorialPage(
            title: "Current Quote",
            description: "Your quote changes every 5 minutes to give you fresh inspiration throughout the day.",
            systemImage: "quote.bubble.fill"
        ),
        TutorialPage(
            title: "Save Your Favorites",
            description: "Tap the bookmark icon to save quotes you love. Find them later in the Books tab.",
            systemImage: "bookmark.fill"
        ),
        TutorialPage(
            title: "Get the Book",
            description: "If a quote resonates with you, tap 'Get this book' to purchase the full book on Amazon.",
            systemImage: "book.fill"
        ),
        TutorialPage(
            title: "Temporary Unlock",
            description: "When you absolutely need to access a blocked app, use the lock button to temporarily unlock it.",
            systemImage: "lock.open.fill"
        ),
        TutorialPage(
            title: "Track Your Progress",
            description: "Health Score tracks your focus, and Unlock Streak shows consecutive days without unlocking apps.",
            systemImage: "chart.line.uptrend.xyaxis"
        )
    ]

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: 500)

                // Navigation
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    Button(currentPage == pages.count - 1 ? "Done" : "Next") {
                        if currentPage == pages.count - 1 {
                            isPresented = false
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Tutorial Page View

struct TutorialPageView: View {
    let page: TutorialPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 80))
                .foregroundColor(.blue)

            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// MARK: - Model

struct TutorialPage {
    let title: String
    let description: String
    let systemImage: String
}

// MARK: - How to Use

struct ContentView_WithTextTutorial: View {
    @State private var showTutorial = true

    var body: some View {
        ZStack {
            // Your normal app UI
            Color.black.ignoresSafeArea()

            VStack {
                Text("App Content Here")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            // Tutorial overlay
            if showTutorial {
                SimpleTextTutorial(isPresented: $showTutorial)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    ContentView_WithTextTutorial()
}

// MARK: - Pros & Cons

/*
 ✅ PROS:
 - Zero fragility - never breaks when UI changes
 - Works on any screen size
 - Easy to maintain and update text
 - Familiar pattern (like App Store tutorials)
 - Can include screenshots/images if desired

 ❌ CONS:
 - Not contextual - user can't see actual UI elements
 - Less "in-context" learning
 - User has to remember where things are
 - More generic feeling

 BEST FOR:
 - Apps with frequently changing UI
 - High-level concept explanation
 - First-time user onboarding
 */
