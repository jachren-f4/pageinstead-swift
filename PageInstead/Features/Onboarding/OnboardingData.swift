import Foundation

/// Manages onboarding state and user preferences
class OnboardingData: ObservableObject {
    static let shared = OnboardingData()

    private let defaults = UserDefaults.standard
    private let appGroupDefaults = UserDefaults(suiteName: "group.com.pageinstead")

    // MARK: - Published State
    @Published var currentScreen: Int = 1
    @Published var gender: String = ""
    @Published var ageGroup: String = ""
    @Published var bookCategories: Set<String> = []
    @Published var hasSeenFirstShield: Bool = false

    // MARK: - Persistence Keys
    private enum Keys {
        static let completed = "onboarding_completed"
        static let step = "onboarding_step"
        static let completedDate = "onboarding_completed_date"
        static let version = "onboarding_version"
        static let gender = "onboarding_gender"
        static let ageGroup = "onboarding_age_group"
        static let bookCategories = "onboarding_book_categories"
        static let skippedTryItNow = "skipped_try_it_now"
        static let hasSeenUnlockTutorial = "has_seen_unlock_tutorial"
    }

    private enum AppGroupKeys {
        static let firstShieldSeen = "firstShieldSeen"
        static let firstShieldSeenDate = "firstShieldSeenDate"
        static let bookCategories = "book_categories"
    }

    // MARK: - Initialization
    private init() {
        loadSavedData()
    }

    // MARK: - Computed Properties
    var isOnboardingCompleted: Bool {
        defaults.bool(forKey: Keys.completed)
    }

    var hasSkippedTryItNow: Bool {
        defaults.bool(forKey: Keys.skippedTryItNow)
    }

    // MARK: - Data Management
    func loadSavedData() {
        currentScreen = defaults.integer(forKey: Keys.step)
        if currentScreen == 0 {
            currentScreen = 1
        }

        gender = defaults.string(forKey: Keys.gender) ?? ""
        ageGroup = defaults.string(forKey: Keys.ageGroup) ?? ""

        // Load categories from App Group UserDefaults (so Shield Extension can access)
        if let categories = appGroupDefaults?.array(forKey: AppGroupKeys.bookCategories) as? [String] {
            bookCategories = Set(categories)
        } else if let categories = defaults.array(forKey: Keys.bookCategories) as? [String] {
            // Migration: Load from old location if not in App Group yet
            bookCategories = Set(categories)
            // Migrate to App Group
            appGroupDefaults?.set(Array(categories), forKey: AppGroupKeys.bookCategories)
        }

        hasSeenFirstShield = appGroupDefaults?.bool(forKey: AppGroupKeys.firstShieldSeen) ?? false
    }

    func saveCurrentStep() {
        defaults.set(currentScreen, forKey: Keys.step)
    }

    func saveGender(_ value: String) {
        gender = value
        defaults.set(value, forKey: Keys.gender)
    }

    func saveAgeGroup(_ value: String) {
        ageGroup = value
        defaults.set(value, forKey: Keys.ageGroup)
    }

    func saveBookCategories(_ categories: Set<String>) {
        bookCategories = categories
        // Save to App Group UserDefaults (so Shield Extension can access)
        appGroupDefaults?.set(Array(categories), forKey: AppGroupKeys.bookCategories)
        // Also save to standard UserDefaults for backward compatibility
        defaults.set(Array(categories), forKey: Keys.bookCategories)
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Keys.completed)
        defaults.set(Date(), forKey: Keys.completedDate)
        defaults.set("v5", forKey: Keys.version)
        defaults.set(0, forKey: Keys.step) // Reset step
    }

    func skipTryItNow() {
        defaults.set(true, forKey: Keys.skippedTryItNow)
        defaults.set(false, forKey: Keys.hasSeenUnlockTutorial)
        completeOnboarding()
    }

    func checkForFirstShield() {
        let shieldSeen = appGroupDefaults?.bool(forKey: AppGroupKeys.firstShieldSeen) ?? false
        if shieldSeen != hasSeenFirstShield {
            hasSeenFirstShield = shieldSeen
        }
    }

    // MARK: - Reset (for testing)
    func resetOnboarding() {
        defaults.removeObject(forKey: Keys.completed)
        defaults.removeObject(forKey: Keys.step)
        defaults.removeObject(forKey: Keys.completedDate)
        defaults.removeObject(forKey: Keys.gender)
        defaults.removeObject(forKey: Keys.ageGroup)
        defaults.removeObject(forKey: Keys.bookCategories)
        defaults.removeObject(forKey: Keys.skippedTryItNow)
        appGroupDefaults?.removeObject(forKey: AppGroupKeys.firstShieldSeen)
        appGroupDefaults?.removeObject(forKey: AppGroupKeys.firstShieldSeenDate)

        currentScreen = 1
        gender = ""
        ageGroup = ""
        bookCategories = []
        hasSeenFirstShield = false
    }
}

/// Book category options for Screen 6
enum BookCategory: String, CaseIterable {
    case selfHelp = "Self-help & Growth"
    case productivity = "Productivity & Focus"
    case philosophy = "Philosophy & Mindfulness"
    case psychology = "Psychology & Relationships"
    case business = "Business & Leadership"
    case creativity = "Creativity & Art"
    case spirituality = "Spirituality & Meaning"
    case womens = "Women's Empowerment"
    case classics = "Classics & Literature"
    case science = "Science & Nature"
}
