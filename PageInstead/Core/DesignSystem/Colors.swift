import SwiftUI

// MARK: - Liquid Glass Color System
// Semantic colors following iOS 26 Liquid Glass guidelines

extension Color {

    // MARK: - Primary Action Colors

    /// Primary action tint (vibrant blue)
    /// Use for main CTAs and active states
    static let liquidGlassPrimary = Color.blue

    /// Secondary action tint (subtle)
    /// Use sparingly, prefer pure glass for secondary actions
    static let liquidGlassSecondary = Color(white: 0.5)

    /// Destructive action tint (red)
    /// Use for destructive actions only
    static let liquidGlassDestructive = Color.red

    /// Success tint (green)
    static let liquidGlassSuccess = Color.green

    // MARK: - Glass Tints

    /// Subtle blue tint for glass elements
    static let liquidGlassBlueTint = Color.blue.opacity(0.15)

    /// Subtle white overlay for glass highlights
    static let liquidGlassHighlight = Color.white.opacity(0.2)

    /// Dark overlay for dimming beneath clear glass
    static let liquidGlassDimming = Color.black.opacity(0.3)

    // MARK: - Text Colors on Glass

    /// Primary text on glass surfaces
    static let liquidGlassTextPrimary = Color.primary

    /// Secondary text on glass surfaces
    static let liquidGlassTextSecondary = Color.secondary

    /// Emphasized text on glass (for CTAs)
    static let liquidGlassTextEmphasis = Color.white

    // MARK: - Glow Colors

    /// Soft glow for elevated glass cards
    static let liquidGlassGlowSoft = Color.white.opacity(0.1)

    /// Emphasized glow for interactive elements
    static let liquidGlassGlowEmphasis = Color.blue.opacity(0.2)
}

// MARK: - Dynamic Color Helpers

extension Color {
    /// Creates a color that adapts based on the underlying content brightness
    /// Mimics real colored glass behavior
    static func liquidGlassTint(_ baseColor: Color, intensity: Double = 0.15) -> Color {
        baseColor.opacity(intensity)
    }
}

// MARK: - Opus Background Colors

extension Color {
    /// Dark purple background (Opus design system)
    static let backgroundDarkPurple = Color(hex: "1a0033")

    /// Mid purple background (Opus design system)
    static let backgroundMidPurple = Color(hex: "330066")

    /// Bright purple background (Opus design system)
    static let backgroundBrightPurple = Color(hex: "4d0073")
}

// MARK: - Gradient Helpers for Glass

extension LinearGradient {
    /// Subtle gradient for glass surface depth
    static var liquidGlassGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Vibrant gradient for primary action buttons
    static func liquidGlassPrimaryGradient(color: Color = .blue) -> LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(0.2),
                color.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Opus Progress Ring Gradients

    /// Primary progress gradient (purple, Opus design system)
    static var progressRingPrimary: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Focus time progress gradient (blue)
    static var progressRingFocus: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "4facfe"),
                Color(hex: "00f2fe")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Activity progress gradient (orange-pink)
    static var progressRingActivity: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "fa709a"),
                Color(hex: "fee140")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Quotes seen progress gradient (green)
    static var progressRingQuotes: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "4ADE80"),
                Color(hex: "22C55E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Opus Background Gradient

    /// Full Opus animated background gradient
    static var opusBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.backgroundDarkPurple,
                Color.backgroundMidPurple,
                Color.backgroundBrightPurple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
