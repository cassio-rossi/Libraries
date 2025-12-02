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
///
///     func get(url: URL, headers: [String: String]?) async throws -> Data {
///         // Implementation
///     }
/// }
/// ```
public protocol Network {
	/// Custom host configuration for environment switching.
	var customHost: CustomHost? { get }

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

	/// Checks network availability by pinging a host.
	///
	/// - Parameter url: The URL to ping.
	/// - Throws: ``NetworkAPIError/noNetwork`` if the host is unreachable.
	func ping(url: URL) async throws
}

extension Network {
    /// Performs a GET request with optional headers.
    func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        try await self.get(url: url, headers: headers)
    }

    /// Performs a POST request with optional headers.
    func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        try await self.post(url: url, headers: headers, body: body)
    }

    /// Checks network availability by pinging a host.
    func ping(url: URL) async throws {
        try await self.ping(url: url)
    }
}
