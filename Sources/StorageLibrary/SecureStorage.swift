import Foundation

/// Errors that can occur during keychain operations.
///
/// This enum represents all possible error conditions that may arise when interacting with the iOS Keychain
/// through the ``SecureStorage`` API.
public enum KeychainError: Error {
	/// The requested keychain item was not found.
	///
	/// This error is thrown when attempting to read or update a keychain item that doesn't exist.
	case itemNotFound

	/// An item with the same key already exists in the keychain.
	///
	/// This error indicates that the save operation failed because a duplicate item was found.
	/// Use the ``SecureStorage/update(_:key:type:synchronizable:accessible:)`` method to modify existing items,
	/// or delete the existing item first.
	case duplicateItem

	/// The retrieved keychain item has an invalid or unexpected format.
	///
	/// This error occurs when the data retrieved from the keychain cannot be converted to the expected `Data` type.
	case invalidItemFormat

	/// An unexpected keychain operation status was encountered.
	///
	/// This error wraps any OSStatus code that doesn't match the expected success or known failure cases.
	///
	/// - Parameter OSStatus: The underlying system status code returned by the Security framework.
	case unexpectedStatus(OSStatus)

	/// The biometric authentication failed.
	///
	/// This error indicates that the user's biometric authentication (Touch ID or Face ID) was unsuccessful.
	case biometricFailed

	/// The user cancelled the authentication prompt.
	///
	/// This error is thrown when the user explicitly cancels a biometric or password authentication dialog.
	case userCancelled
}

/// A secure storage wrapper for managing sensitive data in the iOS Keychain.
///
/// ``SecureStorage`` provides a type-safe interface for storing, retrieving, updating, and deleting
/// sensitive information using Apple's Keychain Services. The keychain provides a secure way to store
/// small amounts of sensitive data, such as passwords, tokens, and encryption keys.
///
/// ## Overview
///
/// This struct simplifies keychain operations by providing a clean API while supporting advanced features like:
/// - Service-specific storage isolation
/// - Access group sharing between apps
/// - Synchronization across devices via iCloud Keychain
/// - Configurable accessibility levels
///
/// ## Usage
///
/// Create a ``SecureStorage`` instance and use it to store sensitive data:
///
/// ```swift
/// let storage = SecureStorage(service: "com.example.app")
///
/// // Save a password
/// let passwordData = "secretPassword".data(using: .utf8)!
/// try storage.save(
///     passwordData,
///     key: "userPassword",
///     synchronizable: false,
///     accessible: kSecAttrAccessibleWhenUnlocked
/// )
///
/// // Read the password
/// let retrievedData = try storage.read(
///     key: "userPassword",
///     synchronizable: false,
///     accessible: kSecAttrAccessibleWhenUnlocked
/// )
/// let password = String(data: retrievedData, encoding: .utf8)
///
/// // Update the password
/// let newPasswordData = "newPassword".data(using: .utf8)!
/// try storage.update(
///     newPasswordData,
///     key: "userPassword",
///     synchronizable: false,
///     accessible: kSecAttrAccessibleWhenUnlocked
/// )
///
/// // Delete the password
/// try storage.delete(
///     key: "userPassword",
///     synchronizable: false,
///     accessible: kSecAttrAccessibleWhenUnlocked
/// )
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

	/// Creates a new secure storage instance.
	///
	/// The service and access group parameters allow you to organize and share keychain items
	/// across different contexts within your app or between apps.
	///
	/// - Parameters:
	///   - service: An optional service identifier to namespace keychain items. This helps distinguish
	///              items from different parts of your app. If `nil`, items won't be scoped to a service.
	///              Common practice is to use a reverse DNS identifier like "com.example.app.auth".
	///   - accessGroup: An optional access group identifier for sharing keychain items between apps
	///                  with the same team ID. Requires the Keychain Sharing capability to be enabled.
	///                  If `nil`, items are only accessible to the current app.
	///
	/// ## Example
	///
	/// ```swift
	/// // Create storage for a specific service
	/// let authStorage = SecureStorage(service: "com.example.app.auth")
	///
	/// // Create storage shared between apps
	/// let sharedStorage = SecureStorage(
	///     service: "com.example.shared",
	///     accessGroup: "TEAMID.com.example.shared"
	/// )
	/// ```
	public init(service: String? = nil,
				accessGroup: String? = nil) {
		self.service = service
		self.accessGroup = accessGroup
	}

	// MARK: - Keychain access -

	/// Retrieves data from the keychain for the specified key.
	///
	/// This method queries the keychain to retrieve previously stored data. The query parameters
	/// (type, synchronizable, accessible) must match those used when the item was saved.
	///
	/// - Parameters:
	///   - key: The unique identifier for the keychain item. This is stored as the `kSecAttrAccount` attribute.
	///   - type: The keychain item class. Defaults to `kSecClassGenericPassword` for password items.
	///           Other options include `kSecClassInternetPassword`, `kSecClassCertificate`, etc.
	///   - synchronizable: Indicates whether the item should be synchronized via iCloud Keychain.
	///                     Must match the value used when saving the item.
	///   - accessible: Determines when the keychain item is accessible. Common values include:
	///                 - `kSecAttrAccessibleWhenUnlocked`: Item accessible only while device is unlocked
	///                 - `kSecAttrAccessibleAfterFirstUnlock`: Item accessible after first unlock
	///                 - `kSecAttrAccessibleAlways`: Item always accessible (deprecated, less secure)
	///                 Must match the value used when saving the item.
	///
	/// - Returns: The data stored in the keychain for the specified key.
	///
	/// - Throws:
	///   - ``KeychainError/itemNotFound`` if no item exists for the specified key.
	///   - ``KeychainError/invalidItemFormat`` if the retrieved item cannot be converted to `Data`.
	///   - ``KeychainError/unexpectedStatus(_:)`` if an unexpected system error occurs.
	///
	/// ## Example
	///
	/// ```swift
	/// let storage = SecureStorage(service: "com.example.app")
	///
	/// do {
	///     let data = try storage.read(
	///         key: "apiToken",
	///         synchronizable: false,
	///         accessible: kSecAttrAccessibleWhenUnlocked
	///     )
	///     let token = String(data: data, encoding: .utf8)
	///     print("Retrieved token: \(token ?? "")")
	/// } catch KeychainError.itemNotFound {
	///     print("No token found in keychain")
	/// } catch {
	///     print("Failed to read token: \(error)")
	/// }
	/// ```
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

	/// Saves data to the keychain with the specified key.
	///
	/// This method stores sensitive data in the keychain. If an item with the same key already exists,
	/// it will be deleted first to ensure a clean save operation. For updating existing items without
	/// deletion, use ``update(_:key:type:synchronizable:accessible:)`` instead.
	///
	/// - Parameters:
	///   - data: The sensitive data to store in the keychain. This is typically an encoded password,
	///           token, or other sensitive information.
	///   - key: The unique identifier for the keychain item. This is stored as the `kSecAttrAccount` attribute.
	///          Use the same key when reading, updating, or deleting the item.
	///   - type: The keychain item class. Defaults to `kSecClassGenericPassword` for password items.
	///           Other options include `kSecClassInternetPassword`, `kSecClassCertificate`, etc.
	///   - synchronizable: Indicates whether the item should be synchronized via iCloud Keychain.
	///                     Set to `true` to sync across the user's devices, or `false` for local-only storage.
	///   - accessible: Determines when the keychain item is accessible. Common values include:
	///                 - `kSecAttrAccessibleWhenUnlocked`: Item accessible only while device is unlocked (recommended)
	///                 - `kSecAttrAccessibleAfterFirstUnlock`: Item accessible after first unlock
	///                 - `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`: Requires device passcode
	///                 Choose based on your security requirements and when the data needs to be accessible.
	///
	/// - Throws:
	///   - ``KeychainError/duplicateItem`` if an item with the same key exists and couldn't be deleted.
	///   - ``KeychainError/unexpectedStatus(_:)`` if an unexpected system error occurs.
	///
	/// ## Example
	///
	/// ```swift
	/// let storage = SecureStorage(service: "com.example.app")
	/// let credentials = "username:password".data(using: .utf8)!
	///
	/// do {
	///     try storage.save(
	///         credentials,
	///         key: "userCredentials",
	///         synchronizable: true,
	///         accessible: kSecAttrAccessibleWhenUnlocked
	///     )
	///     print("Credentials saved successfully")
	/// } catch {
	///     print("Failed to save credentials: \(error)")
	/// }
	/// ```
	///
	/// - Note: This method automatically attempts to delete any existing item with the same key
	///         before saving. This ensures that stale data doesn't persist.
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

	/// Deletes a keychain item with the specified key.
	///
	/// This method permanently removes an item from the keychain. The query parameters
	/// (type, synchronizable, accessible) must match those used when the item was saved.
	///
	/// - Parameters:
	///   - key: The unique identifier for the keychain item to delete. This is the `kSecAttrAccount` attribute.
	///   - type: The keychain item class. Defaults to `kSecClassGenericPassword` for password items.
	///           Must match the type used when saving the item.
	///   - synchronizable: Indicates whether the item is synchronized via iCloud Keychain.
	///                     Must match the value used when saving the item.
	///   - accessible: Determines when the keychain item is accessible. Common values include:
	///                 - `kSecAttrAccessibleWhenUnlocked`: Item accessible only while device is unlocked
	///                 - `kSecAttrAccessibleAfterFirstUnlock`: Item accessible after first unlock
	///                 Must match the value used when saving the item.
	///
	/// - Throws:
	///   - ``KeychainError/unexpectedStatus(_:)`` if the deletion fails or the item doesn't exist.
	///
	/// ## Example
	///
	/// ```swift
	/// let storage = SecureStorage(service: "com.example.app")
	///
	/// do {
	///     try storage.delete(
	///         key: "sessionToken",
	///         synchronizable: false,
	///         accessible: kSecAttrAccessibleWhenUnlocked
	///     )
	///     print("Session token deleted successfully")
	/// } catch {
	///     print("Failed to delete session token: \(error)")
	/// }
	/// ```
	///
	/// - Note: If the item doesn't exist, this method will throw an error. If you want to delete
	///         an item without throwing when it doesn't exist, wrap this call in a try? statement.
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

	/// Updates an existing keychain item with new data.
	///
	/// This method modifies the data of an existing keychain item without deleting and recreating it.
	/// The item must already exist in the keychain; otherwise, the operation will fail. Use
	/// ``save(_:key:type:synchronizable:accessible:)`` to create a new item or replace an existing one.
	///
	/// - Parameters:
	///   - data: The new data to store in the keychain item. This replaces the existing data.
	///   - key: The unique identifier for the keychain item to update. This is the `kSecAttrAccount` attribute.
	///   - type: The keychain item class. Defaults to `kSecClassGenericPassword` for password items.
	///           Must match the type used when the item was originally saved.
	///   - synchronizable: Indicates whether the item is synchronized via iCloud Keychain.
	///                     Must match the value used when the item was originally saved.
	///   - accessible: Determines when the keychain item is accessible. Common values include:
	///                 - `kSecAttrAccessibleWhenUnlocked`: Item accessible only while device is unlocked
	///                 - `kSecAttrAccessibleAfterFirstUnlock`: Item accessible after first unlock
	///                 Must match the value used when the item was originally saved.
	///
	/// - Throws:
	///   - ``KeychainError/unexpectedStatus(_:)`` if the update fails. This can occur if the item
	///     doesn't exist or if the query parameters don't match the existing item.
	///
	/// ## Example
	///
	/// ```swift
	/// let storage = SecureStorage(service: "com.example.app")
	///
	/// // First, save an item
	/// let initialData = "initialToken".data(using: .utf8)!
	/// try storage.save(
	///     initialData,
	///     key: "authToken",
	///     synchronizable: false,
	///     accessible: kSecAttrAccessibleWhenUnlocked
	/// )
	///
	/// // Later, update it with new data
	/// let updatedData = "refreshedToken".data(using: .utf8)!
	/// do {
	///     try storage.update(
	///         updatedData,
	///         key: "authToken",
	///         synchronizable: false,
	///         accessible: kSecAttrAccessibleWhenUnlocked
	///     )
	///     print("Token updated successfully")
	/// } catch {
	///     print("Failed to update token: \(error)")
	/// }
	/// ```
	///
	/// - Note: All query parameters (type, synchronizable, accessible) must exactly match those used
	///         when the item was originally saved, or the update will fail.
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
