import Foundation
import LoggerLibrary

// MARK: - Network Default Implementation -

/// The default implementation of the ``Network`` protocol.
///
/// ``NetworkAPI`` provides a production-ready networking layer with support for
/// async/await, mocking, logging, and environment configuration. It uses URLSession
/// internally and handles SSL challenges, request/response logging, and error management.
///
/// ## Overview
///
/// NetworkAPI features:
/// - Async/await based HTTP methods (GET, POST)
/// - Optional request/response logging
/// - Mock data support for testing and development
/// - Custom host configuration for multiple environments
/// - SSL challenge handling
/// - Comprehensive error handling
/// - Cache-disabled ephemeral sessions
///
/// ## Basic Usage
///
/// ```swift
/// // Create a network instance
/// let network = NetworkAPI()
///
/// // Define your endpoint
/// let host = CustomHost(host: "api.example.com", path: "/v1")
/// let endpoint = Endpoint(customHost: host, api: "/users")
///
/// // Make a GET request
/// let data = try await network.get(url: endpoint.url)
/// let users = try JSONDecoder().decode([User].self, from: data)
/// ```
///
/// ## With Logging
///
/// ```swift
/// let logger = Logger(category: "Network")
/// let network = NetworkAPI(logger: logger)
///
/// // All requests and responses will be logged
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// ## With Mocking
///
/// ```swift
/// let mockData = [
///     NetworkMockData(api: "/v1/users", filename: "users_sample")
/// ]
/// let network = NetworkAPI(mock: mockData)
///
/// // Requests to /v1/users will load from users_sample.json
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// - Note: This class is marked `@unchecked Sendable` as it safely manages URLSession
///   and logging across concurrency boundaries.
public final class NetworkAPI: NSObject, Network, @unchecked Sendable {

	/// Optional logger for debugging network requests and responses.
	private let logger: LoggerProtocol?

	/// Optional custom host configuration.
	public let customHost: CustomHost?

	/// Optional array of mock data configurations.
	public var mock: [NetworkMockData]?

	/// Creates a new NetworkAPI instance.
	///
	/// - Parameters:
	///   - logger: An optional logger conforming to ``LoggerProtocol`` for debugging.
	///     When provided, all requests, responses, and errors are logged.
	///   - customHost: An optional ``CustomHost`` for environment configuration.
	///   - mock: An optional array of ``NetworkMockData`` for loading responses from JSON files.
	///
	/// ## Example
	///
	/// ```swift
	/// // Basic initialization
	/// let network = NetworkAPI()
	///
	/// // With logging
	/// let logger = Logger(category: "API")
	/// let network = NetworkAPI(logger: logger)
	///
	/// // With custom host
	/// let host = CustomHost(host: "api.example.com", path: "/v1")
	/// let network = NetworkAPI(customHost: host)
	///
	/// // With mocking
	/// let mocks = [NetworkMockData(api: "/users", filename: "users")]
	/// let network = NetworkAPI(mock: mocks)
	/// ```
	public init(logger: LoggerProtocol? = nil,
				customHost: CustomHost? = nil,
				mock: [NetworkMockData]? = nil) {
		self.logger = logger
		self.customHost = customHost
		self.mock = mock
	}

	/// Performs an HTTP GET request.
	///
	/// Makes an asynchronous GET request, attempting to load from mock data first
	/// (if configured), then falling back to a real network request.
	///
	/// - Parameters:
	///   - url: The URL to request.
	///   - headers: Optional HTTP headers.
	///
	/// - Returns: The response data.
	///
	/// - Throws: ``NetworkAPIError`` if the request fails.
	///
	/// ## Example
	///
	/// ```swift
	/// let endpoint = Endpoint(customHost: host, api: "/users")
	/// let headers = ["Authorization": "Bearer \(token)"]
	/// let data = try await network.get(url: endpoint.url, headers: headers)
	/// ```
	public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		let request = createRequest(method: "GET", url: url, headers: headers)
		return try await execute(request: request)
	}

	/// Performs an HTTP POST request.
	///
	/// Makes an asynchronous POST request with a body, attempting to load from mock data
	/// first (if configured), then falling back to a real network request.
	///
	/// - Parameters:
	///   - url: The URL to request.
	///   - headers: Optional HTTP headers.
	///   - body: The request body data.
	///
	/// - Returns: The response data.
	///
	/// - Throws: ``NetworkAPIError`` if the request fails.
	///
	/// ## Example
	///
	/// ```swift
	/// let endpoint = Endpoint(customHost: host, api: "/users")
	/// let user = CreateUserRequest(name: "Alice", email: "alice@example.com")
	/// let body = try JSONEncoder().encode(user)
	/// let headers = ["Content-Type": "application/json"]
	///
	/// let data = try await network.post(url: endpoint.url, headers: headers, body: body)
	/// ```
	public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		let request = createRequest(method: "POST", url: url, headers: headers, body: body)
		return try await execute(request: request)
	}

	/// Checks network availability by pinging a host.
	///
	/// Performs a lightweight HEAD request to verify the host is reachable.
	///
	/// - Parameter url: The URL to ping.
	///
	/// - Throws: ``NetworkAPIError/noNetwork`` if unreachable.
	///
	/// ## Example
	///
	/// ```swift
	/// let apiURL = URL(string: "https://api.example.com")!
	///
	/// do {
	///     try await network.ping(url: apiURL)
	///     // Network is available
	/// } catch {
	///     // Network unavailable
	/// }
	/// ```
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
