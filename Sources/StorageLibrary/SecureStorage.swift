import Foundation

public enum KeychainError: Error {
	case itemNotFound
	case duplicateItem
	case invalidItemFormat
	case unexpectedStatus(OSStatus)

	case biometricFailed
	case userCancelled
}

public struct SecureStorage {

	// MARK: - Properties -

	let service: String?
	let accessGroup: String?

	// MARK: - Intialization -

	public init(service: String? = nil,
				accessGroup: String? = nil) {
		self.service = service
		self.accessGroup = accessGroup
	}

	// MARK: - Keychain access -

	@discardableResult
	public func read(key: String,
					 type: CFString = kSecClassGenericPassword,
					 synchronizable: Bool,
					 accessible: CFString) throws -> Data {
		var query: [CFString: AnyObject] = [
			kSecAttrAccount: key as AnyObject,
			kSecClass: type,
			kSecMatchLimit: kSecMatchLimitOne,
			kSecReturnData: kCFBooleanTrue,
			kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue : kCFBooleanFalse,
			kSecAttrAccessible: accessible
		]
		if let service = service {
			query[kSecAttrService] = service as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup] = accessGroup as AnyObject
		}

		var itemCopy: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary,
										 &itemCopy)

		switch status {
		case errSecItemNotFound:
			throw KeychainError.itemNotFound
		case errSecSuccess:
			break
		default:
			throw KeychainError.unexpectedStatus(status)
		}

		guard let data = itemCopy as? Data else {
			throw KeychainError.invalidItemFormat
		}

		return data
	}

	public func save(_ data: Data,
					 key: String,
					 type: CFString = kSecClassGenericPassword,
					 synchronizable: Bool,
					 accessible: CFString) throws {
		try? delete(key: key)

		var query: [CFString: AnyObject] = [
			kSecAttrAccount: key as AnyObject,
			kSecClass: type,
			kSecValueData: data as AnyObject,
			kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue : kCFBooleanFalse,
			kSecAttrAccessible: accessible
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
			throw KeychainError.duplicateItem
		case errSecSuccess:
			break
		default:
			throw KeychainError.unexpectedStatus(status)
		}
	}

	public func delete(key: String,
					   type: CFString = kSecClassGenericPassword,
					   synchronizable: Bool,
					   accessible: CFString) throws {
		var query: [CFString: AnyObject] = [
			kSecAttrAccount: key as AnyObject,
			kSecClass: kSecClassGenericPassword,
			kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue : kCFBooleanFalse,
			kSecAttrAccessible: accessible
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

	public func update(_ data: Data,
					   key: String,
					   type: CFString = kSecClassGenericPassword,
					   synchronizable: Bool,
					   accessible: CFString) throws {
		var query: [CFString: AnyObject] = [
			kSecAttrAccount: key as AnyObject,
			kSecClass: type,
			kSecValueData: data as AnyObject,
			kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue : kCFBooleanFalse,
			kSecAttrAccessible: accessible
		]
		if let service = service {
			query[kSecAttrService] = service as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup] = accessGroup as AnyObject
		}

		// Save new
		let status = SecItemUpdate(query as CFDictionary,
								   [kSecValueData: data] as CFDictionary)
		switch status {
		case errSecSuccess:
			break
		default:
			throw KeychainError.unexpectedStatus(status)
		}
	}
}
