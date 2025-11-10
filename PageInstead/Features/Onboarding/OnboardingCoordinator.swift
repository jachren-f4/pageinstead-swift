import SwiftUI
import AVKit
import AVFoundation
import Combine

/// Main onboarding coordinator managing all 11 screens
struct OnboardingCoordinator: View {
    @StateObject private var data = OnboardingData.shared
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            // Background gradient (static)
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0, blue: 0.20),    // #1a0033
                    Color(red: 0.20, green: 0, blue: 0.40),    // #330066
                    Color(red: 0.44, green: 0.26, blue: 0.76) // #6f42c1
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Screen content
            Group {
                switch data.currentScreen {
                case 1:
                    OnboardingScreen1_Hero(onNext: { nextScreen() })
                case 2:
                    OnboardingScreen2_Difference(onNext: { nextScreen() })
                case 3:
                    OnboardingScreen3_HowItWorks(onNext: { nextScreen() })
                case 4:
                    OnboardingScreen4_Gender(onNext: { nextScreen() })
                case 5:
                    OnboardingScreen5_AgeGroup(onNext: { nextScreen() })
                case 6:
                    OnboardingScreen6_BookCategories(onNext: { nextScreen() })
                case 7:
                    OnboardingScreen7_Permissions(onNext: { nextScreen() })
                case 8:
                    OnboardingScreen8_AppSelection(onNext: { nextScreen() })
                case 9:
                    OnboardingScreen9_UnlockExplanation(onNext: { nextScreen() })
                case 10:
                    OnboardingScreen10_SetupComplete(onNext: { nextScreen() })
                case 11:
                    OnboardingScreen11_TryItNow(
                        onComplete: { completeOnboarding() },
                        onSkip: { skipAndComplete() }
                    )
                default:
                    OnboardingScreen1_Hero(onNext: { nextScreen() })
                }
            }
            .transition(.opacity)
        }
    }

    private func nextScreen() {
        withAnimation(.easeInOut(duration: 0.3)) {
            data.currentScreen += 1
            data.saveCurrentStep()
        }
    }

    private func completeOnboarding() {
        data.completeOnboarding()
        withAnimation {
            showOnboarding = false
        }
    }

    private func skipAndComplete() {
        data.skipTryItNow()
        withAnimation {
            showOnboarding = false
        }
    }
}

// MARK: - Video Test Screen (Screen 0)

/// Screen 0: Video Test - Simple test screen to debug video playback
struct OnboardingScreen0_VideoTest: View {
    let onNext: () -> Void
    @State private var player: AVPlayer?
    @State private var debugLog: [String] = []
    @State private var cancellables = Set<AnyCancellable>()

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
                        VideoPlayerTestView(player: player)
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
                VStack(spacing: 0) {
                    HStack {
                        Text("Debug Log")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = debugLog.joined(separator: "\n")
                            log("📋 Copied to clipboard!")
                        }) {
                            Text("📋 Copy")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(debugLog.indices, id: \.self) { index in
                                Text(debugLog[index])
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.gray.opacity(0.3))

                Spacer()

                // Debug button - force reload
                Button(action: {
                    log("🔄 Reloading video...")
                    player = nil
                    debugLog.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        setupVideoPlayer()
                    }
                }) {
                    Text("🔄 Reload Video")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)

                // Next button - DISABLED for debugging
                Button(action: {}) {
                    Text("Next → (Disabled for Debug)")
                        .foregroundColor(.white.opacity(0.5))
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                .disabled(true)
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
        DispatchQueue.main.async {
            debugLog.append(logMessage)
        }
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
            let allMP4s = Bundle.main.paths(forResourcesOfType: "mp4", inDirectory: nil)
            log("🔍 All MP4 resources: \(allMP4s)")
            return
        }

        log("✅ Found video at: \(videoURL.path)")

        if let attrs = try? FileManager.default.attributesOfItem(atPath: videoURL.path),
           let size = attrs[.size] as? NSNumber {
            log("📊 Video file size: \(size) bytes")
        }

        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)

        log("🎮 AVPlayer created")

        // Observe player item status
        playerItem.publisher(for: \.status)
            .sink { [self] status in
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

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [self] _ in
            log("🔁 Video ended, looping")
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        self.player = newPlayer
        log("💾 Player stored in @State")

        newPlayer.isMuted = true
        log("🔇 Player muted")

        // Try to play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            log("▶️ Calling play()")
            newPlayer.play()

            // Check if playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                log("📊 Player rate: \(newPlayer.rate)")
                log("📊 Player timeControlStatus: \(newPlayer.timeControlStatus.rawValue)")
            }
        }
    }
}

/// Custom UIViewRepresentable for AVPlayer
private struct VideoPlayerTestView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        print("🎨 VideoPlayerView makeUIView called")

        let view = UIView()
        view.backgroundColor = .purple // Purple to see if UIView is created

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.orange.cgColor // Orange to see layer
        view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer

        print("🎨 Player layer added, frame will be set in updateUIView")

        // Force initial frame on next run loop
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
            print("🎨 Initial frame set: \(view.bounds)")
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        print("📐 VideoPlayerView updateUIView called, bounds: \(uiView.bounds)")

        if let playerLayer = context.coordinator.playerLayer {
            let newFrame = uiView.bounds
            print("📐 Setting playerLayer frame to: \(newFrame)")
            playerLayer.frame = newFrame

            // Force layout
            uiView.layoutIfNeeded()

            print("📐 PlayerLayer actual frame after setting: \(playerLayer.frame)")
            print("📐 PlayerLayer superlayer: \(playerLayer.superlayer != nil)")
        } else {
            print("⚠️ PlayerLayer is nil in updateUIView!")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
