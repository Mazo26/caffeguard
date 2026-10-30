import Foundation
import Security

/// The Gmail app password, kept in the login keychain rather than in preferences.
enum Keychain {
    private static let item: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.hamzaplojovic.Caffeguard",
        kSecAttrAccount as String: "Gmail app password",
    ]

    static var appPassword: String? {
        get {
            var query = item
            query[kSecReturnData as String] = true
            var result: CFTypeRef?
            guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
                  let data = result as? Data
            else { return nil }
            return String(decoding: data, as: UTF8.self)
        }
        set {
            SecItemDelete(item as CFDictionary)
            guard let newValue, !newValue.isEmpty else { return }
            var attributes = item
            attributes[kSecValueData as String] = Data(newValue.utf8)
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }
}
