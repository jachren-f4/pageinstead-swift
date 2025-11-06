//
//  AppGroupRulesView.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import SwiftUI
import FamilyControls

struct AppGroupRulesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager = AppGroupManager.shared

    @State private var group: AppGroup
    @State private var isPickerPresented = false
    @State private var showNameAlert = false
    @State private var editedName = ""
    @State private var showDeleteConfirmation = false
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""

    // UI State
    @State private var isDailyLimitEnabled: Bool
    @State private var isScheduleEnabled: Bool

    let isNewGroup: Bool
    let onSave: (AppGroup) -> Void

    init(group: AppGroup? = nil, onSave: @escaping (AppGroup) -> Void = { _ in }) {
        let initialGroup = group ?? AppGroup(
            name: AppGroupManager.shared.generateGroupName(),
            pauseForSeconds: 10,
            dailyOpenLimit: nil,
            blockAfterMaxUse: false
        )

        _group = State(initialValue: initialGroup)
        _editedName = State(initialValue: initialGroup.name)
        _isDailyLimitEnabled = State(initialValue: initialGroup.dailyOpenLimit != nil)
        _isScheduleEnabled = State(initialValue: !initialGroup.schedule.alwaysActive)

        self.isNewGroup = group == nil
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackground.standard()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                header

                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Group Name
                        groupNameSection

                        // Section 2: App Selection
                        appSelectionSection

                        // Section 3: Pause For
                        pauseForSection

                        // Section 4: Daily Open Limit
                        dailyLimitSection

                        // Section 5: Schedule
                        scheduleSection

                        // Section 6: Actions
                        actionButtons

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: Binding(
                get: { group.selection },
                set: { group.selection = $0 }
            )
        )
        .alert("Edit Group Name", isPresented: $showNameAlert) {
            TextField("Group Name", text: $editedName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !editedName.trimmingCharacters(in: .whitespaces).isEmpty {
                    group.name = editedName.trimmingCharacters(in: .whitespaces)
                }
            }
        }
        .alert("Conflict Detected", isPresented: $showConflictAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(conflictMessage)
        }
        .alert("Delete Group?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteGroup()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { dismiss() }) {
                HStack(spacing: 5) {
                    Text("‹")
                        .font(.system(size: 24))
                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(Color(hex: "6CC8FF"))
            }

            Text("Group Rules")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    // MARK: - Section 1: Group Name

    private var groupNameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GROUP NAME")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .kerning(0.5)

            Button(action: {
                editedName = group.name
                showNameAlert = true
            }) {
                HStack {
                    Text(group.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("✏️")
                        .font(.system(size: 18))
                }
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    // MARK: - Section 2: App Selection

    private var appSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("APPS")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .kerning(0.5)

            #if targetEnvironment(simulator)
            // Simulator: Show mock app selection
            Button(action: {}) {
                HStack {
                    Text("Selected Apps")
                        .font(.system(size: 17))
                        .foregroundColor(.white)

                    Spacer()

                    Text("SIMULATOR MODE")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "6CC8FF"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: "6CC8FF").opacity(0.2))
                        .cornerRadius(12)

                    Text("›")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .disabled(true)
            #else
            // Device: Show actual FamilyActivityPicker
            Button(action: { isPickerPresented = true }) {
                HStack {
                    Text("Selected Apps")
                        .font(.system(size: 17))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(group.appCount) app\(group.appCount == 1 ? "" : "s")")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                    Text("›")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            #endif

            #if targetEnvironment(simulator)
            Text("🔧 FamilyActivityPicker requires a physical device. Test UI layout in simulator, then run on device for full functionality.")
                .font(.system(size: 14))
                .foregroundColor(.orange.opacity(0.8))
            #else
            Text("Tap to select which apps to block")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            #endif
        }
        .padding(20)
        .liquidGlassCard()
    }

    // MARK: - Section 3: Pause For

    private var pauseForSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PAUSE FOR")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .kerning(0.5)

            Menu {
                ForEach([0, 5, 10, 20, 30, 60, 120, 180, 300], id: \.self) { seconds in
                    Button(formatDuration(seconds)) {
                        group.pauseForSeconds = seconds
                    }
                }
            } label: {
                HStack {
                    Text("Wait before opening")
                        .font(.system(size: 17))
                        .foregroundColor(.white)

                    Spacer()

                    Text(formatDuration(group.pauseForSeconds))
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                    Text("›")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Text("How long to reflect on a quote before app access")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(20)
        .liquidGlassCard()
    }

    // MARK: - Section 4: Daily Open Limit

    private var dailyLimitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY OPEN LIMIT")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .kerning(0.5)

            Toggle(isOn: $isDailyLimitEnabled) {
                Text("Enable Daily Limit")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
            }
            .tint(Color(hex: "34C759"))
            .onChange(of: isDailyLimitEnabled) { enabled in
                if enabled && group.dailyOpenLimit == nil {
                    group.dailyOpenLimit = 20
                } else if !enabled {
                    group.dailyOpenLimit = nil
                }
            }

            if isDailyLimitEnabled {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.08))

                    HStack {
                        Text("Opens per day")
                            .font(.system(size: 17))
                            .foregroundColor(.white)

                        Spacer()

                        HStack(spacing: 12) {
                            Button(action: {
                                if let current = group.dailyOpenLimit, current > 1 {
                                    group.dailyOpenLimit = current - 1
                                }
                            }) {
                                Text("−")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "6CC8FF"))
                                    .frame(width: 28, height: 28)
                                    .background(Color(hex: "6CC8FF").opacity(0.2))
                                    .cornerRadius(8)
                            }

                            Text("\(group.dailyOpenLimit ?? 20)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60)

                            Button(action: {
                                if let current = group.dailyOpenLimit, current < 100 {
                                    group.dailyOpenLimit = current + 1
                                }
                            }) {
                                Text("+")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "6CC8FF"))
                                    .frame(width: 28, height: 28)
                                    .background(Color(hex: "6CC8FF").opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }

                    Toggle(isOn: $group.blockAfterMaxUse) {
                        Text("Block after max use")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                    }
                    .tint(Color(hex: "34C759"))

                    Text(group.blockAfterMaxUse
                         ? "Apps will be completely blocked after limit is reached"
                         : "Continue showing quotes after limit (motivational mode)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    // MARK: - Section 5: Schedule

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SCHEDULE")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .kerning(0.5)

            Toggle(isOn: Binding(
                get: { !isScheduleEnabled },
                set: { group.schedule.alwaysActive = $0 }
            )) {
                Text("Always Active")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
            }
            .tint(Color(hex: "34C759"))
            .onChange(of: group.schedule.alwaysActive) { alwaysActive in
                isScheduleEnabled = !alwaysActive
            }

            if isScheduleEnabled {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.08))

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start time")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))

                            DatePicker("", selection: Binding(
                                get: { dateFromComponents(group.schedule.startTime) },
                                set: { group.schedule.startTime = componentsFromDate($0) }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("End time")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))

                            DatePicker("", selection: Binding(
                                get: { dateFromComponents(group.schedule.endTime) },
                                set: { group.schedule.endTime = componentsFromDate($0) }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                        }
                    }

                    DayPillSelector(selectedDays: $group.schedule.activeDays)

                    Text("Group will only be active during selected days and times")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    // MARK: - Section 6: Actions

    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Save Button
            Button(action: saveGroup) {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "6CC8FF"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .liquidGlassPrimaryButton()

            // Delete Button (only for existing groups)
            if !isNewGroup {
                Button(action: { showDeleteConfirmation = true }) {
                    Text("Delete Group")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .liquidGlassDestructiveButton()
            }
        }
    }

    // MARK: - Actions

    private func saveGroup() {
        do {
            if isNewGroup {
                try manager.createGroup(group)
            } else {
                try manager.updateGroup(group)
            }
            onSave(group)
            dismiss()
        } catch AppGroupError.validationFailed(let title, let message) {
            conflictMessage = message
            showConflictAlert = true
        } catch {
            print("Error saving group: \(error)")
        }
    }

    private func deleteGroup() {
        do {
            try manager.deleteGroup(id: group.id)
            dismiss()
        } catch {
            print("Error deleting group: \(error)")
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 {
            return "0 seconds"
        } else if seconds < 60 {
            return "\(seconds) seconds"
        } else if seconds == 60 {
            return "1 minute"
        } else if seconds < 120 {
            return "\(seconds / 60) minute"
        } else {
            return "\(seconds / 60) minutes"
        }
    }

    private func dateFromComponents(_ components: DateComponents) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }

    private func componentsFromDate(_ date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.hour, .minute], from: date)
    }
}

// MARK: - Day Pill Selector

struct DayPillSelector: View {
    @Binding var selectedDays: Set<Int>

    private let days = [
        (1, "Su"), (2, "M"), (3, "T"), (4, "W"),
        (5, "Th"), (6, "F"), (7, "Sa")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { day, label in
                Button(action: {
                    if selectedDays.contains(day) {
                        // Keep at least one day selected
                        if selectedDays.count > 1 {
                            selectedDays.remove(day)
                        }
                    } else {
                        selectedDays.insert(day)
                    }
                }) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedDays.contains(day) ? .white : Color(hex: "6CC8FF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(selectedDays.contains(day)
                                    ? Color(hex: "6CC8FF")
                                    : Color(hex: "6CC8FF").opacity(0.2))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(hex: "6CC8FF").opacity(selectedDays.contains(day) ? 1 : 0.3), lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    AppGroupRulesView()
}
