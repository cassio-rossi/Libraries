import Foundation

/// Configuration for loading mock response data from JSON files.
///
/// ``NetworkMockData`` specifies which JSON file to load for a given API endpoint,
/// enabling offline development and testing without live servers.
///
/// ## Overview
///
/// Use mock data to:
/// - Develop and test without backend dependencies
/// - Create consistent test scenarios
/// - Demonstrate features with sample data
/// - Test error handling with crafted responses
///
/// ## Example Usage
///
/// ```swift
/// // Create mock data configuration
/// let mockData = [
///     NetworkMockData(
///         api: "/v1/users",
///         filename: "users_sample"
///     ),
///     NetworkMockData(
///         api: "/v1/posts",
///         filename: "posts_sample",
///         bundle: .main
///     )
/// ]
///
/// // Initialize network with mocks
/// let network = NetworkAPI(mock: mockData)
///
/// // Requests to /v1/users will load users_sample.json
/// let endpoint = Endpoint(customHost: host, api: "/users")
/// let data = try await network.get(url: endpoint.url)
/// ```
///
/// ## JSON File Format
///
/// Mock JSON files should contain valid JSON matching your expected response structure:
///
/// **users_sample.json:**
/// ```json
/// [
///     {
///         "id": 1,
///         "name": "Alice",
///         "email": "alice@example.com"
///     },
///     {
///         "id": 2,
///         "name": "Bob",
///         "email": "bob@example.com"
///     }
/// ]
/// ```
public struct NetworkMockData {
    /// The API path to match for this mock data.
    ///
    /// This should match the full path including any prefix from the endpoint,
    /// typically matching ``Endpoint/restAPI``.
    ///
    /// Example: "/v1/users", "/api/posts/123"
    let api: String

    /// The name of the JSON file (without extension).
    ///
    /// The file should be in the specified bundle with a `.json` extension.
    ///
    /// Example: "users" for "users.json"
    let filename: String

    /// The bundle containing the JSON file.
    ///
    /// Defaults to `.main` if not specified.
    let bundle: Bundle

    /// Creates a new mock data configuration.
    ///
    /// - Parameters:
    ///   - api: The API path to match (e.g., "/v1/users").
    ///   - filename: The JSON filename without extension (e.g., "users").
    ///   - bundle: The bundle containing the file. Defaults to `.main`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let mockData = NetworkMockData(
    ///     api: "/v1/users",
    ///     filename: "mock_users",
    ///     bundle: .main
    /// )
    /// ```
    public init(api: String,
                filename: String,
                bundle: Bundle = .main) {
        self.api = api
        self.filename = filename
        self.bundle = bundle
    }
}
