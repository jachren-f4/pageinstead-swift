import SwiftUI

/// View for entering a passcode to unlock settings
struct PasscodeEntryView: View {
    @Binding var isPresented: Bool
    let onSuccess: () -> Void

    @State private var passcode: String = ""
    @State private var showError: Bool = false
    @State private var attemptCount: Int = 0

    private let maxLength = 4
    private let manager = SelfRestrictionManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            AnimatedGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 40)

                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)

                    Text("Enter Passcode")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Enter your passcode to access settings")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Passcode dots
                HStack(spacing: 20) {
                    ForEach(0..<maxLength, id: \.self) { index in
                        PasscodeDot(isFilled: index < passcode.count, showError: showError)
                    }
                }
                .padding(.vertical, 16)

                // Error message (fixed height to prevent layout shift)
                Group {
                    if showError {
                        Text("Incorrect passcode. Try again.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    } else {
                        Text(" ")
                            .font(.subheadline)
                            .foregroundColor(.clear)
                    }
                }
                .frame(height: 20)

                Spacer()
                    .frame(height: 20)

                // Number pad
                VStack(spacing: 20) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 20) {
                            ForEach(1..<4) { col in
                                let number = row * 3 + col
                                PasscodeButton(text: "\(number)") {
                                    addDigit(number)
                                }
                            }
                        }
                    }

                    // Bottom row: Cancel, 0, Delete
                    HStack(spacing: 20) {
                        PasscodeButton(text: "", systemImage: "xmark") {
                            isPresented = false
                        }

                        PasscodeButton(text: "0") {
                            addDigit(0)
                        }

                        PasscodeButton(text: "", systemImage: "delete.left") {
                            removeDigit()
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .offset(x: showError ? -10 : 0)
        .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: showError)
    }

    private func addDigit(_ digit: Int) {
        guard passcode.count < maxLength else { return }

        passcode += "\(digit)"
        showError = false

        if passcode.count == maxLength {
            verifyPasscode()
        }
    }

    private func removeDigit() {
        guard !passcode.isEmpty else { return }
        passcode.removeLast()
        showError = false
    }

    private func verifyPasscode() {
        #if targetEnvironment(simulator)
        // Bypass with "0000" in simulator
        if passcode == "0000" {
            onSuccess()
            isPresented = false
            return
        }
        #endif

        if manager.verifyPasscode(passcode) {
            onSuccess()
            isPresented = false
        } else {
            showError = true
            attemptCount += 1
            passcode = ""
        }
    }
}

// MARK: - Passcode Dot
struct PasscodeDot: View {
    let isFilled: Bool
    let showError: Bool

    var body: some View {
        Circle()
            .fill(isFilled ? Color.white : Color.clear)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(showError ? Color.red : Color.white, lineWidth: 2)
            )
    }
}

// MARK: - Passcode Button
struct PasscodeButton: View {
    let text: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 80)

                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Text(text)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PasscodeEntryView(isPresented: .constant(true)) {
        print("Success")
    }
}
