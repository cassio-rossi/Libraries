import Foundation

// MARK: - Custom Host -

/// Configuration for custom API hosts and environments.
///
/// Use ``CustomHost`` to configure different API environments by specifying the host, port, path,
/// and query parameters.
///
/// ```swift
/// let host = CustomHost(
///     host: "api.example.com",
///     path: "/v1"
/// )
/// ```
public struct CustomHost: Sendable {
	/// Whether to use HTTPS (`true`) or HTTP (`false`).
	public let secure: Bool

	/// The host domain or IP address.
	public let host: String

	/// Port number for non-standard ports.
	public let port: Int?

	/// Path prefix prepended to API endpoints.
	public let path: String?

	/// Default API endpoint.
	public let api: String?

	/// Default query parameters for all requests.
	public let queryItems: [URLQueryItem]?

	/// Creates a custom host configuration.
	///
	/// - Parameters:
	///   - secure: Whether to use HTTPS. Defaults to `true`.
	///   - host: The host domain or IP address.
	///   - port: Port number for non-standard ports.
	///   - path: Path prefix (e.g., "/v1").
	///   - api: Default API endpoint.
	///   - queryItems: Default query parameters.
	public init(
		secure: Bool = true,
		host: String,
		port: Int? = nil,
		path: String? = nil,
		api: String? = nil,
		queryItems: [URLQueryItem]? = nil
	) {
		self.secure = secure
		self.host = host
		self.port = port
		self.path = path
		self.api = api
		self.queryItems = queryItems
	}
}

// MARK: - Endpoint -

/// Type-safe builder for API endpoint URLs.
///
/// ``Endpoint`` combines a ``CustomHost`` with API paths and query parameters to construct
/// complete URLs for network requests.
///
/// ```swift
/// let endpoint = Endpoint(
///     customHost: host,
///     api: "/users",
///     queryItems: [URLQueryItem(name: "page", value: "1")]
/// )
/// let data = try await network.get(url: endpoint.url)
/// ```
public struct Endpoint {
	/// The host domain or IP address.
	public private(set) var host: String

	/// Port number.
	public private(set) var port: Int?

	/// Path prefix (e.g., "/v1").
	public private(set) var path: String?

	/// API endpoint path (e.g., "/users").
	public private(set) var api: String

	/// Query parameters.
	public private(set) var queryItems: [URLQueryItem]?

	/// Whether to use HTTPS (`true`) or HTTP (`false`).
	public var isSecure = true

	/// Creates an endpoint from a custom host and API path.
	///
	/// - Parameters:
	///   - customHost: Host configuration with domain, port, and path prefix.
	///   - api: API endpoint path (e.g., "/users").
	///   - queryItems: Query parameters to append to the URL.
	public init(
		customHost: CustomHost,
		api: String,
		queryItems: [URLQueryItem]? = nil
	) {
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
	/// The complete URL for network requests.
	///
	/// Constructs a fully-qualified URL from the endpoint's components.
	///
	/// - Important: Triggers `preconditionFailure` if URL components are invalid.
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

	/// The combined path and API endpoint for mock matching.
	///
	/// Returns the full path including prefix and endpoint, excluding query parameters.
	public var restAPI: String { "\(self.path ?? "")\(self.api)" }
}
