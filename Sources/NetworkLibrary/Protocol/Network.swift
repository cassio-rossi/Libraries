import Foundation

// MARK: - Network Protocol -

/// Protocol to create the network layer
public protocol Network {
	var customHost: CustomHost? { get }
	var mock: [NetworkMockData]? { get }

	/// HTTP GET Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Necessary headers to perform the request
	/// - Returns: A Data object or `throws` an NetworkAPIError error
	func get(url: URL, headers: [String: String]?) async throws -> Data

	/// HTTP POST Method
	///
	/// - Parameter url: The URL to make the request
	/// - Parameter headers: Necessary headers to perform the request
	/// - Parameter body: The body to be sent on the request
	/// - Returns: A Data object or `throws` an NetworkAPIError error
	func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data

	/// Complementary HTTP GET Method to load a file from Bundle
	///
	/// - Parameter url: The URL to make the request
    /// - Parameter bundle: Optional Bundle to be used, otherwise, `.main` will be used
	/// - Returns: A Data object or `throws` an NetworkAPIError error
	func get(file: URL, bundle: Bundle?) throws -> Data

	/// Allow a mocked file to be loaded
	///
	/// - Parameter file: The filename that contains the json object
    /// - Parameter bundle: Optional Bundle to be used, otherwise, `.main` will be used
	/// - Returns: A Data object or `throws` an NetworkAPIError error
    func load(file: String, bundle: Bundle?) throws -> Data

	/// Ping a host to check network availability
	///
	/// - Parameter url: A valid URL to check against
	/// - Returns: `throws` an NetworkAPIError error
	func ping(url: URL) async throws
}

extension Network {
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

    public func load(file: String, bundle: Bundle?) throws -> Data {
        guard let path = (bundle ?? Bundle.main).path(forResource: file, ofType: "json"),
              let content = FileManager.default.contents(atPath: path) else {
            throw NetworkAPIError.network
        }
        return content
	}
}

extension Network {
	func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
		return try await self.get(url: url, headers: headers)
	}

	func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
		return try await self.post(url: url, headers: headers, body: body)
	}
}
