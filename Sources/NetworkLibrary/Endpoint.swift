import Foundation

// MARK: - Custom Host -

/// Custom host allows to replace the default host used by the library
/// allowing the usage of different environments like `debug`, `qa` or `production`
public struct CustomHost: Sendable {
	let secure: Bool
	let host: String
	let port: Int?
	let path: String?
	public let api: String?
	public let queryItems: [URLQueryItem]?

	/// Initialization method
	///
	/// - Parameter secure: The host uses secure SSL connection
	/// - Parameter host: The host to be used as `example.co.uk`
	/// - Parameter path: The path of the endpoint to be used as `v1`
	/// - Parameter api: The API endpoint to be used as `pay`
	public init(secure: Bool = true,
				host: String,
				port: Int? = nil,
				path: String? = nil,
				api: String? = nil,
				queryItems: [URLQueryItem]? = nil) {
		self.secure = secure
		self.host = host
		self.port = port
		self.path = path
		self.api = api
		self.queryItems = queryItems
	}
}

// MARK: - Endpoint -

/// Delay the execution of a closure
public struct Endpoint {
	public private(set) var host: String
	public private(set) var port: Int?
	public private(set) var path: String?

	public private(set) var api: String
	public private(set) var queryItems: [URLQueryItem]?

	var isSecure = true

	/// Initialization method
	///
	/// - Parameter customHost: A CustomHost obejct to specify the host and path to connect to
	/// - Parameter api: The API endpoint to be used as `pay`
	/// - Parameter queryItems: The query parameters usually used on GET methods
	public init(customHost: CustomHost,
				api: String,
				queryItems: [URLQueryItem]? = nil) {
		self.isSecure = customHost.secure
		self.host = customHost.host
		self.port = customHost.port
		self.api = customHost.api ?? api
		self.queryItems = customHost.queryItems ?? queryItems

		if var path = customHost.path,
		   !path.isEmpty {
			if path.first != "/" {
				path = "/\(path)"
			}
			self.path = path
		}
	}
}

extension Endpoint {
	/// Composed URL to be used on requests
	public var url: URL {
		var components = URLComponents()
		components.scheme = isSecure ? "https" : "http"
		components.host = host
		components.port = port
		components.path = (path ?? "") + api

		if !(queryItems?.isEmpty ?? true) {
			components.queryItems = queryItems
		}

		guard let url = components.url else {
			preconditionFailure("Invalid URL components: \(components)")
		}

		return url
	}

	/// Composed API to be used on `mock` requests
	public var restAPI: String { "\(self.path ?? "")\(self.api)" }
}
