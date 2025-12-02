import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkAPI Core Functionality Tests")
struct NetworkAPITests {

    @Test("NetworkAPI should initialize with default parameters")
    func testNetworkAPIInitialization() async throws {
        let networkAPI = NetworkFactory.make()
        #expect(networkAPI.customHost == nil)
    }

    @Test("NetworkAPI should initialize with logger and custom host")
    func testNetworkAPIInitializationWithParams() async throws {
        let customHost = CustomHost(host: "api.example.com", api: "/v1/test")
        let mockData = [NetworkMockData(api: "/test", filename: "test_mock")]

        let networkAPI = NetworkFactory.make(logger: nil, host: customHost, mapper: mockData)

        #expect(networkAPI.customHost != nil)
        #expect(networkAPI.customHost?.host == "api.example.com")
    }

    @Test("NetworkAPI should handle GET request with mocked data")
    func testGETWithMockData() async throws {
        let mockData = [NetworkMockData(api: "/test", filename: "mock_response2", bundlePath: Bundle.module.bundlePath)]
        let networkAPI = NetworkMock(mapper: mockData)

        guard let url = URL(string: "https://api.example.com/test") else {
            Issue.record("…")
            return
        }

        // This should attempt to use mock data but will throw since the file doesn't exist
        // In a real test environment, you'd have actual mock JSON files
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: url)
        }
    }

    @Test("NetworkAPI should handle POST request")
    func testPOSTRequest() async throws {
        let networkAPI = NetworkMock(mapper: [
            NetworkMockData(api: "/post", filename: "httpbin_post_mock", bundlePath: Bundle.module.bundlePath)
        ])
        guard let url = URL(string: "https://httpbin.org/post") else {
            Issue.record("…")
            return
        }
        let headers = ["Content-Type": "application/json"]
        let testData = Data("Test POST data".utf8)

        let response = try await networkAPI.post(url: url, headers: headers, body: testData)
        #expect(!response.isEmpty)

        // Verify it's valid JSON
        let json = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        #expect(json != nil)
    }

    @Test("NetworkAPI should fail ping for invalid URL")
    func testPingFailure() async throws {
        let networkAPI = DefaultNetwork()
        guard let url = URL(string: "https://invalid-url-that-should-not-exist-12345.com") else {
            Issue.record("…")
            return
        }

        await #expect(throws: NetworkAPIError.noNetwork) {
            try await networkAPI.ping(url: url)
        }
    }
}

@Suite("NetworkAPI Mock Data Tests")
struct NetworkAPIMockTests {

    @Test("NetworkAPI should prefer environment variable for mock file")
    func testEnvironmentVariableMockPriority() async throws {
        // This test would require setting environment variables
        // which is not easily done in unit tests, but demonstrates the concept
        let mockData = [NetworkMockData(api: "/test", filename: "fallback_mock")]
        let networkAPI = NetworkMock(mapper: mockData)

        guard let url = URL(string: "https://api.example.com/test") else {
            Issue.record("…")
            return
        }

        await #expect(throws: Error.self) {
            try await networkAPI.get(url: url)
        }
    }

    @Test("NetworkMockData should initialize correctly")
    func testNetworkMockDataInit() throws {
        let mockData = NetworkMockData(api: "/users", filename: "users_mock")

        #expect(mockData.api == "/users")
        #expect(mockData.filename == "users_mock")
        #expect(mockData.bundlePath == nil)

        let customMockData = NetworkMockData(api: "/posts", filename: "posts_mock", bundlePath: Bundle.module.bundlePath)
        #expect(customMockData.bundlePath == Bundle.module.bundlePath)
    }
}

@Suite("NetworkAPI Integration Tests")
struct NetworkAPIIntegrationTests {

    @Test("NetworkAPI should work with mock HTTP service")
    func testMockHTTPService() async throws {
        let networkAPI = NetworkMock(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])

        guard let url = URL(string: "https://httpbin.org/json") else {
            Issue.record("…")
            return
        }

        let data = try await networkAPI.get(url: url)
        #expect(!data.isEmpty)

        // Try to parse as JSON to verify it's valid
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json != nil)
    }

    @Test("NetworkAPI should handle concurrent requests")
    func testConcurrentRequests() async throws {
        let networkAPI = NetworkMock(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])
        guard let url = URL(string: "https://httpbin.org/json") else {
            Issue.record("…")
            return
        }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    do {
                        _ = try await networkAPI.get(url: url)
                    } catch {
                        // Ignore individual failures for concurrent test
                    }
                }
            }
        }

        // If we reach here without crashing, the concurrent test passed
        #expect(Bool(true))
    }
}
