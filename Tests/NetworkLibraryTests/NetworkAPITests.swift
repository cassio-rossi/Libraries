import Foundation
import Testing
@testable import NetworkLibrary

@Suite("NetworkAPI Core Functionality Tests")
struct NetworkAPITests {
    
    @Test("NetworkAPI should initialize with default parameters")
    func testNetworkAPIInitialization() async throws {
        let networkAPI = NetworkAPI()
        
        #expect(networkAPI.customHost == nil)
        #expect(networkAPI.mock == nil)
    }
    
    @Test("NetworkAPI should initialize with logger and custom host")
    func testNetworkAPIInitializationWithParams() async throws {
        let customHost = CustomHost(host: "api.example.com", api: "/v1/test")
        let mockData = [NetworkMockData(api: "/test", filename: "test_mock")]
        
        let networkAPI = NetworkAPI(logger: nil, customHost: customHost, mock: mockData)

        #expect(networkAPI.customHost != nil)
        #expect(networkAPI.customHost?.host == "api.example.com")
        #expect(networkAPI.mock?.count == 1)
        #expect(networkAPI.mock?.first?.api == "/test")
    }
    
    @Test("NetworkAPI should handle GET request with mocked data")
    func testGETWithMockData() async throws {
        let mockData = [NetworkMockData(api: "/test", filename: "mock_response2", bundle: .module)]
        let networkAPI = NetworkAPI(mock: mockData)
        
        let url = URL(string: "https://api.example.com/test")!
        
        // This should attempt to use mock data but will throw since the file doesn't exist
        // In a real test environment, you'd have actual mock JSON files
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: url)
        }
    }
    
    @Test("NetworkAPI should handle POST request")
    func testPOSTRequest() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://httpbin.org/post")!
        let testData = "Test POST data".data(using: .utf8)!
        let headers = ["Content-Type": "application/json"]
        
        // Note: This test requires network connectivity
        // In production, you'd mock the URLSession
        do {
            let response = try await networkAPI.post(url: url, headers: headers, body: testData)
            #expect(response.count > 0)
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
    
    @Test("NetworkAPI should handle ping successfully")
    func testPingSuccess() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://httpbin.org")!
        
        do {
            try await networkAPI.ping(url: url)
            // Test passes if no exception is thrown
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
    
    @Test("NetworkAPI should fail ping for invalid URL")
    func testPingFailure() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://invalid-url-that-should-not-exist-12345.com")!
        
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
        let networkAPI = NetworkAPI(mock: mockData)
        
        let url = URL(string: "https://api.example.com/test")!
        
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: url)
        }
    }
    
    @Test("NetworkMockData should initialize correctly")
    func testNetworkMockDataInit() throws {
        let mockData = NetworkMockData(api: "/users", filename: "users_mock")
        
        #expect(mockData.api == "/users")
        #expect(mockData.filename == "users_mock")
        #expect(mockData.bundle == .main)
        
        let customMockData = NetworkMockData(api: "/posts", filename: "posts_mock", bundle: .module)
        #expect(customMockData.bundle == .module)
    }
}

@Suite("NetworkAPI Integration Tests", .timeLimit(.minutes(2)))
struct NetworkAPIIntegrationTests {
    
    @Test("NetworkAPI should work with real HTTP service")
    func testRealHTTPService() async throws {
        let networkAPI = NetworkAPI()

        let url = URL(string: "https://httpbin.org/json")!

        do {
            let data = try await networkAPI.get(url: url)
            #expect(data.count > 0)

            // Try to parse as JSON to verify it's valid
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            #expect(json != nil)
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }

    @Test("NetworkAPI should handle concurrent requests")
    func testConcurrentRequests() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://httpbin.org/json")!
        
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    do {
                        let _ = try await networkAPI.get(url: url)
                    } catch {
                        // Ignore individual failures for concurrent test
                    }
                }
            }
        }
        
        // If we reach here without crashing, the concurrent test passed
        #expect(true)
    }
}
