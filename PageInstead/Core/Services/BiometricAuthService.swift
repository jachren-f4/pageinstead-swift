import Foundation
import LocalAuthentication

/// Service for handling biometric authentication (Face ID / Touch ID)
class BiometricAuthService {
    static let shared = BiometricAuthService()

    private init() {}

    // MARK: - Biometric Availability

    /// Check if biometric authentication is available on this device
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Get the type of biometric authentication available
    func biometricType() -> BiometricType {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    // MARK: - Authentication

    /// Authenticate user with biometrics
    /// - Parameter reason: The reason to display in the authentication prompt
    /// - Returns: True if authentication succeeded, false otherwise
    func authenticate(reason: String = "Authenticate to access settings") async -> Bool {
        #if targetEnvironment(simulator)
        // Auto-succeed in simulator for testing
        print("⚠️ Biometric authentication bypassed in simulator")
        return true
        #endif

        let context = LAContext()
        context.localizedCancelTitle = "Use Passcode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .userFallback, .systemCancel:
                print("Biometric authentication cancelled")
            case .biometryNotAvailable:
                print("Biometry not available")
            case .biometryNotEnrolled:
                print("Biometry not enrolled")
            case .biometryLockout:
                print("Biometry locked out")
            default:
                print("Biometric authentication error: \(error.localizedDescription)")
            }
            return false
        } catch {
            print("Unexpected error during biometric authentication: \(error)")
            return false
        }
    }
}

// MARK: - Biometric Type Enum

enum BiometricType {
    case none
    case faceID
    case touchID

    var name: String {
        switch self {
        case .none:
            return "None"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "exclamationmark.triangle"
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        }
    }
}
