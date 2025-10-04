import Foundation

public final class NetworkFailed: NSObject, Network {
    public var customHost: CustomHost?
	public var mock: [NetworkMockData]?

    public func get(url: URL, headers: [String: String]? = nil) async throws -> Data {
        throw NetworkAPIError.network
    }

    public func post(url: URL, headers: [String: String]? = nil, body: Data) async throws -> Data {
        throw NetworkAPIError.network
    }

    public func ping(url: URL) async throws {
        throw NetworkAPIError.noNetwork
    }
}
