import SwiftUI

/// View for creating a new passcode
struct PasscodeSetupView: View {
    @Binding var isPresented: Bool

    @State private var passcode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var step: SetupStep = .enter
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let maxLength = 4
    private let manager = SelfRestrictionManager.shared

    enum SetupStep {
        case enter
        case confirm
    }

    var body: some View {
        ZStack {
            // Background gradient
            AnimatedGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Header
                VStack(spacing: 16) {
                    Image(systemName: step == .enter ? "lock.fill" : "checkmark.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text(step == .enter ? "Create Passcode" : "Confirm Passcode")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(step == .enter ? "Enter a 4-digit passcode" : "Enter your passcode again")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                // Passcode dots
                HStack(spacing: 20) {
                    ForEach(0..<maxLength, id: \.self) { index in
                        PasscodeDot(isFilled: index < currentPasscode.count, showError: showError)
                    }
                }
                .padding(.vertical, 20)

                // Error message
                if showError {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                // Passcode strength indicator (only on first step)
                if step == .enter && !passcode.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Rectangle()
                                .fill(strengthColor(index: index))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(width: 120)

                    Text(strengthText)
                        .font(.caption)
                        .foregroundColor(strengthColor(index: 2))
                }

                Spacer()

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

    private var currentPasscode: String {
        step == .enter ? passcode : confirmPasscode
    }

    private var strengthText: String {
        let uniqueDigits = Set(passcode).count
        if uniqueDigits <= 2 {
            return "Weak"
        } else if uniqueDigits <= 4 {
            return "Medium"
        } else {
            return "Strong"
        }
    }

    private func strengthColor(index: Int) -> Color {
        let uniqueDigits = Set(passcode).count
        let strength = uniqueDigits <= 2 ? 1 : (uniqueDigits <= 4 ? 2 : 3)

        if index < strength {
            switch strength {
            case 1: return .red
            case 2: return .orange
            default: return .green
            }
        }
        return Color.white.opacity(0.2)
    }

    private func addDigit(_ digit: Int) {
        if step == .enter {
            guard passcode.count < maxLength else { return }
            passcode += "\(digit)"
            showError = false

            if passcode.count == maxLength {
                // Move to confirm step
                step = .confirm
            }
        } else {
            guard confirmPasscode.count < maxLength else { return }
            confirmPasscode += "\(digit)"
            showError = false

            if confirmPasscode.count == maxLength {
                verifyAndSave()
            }
        }
    }

    private func removeDigit() {
        if step == .enter {
            guard !passcode.isEmpty else { return }
            passcode.removeLast()
        } else {
            guard !confirmPasscode.isEmpty else { return }
            confirmPasscode.removeLast()
        }
        showError = false
    }

    private func verifyAndSave() {
        if passcode == confirmPasscode {
            // Save passcode
            if manager.setPasscode(passcode) {
                manager.settings.isPasscodeLockEnabled = true
                manager.saveSettings()
                isPresented = false
            } else {
                showError = true
                errorMessage = "Failed to save passcode"
                confirmPasscode = ""
            }
        } else {
            showError = true
            errorMessage = "Passcodes don't match"
            confirmPasscode = ""
        }
    }
}

#Preview {
    PasscodeSetupView(isPresented: .constant(true))
}
