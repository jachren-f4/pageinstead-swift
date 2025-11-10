import SwiftUI

struct SettingsView: View {
    @StateObject private var restrictionManager = SelfRestrictionManager.shared
    @StateObject private var onboardingData = OnboardingData.shared
    @State private var showingPasscodeSetup = false
    @State private var showingPasscodeChange = false
    @State private var showingPasscodeEntry = false
    @State private var isSettingsUnlocked = false
    @Binding var showOnboarding: Bool

    // Health Score data
    @State private var healthScore: Double = 75.0
    @State private var blockedAttempts: Int = 0
    @State private var baselineAttempts: Int = 15
    @State private var isCalibrated: Bool = false
    @State private var calibrationProgress: Int = 0

    // Get app version from Bundle
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "Version \(version) (\(build))"
        }
        return "Version 1.0.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                AnimatedGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Top spacing
                        Spacer()
                            .frame(height: 20)

                        // Header - scrollable
                        Text("Settings")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        // Quote Preferences section
                        GlassCard(standard: {
                            VStack(spacing: 20) {
                                // Section title
                                Text("Quote Preferences")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Book Categories navigation
                                NavigationLink(destination: CategorySelectionView()) {
                                    VStack(spacing: 14) {
                                        // Header with title and chevron
                                        HStack {
                                            Text("Book Categories")
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundColor(.white)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.4))
                                        }

                                        // Category chips - elegant horizontal scroll
                                        if !onboardingData.bookCategories.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    let categories = Array(onboardingData.bookCategories).prefix(4)
                                                    ForEach(categories, id: \.self) { category in
                                                        CategoryPreviewChip(text: shortenCategoryName(category))
                                                    }

                                                    if onboardingData.bookCategories.count > 4 {
                                                        CategoryPreviewChip(text: "+\(onboardingData.bookCategories.count - 4)")
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("No categories selected")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.5))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 18)
                                    .background(
                                        ZStack {
                                            // Subtle glass background
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.03))

                                            // Gradient overlay
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.08),
                                                            Color(red: 124/255, green: 58/255, blue: 237/255).opacity(0.05)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        })
                        .padding(.horizontal)

                        // About Quotes section
                        GlassCard(standard: {
                            VStack(spacing: 20) {
                                // Section title
                                Text("About Quotes")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Fair Use & Attribution navigation
                                NavigationLink(destination: FairUseAttributionView()) {
                                    VStack(spacing: 8) {
                                        // Header with title and chevron
                                        HStack {
                                            Text("Fair Use & Attribution")
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundColor(.white)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.4))
                                        }

                                        // Description
                                        Text("How we source and attribute quotes")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 18)
                                    .background(
                                        ZStack {
                                            // Subtle glass background
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.03))

                                            // Gradient overlay
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.08),
                                                            Color(red: 124/255, green: 58/255, blue: 237/255).opacity(0.05)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        })
                        .padding(.horizontal)

                        // Lock Settings section
                    GlassCard(standard: {
                        VStack(spacing: 24) {
                            // Section title
                            Text("Lock Settings")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 20) {
                                    // Timer Lock
                                    SettingsToggleRow(
                                        icon: "timer",
                                        title: "Lock Settings Timer",
                                        description: "Locks access to unlock screen and Settings tab when app opens.",
                                        isOn: Binding(
                                            get: { restrictionManager.settings.isTimerLockEnabled },
                                            set: { newValue in
                                                restrictionManager.settings.isTimerLockEnabled = newValue
                                                restrictionManager.saveSettings()
                                            }
                                        )
                                    )

                                    if restrictionManager.settings.isTimerLockEnabled {
                                        SettingsPickerRow(
                                            title: "Timer Duration",
                                            selection: Binding(
                                                get: { restrictionManager.settings.timerDuration },
                                                set: { newValue in
                                                    restrictionManager.settings.timerDuration = newValue
                                                    restrictionManager.saveSettings()
                                                }
                                            ),
                                            options: [5, 10, 15, 30, 60, 120],
                                            formatter: { "\(Int($0)) seconds" }
                                        )
                                    }

                                    Divider()
                                        .background(Color.white.opacity(0.2))

                                    // Passcode Lock
                                    SettingsToggleRow(
                                        icon: "lock.fill",
                                        title: "Lock Settings Passcode",
                                        description: "Require 4-digit passcode to access unlock screen and Settings tab.",
                                        isOn: Binding(
                                            get: { restrictionManager.settings.isPasscodeLockEnabled },
                                            set: { newValue in
                                                if newValue && !restrictionManager.hasPasscode() {
                                                    showingPasscodeSetup = true
                                                } else {
                                                    restrictionManager.settings.isPasscodeLockEnabled = newValue
                                                    restrictionManager.saveSettings()
                                                }
                                            }
                                        )
                                    )

                                if restrictionManager.hasPasscode() {
                                    Button(action: {
                                        showingPasscodeChange = true
                                    }) {
                                        Text("Change Passcode")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    })
                    .padding(.horizontal)

                    #if targetEnvironment(simulator)
                    // Debug Section - App Groups Data (simulator only)
                    GlassCard(standard: {
                        VStack(spacing: 16) {
                            Text("🐛 Debug: App Groups Data")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: checkAppGroupsData) {
                                Text("Refresh App Groups Data")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(12)
                            }

                            if let defaults = UserDefaults(suiteName: "group.com.pageinstead"),
                               let allKeys = defaults.dictionaryRepresentation().keys as? Set<String> {

                                let unlockKeys = allKeys.filter { $0.hasPrefix("unlock_request") }
                                let pauseKeys = allKeys.filter { $0.hasPrefix("pause_") }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Unlock Requests: \(unlockKeys.count)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))

                                    ForEach(Array(unlockKeys), id: \.self) { key in
                                        Text("• \(key)")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.green)
                                    }

                                    if !unlockKeys.isEmpty {
                                        Button("Clear Unlock Requests") {
                                            for key in unlockKeys {
                                                defaults.removeObject(forKey: key)
                                            }
                                            defaults.synchronize()
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    }

                                    Divider().background(Color.white.opacity(0.2)).padding(.vertical, 4)

                                    Text("Pause Timers: \(pauseKeys.count)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))

                                    ForEach(Array(pauseKeys.prefix(3)), id: \.self) { key in
                                        Text("• \(key)")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                        }
                    })
                    .padding(.horizontal)
                    #endif

                    #if targetEnvironment(simulator)
                    // Tutorial section (simulator only)
                    GlassCard(standard: {
                        VStack(spacing: 16) {
                            // Section title
                            Text("Tutorial")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Replay the interactive tutorial")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Replay Tutorial button
                            Button(action: {
                                replayQuoteTutorial()
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                    Text("Replay Quote Tutorial")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .liquidGlassPrimaryButton()
                        }
                    })
                    .padding(.horizontal)
                    #endif

                    #if targetEnvironment(simulator)
                    // Development section (simulator only)
                    GlassCard(standard: {
                        VStack(spacing: 16) {
                            // Section title
                            Text("Development")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Tools for testing and development")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Onboarding button
                            Button(action: {
                                resetAndShowOnboarding()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.title3)
                                    Text("Reset & Show Onboarding")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .liquidGlassPrimaryButton()
                        }
                    })
                    .padding(.horizontal)
                    #endif

                    Spacer(minLength: 80)

                    // Footer with health data
                    VStack(spacing: 8) {
                        Text("PageInstead")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Text(appVersion)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))

                        // Health Score info
                        if isCalibrated {
                            Text("Blocked Attempts: \(blockedAttempts) / \(baselineAttempts) baseline | Health Score: \(Int(healthScore))%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.top, 4)
                        } else {
                            Text("Calibrating: Day \(calibrationProgress) of 3 | Health Score: \(Int(healthScore))%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .scrollFadeOverlay()
        }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPasscodeSetup) {
            PasscodeSetupView(isPresented: $showingPasscodeSetup)
        }
        .sheet(isPresented: $showingPasscodeChange) {
            PasscodeChangeView(isPresented: $showingPasscodeChange)
        }
        .onAppear {
            loadHealthScoreData()
        }
    }

    // MARK: - Helper Methods

    private func loadHealthScoreData() {
        healthScore = HealthScoreService.shared.getCurrentHealthScore()
        blockedAttempts = HealthScoreService.shared.getBlockedAttemptsToday()
        baselineAttempts = HealthScoreService.shared.getBaselineAttempts()
        isCalibrated = HealthScoreService.shared.isCalibrated()
        calibrationProgress = HealthScoreService.shared.getCalibrationProgress()

        print("⚙️ Settings: Loaded health score - \(Int(healthScore))% (Attempts: \(blockedAttempts)/\(baselineAttempts))")
    }

    private func checkAppGroupsData() {
        guard let defaults = UserDefaults(suiteName: "group.com.pageinstead") else {
            print("❌ Cannot access App Groups")
            return
        }

        let allKeys = defaults.dictionaryRepresentation().keys
        print("📋 All App Groups Keys:")
        for key in allKeys.sorted() {
            if let value = defaults.object(forKey: key) {
                print("  \(key): \(value)")
            }
        }
    }

    private func resetAndShowOnboarding() {
        // Reset onboarding data
        OnboardingData.shared.resetOnboarding()
        print("🔄 Reset onboarding data")

        // Trigger onboarding to show
        showOnboarding = true
        print("✨ Showing onboarding flow")
    }

    private func replayQuoteTutorial() {
        // Reset the tutorial flag
        UserDefaults.standard.set(false, forKey: "hasSeenQuoteTutorial")
        UserDefaults.standard.synchronize()

        // Post notification to trigger tutorial immediately
        NotificationCenter.default.post(name: Notification.Name("ReplayQuoteTutorial"), object: nil)

        print("🎓 Reset Quote Tutorial flag and posted notification to trigger tutorial")
    }

    private func shortenCategoryName(_ category: String) -> String {
        // Shorten category names for chip display
        let shortened = category
            .replacingOccurrences(of: " & ", with: " ")
            .replacingOccurrences(of: "Self-help", with: "Self-help")
            .replacingOccurrences(of: "Growth", with: "")
            .replacingOccurrences(of: "Focus", with: "")
            .replacingOccurrences(of: "Mindfulness", with: "")
            .replacingOccurrences(of: "Relationships", with: "")
            .replacingOccurrences(of: "Leadership", with: "")
            .replacingOccurrences(of: "Art", with: "")
            .replacingOccurrences(of: "Meaning", with: "")
            .replacingOccurrences(of: "Empowerment", with: "")
            .replacingOccurrences(of: "Literature", with: "")
            .replacingOccurrences(of: "Nature", with: "")
            .trimmingCharacters(in: .whitespaces)

        return shortened
    }
}

// MARK: - Category Preview Chip
struct CategoryPreviewChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.95))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.2))

                    // Top highlight
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        Color(red: 196/255, green: 181/255, blue: 253/255).opacity(0.35),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 30)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Settings Picker Row
struct SettingsPickerRow: View {
    let title: String
    @Binding var selection: TimeInterval
    let options: [TimeInterval]
    let formatter: (TimeInterval) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(formatter(option))
                        .foregroundColor(.white)
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
    }
}

#Preview {
    SettingsView(showOnboarding: .constant(false))
}
