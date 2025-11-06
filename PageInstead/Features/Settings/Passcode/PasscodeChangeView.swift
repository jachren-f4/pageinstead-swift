import SwiftUI

/// View for changing an existing passcode
struct PasscodeChangeView: View {
    @Binding var isPresented: Bool

    @State private var currentPasscode: String = ""
    @State private var newPasscode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var step: ChangeStep = .enterCurrent
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let maxLength = 4
    private let manager = SelfRestrictionManager.shared

    enum ChangeStep {
        case enterCurrent
        case enterNew
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
                    Image(systemName: iconForStep)
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text(titleForStep)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(subtitleForStep)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                // Passcode dots
                HStack(spacing: 20) {
                    ForEach(0..<maxLength, id: \.self) { index in
                        PasscodeDot(isFilled: index < currentInput.count, showError: showError)
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

    private var iconForStep: String {
        switch step {
        case .enterCurrent:
            return "lock.fill"
        case .enterNew:
            return "lock.open.fill"
        case .confirm:
            return "checkmark.shield.fill"
        }
    }

    private var titleForStep: String {
        switch step {
        case .enterCurrent:
            return "Enter Current Passcode"
        case .enterNew:
            return "Enter New Passcode"
        case .confirm:
            return "Confirm New Passcode"
        }
    }

    private var subtitleForStep: String {
        switch step {
        case .enterCurrent:
            return "Enter your current passcode to continue"
        case .enterNew:
            return "Enter your new 4-digit passcode"
        case .confirm:
            return "Enter your new passcode again"
        }
    }

    private var currentInput: String {
        switch step {
        case .enterCurrent:
            return currentPasscode
        case .enterNew:
            return newPasscode
        case .confirm:
            return confirmPasscode
        }
    }

    private func addDigit(_ digit: Int) {
        switch step {
        case .enterCurrent:
            guard currentPasscode.count < maxLength else { return }
            currentPasscode += "\(digit)"
            showError = false
            if currentPasscode.count == maxLength {
                verifyCurrentPasscode()
            }

        case .enterNew:
            guard newPasscode.count < maxLength else { return }
            newPasscode += "\(digit)"
            showError = false
            if newPasscode.count == maxLength {
                step = .confirm
            }

        case .confirm:
            guard confirmPasscode.count < maxLength else { return }
            confirmPasscode += "\(digit)"
            showError = false
            if confirmPasscode.count == maxLength {
                verifyAndSave()
            }
        }
    }

    private func removeDigit() {
        showError = false

        switch step {
        case .enterCurrent:
            guard !currentPasscode.isEmpty else { return }
            currentPasscode.removeLast()

        case .enterNew:
            guard !newPasscode.isEmpty else { return }
            newPasscode.removeLast()

        case .confirm:
            guard !confirmPasscode.isEmpty else { return }
            confirmPasscode.removeLast()
        }
    }

    private func verifyCurrentPasscode() {
        #if targetEnvironment(simulator)
        // Bypass with "0000" in simulator
        if currentPasscode == "0000" {
            step = .enterNew
            return
        }
        #endif

        if manager.verifyPasscode(currentPasscode) {
            step = .enterNew
        } else {
            showError = true
            errorMessage = "Incorrect passcode"
            currentPasscode = ""
        }
    }

    private func verifyAndSave() {
        if newPasscode == confirmPasscode {
            // Save new passcode
            if manager.setPasscode(newPasscode) {
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
    PasscodeChangeView(isPresented: .constant(true))
}
