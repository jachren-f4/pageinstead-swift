import Foundation
import Security

/// Helper class for securely storing sensitive data in the Keychain
class KeychainHelper {
    static let shared = KeychainHelper()

    private let service = "com.joakimachren.PageInstead.passcode"

    private init() {}

    // MARK: - Passcode Storage

    /// Save passcode hash to Keychain
    func savePasscode(hash: String) -> Bool {
        guard let data = hash.data(using: .utf8) else { return false }

        // Delete existing passcode first
        _ = deletePasscode()

        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "userPasscode",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Add to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve passcode hash from Keychain
    func getPasscode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "userPasscode",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let hash = String(data: data, encoding: .utf8) else {
            return nil
        }

        return hash
    }

    /// Delete passcode from Keychain
    func deletePasscode() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "userPasscode"
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Check if passcode exists in Keychain
    func hasPasscode() -> Bool {
        return getPasscode() != nil
    }
}
