import Foundation
import LoggerLibrary

// MARK: - Network Default Implementation -

/// Production-ready implementation of the ``Network`` protocol.
///
/// ``NetworkAPI`` provides async/await HTTP operations with support for mocking, logging,
/// and custom host configuration using URLSession.
///
/// ```swift
/// let network = NetworkAPI()
/// let endpoint = Endpoint(customHost: host, api: "/users")
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// - Note: Marked `@unchecked Sendable` for safe concurrent access to URLSession and logging.
public final class NetworkAPI: NSObject, Network, @unchecked Sendable {

	/// Logger for debugging network requests and responses.
	private let logger: LoggerProtocol?

	/// Custom host configuration for environment switching.
	public let customHost: CustomHost?

	/// Mock data configurations for testing.
	public var mock: [NetworkMockData]?

	/// Creates a network API instance.
	///
	/// - Parameters:
	///   - logger: Logger for request/response debugging.
	///   - customHost: Custom host for environment configuration.
	///   - mock: Mock data for loading responses from JSON files.
	public init(logger: LoggerProtocol? = nil,
				customHost: CustomHost? = nil,
				mock: [NetworkMockData]? = nil) {
		self.logger = logger
		self.customHost = customHost
		self.mock = mock
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

extension NetworkAPI {
    // Create a URLRequest request to be used on the URLSession
    fileprivate func createRequest(method: String,
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
    fileprivate func execute(request: URLRequest) async throws -> Data {
        do {
            return try executeWithMock(request: request)
        } catch {
            return try await executeWithReal(request: request)
        }
    }

    fileprivate func executeWithReal(request: URLRequest) async throws -> Data {
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

    fileprivate func executeWithMock(request: URLRequest) throws -> Data {
        logger?.info("Mocked data \(request.url?.path ?? "")")
        guard let api = request.url?.path else {
            throw NetworkAPIError.couldNotBeMock
        }
        if let mockData = mock?.first(where: { $0.api == api }) {
            let data = try load(file: mockData.filename, bundle: mockData.bundle)
            logger?.debug(data.asString ?? "")
            return data
        }
        if let filename = ProcessInfo.processInfo.environment[api] {
            let data = try load(file: filename, bundle: .main)
            logger?.debug(data.asString ?? "")
            return data
        }
        throw NetworkAPIError.couldNotBeMock
    }
}

// MARK: - Network Default Delegate Implementation -

// In case SSL challenges should be handled
extension NetworkAPI: URLSessionDelegate {
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
