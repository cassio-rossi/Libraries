import Foundation

// MARK: - Biometric Methods -

extension SecureStorage {
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
