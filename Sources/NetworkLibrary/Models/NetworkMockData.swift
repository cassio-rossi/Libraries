import Foundation

/// Configuration for loading mock response data from JSON files.
///
/// Specifies which JSON file to load for a given API endpoint, enabling offline
/// development and testing.
///
/// ```swift
/// let mockData = [
///     NetworkMockData(api: "/v1/users", filename: "users_sample")
/// ]
/// let network = NetworkAPI(mock: mockData)
/// ```
public struct NetworkMockData: Codable {
    /// The API path to match for this mock data.
    public let api: String

    /// The JSON filename without extension.
    public let filename: String

    /// The bundle path where the JSON file exists.
    public let bundlePath: String?

    /// Creates a mock data configuration.
    ///
    /// - Parameters:
    ///   - api: API path to match (e.g., "/v1/users").
    ///   - filename: JSON filename without extension.
    ///   - bundle: Bundle path where the JSON file exists. Defaults to nil which should be use as `Bundle.main`.
    public init(api: String,
                filename: String,
                bundlePath: String? = nil) {
        self.api = api
        self.filename = filename
        self.bundlePath = bundlePath
    }
}
