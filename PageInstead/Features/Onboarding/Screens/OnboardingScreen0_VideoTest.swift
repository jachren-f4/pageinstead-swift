import SwiftUI
import AVKit
import AVFoundation

/// Screen 0: Video Test - Simple test screen to debug video playback
struct OnboardingScreen0_VideoTest: View {
    let onNext: () -> Void
    @State private var player: AVPlayer?
    @State private var debugLog: [String] = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                // Title
                Text("Video Test Screen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)

                // Video container
                ZStack {
                    if let player = player {
                        VideoPlayerView(player: player)
                            .frame(width: 300, height: 300)
                            .background(Color.red) // Red background to see if view exists
                    } else {
                        Text("Player not initialized")
                            .foregroundColor(.yellow)
                            .frame(width: 300, height: 300)
                            .background(Color.blue)
                    }
                }
                .border(Color.green, width: 2) // Green border to see bounds

                // Debug log
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(debugLog.indices, id: \.self) { index in
                            Text(debugLog[index])
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .padding()
                .background(Color.gray.opacity(0.3))

                Spacer()

                // Next button
                Button(action: onNext) {
                    Text("Next →")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            log("🎬 onAppear called")
            setupVideoPlayer()
        }
    }

    private func log(_ message: String) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        let logMessage = "[\(timestamp)] \(message)"
        debugLog.append(logMessage)
        print(logMessage)
    }

    private func setupVideoPlayer() {
        log("🔍 setupVideoPlayer started")
        log("📦 Bundle path: \(Bundle.main.bundlePath)")

        // Check if video exists
        if let resourcePath = Bundle.main.resourcePath {
            log("📂 Resource path: \(resourcePath)")
            let videoPath = "\(resourcePath)/video.mp4"
            let fileExists = FileManager.default.fileExists(atPath: videoPath)
            log("📹 video.mp4 exists: \(fileExists)")
        }

        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            log("❌ video.mp4 NOT FOUND in bundle")
            log("🔍 All resources: \(Bundle.main.paths(forResourcesOfType: "mp4", inDirectory: nil))")
            return
        }

        log("✅ Found video at: \(videoURL.path)")
        log("📊 Video file size: \(try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] ?? "unknown")")

        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)

        log("🎮 AVPlayer created")

        // Observe player status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            log("🔁 Video ended, looping")
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        // Observe player item status
        playerItem.publisher(for: \.status)
            .sink { status in
                switch status {
                case .unknown:
                    log("⏸️ Player status: unknown")
                case .readyToPlay:
                    log("✅ Player status: readyToPlay")
                case .failed:
                    log("❌ Player status: FAILED - \(playerItem.error?.localizedDescription ?? "no error")")
                @unknown default:
                    log("❓ Player status: unknown default")
                }
            }
            .store(in: &cancellables)

        self.player = newPlayer
        log("💾 Player stored in @State")

        newPlayer.isMuted = true
        log("🔇 Player muted")

        // Try to play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            log("▶️ Calling play()")
            newPlayer.play()

            // Check if playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                log("📊 Player rate: \(newPlayer.rate)")
                log("📊 Player timeControlStatus: \(newPlayer.timeControlStatus.rawValue)")
            }
        }
    }

    @State private var cancellables = Set<AnyCancellable>()
}

/// Custom UIViewRepresentable for AVPlayer (same as before)
private struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .purple // Purple to see if UIView is created

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.orange.cgColor // Orange to see layer
        view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer

        print("🎨 VideoPlayerView makeUIView called")
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = context.coordinator.playerLayer {
            playerLayer.frame = uiView.bounds
            print("📐 VideoPlayerView updated frame: \(uiView.bounds)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

import Combine
