import SwiftUI
import FamilyControls

@available(iOS 16.0, *)
struct AppSelectionView: View {
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @State private var isPickerPresented = false

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground.standard()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Block Apps")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Choose apps to replace with book quotes")
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)

                    // Blocked apps count card
                    if screenTimeService.getBlockedAppsCount() > 0 {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "6CC8FF"))

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(screenTimeService.getBlockedAppsCount())")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("apps blocked")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(24)
                            .background(Color.white.opacity(0.06))
                            .background(.ultraThinMaterial)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(hex: "6CC8FF").opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Info card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "6CC8FF").opacity(0.8))

                            Text("How it works")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(number: "1", text: "Select apps you want to block")
                            InfoRow(number: "2", text: "Try to open a blocked app")
                            InfoRow(number: "3", text: "Get a thought-provoking book quote instead")
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.04))
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 40)

                    // Action buttons
                    VStack(spacing: 16) {
                        // Select Apps Button
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.app.fill")
                                    .font(.system(size: 18))
                                Text("Select Apps to Block")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "6CC8FF"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                        }
                        .background(Color(hex: "6CC8FF").opacity(0.2))
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "6CC8FF").opacity(0.4), lineWidth: 1)
                        )

                        // Remove All Blocks Button
                        if screenTimeService.getBlockedAppsCount() > 0 {
                            Button(action: {
                                screenTimeService.removeAllShields()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Remove All Blocks")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.red.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                            }
                            .background(Color.red.opacity(0.15))
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 80)
                }
            }
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $screenTimeService.selectedApps
        )
        .onChange(of: screenTimeService.selectedApps) { newSelection in
            screenTimeService.applyShield(to: newSelection)
        }
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "6CC8FF"))
                .frame(width: 24, height: 24)
                .background(Color(hex: "6CC8FF").opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        AppSelectionView()
    }
}
