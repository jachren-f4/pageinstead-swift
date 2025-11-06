import SwiftUI

/// Detail sheet explaining Unlock Streak metric
struct StreakDetailSheet: View {
    @Environment(\.dismiss) var dismiss

    let currentStreak: Int
    let recordStreak: Int
    let lastUnlockDate: Date?
    let streakStartedDate: Date?

    var streakProgress: Double {
        if currentStreak >= recordStreak {
            return 1.0
        }
        return max(0.05, Double(currentStreak) / Double(recordStreak))
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack(alignment: .center) {
                        Text("Unlock Streak")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Current Stats Card
                    GlassCard(standard: {
                        VStack(spacing: 20) {
                            HStack(alignment: .center) {
                                Text("Current Stats")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Spacer()
                            }

                            if currentStreak >= recordStreak {
                                // On a record streak - special display
                                VStack(spacing: 12) {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(currentStreak)")
                                            .font(.system(size: 64, weight: .bold))
                                            .foregroundColor(Color(hex: "A78BFA"))

                                        Text("days")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }

                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "FFD700"))

                                        Text("You're on a record streak!")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.85))

                                        Image(systemName: "star.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "FFD700"))
                                    }
                                }
                            } else {
                                // Building toward record
                                // Current streak
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("Current Streak")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))

                                    Spacer()

                                    Text("\(currentStreak)")
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundColor(Color(hex: "A78BFA"))

                                    Text("days")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }

                                // Divider
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)

                                // Record streak
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("Record Streak")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))

                                    Spacer()

                                    Text("\(recordStreak)")
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("days")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }

                                // Progress bar
                                VStack(alignment: .leading, spacing: 8) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(height: 8)

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(hex: "A78BFA"), Color(hex: "8B5CF6")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * streakProgress, height: 8)
                                        }
                                    }
                                    .frame(height: 8)

                                    Text("\(Int(streakProgress * 100))% of your record")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                        }
                    })
                    .padding(.horizontal)

                    // How It Works Card
                    GlassCard(standard: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How It Works")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            Text("This meter tracks consecutive days without unlocking blocked apps. It measures your commitment to staying focused.")
                                .font(.system(size: 15))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))

                            VStack(alignment: .leading, spacing: 12) {
                                BulletPoint(text: "Each day without unlocking increases your streak")
                                BulletPoint(text: "Unlocking apps resets your streak to day 1")
                                BulletPoint(text: "The meter shows progress toward your personal record")
                                BulletPoint(text: "100% means you're on a record streak")
                            }
                        }
                    })
                    .padding(.horizontal)

                    // Last Unlock Card (only show if there was an unlock)
                    if let lastUnlock = lastUnlockDate {
                        GlassCard(compact: {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Last Unlock")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(lastUnlock))
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.85))

                                    Text(formatRelativeDate(lastUnlock))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.65))
                                }
                            }
                        })
                        .padding(.horizontal)
                    }

                    // What Breaks Streak Card
                    GlassCard(compact: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What Breaks Your Streak")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            Text("Your streak resets when you unlock apps through:")
                                .font(.system(size: 15))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))

                            VStack(alignment: .leading, spacing: 12) {
                                BulletPoint(text: "Manual unlock via the unlock screen")
                                BulletPoint(text: "Pause timer expiring (automatic unlock)")
                            }

                            Text("The longer you go without accessing blocked apps, the stronger your streak becomes.")
                                .font(.system(size: 15))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.top, 4)
                        }
                    })
                    .padding(.horizontal)

                    // Streak Started Card
                    if let startedDate = streakStartedDate {
                        GlassCard(compact: {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Streak Started")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(startedDate))
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.85))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("Day 1 of current streak")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.65))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        })
                        .padding(.horizontal)
                    }

                    // Bottom spacing for tab bar
                    Spacer(minLength: 120)
                }
            }
        }
    }

    // MARK: - Date Formatting

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "(\(formatter.localizedString(for: date, relativeTo: Date())))"
    }
}

// MARK: - Helper Views

private struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))

            Text(text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

// MARK: - Preview

#Preview {
    StreakDetailSheet(
        currentStreak: 8,
        recordStreak: 12,
        lastUnlockDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
        streakStartedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())
    )
}
