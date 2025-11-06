//
//  AppGroupCard.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import SwiftUI
import FamilyControls

struct AppGroupCard: View {
    let group: AppGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Group Name
            Text(group.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Content: App Icons or Empty State
            HStack {
                if group.hasApps {
                    // Show app icon placeholders
                    HStack(spacing: 12) {
                        ForEach(0..<min(3, group.appCount), id: \.self) { _ in
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("📱")
                                        .font(.system(size: 20))
                                )
                        }
                    }
                } else {
                    Text("No Apps Selected")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))
                        .italic()
                }

                Spacer()

                // Streak Badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Streak")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))

                    Text("\(group.streakDays) day\(group.streakDays == 1 ? "" : "s")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "6CC8FF"))
                }
            }
        }
        .padding(24)
        .liquidGlassCard()
    }
}

#Preview {
    VStack(spacing: 16) {
        AppGroupCard(group: AppGroup(
            name: "Social Media",
            applicationTokens: Set([]),
            streakDays: 3
        ))

        AppGroupCard(group: AppGroup(
            name: "Work Focus",
            streakDays: 0
        ))
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
