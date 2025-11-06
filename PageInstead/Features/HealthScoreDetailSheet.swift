import SwiftUI

/// Detail sheet explaining Health Score metric
struct HealthScoreDetailSheet: View {
    @Environment(\.dismiss) var dismiss

    let currentScore: Double // 0-100
    let blockedToday: Int
    let baseline: Int
    let isCalibrated: Bool
    let calibrationProgress: Int // 0-3 days

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack(alignment: .center) {
                        Text("Health Score")
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

                    // Current Score Card
                    GlassCard(standard: {
                        VStack(spacing: 20) {
                            HStack(alignment: .center) {
                                Text("Current Score")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Spacer()
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(currentScore))")
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundColor(Color(hex: "4CD964"))

                                Text("%")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Spacer()
                            }

                            // Stats grid (only show if calibrated)
                            if isCalibrated {
                                // Divider
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)

                                HStack(spacing: 16) {
                                    VStack(spacing: 4) {
                                        Text("\(blockedToday)")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("Blocked Today")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)

                                    VStack(spacing: 4) {
                                        Text("\(baseline)")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("Baseline")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }

                            // Status badge (only show if calibrated)
                            if isCalibrated {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Active Tracking")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(Color(hex: "4CD964"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "4CD964").opacity(0.2))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color(hex: "4CD964").opacity(0.3), lineWidth: 1)
                                )
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

                            Text("Your Health Score measures how well you're avoiding distracting apps compared to your personal baseline.")
                                .font(.system(size: 15))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))

                            VStack(alignment: .leading, spacing: 12) {
                                BulletPoint(text: "Each time you try to open a blocked app, it's counted as an attempt")
                                BulletPoint(text: "Your baseline is the average attempts during the first 3 days")
                                BulletPoint(text: "Score = 100% minus your attempts relative to baseline")
                                BulletPoint(text: "Fewer attempts = higher score")
                            }

                            // Formula
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Formula")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Text("Score = 100 - ((attempts / baseline) × 100)")
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                    })
                    .padding(.horizontal)

                    // Calibration Card
                    GlassCard(compact: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Calibration Period")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            Text("The first 3 days establish your baseline. During this time, your score shows 75% by default.")
                                .font(.system(size: 15))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))

                            if !isCalibrated {
                                // Progress bar
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Progress")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.7))

                                        Spacer()

                                        Text("\(calibrationProgress)/3 days")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.85))
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(height: 8)

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(hex: "4CD964"), Color(hex: "5DE66E")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * (Double(calibrationProgress) / 3.0), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            } else {
                                Text("Calibrated")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    })
                    .padding(.horizontal)

                    // What's Tracked Card
                    GlassCard(compact: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What's Tracked")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            HStack(alignment: .top, spacing: 0) {
                                Text("Only ")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.85))
                                +
                                Text("blocked attempts")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "4CD964"))
                                +
                                Text(" are tracked — when you tap a shielded app and see a quote. Screen time itself is not measured due to iOS limitations.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .lineSpacing(4)
                        }
                    })
                    .padding(.horizontal)

                    // Bottom spacing for tab bar
                    Spacer(minLength: 120)
                }
            }
        }
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
    HealthScoreDetailSheet(
        currentScore: 73,
        blockedToday: 4,
        baseline: 15,
        isCalibrated: true,
        calibrationProgress: 3
    )
}
