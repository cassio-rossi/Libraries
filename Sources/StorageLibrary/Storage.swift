import Foundation

/// A protocol for simple key-value storage operations.
///
/// Use ``DefaultStorage`` for a UserDefaults-based implementation,
/// or conform to this protocol for custom storage backends.
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
	/// The underlying UserDefaults instance.
	var userDefaults: UserDefaults { get }

	/// Creates a storage instance.
	/// - Parameter storage: Optional suite name for UserDefaults, or `nil` for standard UserDefaults.
	init(_ storage: String?)

	/// Saves an object to storage.
	/// - Parameters:
	///   - object: The object to save (must be a property list type).
	///   - key: The key for the object.
	func save(object: Any, key: String)

	/// Deletes an object from storage.
	/// - Parameter key: The key of the object to delete.
	func delete(key: String)

	/// Retrieves an object from storage.
	/// - Parameter key: The key of the object to retrieve.
	/// - Returns: The stored object, or `nil` if not found.
	func get(key: String) -> Any?
}

/// A UserDefaults-based storage implementation.
///
/// Provides a simple wrapper around ``UserDefaults`` with automatic synchronization.
///
/// ```swift
/// let storage = DefaultStorage(nil)
/// storage.save(object: "John Doe", key: "userName")
/// ```
public class DefaultStorage: Storage {
	/// The underlying UserDefaults instance.
	public var userDefaults: UserDefaults

	/// Creates a storage instance.
	///
	/// - Parameter storage: Optional suite name for UserDefaults, or `nil` for standard UserDefaults.
	///
	/// - Note: When a suite name is provided, the persistent domain is cleared on initialization.
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

	/// Saves an object to UserDefaults.
	///
	/// - Parameters:
	///   - object: The object to save (must be a property list type).
	///   - key: The key for the object.
	public func save(object: Any, key: String) {
		userDefaults.setValue(object, forKey: key)
		userDefaults.synchronize()
	}

	/// Deletes an object from UserDefaults.
	///
	/// - Parameter key: The key of the object to delete.
	public func delete(key: String) {
		userDefaults.removeObject(forKey: key)
		userDefaults.synchronize()
	}

	/// Retrieves an object from UserDefaults.
	///
	/// - Parameter key: The key of the object to retrieve.
	/// - Returns: The stored object, or `nil` if not found.
	public func get(key: String) -> Any? {
		return userDefaults.object(forKey: key)
	}
}
