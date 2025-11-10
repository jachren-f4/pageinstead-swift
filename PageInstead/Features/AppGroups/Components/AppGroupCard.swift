//
//  AppGroupCard.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import SwiftUI
import FamilyControls
import UIKit

struct AppGroupCard: View {
    let group: AppGroup

    // Display up to 5 apps, then show "+X" badge
    private let maxVisibleApps = 5

    private var visibleTokens: [SafeApplicationToken] {
        Array(group.applicationTokens.prefix(maxVisibleApps))
    }

    private var remainingCount: Int {
        max(0, group.appCount - maxVisibleApps)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Left side: Group info
            VStack(alignment: .leading, spacing: 12) {
                // Group Name
                Text(group.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                // Content: App Icons or Empty State
                HStack(spacing: 12) {
                    if group.hasApps {
                        // Show actual app icons using Label
                        ForEach(visibleTokens, id: \.self) { token in
                            Label(token)
                                .labelStyle(.iconOnly)
                                .frame(width: 40, height: 40)
                        }

                        // Show "+X" badge if there are more apps
                        if remainingCount > 0 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 40, height: 40)

                                Text("+\(remainingCount)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    } else {
                        Text("No Apps Selected")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.5))
                            .italic()
                    }
                }

                // App count label
                if group.hasApps {
                    Text("\(group.appCount) app\(group.appCount == 1 ? "" : "s")")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // Right side: Chevron indicator
            Text("›")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                Color.white.opacity(0.08)
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                    .blur(radius: 40)
                    .opacity(0.33)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
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
