import Foundation

/// A manager for persisting and restoring HTTP cookies.
///
/// Provides a simple way to save and restore cookies using any ``Storage`` backend.
///
/// ```swift
/// let storage = DefaultStorage("com.myapp.cookies")
/// let cookieManager = Cookies(storage: storage)
/// cookieManager.save(cookies: HTTPCookieStorage.shared.cookies ?? [])
/// ```
///
/// ## Topics
///
/// ### Creating a Cookie Manager
/// - ``init(storage:)``
///
/// ### Managing Cookies
/// - ``save(cookies:)``
/// - ``restore()``
public struct Cookies {
	/// The underlying storage mechanism.
	let storage: Storage

	/// Creates a cookie manager.
	///
	/// - Parameter storage: The ``Storage`` implementation for persisting cookies.
	public init(storage: Storage) {
		self.storage = storage
	}

	/// Saves HTTP cookies to storage.
	///
	/// - Parameter cookies: The cookies to save (empty array clears all cookies).
	///
	/// - Note: Replaces any previously saved cookies.
	public func save(cookies: [HTTPCookie]) {
		var newCookies = [String: AnyObject]()
		for cookie in cookies {
			newCookies[cookie.name] = cookie.properties as AnyObject?
		}
		storage.save(object: newCookies, key: "cookies")
	}

	/// Restores previously saved HTTP cookies.
	///
	/// - Returns: Array of cookies, or empty array if none exist or restoration fails.
	public func restore() -> [HTTPCookie] {
		var newCookies = [HTTPCookie]()

		guard let cookies = storage.get(key: "cookies") as? [String: AnyObject] else {
			return newCookies
		}
		for (_, properties) in cookies {
			guard let prop = properties as? [HTTPCookiePropertyKey: Any],
				  let cookie = HTTPCookie(properties: prop) else { continue }
			newCookies.append(cookie)
		}

		return newCookies
	}
}
