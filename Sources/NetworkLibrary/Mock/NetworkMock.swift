#if DEBUG
import Foundation
import LoggerLibrary
import UtilityLibrary

// MARK: - Network Mock Implementation -

/// Production-ready implementation of the ``Network`` protocol.
///
/// ``NetworkMock`` provides async/await HTTP operations with support for mocking, logging,
/// and custom host configuration using URLSession.
///
/// ```swift
/// let network = NetworkMock()
/// let endpoint = Endpoint(customHost: host, api: "/users")
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// - Note: Marked `@unchecked Sendable` for safe concurrent access to URLSession and logging.
public final class NetworkMock: NSObject, Network, @unchecked Sendable {

    /// Logger for debugging network requests and responses.
    private let logger: LoggerProtocol?

    /// Custom host configuration for environment switching.
    public let customHost: CustomHost?

    /// A NetworkMockData object mapping api against local file for mocking purposes.
    public var mapper = [NetworkMockData]()

    /// Creates a network API instance.
    ///
    /// - Parameters:
    ///   - logger: Logger for request/response debugging.
    ///   - customHost: Custom host for environment configuration.
    /// - Parameter mapper: A NetworkMockData object mapping api against local file for mocking purposes.
    public init(logger: LoggerProtocol? = nil,
                customHost: CustomHost? = nil,
                mapper: [NetworkMockData] = []) {
        self.logger = logger
        self.customHost = customHost
        self.mapper = mapper
    }

    /// Performs an HTTP GET request.
    ///
    /// - Parameters:
    ///   - url: The URL to request.
    ///   - headers: HTTP headers for the request.
    /// - Returns: Response data from the server.
    /// - Throws: ``NetworkAPIError`` if the request fails.
    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        try await loadFile(from: url)
    }

    /// Performs an HTTP POST request.
    ///
    /// - Parameters:
    ///   - url: The URL to request.
    ///   - headers: HTTP headers for the request.
    ///   - body: Request body data.
    /// - Returns: Response data from the server.
    /// - Throws: ``NetworkAPIError`` if the request fails.
    public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        try await loadFile(from: url)
    }

    /// Checks network availability by pinging a host.
    ///
    /// - Parameter url: The URL to ping.
    /// - Throws: ``NetworkAPIError/noNetwork`` if the host is unreachable.
    public func ping(url: URL) async throws {}
}

private extension NetworkMock {
    func loadFile(from url: URL) async throws -> Data {
        logger?.info("Mocked data \(url.path)")

        // Determine which mock file to load based on the URL path
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let mockObject = mapper.first(where: { $0.api == components.path }) else {
            throw NetworkAPIError.couldNotBeMock
        }
        let bundle = {
            if let bundlePath = mockObject.bundlePath {
                Bundle(path: bundlePath)
            } else {
                Bundle.main
            }
        }()
        guard let path = bundle?.path(forResource: mockObject.filename, ofType: "json"),
              let content = FileManager.default.contents(atPath: path) else {
            throw NetworkAPIError.couldNotBeMock
        }
        return content
    }
}
#endif
