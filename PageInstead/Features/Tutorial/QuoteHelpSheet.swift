import SwiftUI

// MARK: - Help Sheet

struct QuoteHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showTutorial: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Replay Tutorial Button
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UserDefaults.standard.set(false, forKey: "hasSeenQuoteTutorial")
                            showTutorial = true
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Replay Tutorial")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("See the interactive walkthrough again")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Quick Reference
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Reference")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        QuickHelpItem(
                            icon: "quote.bubble.fill",
                            title: "Current Quote",
                            description: "Changes every 5 minutes"
                        )

                        QuickHelpItem(
                            icon: "bookmark.fill",
                            title: "Bookmark",
                            description: "Save quotes to Books tab"
                        )

                        QuickHelpItem(
                            icon: "book.fill",
                            title: "Get the Book",
                            description: "Purchase on Amazon"
                        )

                        QuickHelpItem(
                            icon: "lock.open.fill",
                            title: "Unlock Apps",
                            description: "Temporary access to blocked apps"
                        )

                        QuickHelpItem(
                            icon: "heart.fill",
                            title: "Health Score",
                            description: "Focus tracking metric"
                        )

                        QuickHelpItem(
                            icon: "calendar.badge.checkmark",
                            title: "Unlock Streak",
                            description: "Consecutive days without unlocking"
                        )
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
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

struct QuickHelpItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
