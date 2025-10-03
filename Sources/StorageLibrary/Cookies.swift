import Foundation

public struct Cookies {
	let storage: Storage

	public init(storage: Storage) {
		self.storage = storage
	}

	public func save(cookies: [HTTPCookie]) {
		var newCookies = [String: AnyObject]()
		for cookie in cookies {
			newCookies[cookie.name] = cookie.properties as AnyObject?
		}
		storage.save(object: newCookies, key: "cookies")
	}

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
