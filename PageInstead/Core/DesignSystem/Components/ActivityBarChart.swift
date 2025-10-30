import SwiftUI

/// Mini bar chart showing activity pattern
/// Displays 7 bars typically, with last/highlighted bar using gradient
/// Based on Opus mockup design system
struct ActivityBarChart: View {
    let data: [Double] // Values 0-1
    let highlightIndex: Int? // Which bar to highlight with gradient
    let barSpacing: CGFloat
    let cornerRadius: CGFloat
    let height: CGFloat

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        data: [Double],
        highlightIndex: Int? = nil,
        barSpacing: CGFloat = 4,
        cornerRadius: CGFloat = 2,
        height: CGFloat = 40
    ) {
        self.data = data
        self.highlightIndex = highlightIndex ?? (data.count - 1) // Default to last bar
        self.barSpacing = barSpacing
        self.cornerRadius = cornerRadius
        self.height = height
    }

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                GeometryReader { geometry in
                    VStack {
                        Spacer()

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(barFill(for: index))
                            .frame(
                                width: geometry.size.width,
                                height: max(4, value * geometry.size.height) // Minimum 4px height
                            )
                            .animation(
                                reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05),
                                value: value
                            )
                    }
                }
            }
        }
        .frame(height: height)
    }

    private func barFill(for index: Int) -> AnyShapeStyle {
        if index == highlightIndex {
            // Highlighted bar uses gradient
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(hex: "FFD60A"),
                        Color(hex: "FFA500")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        } else {
            // Other bars use subtle white
            return AnyShapeStyle(Color.white.opacity(0.15))
        }
    }
}

// MARK: - Convenience Initializers

extension ActivityBarChart {
    /// Activity chart with purple gradient highlight (Opus primary)
    static func primary(
        data: [Double],
        highlightIndex: Int? = nil,
        height: CGFloat = 40
    ) -> ActivityBarChart {
        ActivityBarChart(
            data: data,
            highlightIndex: highlightIndex,
            height: height
        )
    }

    /// Activity chart for 7-bar hourly pattern
    static func hourly(
        hours: [Double],
        height: CGFloat = 40
    ) -> ActivityBarChart {
        ActivityBarChart(
            data: hours,
            highlightIndex: hours.count - 1, // Highlight current hour
            height: height
        )
    }

    /// Activity chart for daily pattern (last 7 days)
    static func daily(
        days: [Double],
        height: CGFloat = 40
    ) -> ActivityBarChart {
        ActivityBarChart(
            data: days,
            highlightIndex: days.count - 1, // Highlight today
            height: height
        )
    }
}

// MARK: - Activity Bar with Custom Gradient

struct ActivityBarChartGradient: View {
    let data: [Double]
    let gradient: LinearGradient
    let highlightIndex: Int?
    let barSpacing: CGFloat
    let cornerRadius: CGFloat
    let height: CGFloat

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        data: [Double],
        gradient: LinearGradient,
        highlightIndex: Int? = nil,
        barSpacing: CGFloat = 4,
        cornerRadius: CGFloat = 2,
        height: CGFloat = 40
    ) {
        self.data = data
        self.gradient = gradient
        self.highlightIndex = highlightIndex ?? (data.count - 1)
        self.barSpacing = barSpacing
        self.cornerRadius = cornerRadius
        self.height = height
    }

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                GeometryReader { geometry in
                    VStack {
                        Spacer()

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(index == highlightIndex ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.white.opacity(0.15)))
                            .frame(
                                width: geometry.size.width,
                                height: max(4, value * geometry.size.height)
                            )
                            .animation(
                                reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05),
                                value: value
                            )
                    }
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview("Activity Patterns") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("7-Hour Pattern")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                ActivityBarChart.hourly(
                    hours: [0.3, 0.5, 0.7, 0.4, 0.8, 0.6, 0.9]
                )
                .frame(width: 200)
            }

            VStack(spacing: 12) {
                Text("7-Day Pattern")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                ActivityBarChart.daily(
                    days: [0.6, 0.4, 0.8, 0.5, 0.7, 0.9, 0.65]
                )
                .frame(width: 200)
            }

            VStack(spacing: 12) {
                Text("Custom Gradient")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                ActivityBarChartGradient(
                    data: [0.2, 0.4, 0.3, 0.6, 0.5, 0.7, 0.8],
                    gradient: LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200)
            }

            VStack(spacing: 12) {
                Text("All Equal")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                ActivityBarChart.primary(
                    data: [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
                )
                .frame(width: 200)
            }
        }
        .padding()
    }
}

#Preview("Animated") {
    struct AnimatedChartPreview: View {
        @State private var data: [Double] = [0.3, 0.5, 0.7, 0.4, 0.8, 0.6, 0.9]

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {
                    ActivityBarChart.hourly(hours: data)
                        .frame(width: 250)

                    Button("Randomize") {
                        data = (0..<7).map { _ in Double.random(in: 0.2...1.0) }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }

    return AnimatedChartPreview()
}

#Preview("In Card Context") {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "1a0033"),
                Color(hex: "330066"),
                Color(hex: "4d0073")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            // Simulating stat card with progress ring and activity bars
            VStack(spacing: 16) {
                CircularProgressRing.primary(progress: 0.75, size: 100)

                ActivityBarChart.hourly(
                    hours: [0.5, 0.6, 0.7, 0.4, 0.8, 0.6, 0.9],
                    height: 30
                )
            }
            .padding(24)
            .background(Color.white.opacity(0.08))
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding()
    }
}
