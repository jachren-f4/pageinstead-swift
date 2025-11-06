import Foundation
import CryptoKit

/// Utility class for hashing and verifying passcodes securely
class PasscodeHasher {
    static let shared = PasscodeHasher()

    private init() {}

    /// Hash a passcode with a random salt using SHA-256
    /// - Parameter passcode: The plain text passcode
    /// - Returns: A string in format "salt:hash"
    func hash(passcode: String) -> String {
        let salt = generateSalt()
        let saltedPasscode = passcode + salt
        let hash = SHA256.hash(data: Data(saltedPasscode.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        return "\(salt):\(hashString)"
    }

    /// Verify a passcode against a stored hash
    /// - Parameters:
    ///   - passcode: The plain text passcode to verify
    ///   - storedHash: The stored hash in format "salt:hash"
    /// - Returns: True if passcode matches, false otherwise
    func verify(passcode: String, storedHash: String) -> Bool {
        let components = storedHash.split(separator: ":").map(String.init)
        guard components.count == 2 else { return false }

        let salt = components[0]
        let originalHash = components[1]

        let saltedPasscode = passcode + salt
        let hash = SHA256.hash(data: Data(saltedPasscode.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()

        return hashString == originalHash
    }

    // MARK: - Private Helpers

    private func generateSalt() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<16).map { _ in letters.randomElement()! })
    }
}
