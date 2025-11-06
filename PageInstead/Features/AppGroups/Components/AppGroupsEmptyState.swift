//
//  AppGroupsEmptyState.swift
//  PageInstead
//
//  Created by Claude on 10/31/25.
//

import SwiftUI

struct AppGroupsEmptyState: View {
    let onCreateGroup: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // Icon
                Text("🛡️")
                    .font(.system(size: 80))
                    .opacity(0.4)

                // Title
                Text("Create Your First\nApp Group")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Description
                Text("Take control of your digital habits with customizable app groups and mindful pauses")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
                    .padding(.bottom, 24)

                // CTA Button
                Button(action: onCreateGroup) {
                    HStack(spacing: 12) {
                        Text("+")
                            .font(.system(size: 24))
                        Text("Create App Group")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 12, x: 0, y: 8)
                }
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        AnimatedGradientBackground.standard()
        AppGroupsEmptyState(onCreateGroup: {})
    }
}
