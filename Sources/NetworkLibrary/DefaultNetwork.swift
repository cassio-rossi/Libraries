import Foundation
import LoggerLibrary

// MARK: - Network Default Implementation -

/// Production-ready implementation of the ``Network`` protocol.
///
/// ``DefaultNetwork`` provides async/await HTTP operations with support for mocking, logging,
/// and custom host configuration using URLSession.
///
/// ```swift
/// let network = DefaultNetwork()
/// let endpoint = Endpoint(customHost: host, api: "/users")
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// - Note: Marked `@unchecked Sendable` for safe concurrent access to URLSession and logging.
public final class DefaultNetwork: NSObject, Network, @unchecked Sendable {

    /// Logger for debugging network requests and responses.
    private let logger: LoggerProtocol?

    /// Custom host configuration for environment switching.
    public let customHost: CustomHost?

    /// Creates a network API instance.
    ///
    /// - Parameters:
    ///   - logger: Logger for request/response debugging.
    ///   - customHost: Custom host for environment configuration.
    public init(logger: LoggerProtocol? = nil,
                customHost: CustomHost? = nil) {
        self.logger = logger
        self.customHost = customHost
    }

    /// Performs an HTTP GET request.
    ///
    /// - Parameters:
    ///   - url: The URL to request.
    ///   - headers: HTTP headers for the request.
    /// - Returns: Response data from the server.
    /// - Throws: ``NetworkAPIError`` if the request fails.
    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        let request = createRequest(method: "GET", url: url, headers: headers)
        return try await execute(request: request)
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
        let request = createRequest(method: "POST", url: url, headers: headers, body: body)
        return try await execute(request: request)
    }

    /// Checks network availability by pinging a host.
    ///
    /// - Parameter url: The URL to ping.
    /// - Throws: ``NetworkAPIError/noNetwork`` if unreachable.
    public func ping(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.hasSuccessStatusCode else {
                throw NetworkAPIError.noNetwork
            }
        } catch {
            throw NetworkAPIError.noNetwork
        }
    }
}

private extension DefaultNetwork {
    // Create a URLRequest request to be used on the URLSession
    func createRequest(method: String,
                       url: URL,
                       headers: [String: String]? = nil,
                       body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // Executiong block of the network request
    func execute(request: URLRequest) async throws -> Data {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        logger?.debug("\(request.debugDescription) - \(request.httpMethod ?? "")")
        logger?.debug(request.allHTTPHeaderFields?.debugDescription ?? "")
        logger?.debug(request.httpBody?.asString ?? "")

        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)

        do {
            let (data, response) = try await session.data(for: request)

            logger?.debug(response.debugDescription)
            logger?.debug(data.asString ?? "")

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.hasSuccessStatusCode else {
                throw NetworkAPIError.error(reason: data)
            }

            return data

        } catch {
            logger?.error(error.localizedDescription)
            throw error
        }
    }
}

// MARK: - Network Default Delegate Implementation -

// In case SSL challenges should be handled
extension DefaultNetwork: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard let challenge = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: challenge))
    }
}
