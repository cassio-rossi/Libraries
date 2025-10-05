import Foundation

/// A protocol defining the interface for simple key-value storage operations.
///
/// Conform to this protocol to create custom storage implementations or use ``DefaultStorage``
/// for a UserDefaults-based implementation.
///
/// ## Topics
/// ### Instance Properties
/// - ``userDefaults``
///
/// ### Instance Methods
/// - ``save(object:key:)``
/// - ``get(key:)``
/// - ``delete(key:)``
public protocol Storage {
	/// The underlying UserDefaults instance used for storage.
	var userDefaults: UserDefaults { get }

	/// Initializes a new storage instance.
	/// - Parameter storage: An optional suite name for the UserDefaults. Pass `nil` to use the standard UserDefaults.
	init(_ storage: String?)

	/// Saves an object to storage.
	/// - Parameters:
	///   - object: The object to save. Must be a property list type.
	///   - key: The key to associate with the object.
	func save(object: Any, key: String)

	/// Deletes an object from storage.
	/// - Parameter key: The key of the object to delete.
	func delete(key: String)

	/// Retrieves an object from storage.
	/// - Parameter key: The key of the object to retrieve.
	/// - Returns: The stored object, or `nil` if no object exists for the key.
	func get(key: String) -> Any?
}

/// A UserDefaults-based implementation of the ``Storage`` protocol.
///
/// `DefaultStorage` provides a simple wrapper around UserDefaults with automatic synchronization.
///
/// ## Usage
///
/// ```swift
/// // Use standard UserDefaults
/// let storage = DefaultStorage(nil)
/// storage.save(object: "John Doe", key: "userName")
///
/// // Use a custom suite
/// let customStorage = DefaultStorage("com.myapp.settings")
/// customStorage.save(object: true, key: "darkMode")
/// ```
public class DefaultStorage: Storage {
	/// The underlying UserDefaults instance.
	public var userDefaults: UserDefaults

	/// Initializes a new storage instance.
	///
	/// - Parameter storage: An optional suite name for the UserDefaults. Pass `nil` to use the standard UserDefaults.
	///   If a suite name is provided, the persistent domain is cleared on initialization.
	public required init(_ storage: String? = nil) {
		let userDefaults = {
			guard let storage = storage,
				  let newUserDefaults = UserDefaults(suiteName: storage) else {
				return UserDefaults.standard
			}
			newUserDefaults.removePersistentDomain(forName: storage)
			return newUserDefaults
		}()
		self.userDefaults = userDefaults
	}

	/// Saves an object to UserDefaults and synchronizes.
	///
	/// - Parameters:
	///   - object: The object to save. Must be a property list type (String, Number, Date, Data, Array, or Dictionary).
	///   - key: The key to associate with the object.
	public func save(object: Any, key: String) {
		userDefaults.setValue(object, forKey: key)
		userDefaults.synchronize()
	}

	/// Deletes an object from UserDefaults and synchronizes.
	///
	/// - Parameter key: The key of the object to delete.
	public func delete(key: String) {
		userDefaults.removeObject(forKey: key)
		userDefaults.synchronize()
	}

	/// Retrieves an object from UserDefaults.
	///
	/// - Parameter key: The key of the object to retrieve.
	/// - Returns: The stored object, or `nil` if no object exists for the key.
	public func get(key: String) -> Any? {
		return userDefaults.object(forKey: key)
	}
}
