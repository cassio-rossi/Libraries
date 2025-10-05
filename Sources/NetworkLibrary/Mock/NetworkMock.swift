import Foundation

/// A network implementation that always fails, useful for testing error scenarios.
///
/// ``NetworkFailed`` is a mock implementation of the ``Network`` protocol that throws
/// errors for all network operations. Use this in tests to verify your error handling logic.
///
/// ## Overview
///
/// This class is particularly useful for:
/// - Testing offline scenarios
/// - Verifying error handling paths
/// - Simulating network failures
/// - Testing UI behavior when requests fail
///
/// ## Example Usage
///
/// ```swift
/// // In your tests
/// func testOfflineHandling() async {
///     let failedNetwork = NetworkFailed()
///     let viewModel = UserViewModel(network: failedNetwork)
///
///     await viewModel.fetchUsers()
///
///     // Verify error state
///     XCTAssertNotNil(viewModel.errorMessage)
///     XCTAssertTrue(viewModel.users.isEmpty)
/// }
/// ```
///
/// ## Error Behavior
///
/// All methods throw specific errors:
/// - ``get(url:headers:)`` throws ``NetworkAPIError/network``
/// - ``post(url:headers:body:)`` throws ``NetworkAPIError/network``
/// - ``ping(url:)`` throws ``NetworkAPIError/noNetwork``
public final class NetworkFailed: NSObject, Network {
    /// Always `nil` for this implementation.
    public var customHost: CustomHost?

    /// Always `nil` for this implementation.
	public var mock: [NetworkMockData]?

    /// Always throws a network error.
    ///
    /// - Throws: ``NetworkAPIError/network``
    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws a network error.
    ///
    /// - Throws: ``NetworkAPIError/network``
    public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws a no network error.
    ///
    /// - Throws: ``NetworkAPIError/noNetwork``
    public func ping(url: URL) async throws {
        throw NetworkAPIError.noNetwork
    }
}
