//
//  AppGroupsListView.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import SwiftUI

struct AppGroupsListView: View {
    @ObservedObject var manager = AppGroupManager.shared
    @State private var showingRulesSheet = false
    @State private var selectedGroup: AppGroup?

    var body: some View {
        ZStack {
            // Background - extends behind tab bar for iOS 18+ liquid glass effect
            AnimatedGradientBackground.standard()
                .ignoresSafeArea()

            if manager.groups.isEmpty {
                // Empty State
                AppGroupsEmptyState(onCreateGroup: createNewGroup)
            } else {
                // List of Groups
                ZStack {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Top spacing for fixed header
                            Spacer()
                                .frame(height: 140)

                        // Group Cards
                        ForEach(manager.groups) { group in
                            Button(action: {
                                selectedGroup = group
                                showingRulesSheet = true
                            }) {
                                AppGroupCard(group: group)
                                    .padding(.horizontal)
                            }
                        }

                        // Add Button
                        Button(action: createNewGroup) {
                            HStack(spacing: 12) {
                                Text("+")
                                    .font(.system(size: 24))
                                Text("Add App Group")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        }
                        .background(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                                .foregroundColor(.white.opacity(0.2))
                        )
                        .cornerRadius(24)
                        .padding(.horizontal)

                        Spacer(minLength: 80)
                    }
                }
                .scrollFadeOverlay()

                    // Fixed header overlay
                    VStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Blocked Apps")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Organize apps into groups with custom rules")
                                .font(.system(size: 17))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)

                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showingRulesSheet) {
            if let group = selectedGroup {
                AppGroupRulesView(group: group) { updatedGroup in
                    // Refresh triggered by AppGroupManager @Published property
                }
            } else {
                AppGroupRulesView() { newGroup in
                    // Refresh triggered by AppGroupManager @Published property
                }
            }
        }
    }

    private func createNewGroup() {
        selectedGroup = nil
        showingRulesSheet = true
    }
}

#Preview {
    AppGroupsListView()
}
