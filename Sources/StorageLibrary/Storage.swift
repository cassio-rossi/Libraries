import Foundation

public protocol Storage {
	var userDefaults: UserDefaults { get }
	init(_ storage: String?)
	func save(object: Any, key: String)
	func delete(key: String)
	func get(key: String) -> Any?
}

public class DefaultStorage: Storage {
	public var userDefaults: UserDefaults

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

	public func save(object: Any, key: String) {
		userDefaults.setValue(object, forKey: key)
		userDefaults.synchronize()
	}

	public func delete(key: String) {
		userDefaults.removeObject(forKey: key)
		userDefaults.synchronize()
	}

	public func get(key: String) -> Any? {
		return userDefaults.object(forKey: key)
	}
}
