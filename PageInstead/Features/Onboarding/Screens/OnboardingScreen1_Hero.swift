import SwiftUI
import AVKit
import AVFoundation

/// Screen 1: Hero Moment - Introduce the core concept with video
struct OnboardingScreen1_Hero: View {
    let onNext: () -> Void
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            // Background gradient - full screen
            LinearGradient(
                colors: [
                    Color(red: 0.40, green: 0.49, blue: 0.92),
                    Color(red: 0.46, green: 0.29, blue: 0.64)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Video Container - Top half
                ZStack(alignment: .bottom) {
                    if let player = player {
                        VideoPlayerView(player: player)
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.black
                    }

                    // Gradient veil - fades video into purple background
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(red: 0.40, green: 0.49, blue: 0.92).opacity(0.3),
                            Color(red: 0.40, green: 0.49, blue: 0.92).opacity(0.7),
                            Color(red: 0.40, green: 0.49, blue: 0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)

                Spacer()
            }

            // Content - layered on top
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.5 + 30)

                // Title
                Text("PageInstead")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer().frame(height: 16)

                // Subtitle
                Text("Stop doomscrolling and get inspired.")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()

                // CTA Button
                Button(action: onNext) {
                    Text("Get Started")
                }
                .onboardingPrimaryButton()
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("⚠️ video.mp4 not found in bundle")
            print("⚠️ Searched in: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                print("⚠️ Resource path: \(resourcePath)")
            }
            return
        }

        print("✅ Found video at: \(videoURL.path)")

        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)

        // Set audio to not interrupt other audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to set audio session: \(error)")
        }

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        self.player = newPlayer
        newPlayer.isMuted = true

        // Force play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            newPlayer.play()
            print("🎬 Video started playing")
        }
    }
}

/// Custom UIViewRepresentable for AVPlayer
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer

        // Force initial frame on next run loop
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = context.coordinator.playerLayer {
            playerLayer.frame = uiView.bounds
            uiView.layoutIfNeeded()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

/// Custom shape for diagonal border at -20 degrees
struct DiagonalBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let angle: CGFloat = -20 * .pi / 180 // -20 degrees in radians
        let height = rect.height
        let offset = tan(angle) * rect.width

        path.move(to: CGPoint(x: 0, y: -offset))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height - offset))
        path.closeSubpath()

        return path
    }
}
