#if DEBUG
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
    /// Custom host configuration. Always returns `nil`.
    public var customHost: CustomHost?

    /// Creates a failed network instance.
    public override init() {
        super.init()
    }

    /// Always throws ``NetworkAPIError/network``.
    ///
    /// - Parameters:
    ///   - url: The URL to request (ignored).
    ///   - headers: HTTP headers (ignored).
    /// - Throws: Always throws ``NetworkAPIError/network``.
    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws ``NetworkAPIError/network``.
    ///
    /// - Parameters:
    ///   - url: The URL to request (ignored).
    ///   - headers: HTTP headers (ignored).
    ///   - body: Request body data (ignored).
    /// - Throws: Always throws ``NetworkAPIError/network``.
    public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        throw NetworkAPIError.network
    }

    /// Always throws ``NetworkAPIError/noNetwork``.
    ///
    /// - Parameter url: The URL to ping (ignored).
    /// - Throws: Always throws ``NetworkAPIError/noNetwork``.
    public func ping(url: URL) async throws {
        throw NetworkAPIError.noNetwork
    }
}
#endif
