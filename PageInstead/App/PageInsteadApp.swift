import SwiftUI
import Combine

@main
struct PageInsteadApp: App {
    init() {
        // Perform migration from old ScreenTimeService to App Groups
        AppGroupManager.shared.performMigrationIfNeeded()

        // Start auto-unlock monitoring
        UnlockMonitorService.shared.startMonitoring()
        print("🔓 Started UnlockMonitorService - will auto-remove shields when timers expire")

        // Test App Groups access (from expert's paid_account.md)
        print("🧪 TESTING APP GROUPS ACCESS FROM MAIN APP...")
        if let defaults = UserDefaults(suiteName: "group.com.pageinstead") {
            defaults.set(Date(), forKey: "test_write_from_main_app")
            defaults.synchronize()
            print("✅ MAIN APP: Successfully wrote to App Group!")

            if let value = defaults.object(forKey: "test_write_from_main_app") {
                print("✅ MAIN APP: Successfully read from App Group: \(value)")
            }
        } else {
            print("❌ MAIN APP: Failed to access App Groups - UserDefaults(suiteName:) returned nil!")
            print("❌ This means the App Group container was not created!")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Image Loading with Retry and Caching

/// Custom image loader with retry logic and optimized caching for book cover images
/// Addresses issues with image loading failures after app background suspension
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?

    private var cancellable: AnyCancellable?
    let url: URL  // Made internal so CachedAsyncImage can access it
    private let maxRetries: Int
    private var retryCount = 0

    // Shared URLSession with optimized configuration
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default

        // Shorter timeout for faster failure detection after background suspension
        config.timeoutIntervalForRequest = 15.0  // 15s instead of default 60s
        config.timeoutIntervalForResource = 30.0

        // Aggressive caching to reduce network dependency
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory cache
            diskCapacity: 200 * 1024 * 1024,    // 200 MB disk cache
            diskPath: "book_covers"
        )

        // Better performance on cellular
        config.allowsCellularAccess = true
        config.waitsForConnectivity = false  // Fail fast instead of waiting

        return URLSession(configuration: config)
    }()

    init(url: URL, maxRetries: Int = 2) {
        self.url = url
        self.maxRetries = maxRetries
    }

    nonisolated deinit {
        // Cancellation will happen automatically via Combine
    }

    /// Load the image with automatic retry on failure
    func load() {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        // First, try to get cached image synchronously
        if let cachedResponse = Self.session.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)),
           let cachedImage = UIImage(data: cachedResponse.data) {
            print("📸 ImageLoader: Loaded from cache - \(url.lastPathComponent)")
            self.image = cachedImage
            self.isLoading = false
            return
        }

        print("📸 ImageLoader: Loading from network - \(url.lastPathComponent) (attempt \(retryCount + 1)/\(maxRetries + 1))")

        cancellable = Self.session.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    print("⚠️ ImageLoader: HTTP \(httpResponse.statusCode) for \(self.url.lastPathComponent)")
                    throw URLError(.badServerResponse)
                }

                guard let image = UIImage(data: data) else {
                    print("⚠️ ImageLoader: Invalid image data for \(self.url.lastPathComponent)")
                    throw URLError(.cannotDecodeContentData)
                }

                print("✅ ImageLoader: Successfully loaded \(self.url.lastPathComponent)")
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }

                    self.isLoading = false

                    switch completion {
                    case .finished:
                        self.retryCount = 0  // Reset on success
                    case .failure(let error):
                        self.error = error
                        print("❌ ImageLoader: Failed to load \(self.url.lastPathComponent) - \(error.localizedDescription)")

                        // Retry logic with exponential backoff
                        if self.retryCount < self.maxRetries {
                            self.retryCount += 1
                            let delay = Double(self.retryCount) * 0.5  // 0.5s, 1.0s, 1.5s...
                            print("🔄 ImageLoader: Retrying in \(delay)s...")

                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                self.load()
                            }
                        } else {
                            print("❌ ImageLoader: Max retries reached for \(self.url.lastPathComponent)")
                        }
                    }
                },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
    }

    /// Reload the image (resets retry count)
    func reload() {
        cancel()
        retryCount = 0
        image = nil
        load()
    }

    /// Cancel the current load operation
    func cancel() {
        cancellable?.cancel()
        isLoading = false
    }
}

/// SwiftUI view for displaying images with automatic loading and retry
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    init(
        url: URL?,
        maxRetries: Int = 2,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        // Use a dummy URL if nil, but won't load it
        let loadURL = url ?? URL(string: "about:blank")!
        _loader = StateObject(wrappedValue: ImageLoader(url: loadURL, maxRetries: maxRetries))
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .onAppear {
            // Only load if we have a valid URL
            if loader.url.absoluteString != "about:blank" {
                loader.load()
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

/// Extension to reload images when app becomes active from background
extension CachedAsyncImage {
    /// Reload image when app becomes active (for handling background suspension issues)
    func reloadOnAppear(scenePhase: ScenePhase) -> some View {
        if #available(iOS 17.0, *) {
            return self.onChange(of: scenePhase) { oldPhase, newPhase in
                // When app becomes active from background, reload failed images
                if oldPhase == .background && newPhase == .active {
                    if loader.error != nil && loader.image == nil {
                        print("🔄 CachedAsyncImage: App became active, reloading failed image")
                        loader.reload()
                    }
                }
            }
        } else {
            // iOS 16 fallback - use older onChange API
            return self.onChange(of: scenePhase) { newPhase in
                // When app becomes active from background, reload failed images
                if newPhase == .active {
                    if loader.error != nil && loader.image == nil {
                        print("🔄 CachedAsyncImage: App became active, reloading failed image")
                        loader.reload()
                    }
                }
            }
        }
    }
}
