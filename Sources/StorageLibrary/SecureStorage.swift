import Foundation

/// Errors that can occur during keychain operations.
public enum KeychainError: Error {
	/// The requested keychain item was not found.
	case itemNotFound

	/// An item with the same key already exists.
	case duplicateItem

	/// The retrieved keychain item has an invalid format.
	case invalidItemFormat

	/// An unexpected keychain operation status.
	///
	/// - Parameter OSStatus: The underlying system status code.
	case unexpectedStatus(OSStatus)

	/// Biometric authentication failed.
	case biometricFailed

	/// The user cancelled the authentication prompt.
	case userCancelled
}

/// A secure wrapper for managing sensitive data in the keychain.
///
/// Provides a type-safe interface for keychain operations with support for service-specific storage, access group sharing, iCloud synchronization, and configurable accessibility.
///
/// ```swift
/// let storage = SecureStorage(service: "com.example.app")
/// let data = "secret".data(using: .utf8)!
/// try storage.save(data, key: "password", synchronizable: false, accessible: kSecAttrAccessibleWhenUnlocked)
/// ```
///
/// ## Topics
///
/// ### Creating a Secure Storage Instance
/// - ``init(service:accessGroup:)``
///
/// ### Managing Keychain Items
/// - ``read(key:type:synchronizable:accessible:)``
/// - ``save(_:key:type:synchronizable:accessible:)``
/// - ``update(_:key:type:synchronizable:accessible:)``
/// - ``delete(key:type:synchronizable:accessible:)``
///
/// ### Error Handling
/// - ``KeychainError``
public struct SecureStorage {

	// MARK: - Properties -

	let service: String?
	let accessGroup: String?

	// MARK: - Intialization -

	/// Creates a secure storage instance.
	///
	/// - Parameters:
	///   - service: Optional service identifier to namespace keychain items.
	///   - accessGroup: Optional access group identifier for sharing keychain items between apps.
	public init(service: String? = nil,
				accessGroup: String? = nil) {
		self.service = service
		self.accessGroup = accessGroup
	}

	// MARK: - Keychain access -

	/// Retrieves data from the keychain.
	///
	/// - Parameters:
	///   - key: The unique identifier for the keychain item.
	///   - type: The keychain item class (defaults to `kSecClassGenericPassword`).
	///   - synchronizable: Whether the item is synchronized via iCloud Keychain.
	///   - accessible: When the keychain item is accessible.
	///
	/// - Returns: The stored data.
	///
	/// - Throws: ``KeychainError`` if the operation fails.
	///
	/// - Note: Query parameters must match those used when saving the item.
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

	/// Saves data to the keychain.
	///
	/// - Parameters:
	///   - data: The sensitive data to store.
	///   - key: The unique identifier for the keychain item.
	///   - type: The keychain item class (defaults to `kSecClassGenericPassword`).
	///   - synchronizable: Whether the item should be synchronized via iCloud Keychain.
	///   - accessible: When the keychain item is accessible.
	///
	/// - Throws: ``KeychainError`` if the operation fails.
	///
	/// - Note: Existing items with the same key are automatically deleted before saving.
	public func save(_ data: Data,
					 key: String,
					 type: CFString = kSecClassGenericPassword,
					 synchronizable: Bool,
					 accessible: CFString) throws {
		try? delete(key: key, type: type, synchronizable: synchronizable, accessible: accessible)

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

	/// Deletes a keychain item.
	///
	/// - Parameters:
	///   - key: The unique identifier for the keychain item.
	///   - type: The keychain item class (defaults to `kSecClassGenericPassword`).
	///   - synchronizable: Whether the item is synchronized via iCloud Keychain.
	///   - accessible: When the keychain item is accessible.
	///
	/// - Throws: ``KeychainError`` if the operation fails.
	///
	/// - Note: Query parameters must match those used when saving the item.
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

	/// Updates an existing keychain item.
	///
	/// - Parameters:
	///   - data: The new data to store.
	///   - key: The unique identifier for the keychain item.
	///   - type: The keychain item class (defaults to `kSecClassGenericPassword`).
	///   - synchronizable: Whether the item is synchronized via iCloud Keychain.
	///   - accessible: When the keychain item is accessible.
	///
	/// - Throws: ``KeychainError`` if the operation fails.
	///
	/// - Note: Query parameters must match those used when saving the item.
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
