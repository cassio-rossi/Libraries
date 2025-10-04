import Foundation
import LoggerLibrary

// MARK: - Network Default Implementation -

public final class NetworkAPI: NSObject, Network, @unchecked Sendable {

	private let logger: LoggerProtocol?
	public let customHost: CustomHost?
	public var mock: [NetworkMockData]?

	/// Initialization method
	///
	/// - Parameter logger: A LoggerProtocol object to allow logging of network calls
	/// - Parameter customHost: A custom host object to allow override of host, path and api
	public init(logger: LoggerProtocol? = nil,
				customHost: CustomHost? = nil,
				mock: [NetworkMockData]? = nil) {
		self.logger = logger
		self.customHost = customHost
		self.mock = mock
	}

	/// HTTP GET Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Necessary headers to perform the request
	/// - Returns: A Data object or `throws` an NetworkAPIError error
	public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		let request = createRequest(method: "GET", url: url, headers: headers)
		return try await execute(request: request)
	}

	/// HTTP POST Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Necessary headers to perform the request
	/// - Parameter body: The body to be sent on the request
	/// - Returns: A Data object or `throws` an NetworkAPIError error
	public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		let request = createRequest(method: "POST", url: url, headers: headers, body: body)
		return try await execute(request: request)
	}

	/// Ping a host to check network availability
	///
	/// - Parameter url: A valid URL to check against
	/// - Returns: `throws` an NetworkAPIError error
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
        guard let api = request.url?.path else {
            throw NetworkAPIError.couldNotBeMock
        }
        logger?.info("Mocked data")
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
