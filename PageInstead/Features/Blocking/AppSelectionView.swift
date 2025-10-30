import SwiftUI
import FamilyControls

@available(iOS 16.0, *)
struct AppSelectionView: View {
    @ObservedObject var screenTimeService = ScreenTimeService.shared
    @State private var isPickerPresented = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Block Distracting Apps")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Choose apps you want to replace with book recommendations")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Show count of blocked apps
            if screenTimeService.getBlockedAppsCount() > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                    Text("\(screenTimeService.getBlockedAppsCount()) apps blocked")
                        .font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .liquidGlassPill(tintColor: .blue)
            }

            Spacer()

            // Select Apps Button
            Button(action: {
                isPickerPresented = true
            }) {
                Label("Select Apps to Block", systemImage: "plus.app")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .liquidGlassPrimaryButton()
            }
            .padding(.horizontal)

            // Remove All Shields Button
            if screenTimeService.getBlockedAppsCount() > 0 {
                Button(action: {
                    screenTimeService.removeAllShields()
                }) {
                    Label("Remove All Blocks", systemImage: "xmark.shield")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .liquidGlassDestructiveButton()
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $screenTimeService.selectedApps
        )
        .onChange(of: screenTimeService.selectedApps) { newSelection in
            screenTimeService.applyShield(to: newSelection)
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        AppSelectionView()
    }
}
