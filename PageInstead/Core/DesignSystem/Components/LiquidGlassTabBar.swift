/*
 * CUSTOM LIQUID GLASS TAB BAR - PRESERVED FOR REFERENCE
 *
 * This file contains a custom-built liquid glass tab bar implementation.
 * As of iOS 18+, SwiftUI's native TabView automatically applies liquid glass styling,
 * so this custom implementation is no longer needed.
 *
 * Keeping this code commented out for:
 * - Reference and learning purposes
 * - Potential use in iOS 16-17 compatibility layer
 * - Custom tab bar needs in the future
 */

/*
import SwiftUI
import CoreMotion

// MARK: - Custom Animation Easing
extension Animation {
    static let liquidGlassEase = Animation.easeInOut(duration: 0.25)
}

// MARK: - Environment Keys for Scroll State
private struct ScrollOffsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

private struct IsScrollingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var tabBarScrollOffset: CGFloat {
        get { self[ScrollOffsetKey.self] }
        set { self[ScrollOffsetKey.self] = newValue }
    }

    var tabBarIsScrolling: Bool {
        get { self[IsScrollingKey.self] }
        set { self[IsScrollingKey.self] = newValue }
    }
}

// MARK: - Motion Manager with Smoothing
class MotionManager: ObservableObject {
    static let shared = MotionManager()
    private let motionManager = CMMotionManager()

    @Published var tiltX: Double = 0
    @Published var tiltY: Double = 0

    private var smoothingFactor = 0.1 // Controls responsiveness (prevents jitter)

    private init() {
        startMotionUpdates()
    }

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }

            // Get attitude (device orientation in space)
            let pitch = motion.attitude.pitch // Forward/backward tilt
            let roll = motion.attitude.roll   // Left/right tilt

            // Smooth tilt transitions using low-pass filter
            withAnimation(.easeOut(duration: 0.2)) {
                self.tiltX += (roll * 2 - self.tiltX) * self.smoothingFactor
                self.tiltY += (pitch * 2 - self.tiltY) * self.smoothingFactor
            }
        }
    }

    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Tab Item Model
struct TabBarItem: Identifiable {
    let id: Int
    let icon: String
    let label: String
}

// MARK: - Main Liquid Glass Tab Bar
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]

    // Environment
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.tabBarScrollOffset) var scrollOffset
    @Environment(\.tabBarIsScrolling) var isScrolling

    // Motion
    @StateObject private var motionManager = MotionManager.shared
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                TabButton(
                    icon: item.icon,
                    label: item.label,
                    isSelected: selectedTab == item.id,
                    tiltX: reduceMotion ? 0 : motionManager.tiltX,
                    tiltY: reduceMotion ? 0 : motionManager.tiltY,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item.id
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            GlassTabBarBackground(
                reduceTransparency: reduceTransparency,
                isScrolling: isScrolling,
                scrollOffset: scrollOffset
            )
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Tab Button Component with Parallax
private struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let tiltX: Double
    let tiltY: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(iconColor)
                    .scaleEffect(isSelected ? 1.05 : 1.0)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(labelColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.gradient.opacity(0.18))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.clear)
                    }
                }
            )
            // Subtle parallax effect on icons
            .offset(
                x: isSelected ? tiltX * 2 : tiltX * 1,
                y: isSelected ? tiltY * 2 : tiltY * 1
            )
        }
        .buttonStyle(TabButtonStyle())
    }

    // High Contrast: White for active, bright gray for inactive
    private var iconColor: Color {
        isSelected ? .white : Color.white.opacity(0.85)
    }

    private var labelColor: Color {
        isSelected ? .white : Color.white.opacity(0.85)
    }
}

// MARK: - Custom Button Style
private struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.liquidGlassEase, value: configuration.isPressed)
    }
}

// MARK: - iOS 26 Liquid Glass Background (Expert Refined)
private struct GlassTabBarBackground: View {
    let reduceTransparency: Bool
    let isScrolling: Bool
    let scrollOffset: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.clear)
            .background(
                // Primary blur with proper material
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            )
            .overlay(
                // Subtle white sheen as overlay (not background) - keeps glass clear
                Color.white.opacity(isScrolling ? 0.03 : 0.03)
                    .allowsHitTesting(false)
            )
            .overlay(
                // Refined top divider - thinner and more translucent
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 0.5)
                    .background(.ultraThinMaterial),
                alignment: .top
            )
            .overlay(
                // Single radial highlight for glass depth with enhanced shimmer
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 150
                )
                .compositingGroup()
                .allowsHitTesting(false)
            )
            // Simplified shadows - lighter for iOS 26 realism
            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            .animation(.liquidGlassEase, value: isScrolling)
    }
}

// MARK: - Content Container with Tab Bar
struct LiquidGlassTabContainer<Content: View>: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]
    let content: (Int) -> Content

    // Track scroll state
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    @State private var scrollTimer: Timer?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(\.tabBarScrollOffset, scrollOffset)
                .environment(\.tabBarIsScrolling, isScrolling)

            // Floating tab bar
            LiquidGlassTabBar(selectedTab: $selectedTab, items: items)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Scroll Detection Helper
extension View {
    /// Call this from scrollable content to notify tab bar of scroll state
    func detectTabBarScroll(isScrolling: Binding<Bool>) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isScrolling.wrappedValue = true
                }
                .onEnded { _ in
                    // Use a delay to smooth the transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isScrolling.wrappedValue = false
                    }
                }
        )
    }
}

// MARK: - Previews
#Preview("Light Background") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.9, green: 0.85, blue: 0.96),
                Color(red: 0.83, green: 0.76, blue: 0.93),
                Color(red: 0.76, green: 0.67, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            LiquidGlassTabBar(
                selectedTab: .constant(0),
                items: [
                    TabBarItem(id: 0, icon: "quote.bubble.fill", label: "Quote"),
                    TabBarItem(id: 1, icon: "shield.fill", label: "Groups"),
                    TabBarItem(id: 2, icon: "book.fill", label: "Books"),
                    TabBarItem(id: 3, icon: "clock.arrow.circlepath", label: "History"),
                    TabBarItem(id: 4, icon: "gearshape.fill", label: "Settings")
                ]
            )
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Background - Scrolling") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0, blue: 0.2),
                Color(red: 0.2, green: 0, blue: 0.4),
                Color(red: 0.3, green: 0, blue: 0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            LiquidGlassTabBar(
                selectedTab: .constant(2),
                items: [
                    TabBarItem(id: 0, icon: "quote.bubble.fill", label: "Quote"),
                    TabBarItem(id: 1, icon: "shield.fill", label: "Groups"),
                    TabBarItem(id: 2, icon: "book.fill", label: "Books"),
                    TabBarItem(id: 3, icon: "clock.arrow.circlepath", label: "History"),
                    TabBarItem(id: 4, icon: "gearshape.fill", label: "Settings")
                ]
            )
            .environment(\.tabBarIsScrolling, true)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("All Tabs") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0, blue: 0.2),
                Color(red: 0.2, green: 0, blue: 0.4),
                Color(red: 0.3, green: 0, blue: 0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            LiquidGlassTabBar(
                selectedTab: .constant(4),
                items: [
                    TabBarItem(id: 0, icon: "quote.bubble.fill", label: "Quote"),
                    TabBarItem(id: 1, icon: "shield.fill", label: "Groups"),
                    TabBarItem(id: 2, icon: "book.fill", label: "Books"),
                    TabBarItem(id: 3, icon: "clock.arrow.circlepath", label: "History"),
                    TabBarItem(id: 4, icon: "gearshape.fill", label: "Settings")
                ]
            )
        }
    }
    .preferredColorScheme(.dark)
}
*/
