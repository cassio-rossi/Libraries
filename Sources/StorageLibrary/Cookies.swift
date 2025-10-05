import Foundation

/// A manager for persisting and restoring HTTP cookies.
///
/// ``Cookies`` provides a simple way to save and restore `HTTPCookie` objects using any ``Storage``
/// implementation. This is useful for maintaining session state across app launches or for implementing
/// custom cookie management strategies.
///
/// ## Overview
///
/// The cookie manager serializes cookies to a dictionary format and stores them using the provided
/// storage backend. Cookies are identified by their name and can be restored at any time.
///
/// ## Usage
///
/// ```swift
/// // Create a storage backend
/// let storage = DefaultStorage("com.myapp.cookies")
///
/// // Initialize the cookie manager
/// let cookieManager = Cookies(storage: storage)
///
/// // Save cookies from a web session
/// if let cookies = HTTPCookieStorage.shared.cookies {
///     cookieManager.save(cookies: cookies)
/// }
///
/// // Restore cookies later
/// let restoredCookies = cookieManager.restore()
/// for cookie in restoredCookies {
///     HTTPCookieStorage.shared.setCookie(cookie)
/// }
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
	/// The underlying storage mechanism used to persist cookies.
	let storage: Storage

	/// Creates a new cookie manager with the specified storage backend.
	///
	/// - Parameter storage: The ``Storage`` implementation to use for persisting cookies.
	///   Typically a ``DefaultStorage`` instance with a custom suite name.
	///
	/// ## Example
	///
	/// ```swift
	/// let storage = DefaultStorage("com.myapp.cookies")
	/// let cookieManager = Cookies(storage: storage)
	/// ```
	public init(storage: Storage) {
		self.storage = storage
	}

	/// Saves an array of HTTP cookies to storage.
	///
	/// This method serializes the provided cookies and stores them using the storage backend.
	/// Any previously saved cookies will be replaced.
	///
	/// - Parameter cookies: An array of `HTTPCookie` objects to save. Can be empty to clear all cookies.
	///
	/// ## Example
	///
	/// ```swift
	/// // Save cookies from HTTPCookieStorage
	/// if let cookies = HTTPCookieStorage.shared.cookies {
	///     cookieManager.save(cookies: cookies)
	/// }
	///
	/// // Or save specific cookies
	/// let specificCookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
	/// cookieManager.save(cookies: specificCookies)
	///
	/// // Clear all cookies
	/// cookieManager.save(cookies: [])
	/// ```
	///
	/// - Note: Cookies are stored with the key "cookies" in the underlying storage. Calling this method
	///         multiple times will overwrite previously saved cookies.
	public func save(cookies: [HTTPCookie]) {
		var newCookies = [String: AnyObject]()
		for cookie in cookies {
			newCookies[cookie.name] = cookie.properties as AnyObject?
		}
		storage.save(object: newCookies, key: "cookies")
	}

	/// Restores previously saved HTTP cookies from storage.
	///
	/// This method retrieves cookies from the storage backend and reconstructs `HTTPCookie` objects.
	/// If no cookies were previously saved, or if they cannot be restored, an empty array is returned.
	///
	/// - Returns: An array of `HTTPCookie` objects that were previously saved. Returns an empty array
	///            if no cookies exist or if restoration fails.
	///
	/// ## Example
	///
	/// ```swift
	/// // Restore cookies and add them to HTTPCookieStorage
	/// let restoredCookies = cookieManager.restore()
	/// for cookie in restoredCookies {
	///     HTTPCookieStorage.shared.setCookie(cookie)
	/// }
	///
	/// // Check if cookies were restored
	/// if !restoredCookies.isEmpty {
	///     print("Restored \(restoredCookies.count) cookies")
	/// } else {
	///     print("No cookies to restore")
	/// }
	/// ```
	///
	/// - Note: This method gracefully handles cases where cookies cannot be restored (e.g., corrupted data)
	///         by returning an empty array rather than throwing an error.
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
