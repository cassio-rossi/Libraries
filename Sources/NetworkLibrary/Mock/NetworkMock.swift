import Foundation

/// Mock network implementation that always fails.
///
/// Use ``NetworkFailed`` to test error handling by simulating network failures.
///
/// ```swift
/// func testOfflineHandling() async {
///     let network = NetworkFailed()
///     let viewModel = UserViewModel(network: network)
///     await viewModel.fetchUsers()
///     XCTAssertNotNil(viewModel.errorMessage)
/// }
/// ```
public final class NetworkFailed: NSObject, Network {
    public var customHost: CustomHost?
	public var mock: [NetworkMockData]?

    /// Always throws ``NetworkAPIError/network``.
    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws ``NetworkAPIError/network``.
    public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws ``NetworkAPIError/noNetwork``.
    public func ping(url: URL) async throws {
        throw NetworkAPIError.noNetwork
    }
}
