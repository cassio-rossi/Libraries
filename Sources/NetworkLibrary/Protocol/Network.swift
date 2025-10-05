import Foundation

// MARK: - Network Protocol -

/// A protocol defining the core networking interface for HTTP operations.
///
/// ``Network`` provides a clean, testable abstraction for making HTTP requests with support
/// for custom hosts, mocking, and async/await patterns. Implement this protocol to create
/// custom network layers or use the provided ``NetworkAPI`` implementation.
///
/// ## Overview
///
/// The protocol defines methods for:
/// - Making GET and POST requests
/// - Loading JSON files from bundles
/// - Checking network availability
/// - Supporting custom hosts and environments
/// - Mocking responses for testing
///
/// ## Example Implementation
///
/// ```swift
/// class MyNetworkLayer: Network {
///     var customHost: CustomHost?
///     var mock: [NetworkMockData]?
///
///     func get(url: URL, headers: [String: String]?) async throws -> Data {
///         // Your implementation
///     }
///
///     func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data {
///         // Your implementation
///     }
///
///     func ping(url: URL) async throws {
///         // Your implementation
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Configuration
/// - ``customHost``
/// - ``mock``
///
/// ### HTTP Methods
/// - ``get(url:headers:)``
/// - ``post(url:headers:body:)``
///
/// ### Local Resources
/// - ``get(file:bundle:)``
/// - ``load(file:bundle:)``
///
/// ### Network Utilities
/// - ``ping(url:)``
public protocol Network {
	/// Optional custom host configuration for overriding default endpoints.
	///
	/// Use this property to support different environments (development, staging, production)
	/// or to override specific API endpoints.
	var customHost: CustomHost? { get }

	/// Optional array of mock data configurations for testing.
	///
	/// When mock data is provided, the network layer attempts to load responses from
	/// local JSON files instead of making real network requests.
	var mock: [NetworkMockData]? { get }

	/// Performs an HTTP GET request.
	///
	/// Makes an asynchronous GET request to the specified URL with optional headers.
	/// The request uses URLSession internally and supports SSL challenges.
	///
	/// - Parameters:
	///   - url: The URL to request. Should be constructed using ``Endpoint``.
	///   - headers: Optional dictionary of HTTP headers (e.g., "Authorization", "Content-Type").
	///
	/// - Returns: The response data from the server.
	///
	/// - Throws: ``NetworkAPIError`` if the request fails, including:
	///   - `.noNetwork`: No network connection available
	///   - `.network`: Request failed or returned an error status
	///   - `.error(reason:)`: Server returned an error response
	///
	/// ## Example
	///
	/// ```swift
	/// let endpoint = Endpoint(customHost: host, api: "/users")
	/// let headers = ["Authorization": "Bearer \(token)"]
	///
	/// do {
	///     let data = try await network.get(url: endpoint.url, headers: headers)
	///     let users = try JSONDecoder().decode([User].self, from: data)
	/// } catch {
	///     print("Request failed: \(error)")
	/// }
	/// ```
	func get(url: URL, headers: [String: String]?) async throws -> Data

	/// Performs an HTTP POST request.
	///
	/// Makes an asynchronous POST request to the specified URL with a request body
	/// and optional headers. Typically used for creating resources or submitting data.
	///
	/// - Parameters:
	///   - url: The URL to request. Should be constructed using ``Endpoint``.
	///   - headers: Optional dictionary of HTTP headers. Common headers include
	///     "Content-Type": "application/json" and "Authorization".
	///   - body: The request body data, typically JSON-encoded.
	///
	/// - Returns: The response data from the server.
	///
	/// - Throws: ``NetworkAPIError`` if the request fails.
	///
	/// ## Example
	///
	/// ```swift
	/// let endpoint = Endpoint(customHost: host, api: "/users")
	/// let newUser = CreateUserRequest(name: "John", email: "john@example.com")
	/// let body = try JSONEncoder().encode(newUser)
	///
	/// let headers = [
	///     "Content-Type": "application/json",
	///     "Authorization": "Bearer \(token)"
	/// ]
	///
	/// let data = try await network.post(url: endpoint.url, headers: headers, body: body)
	/// ```
	func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data

	/// Loads a JSON file from a bundle.
	///
	/// This method loads JSON data from a file URL within a bundle. Useful for
	/// loading mock data or configuration files packaged with your app.
	///
	/// - Parameters:
	///   - file: A file URL pointing to the JSON file (e.g., `file:///users.json`).
	///   - bundle: The bundle containing the file. Defaults to `.main` if `nil`.
	///
	/// - Returns: The contents of the JSON file as `Data`.
	///
	/// - Throws: ``NetworkAPIError/network`` if the file cannot be found or loaded.
	///
	/// ## Example
	///
	/// ```swift
	/// let fileURL = URL(string: "file:///mock_users.json")!
	/// let data = try network.get(file: fileURL, bundle: .main)
	/// let users = try JSONDecoder().decode([User].self, from: data)
	/// ```
	func get(file: URL, bundle: Bundle?) throws -> Data

	/// Loads a JSON file by filename from a bundle.
	///
	/// This method loads JSON data from a named file within a bundle. The file
	/// should have a `.json` extension (which is added automatically).
	///
	/// - Parameters:
	///   - file: The filename without extension (e.g., "users" for "users.json").
	///   - bundle: The bundle containing the file. Defaults to `.main` if `nil`.
	///
	/// - Returns: The contents of the JSON file as `Data`.
	///
	/// - Throws: ``NetworkAPIError/network`` if the file cannot be found or loaded.
	///
	/// ## Example
	///
	/// ```swift
	/// // Loads "users.json" from the main bundle
	/// let data = try network.load(file: "users", bundle: .main)
	/// let users = try JSONDecoder().decode([User].self, from: data)
	/// ```
    func load(file: String, bundle: Bundle?) throws -> Data

	/// Checks network availability by pinging a host.
	///
	/// Performs a lightweight HEAD request to verify that the specified host is
	/// reachable and responding. Use this before making important requests or to
	/// provide network status feedback to users.
	///
	/// - Parameter url: The URL to ping (typically your API's base URL).
	///
	/// - Throws: ``NetworkAPIError/noNetwork`` if the host is unreachable or
	///   returns an error status code.
	///
	/// ## Example
	///
	/// ```swift
	/// let apiURL = URL(string: "https://api.example.com")!
	///
	/// do {
	///     try await network.ping(url: apiURL)
	///     // Network is available, proceed with requests
	///     await fetchData()
	/// } catch {
	///     // Network unavailable
	///     showOfflineMessage()
	/// }
	/// ```
	func ping(url: URL) async throws
}

/// Default implementations of file loading methods.
extension Network {
	/// Default implementation of file loading from a file URL.
	///
	/// Extracts the filename from the file URL and delegates to ``load(file:bundle:)``.
	public func get(file: URL, bundle: Bundle?) throws -> Data {
		do {
			let components = file.absoluteString.components(separatedBy: "/")
			guard let file = components.last else {
				throw NetworkAPIError.network
			}
            return try load(file: file, bundle: bundle)
		} catch {
			throw NetworkAPIError.network
		}
	}

	/// Default implementation of JSON file loading from bundle.
	///
	/// Locates and loads a JSON file from the specified bundle, automatically
	/// adding the `.json` extension to the filename.
    public func load(file: String, bundle: Bundle?) throws -> Data {
        guard let path = (bundle ?? Bundle.main).path(forResource: file, ofType: "json"),
              let content = FileManager.default.contents(atPath: path) else {
            throw NetworkAPIError.network
        }
        return content
	}
}

/// Convenience overloads providing default parameter values.
extension Network {
	/// Performs a GET request with optional headers.
	///
	/// Convenience method that provides a default `nil` value for headers.
	func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		return try await self.get(url: url, headers: headers)
	}

	/// Performs a POST request with optional headers.
	///
	/// Convenience method that provides a default `nil` value for headers.
	func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		return try await self.post(url: url, headers: headers, body: body)
	}
}
