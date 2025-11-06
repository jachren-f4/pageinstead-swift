import SwiftUI

/// Confetti particle for celebration animations
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let endX: CGFloat
    let rotation: Double
    let scale: CGFloat
    let delay: Double
}

/// Confetti animation view
struct OnboardingConfetti: View {
    let particleCount: Int
    let duration: Double

    @State private var particles: [ConfettiParticle] = []
    @State private var animate = false

    // Confetti colors (purple palette)
    private let colors: [Color] = [
        Color(red: 0.44, green: 0.26, blue: 0.76), // #6f42c1
        Color(red: 0.63, green: 0.50, blue: 0.88), // #a17fe0
        Color(red: 0.77, green: 0.71, blue: 0.99), // #c4b5fd
        Color(red: 0.91, green: 0.84, blue: 1.0)   // #e9d5ff
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(
                        particle: particle,
                        screenHeight: geometry.size.height,
                        animate: animate
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                createParticles(in: geometry.size)
                // Trigger animation after a tiny delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { index in
            let startX = CGFloat.random(in: 0...size.width)
            return ConfettiParticle(
                color: colors.randomElement() ?? colors[0],
                startX: startX,
                endX: startX + CGFloat.random(in: -100...100),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                delay: Double(index) * (duration / Double(particleCount)) * 0.3
            )
        }
    }
}

/// Individual confetti piece that animates
private struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let screenHeight: CGFloat
    let animate: Bool

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 10, height: 10)
            .scaleEffect(particle.scale)
            .rotationEffect(.degrees(animate ? particle.rotation + 720 : particle.rotation))
            .position(
                x: animate ? particle.endX : particle.startX,
                y: animate ? screenHeight + 50 : -20
            )
            .animation(
                .easeIn(duration: 2.0)
                .delay(particle.delay),
                value: animate
            )
    }
}

/// Mini confetti for smaller celebrations (20 particles, 1.5s)
struct MiniConfetti: View {
    var body: some View {
        OnboardingConfetti(particleCount: 20, duration: 1.5)
    }
}

/// Full confetti for major celebrations (50 particles, 2s)
struct FullConfetti: View {
    var body: some View {
        OnboardingConfetti(particleCount: 50, duration: 2.0)
    }
}
