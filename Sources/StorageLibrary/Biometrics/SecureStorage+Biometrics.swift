import Foundation

// MARK: - Biometric Methods

/// Extension providing biometric-protected cryptographic key storage operations.
///
/// This extension adds methods to ``SecureStorage`` for storing and retrieving cryptographic keys
/// with biometric authentication (Face ID or Touch ID). Keys are stored in the keychain and can only
/// be accessed after successful biometric authentication.
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
    /// Retrieves a biometric-protected cryptographic key from the keychain.
    ///
    /// This method fetches a previously stored cryptographic key that is protected by biometric
    /// authentication. The user must authenticate using Face ID or Touch ID before the key can be retrieved.
    ///
    /// The method uses the Security framework to query the keychain for a key stored with the specified
    /// identifier, requiring biometric authentication to access it. The retrieved key is converted from
    /// its X9.63 representation back into the requested ``SecKeyConvertible`` type.
    ///
    /// - Parameters:
    ///   - key: The unique identifier for the stored key. This should match the identifier used when
    ///     saving the key with ``save(biometric:key:accessControl:)``.
    ///   - authenticationContext: An authentication context (typically `LAContext`) that manages the
    ///     biometric authentication session. This should be configured before calling this method.
    ///   - accessControl: The access control flags that determine when biometric authentication is required.
    ///     Defaults to `.userPresence`, which requires biometric or passcode authentication.
    ///
    /// - Returns: The cryptographic key of type `S` conforming to ``SecKeyConvertible``.
    ///
    /// - Throws:
    ///   - ``KeychainError/biometricFailed``: If the access control creation fails or the key cannot be
    ///     converted from its external representation.
    ///   - ``KeychainError/itemNotFound``: If no key exists with the specified identifier.
    ///   - ``KeychainError/userCancelled``: If the user cancels the biometric authentication prompt.
    ///   - ``KeychainError/unexpectedStatus(_:)``: If an unexpected keychain error occurs.
    ///
    /// - Discardable Result: The result can be discarded if you only need to verify that the key exists
    ///   and the user can authenticate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// import LocalAuthentication
    /// import CryptoKit
    ///
    /// let storage = SecureStorage(service: "com.example.app")
    /// let context = LAContext()
    /// context.localizedReason = "Authenticate to access your signing key"
    ///
    /// do {
    ///     let privateKey: P256.Signing.PrivateKey = try storage.read(
    ///         key: "userSigningKey",
    ///         authenticationContext: context
    ///     )
    ///     // Use the private key for signing operations
    /// } catch KeychainError.userCancelled {
    ///     print("User cancelled authentication")
    /// } catch {
    ///     print("Failed to retrieve key: \(error)")
    /// }
    /// ```
    ///
    /// - Important: The authentication context must be properly configured before calling this method.
    ///   The biometric prompt will be displayed to the user during the keychain access operation.
    ///
    /// - Note: This method only works on devices with a passcode set, as indicated by the
    ///   `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` accessibility attribute.
    ///
    /// - SeeAlso:
    ///   - ``save(biometric:key:accessControl:)``
    ///   - ``delete(key:accessControl:)``
    ///   - ``SecKeyConvertible``
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

    /// Stores a cryptographic key in the keychain with biometric authentication protection.
    ///
    /// This method saves a cryptographic key to the keychain, protecting it with biometric authentication.
    /// The key can only be retrieved later by providing valid biometric authentication (Face ID or Touch ID).
    ///
    /// The key is converted to its X9.63 representation and stored as a `SecKey` in the keychain with
    /// the specified access control flags. If a key with the same identifier already exists, it will be updated.
    ///
    /// - Parameters:
    ///   - data: The cryptographic key conforming to ``SecKeyConvertible`` to store. This is typically
    ///     a CryptoKit private key such as `P256.Signing.PrivateKey` or `P256.KeyAgreement.PrivateKey`.
    ///   - key: A unique identifier for this key. Use this same identifier when retrieving the key
    ///     with ``read(key:authenticationContext:accessControl:)``.
    ///   - accessControl: The access control flags that determine when biometric authentication is required.
    ///     Defaults to `.userPresence`, which requires biometric or passcode authentication.
    ///
    /// - Throws:
    ///   - ``KeychainError/biometricFailed``: If the access control creation fails or the key cannot be
    ///     converted to a `SecKey`.
    ///   - ``KeychainError/unexpectedStatus(_:)``: If an unexpected keychain error occurs during save or update.
    ///
    /// ## Example
    ///
    /// ```swift
    /// import CryptoKit
    ///
    /// let storage = SecureStorage(service: "com.example.app")
    /// let privateKey = P256.Signing.PrivateKey()
    ///
    /// do {
    ///     try storage.save(
    ///         biometric: privateKey,
    ///         key: "userSigningKey",
    ///         accessControl: .biometryCurrentSet
    ///     )
    ///     print("Key saved successfully")
    /// } catch {
    ///     print("Failed to save key: \(error)")
    /// }
    /// ```
    ///
    /// ## Access Control Options
    ///
    /// Common `SecAccessControlCreateFlags` values include:
    /// - `.userPresence`: Requires biometric or passcode authentication
    /// - `.biometryCurrentSet`: Requires biometric authentication with the current enrolled biometrics
    /// - `.biometryAny`: Allows any biometric authentication
    ///
    /// - Important: This method requires a device with a passcode set, as indicated by the
    ///   `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` accessibility attribute.
    ///
    /// - Note: If a key with the same identifier already exists, it will be automatically updated
    ///   with the new key data.
    ///
    /// - SeeAlso:
    ///   - ``read(key:authenticationContext:accessControl:)``
    ///   - ``delete(key:accessControl:)``
    ///   - ``SecKeyConvertible``
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

    /// Deletes a biometric-protected cryptographic key from the keychain.
    ///
    /// This method removes a previously stored cryptographic key from the keychain. The key must have
    /// been stored with biometric authentication protection using ``save(biometric:key:accessControl:)``.
    ///
    /// - Parameters:
    ///   - key: The unique identifier of the key to delete. This should match the identifier used when
    ///     the key was saved.
    ///   - accessControl: The access control flags used when the key was saved. This must match the
    ///     access control flags specified during save. Defaults to `.userPresence`.
    ///
    /// - Throws:
    ///   - ``KeychainError/biometricFailed``: If the access control creation fails.
    ///   - ``KeychainError/unexpectedStatus(_:)``: If the deletion fails or an unexpected keychain error occurs.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let storage = SecureStorage(service: "com.example.app")
    ///
    /// do {
    ///     try storage.delete(key: "userSigningKey")
    ///     print("Key deleted successfully")
    /// } catch {
    ///     print("Failed to delete key: \(error)")
    /// }
    /// ```
    ///
    /// - Important: The access control flags specified must match those used when saving the key.
    ///   If they don't match, the deletion may fail.
    ///
    /// - Note: If the specified key does not exist, this method will throw a
    ///   ``KeychainError/unexpectedStatus(_:)`` error with status `errSecItemNotFound`.
    ///
    /// - SeeAlso:
    ///   - ``save(biometric:key:accessControl:)``
    ///   - ``read(key:authenticationContext:accessControl:)``
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
