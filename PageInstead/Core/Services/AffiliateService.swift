import Foundation

/// Configuration loaded from affiliate-config.json
struct AffiliateConfig: Codable {
    let version: Int
    let redirectBaseUrl: String?
    let affiliateTags: [String: String]
}

/// Service for generating Amazon affiliate links based on user region
class AffiliateService {
    static let shared = AffiliateService()

    private let amazonDomains: [String: String] = [
        "US": "amazon.com",
        "UK": "amazon.co.uk",
        "DE": "amazon.de",
        "FR": "amazon.fr",
        "CA": "amazon.ca",
        "JP": "amazon.co.jp",
        "IT": "amazon.it",
        "ES": "amazon.es",
        "IN": "amazon.in",
        "BR": "amazon.com.br",
        "MX": "amazon.com.mx",
        "AU": "amazon.com.au"
    ]

    // Loaded from affiliate-config.json
    private var affiliateTags: [String: String] = [:]
    var redirectBaseUrl: String? = nil

    private init() {
        loadConfig()
    }

    /// Load affiliate configuration from JSON file
    private func loadConfig() {
        guard let url = Bundle.main.url(forResource: "affiliate-config", withExtension: "json") else {
            print("⚠️ affiliate-config.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AffiliateConfig.self, from: data)

            self.affiliateTags = config.affiliateTags
            self.redirectBaseUrl = config.redirectBaseUrl

            print("✅ Loaded affiliate config for \(affiliateTags.count) regions")
            if let redirectUrl = config.redirectBaseUrl {
                print("📊 Using redirect tracking: \(redirectUrl)")
            } else {
                print("🔗 Using direct Amazon links")
            }
        } catch {
            print("⚠️ Failed to load affiliate-config.json: \(error)")
        }
    }

    /// Generate affiliate link - either direct Amazon or through redirect server
    /// - Parameters:
    ///   - asin: Amazon Standard Identification Number
    ///   - userRegion: Optional region override (defaults to device locale)
    /// - Returns: Full affiliate URL, or nil if ASIN is missing
    func getAmazonLink(asin: String?, userRegion: String? = nil) -> URL? {
        guard let asin = asin else {
            return nil
        }

        let region = userRegion ?? detectUserRegion()

        // If redirect server is configured, use it for tracking
        if let redirectBase = redirectBaseUrl {
            return buildRedirectUrl(asin: asin, region: region, redirectBase: redirectBase)
        } else {
            // Direct Amazon link (no tracking)
            return buildDirectAmazonUrl(asin: asin, region: region)
        }
    }

    /// Build direct Amazon affiliate URL
    private func buildDirectAmazonUrl(asin: String, region: String) -> URL? {
        let domain = amazonDomains[region] ?? amazonDomains["US"]!
        let tag = affiliateTags[region] ?? affiliateTags["US"] ?? ""

        let urlString = "https://www.\(domain)/dp/\(asin)?tag=\(tag)"
        return URL(string: urlString)
    }

    /// Build redirect URL for click tracking
    /// Format: https://yourdomain.com/redirect?asin=ASIN&region=REGION
    /// Your server will track the click then redirect to Amazon with proper tag
    private func buildRedirectUrl(asin: String, region: String, redirectBase: String) -> URL? {
        var components = URLComponents(string: redirectBase)
        components?.queryItems = [
            URLQueryItem(name: "asin", value: asin),
            URLQueryItem(name: "region", value: region)
        ]
        return components?.url
    }

    /// Detect user's region from device locale
    /// - Returns: Two-letter region code (e.g., "US", "UK", "DE")
    private func detectUserRegion() -> String {
        let locale = Locale.current

        // iOS 16+ uses region.identifier
        #if swift(>=5.7)
        if #available(iOS 16.0, *) {
            if let regionCode = locale.region?.identifier {
                return regionCode.uppercased()
            }
        }
        #endif

        // iOS 15 and below
        if let regionCode = locale.regionCode {
            return regionCode.uppercased()
        }

        return "US" // Fallback
    }

    /// Get user's region as human-readable name (for UI display)
    /// - Returns: Localized region name (e.g., "United States", "Germany")
    func getUserRegionName() -> String {
        let region = detectUserRegion()
        let locale = Locale.current
        return locale.localizedString(forRegionCode: region) ?? region
    }
}
