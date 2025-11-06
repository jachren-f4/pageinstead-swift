import SwiftUI

// MARK: - Option 4: Help Button/Menu (On-Demand)

/// No automatic tutorial - users access help when they need it
/// Zero fragility - just a menu with text explanations
/// Can be accessed anytime from anywhere

// MARK: - Help Menu Sheet

struct HelpMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let helpItems: [HelpItem] = [
        HelpItem(
            icon: "quote.bubble.fill",
            title: "Current Quote",
            description: "Your quote changes every 5 minutes to give you fresh inspiration throughout the day. Quotes are selected from your chosen book categories."
        ),
        HelpItem(
            icon: "bookmark.fill",
            title: "Bookmarks",
            description: "Tap the bookmark icon to save quotes you love. Access your saved quotes anytime in the Books tab at the bottom of the screen."
        ),
        HelpItem(
            icon: "book.fill",
            title: "Get the Book",
            description: "If a quote resonates with you, tap 'Get this book' to purchase the full book on Amazon. Support authors and dive deeper into their wisdom."
        ),
        HelpItem(
            icon: "lock.open.fill",
            title: "Temporary Unlock",
            description: "When you absolutely need to access a blocked app, tap the lock button. This temporarily unlocks your blocked apps but will affect your Unlock Streak."
        ),
        HelpItem(
            icon: "heart.fill",
            title: "Health Score",
            description: "Your Health Score tracks your focus based on how often you attempt to access blocked apps. Higher scores mean better focus. The system calibrates for 3 days before showing your true score."
        ),
        HelpItem(
            icon: "calendar.badge.checkmark",
            title: "Unlock Streak",
            description: "Unlock Streak counts consecutive days without unlocking your blocked apps. Build your streak to stay focused and build better habits."
        ),
        HelpItem(
            icon: "gearshape.fill",
            title: "App Groups",
            description: "Organize your blocked apps into groups with different rules. Set daily time limits, pause timers, or schedules for each group independently."
        ),
        HelpItem(
            icon: "clock.fill",
            title: "Quote History",
            description: "View all the quotes you've seen today and when they appeared. Access this from the History tab to revisit inspiration from earlier in your day."
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Help & Features")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Learn about PageInstead features")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Help Items
                    VStack(spacing: 16) {
                        ForEach(helpItems) { item in
                            HelpItemRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Help Item Row

struct HelpItemRow: View {
    let item: HelpItem
    @State private var isExpanded = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: item.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                        )

                    // Title
                    Text(item.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }

                // Description (expandable)
                if isExpanded {
                    Text(item.description)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Help Item Model

struct HelpItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Help Button (Floating)

struct FloatingHelpButton: View {
    @Binding var showHelp: Bool

    var body: some View {
        Button(action: {
            showHelp = true
        }) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - Alternative: Help Menu in Navigation Bar

struct HelpBarButton: View {
    @Binding var showHelp: Bool

    var body: some View {
        Button(action: {
            showHelp = true
        }) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - How to Use

struct CurrentQuoteView_WithHelp: View {
    @State private var showHelp = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("The only way to do great work is to love what you do.")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("— Steve Jobs")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(20)
                    }
                    .padding(20)
                }

                // Floating Help Button (bottom-right corner)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingHelpButton(showHelp: $showHelp)
                            .padding(.trailing, 20)
                            .padding(.bottom, 100) // Above tab bar
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HelpBarButton(showHelp: $showHelp)
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpMenuSheet()
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    CurrentQuoteView_WithHelp()
}

// MARK: - Alternative: Settings-Based Help

struct SettingsView_WithHelp: View {
    @State private var showHelp = false

    var body: some View {
        List {
            Section {
                Button(action: {
                    showHelp = true
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                        Text("Help & Features")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            } header: {
                Text("Support")
            }

            // Other settings...
        }
        .sheet(isPresented: $showHelp) {
            HelpMenuSheet()
        }
    }
}

// MARK: - Pros & Cons

/*
 ✅ PROS:
 - ZERO fragility - just text and icons
 - Works forever regardless of UI changes
 - Available anytime user needs it
 - Doesn't interrupt user flow
 - Easy to update and maintain
 - Can be comprehensive without overwhelming
 - Searchable (can add search bar if needed)
 - Users who don't need help aren't bothered

 ❌ CONS:
 - Less discoverable - users have to know to look for it
 - Not in-context - text descriptions instead of showing actual UI
 - Some users never check help menus
 - Less engaging than interactive tutorials

 BEST FOR:
 - Apps with stable, intuitive UI
 - Power users who prefer reference documentation
 - Features that are self-explanatory but benefit from extra detail
 - When you want zero maintenance overhead

 VARIATIONS:
 1. **Floating Button**: Always visible, bottom-right corner
 2. **Navigation Bar Button**: More subtle, standard iOS pattern
 3. **Settings Integration**: Help section within Settings
 4. **Tab Bar Item**: Dedicated Help tab (if you have space)
 5. **Contextual Help**: Help button on specific screens only

 ENHANCEMENTS:
 - Add search functionality for larger help databases
 - Include screenshots or video walkthroughs
 - Link to online documentation or FAQ
 - Add "Contact Support" option
 - Track which help items are viewed most (analytics)
 */
