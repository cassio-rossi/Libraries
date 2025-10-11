import Foundation

// MARK: - Biometric Methods

/// Extension for biometric-protected cryptographic key storage.
///
/// Adds methods to ``SecureStorage`` for storing and retrieving keys with Face ID or Touch ID authentication.
///
/// ## Topics
///
/// ### Reading Biometric-Protected Keys
/// - ``read(key:authenticationContext:accessControl:)``
///
/// ### Saving Biometric-Protected Keys
/// - ``save(biometric:key:accessControl:)``
///
/// ### Deleting Biometric-Protected Keys
/// - ``delete(key:accessControl:)``
extension SecureStorage {
    /// Retrieves a biometric-protected key from the keychain.
    ///
    /// - Parameters:
    ///   - key: The unique identifier for the stored key.
    ///   - authenticationContext: The authentication context (typically `LAContext`).
    ///   - accessControl: Access control flags (defaults to `.userPresence`).
    ///
    /// - Returns: The cryptographic key.
    ///
    /// - Throws: ``KeychainError`` if the operation fails or user cancels authentication.
    ///
    /// - Note: Requires a device with a passcode set.
    @discardableResult
    public func read<S: SecKeyConvertible>(key: String,
                                           authenticationContext: AnyObject,
                                           accessControl: SecAccessControlCreateFlags = .userPresence) throws -> S {
        guard let accessControl = SecAccessControlCreateWithFlags(nil,
                                                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                  accessControl,
                                                                  nil) else {
            throw KeychainError.biometricFailed
        }

        var query: [CFString: AnyObject] = [
            kSecAttrApplicationLabel: key as AnyObject,
            kSecClass: kSecClassKey,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnRef: kCFBooleanTrue,
            kSecAttrAccessControl: accessControl,
            kSecAttrSynchronizable: kCFBooleanFalse,
            kSecUseDataProtectionKeychain: kCFBooleanTrue,
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecUseAuthenticationContext: authenticationContext
        ]
		if let service = service {
			query[kSecAttrService] = service as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup] = accessGroup as AnyObject
		}

        var secureKey: SecKey
        var itemCopy: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        switch status {
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        case errSecSuccess:
			// swiftlint:disable:next force_cast
            secureKey = itemCopy as! SecKey
        case errSecUserCanceled:
            throw KeychainError.userCancelled
        default:
            throw KeychainError.unexpectedStatus(status)
        }

        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secureKey, &error) as Data? else {
            throw KeychainError.biometricFailed
        }
        return try S(x963Representation: data)
    }

    /// Stores a cryptographic key with biometric protection.
    ///
    /// - Parameters:
    ///   - data: The cryptographic key conforming to ``SecKeyConvertible``.
    ///   - key: Unique identifier for the key.
    ///   - accessControl: Access control flags (defaults to `.userPresence`).
    ///
    /// - Throws: ``KeychainError`` if the operation fails.
    ///
    /// - Note: Existing keys with the same identifier are automatically updated.
    public func save<S: SecKeyConvertible>(biometric data: S,
                                           key: String,
                                           accessControl: SecAccessControlCreateFlags = .userPresence) throws {
        // Describe the key.
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                         kSecAttrKeyClass: kSecAttrKeyClassPrivate] as [String: Any]

        guard let accessControl = SecAccessControlCreateWithFlags(nil,
                                                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                  accessControl,
                                                                  nil),
              let secureKey = SecKeyCreateWithData(data.x963Representation as CFData,
                                                attributes as CFDictionary,
                                                nil) else {
            throw KeychainError.biometricFailed
        }

        var query: [CFString: AnyObject] = [
            kSecAttrApplicationLabel: key as AnyObject,
            kSecClass: kSecClassKey,
            kSecValueRef: secureKey as AnyObject,
            kSecAttrAccessControl: accessControl,
            kSecUseDataProtectionKeychain: kCFBooleanTrue,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
		if let service = service {
			query[kSecAttrService] = service as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup] = accessGroup as AnyObject
		}

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecDuplicateItem:
            let status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
            if status != errSecSuccess {
                throw KeychainError.unexpectedStatus(status)
            }
        case errSecSuccess:
            break
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Deletes a biometric-protected key from the keychain.
    ///
    /// - Parameters:
    ///   - key: The unique identifier of the key to delete.
    ///   - accessControl: Access control flags (must match those used when saving).
    ///
    /// - Throws: ``KeychainError`` if the operation fails.
    public func delete(key: String,
                       accessControl: SecAccessControlCreateFlags = .userPresence) throws {
        guard let accessControl = SecAccessControlCreateWithFlags(nil,
                                                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                  accessControl,
                                                                  nil) else {
            throw KeychainError.biometricFailed
        }

        var query: [CFString: AnyObject] = [
            kSecAttrApplicationLabel: key as AnyObject,
            kSecClass: kSecClassKey,
            kSecUseDataProtectionKeychain: kCFBooleanTrue,
            kSecAttrAccessControl: accessControl,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
		if let service = service {
			query[kSecAttrService] = service as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup] = accessGroup as AnyObject
		}

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
