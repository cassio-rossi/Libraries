import Foundation

// MARK: - Custom Host -

/// Configuration for custom API hosts and environments.
///
/// ``CustomHost`` allows you to configure different API environments (development, staging, production)
/// by specifying the host, port, path, and other URL components. This enables seamless switching
/// between environments without changing your API code.
///
/// ## Overview
///
/// Use CustomHost to:
/// - Switch between development, QA, and production environments
/// - Configure local development servers with custom ports
/// - Override API paths and endpoints
/// - Add default query parameters
///
/// ## Example
///
/// ```swift
/// // Production environment
/// let production = CustomHost(
///     host: "api.example.com",
///     path: "/v1"
/// )
///
/// // Development environment with custom port
/// let development = CustomHost(
///     secure: false,
///     host: "localhost",
///     port: 8080,
///     path: "/api/v1"
/// )
///
/// // Staging with default query parameters
/// let staging = CustomHost(
///     host: "staging-api.example.com",
///     path: "/v1",
///     queryItems: [URLQueryItem(name: "debug", value: "true")]
/// )
/// ```
///
/// - Note: This struct is `Sendable`, making it safe to use across concurrency boundaries.
public struct CustomHost: Sendable {
	/// Whether to use HTTPS (true) or HTTP (false).
	///
	/// Defaults to `true` for secure connections. Set to `false` for local development.
	let secure: Bool

	/// The host domain or IP address.
	///
	/// Examples: "api.example.com", "localhost", "192.168.1.100"
	let host: String

	/// Optional port number for the connection.
	///
	/// Only specify if using a non-standard port (not 80 for HTTP or 443 for HTTPS).
	/// Example: 8080 for local development.
	let port: Int?

	/// Optional path prefix for API endpoints.
	///
	/// This is prepended to all API paths. Common examples: "/v1", "/api/v2", "/rest"
	let path: String?

	/// Optional default API endpoint.
	///
	/// If specified, this endpoint is used when creating an ``Endpoint`` unless overridden.
	public let api: String?

	/// Optional default query parameters.
	///
	/// These query items are added to all requests unless overridden.
	/// Useful for API keys, debug flags, or version parameters.
	public let queryItems: [URLQueryItem]?

	/// Creates a new custom host configuration.
	///
	/// - Parameters:
	///   - secure: Whether to use HTTPS. Defaults to `true`.
	///   - host: The host domain or IP address (required).
	///   - port: Optional port number for non-standard ports.
	///   - path: Optional path prefix (e.g., "/v1"). Leading slash is added if missing.
	///   - api: Optional default API endpoint.
	///   - queryItems: Optional default query parameters.
	///
	/// ## Example
	///
	/// ```swift
	/// let host = CustomHost(
	///     host: "api.example.com",
	///     port: 443,
	///     path: "/v2",
	///     api: "/users"
	/// )
	/// ```
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

/// A type-safe builder for constructing API endpoint URLs.
///
/// ``Endpoint`` combines a ``CustomHost`` configuration with specific API paths and query
/// parameters to construct complete, valid URLs for network requests. It ensures URLs are
/// properly formatted with correct schemes, hosts, paths, and query strings.
///
/// ## Overview
///
/// Endpoint provides:
/// - Type-safe URL construction
/// - Automatic scheme selection (HTTP/HTTPS)
/// - Path normalization (ensures leading slashes)
/// - Query parameter support
/// - Compile-time URL validation
///
/// ## Example Usage
///
/// ```swift
/// // Define your host
/// let host = CustomHost(
///     host: "api.example.com",
///     path: "/v1"
/// )
///
/// // Create an endpoint
/// let endpoint = Endpoint(
///     customHost: host,
///     api: "/users",
///     queryItems: [
///         URLQueryItem(name: "page", value: "1"),
///         URLQueryItem(name: "limit", value: "20")
///     ]
/// )
///
/// // Get the complete URL
/// let url = endpoint.url
/// // https://api.example.com/v1/users?page=1&limit=20
///
/// // Make a request
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// ## Topics
///
/// ### Creating an Endpoint
/// - ``init(customHost:api:queryItems:)``
///
/// ### URL Components
/// - ``url``
/// - ``restAPI``
/// - ``host``
/// - ``port``
/// - ``path``
/// - ``api``
/// - ``queryItems``
public struct Endpoint {
	/// The host domain or IP address.
	public private(set) var host: String

	/// Optional port number.
	public private(set) var port: Int?

	/// Optional path prefix (e.g., "/v1").
	public private(set) var path: String?

	/// The API endpoint path (e.g., "/users").
	public private(set) var api: String

	/// Optional query parameters.
	public private(set) var queryItems: [URLQueryItem]?

	/// Whether to use HTTPS (true) or HTTP (false).
	var isSecure = true

	/// Creates a new endpoint from a custom host and API path.
	///
	/// Combines the host configuration with a specific API path and optional query
	/// parameters to create a complete endpoint specification.
	///
	/// - Parameters:
	///   - customHost: The host configuration containing domain, port, and path prefix.
	///   - api: The specific API endpoint path (e.g., "/users", "/posts/123").
	///     If the host has a default API, it will be used unless overridden.
	///   - queryItems: Optional query parameters to append to the URL.
	///
	/// ## Path Normalization
	///
	/// The endpoint automatically ensures paths have leading slashes:
	/// - "users" becomes "/users"
	/// - "/users" remains "/users"
	///
	/// ## Example
	///
	/// ```swift
	/// let host = CustomHost(host: "api.example.com", path: "/v1")
	///
	/// // Simple endpoint
	/// let users = Endpoint(customHost: host, api: "/users")
	/// // URL: https://api.example.com/v1/users
	///
	/// // With query parameters
	/// let filtered = Endpoint(
	///     customHost: host,
	///     api: "/users",
	///     queryItems: [URLQueryItem(name: "role", value: "admin")]
	/// )
	/// // URL: https://api.example.com/v1/users?role=admin
	/// ```
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

/// Computed properties for URL construction.
extension Endpoint {
	/// The complete, constructed URL for making network requests.
	///
	/// This property builds a fully-qualified URL from the endpoint's components,
	/// including scheme, host, port, path, API endpoint, and query parameters.
	///
	/// ## URL Format
	///
	/// The URL is constructed as:
	/// ```
	/// [scheme]://[host]:[port][path][api]?[queryItems]
	/// ```
	///
	/// ## Example
	///
	/// ```swift
	/// let host = CustomHost(
	///     host: "api.example.com",
	///     port: 443,
	///     path: "/v1"
	/// )
	/// let endpoint = Endpoint(
	///     customHost: host,
	///     api: "/users/123",
	///     queryItems: [URLQueryItem(name: "include", value: "profile")]
	/// )
	///
	/// print(endpoint.url)
	/// // https://api.example.com:443/v1/users/123?include=profile
	/// ```
	///
	/// - Important: This property will trigger a `preconditionFailure` if the URL
	///   components cannot form a valid URL. Ensure all components are properly formatted.
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

	/// The combined path and API endpoint for mock request matching.
	///
	/// This property returns the full path including the path prefix and API endpoint,
	/// which is used to match mock data configurations. Query parameters are not included.
	///
	/// ## Example
	///
	/// ```swift
	/// let host = CustomHost(host: "api.example.com", path: "/v1")
	/// let endpoint = Endpoint(customHost: host, api: "/users")
	///
	/// print(endpoint.restAPI)  // "/v1/users"
	///
	/// // Use for mock configuration
	/// let mockData = NetworkMockData(
	///     api: endpoint.restAPI,
	///     filename: "users"
	/// )
	/// ```
	public var restAPI: String { "\(self.path ?? "")\(self.api)" }
}
