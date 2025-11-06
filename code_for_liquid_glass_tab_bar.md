import SwiftUI
import CoreMotion

// MARK: - LiquidGlassTabBar Review + Suggestions
// This version includes inline 💡 comments and examples for improving realism and performance.

// 💡 Reduce shadow layers, simplify gradients, and enhance translucency.
// 💡 Keep only 2–3 soft shadows for performance and realism.
// 💡 Ensure `.ultraThinMaterial` uses `.withinWindow` blending for proper background context.

private struct GlassTabBarBackground_Improved: View {
    let reduceTransparency: Bool
    let isScrolling: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.clear)
            .background(
                // 💡 Primary blur material
                VisualEffectBlur(material: .ultraThin, blendingMode: .withinWindow)
                    .overlay(Color.white.opacity(0.03)) // 💡 subtle white sheen for realism
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            )
            .overlay(
                // 💡 Single top divider line (Apple style)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.white.opacity(0.25)),
                alignment: .top
            )
            .overlay(
                // 💡 Single radial highlight for glass depth
                RadialGradient(
                    colors: [Color.white.opacity(0.15), Color.clear],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 150
                )
            )
            // 💡 Keep only two shadows for layered depth
            .shadow(color: .black.opacity(0.18), radius: 4, y: -2)
            .shadow(color: .black.opacity(0.25), radius: 10, y: -5)
            .animation(.easeInOut(duration: 0.25), value: isScrolling)
    }
}

// MARK: - Parallax Refinement
// 💡 Smooth parallax motion using a low-pass filter to prevent jitter.

class MotionManagerImproved: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var tiltX: Double = 0
    @Published var tiltY: Double = 0

    private var smoothingFactor = 0.1 // 💡 controls responsiveness

    init() { startMotionUpdates() }

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }

            let pitch = motion.attitude.pitch
            let roll = motion.attitude.roll

            // 💡 Smooth tilt transitions
            withAnimation(.easeOut(duration: 0.2)) {
                self.tiltX += (roll * 2 - self.tiltX) * self.smoothingFactor
                self.tiltY += (pitch * 2 - self.tiltY) * self.smoothingFactor
            }
        }
    }
}

// MARK: - Example Use
// 💡 This snippet can replace your current GlassTabBarBackground for a more iOS 26 accurate feel.

struct LiquidGlassTabBar_Improved: View {
    @Binding var selectedTab: Int
    let items: [String]

    @StateObject private var motionManager = MotionManagerImproved()

    var body: some View {
        HStack {
            ForEach(Array(items.enumerated()), id: \.[0]) { index, icon in
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == index ? .semibold : .medium))
                    .foregroundStyle(selectedTab == index ? .accentColor : .secondary)
                    .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                    .offset(x: motionManager.tiltX * 1.5, y: motionManager.tiltY * 1.5) // 💡 gentle motion
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTab = index
                        }
                    }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(GlassTabBarBackground_Improved(reduceTransparency: false, isScrolling: false))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

// 💡 Preview for testing against bright and dark gradients
#Preview("Liquid Glass Improved") {
    ZStack {
        LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack {
            Spacer()
            LiquidGlassTabBar_Improved(selectedTab: .constant(1), items: ["quote.bubble.fill", "book.fill", "gearshape.fill"])
        }
    }
    .preferredColorScheme(.dark)
}