import Foundation

// MARK: - Network Protocol -

/// Protocol defining the core networking interface for HTTP operations.
///
/// Implement ``Network`` to create custom network layers with support for async/await,
/// custom hosts, and mocking, or use the provided ``NetworkAPI`` implementation.
///
/// ```swift
/// class MyNetwork: Network {
///     var customHost: CustomHost?
///     var mock: [NetworkMockData]?
///
///     func get(url: URL, headers: [String: String]?) async throws -> Data {
///         // Implementation
///     }
/// }
/// ```
public protocol Network {
	/// Custom host configuration for environment switching.
	var customHost: CustomHost? { get }

	/// Mock data configurations for testing.
	var mock: [NetworkMockData]? { get }

	/// Performs an HTTP GET request.
	///
	/// - Parameters:
	///   - url: The URL to request.
	///   - headers: HTTP headers for the request.
	/// - Returns: Response data from the server.
	/// - Throws: ``NetworkAPIError`` if the request fails.
	func get(url: URL, headers: [String: String]?) async throws -> Data

	/// Performs an HTTP POST request.
	///
	/// - Parameters:
	///   - url: The URL to request.
	///   - headers: HTTP headers for the request.
	///   - body: Request body data.
	/// - Returns: Response data from the server.
	/// - Throws: ``NetworkAPIError`` if the request fails.
	func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data

	/// Loads a JSON file from a bundle.
	///
	/// - Parameters:
	///   - file: File URL pointing to the JSON file.
	///   - bundle: Bundle containing the file. Defaults to `.main`.
	/// - Returns: Contents of the JSON file.
	/// - Throws: ``NetworkAPIError/network`` if the file cannot be loaded.
	func get(file: URL, bundle: Bundle?) throws -> Data

	/// Loads a JSON file by filename from a bundle.
	///
	/// - Parameters:
	///   - file: Filename without extension (e.g., "users" for "users.json").
	///   - bundle: Bundle containing the file. Defaults to `.main`.
	/// - Returns: Contents of the JSON file.
	/// - Throws: ``NetworkAPIError/network`` if the file cannot be loaded.
    func load(file: String, bundle: Bundle?) throws -> Data

	/// Checks network availability by pinging a host.
	///
	/// - Parameter url: The URL to ping.
	/// - Throws: ``NetworkAPIError/noNetwork`` if the host is unreachable.
	func ping(url: URL) async throws
}

extension Network {
	/// Loads a JSON file from a file URL.
	///
	/// Extracts the filename and delegates to ``load(file:bundle:)``.
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

	/// Loads a JSON file from a bundle by filename.
	///
	/// Automatically adds the `.json` extension to the filename.
    public func load(file: String, bundle: Bundle?) throws -> Data {
        guard let path = (bundle ?? Bundle.main).path(forResource: file, ofType: "json"),
              let content = FileManager.default.contents(atPath: path) else {
            throw NetworkAPIError.network
        }
        return content
	}
}

extension Network {
	/// Performs a GET request with optional headers.
	func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		return try await self.get(url: url, headers: headers)
	}

	/// Performs a POST request with optional headers.
	func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		return try await self.post(url: url, headers: headers, body: body)
	}
}
