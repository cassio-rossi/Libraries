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
public struct NetworkMockData {
    /// The API path to match for this mock data.
    let api: String

    /// The JSON filename without extension.
    let filename: String

    /// The bundle containing the JSON file.
    let bundle: Bundle

    /// Creates a mock data configuration.
    ///
    /// - Parameters:
    ///   - api: API path to match (e.g., "/v1/users").
    ///   - filename: JSON filename without extension.
    ///   - bundle: Bundle containing the file. Defaults to `.main`.
    public init(api: String,
                filename: String,
                bundle: Bundle = .main) {
        self.api = api
        self.filename = filename
        self.bundle = bundle
    }
}
