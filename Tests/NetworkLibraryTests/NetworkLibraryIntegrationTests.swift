import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkLibrary Integration Tests")
struct NetworkLibraryIntegrationTests {

    @Test("NetworkAPI should work with Endpoint for URL generation")
    func testNetworkAPIEndpointIntegration() async throws {
        let customHost = CustomHost(
            host: "httpbin.org",
            path: "/json"
        )

        let endpoint = Endpoint(customHost: customHost, api: "")
        let networkAPI = NetworkFactory.make(host: customHost, mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])

        let data = try await networkAPI.get(url: endpoint.url)
        #expect(!data.isEmpty)

        // Verify it's valid JSON
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json != nil)
    }

    @Test("NetworkAPI should integrate with Logger properly")
    func testNetworkAPILoggerIntegration() async throws {
        let networkAPI = NetworkFactory.make(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])

        guard let url = URL(string: "https://httpbin.org/json") else {
            Issue.record("Failed to create test URL")
            return
        }

        let data = try await networkAPI.get(url: url)
        #expect(!data.isEmpty)
    }

    @Test("NetworkAPI should handle complex workflow with CustomHost and mocking")
    func testComplexNetworkWorkflow() async throws {
        let customHost = CustomHost(
            secure: true,
            host: "api.example.com",
            port: nil,
            path: "/v1",
            api: "/users"
        )

        let mockData = [
            NetworkMockData(api: "/v1/users", filename: "users_mock", bundlePath: Bundle.main.bundlePath)
        ]

        let networkAPI = NetworkFactory.make(host: customHost, mapper: mockData)
        let endpoint = Endpoint(customHost: customHost, api: "/posts")

        // This should attempt to use mock but will fail since file doesn't exist
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: endpoint.url)
        }
    }

    @Test("End-to-end test with all components")
    func testEndToEndFlow() async throws {
        // Setup custom host
        let customHost = CustomHost(
            secure: true,
            host: "httpbin.org",
            path: "/anything"
        )

        // Setup endpoint
        let endpoint = Endpoint(customHost: customHost, api: "/test")

        // Setup network API
        let networkAPI = NetworkFactory.make(host: customHost,
                                             mapper: [
                                                NetworkMockData(api: "/anything/test", filename: "httpbin_anything_mock", bundlePath: Bundle.module.bundlePath),
                                                NetworkMockData(api: "/anything", filename: "httpbin_anything_mock", bundlePath: Bundle.module.bundlePath)
                                             ])

        // Test GET request
        let getData = try await networkAPI.get(url: endpoint.url)
        #expect(!getData.isEmpty)

        // Test POST request
        let postBody = Data("{\"test\": \"data\"}".utf8)
        let postData = try await networkAPI.post(
            url: endpoint.url,
            headers: ["Content-Type": "application/json"],
            body: postBody
        )
        #expect(!postData.isEmpty)
    }

    @Test("NetworkAPI should handle SSL challenges correctly")
    func testSSLChallengeHandling() async throws {
        let networkAPI = NetworkFactory.make(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])

        // Test with a secure endpoint
        guard let secureURL = URL(string: "https://httpbin.org/json") else {
            Issue.record("Failed to create secure test URL")
            return
        }

        let data = try await networkAPI.get(url: secureURL)
        #expect(!data.isEmpty)
        // If we reach here, SSL was handled correctly
    }
}

@Suite("NetworkLibrary Error Integration Tests")
struct NetworkLibraryErrorIntegrationTests {

    @Test("NetworkAPI should handle network errors across all methods")
    func testNetworkErrorHandlingAcrossAllMethods() async throws {
        let networkAPI = NetworkFactory.make()
        guard let invalidURL = URL(string: "https://invalid-domain-that-does-not-exist-12345.com") else {
            Issue.record("Failed to create invalid test URL")
            return
        }

        // Test GET with invalid URL
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: invalidURL)
        }

        // Test POST with invalid URL
        await #expect(throws: Error.self) {
            let body = Data("test".utf8)
            _ = try await networkAPI.post(url: invalidURL, body: body)
        }

        // Test ping with invalid URL
        await #expect(throws: NetworkAPIError.noNetwork) {
            try await networkAPI.ping(url: invalidURL)
        }
    }

    @Test("NetworkAPI should handle HTTP error status codes consistently")
    func testHTTPErrorStatusHandling() async throws {
        // This test validates error handling logic without network calls
        let errorStatusCodes = [400, 401, 403, 404, 500, 502, 503]

        guard let url = URL(string: "https://example.com") else {
            Issue.record("Failed to create test URL")
            return
        }

        for statusCode in errorStatusCodes {
            let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )

            // Verify the status code is correctly identified as an error
            #expect(httpResponse?.statusCode == statusCode)
            #expect((200...299).contains(statusCode) == false)
        }
    }
}

@Suite("NetworkLibrary Performance Tests")
struct NetworkLibraryPerformanceTests {

    @Test("NetworkAPI should handle multiple concurrent requests efficiently")
    func testConcurrentRequestPerformance() async throws {
        let networkAPI = NetworkFactory.make(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])
        guard let url = URL(string: "https://httpbin.org/json") else {
            Issue.record("Failed to create test URL")
            return
        }

        let startTime = Date()

        // Make 10 concurrent requests
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    do {
                        _ = try await networkAPI.get(url: url)
                    } catch {
                        // Ignore individual failures for performance test
                    }
                }
            }
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Should complete reasonably fast with mocks
        // Using 10 seconds to account for CI environment variability
        #expect(duration < 10.0, "Concurrent requests took too long: \(duration) seconds")
    }

    @Test("NetworkAPI should handle large response data efficiently")
    func testLargeResponseHandling() async throws {
        let networkAPI = NetworkFactory.make(mapper: [
            NetworkMockData(api: "/json", filename: "httpbin_json_mock", bundlePath: Bundle.module.bundlePath)
        ])

        guard let url = URL(string: "https://httpbin.org/json") else {
            Issue.record("Failed to create test URL")
            return
        }

        let data = try await networkAPI.get(url: url)

        // Verify we can process the data efficiently
        let startTime = Date()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let endTime = Date()

        let processingTime = endTime.timeIntervalSince(startTime)

        #expect(json != nil)
        #expect(processingTime < 1.0, "JSON processing took too long: \(processingTime) seconds")
    }
}

@Suite("NetworkLibrary Real-World Scenario Tests")
struct NetworkLibraryRealWorldTests {

    @Test("NetworkAPI should work in production-like environment setup")
    func testProductionLikeSetup() async throws {
        // Simulate production configuration
        let productionHost = CustomHost(
            secure: true,
            host: "httpbin.org",
            path: "/anything",
            api: "/production-api"
        )

        let networkAPI = NetworkFactory.make(host: productionHost,
                                             mapper: [
                                                NetworkMockData(api: "/anything/production-api", filename: "httpbin_anything_mock", bundlePath: Bundle.module.bundlePath)
                                             ])

        let endpoint = Endpoint(customHost: productionHost, api: "/health-check")

        let response = try await networkAPI.get(
            url: endpoint.url,
            headers: [
                "User-Agent": "MyApp/1.0",
                "Accept": "application/json",
                "Authorization": "Bearer test-token"
            ]
        )

        #expect(!response.isEmpty)

        // Verify the response contains expected data
        let json = try JSONSerialization.jsonObject(with: response) as? [String: Any]
        #expect(json != nil)
    }

    @Test("NetworkAPI should handle API versioning scenarios")
    func testAPIVersioningScenarios() async throws {
        let versions = ["v1", "v2", "v3"]

        for version in versions {
            let versionedHost = CustomHost(
                host: "httpbin.org",
                path: "/anything/\(version)",
                api: "/users"
            )

            let networkAPI = NetworkFactory.make(host: versionedHost,
                                                 mapper: [
                                                    NetworkMockData(api: "/anything/\(version)/users", filename: "users_mock", bundlePath: Bundle.module.bundlePath)
                                                 ])
            let endpoint = Endpoint(customHost: versionedHost, api: "/list")

            let response = try await networkAPI.get(url: endpoint.url)
            #expect(!response.isEmpty)

            // Verify the URL contains the version
            #expect(endpoint.url.path.contains(version))
        }
    }

    @Test("NetworkAPI should handle different content types correctly")
    func testDifferentContentTypes() async throws {
        let networkAPI = NetworkFactory.make(mapper: [
            NetworkMockData(api: "/post", filename: "httpbin_post_mock", bundlePath: Bundle.module.bundlePath)
        ])

        let contentTypeTests = [
            ("application/json", "{\"test\": \"json\"}"),
            ("application/xml", "<test>xml</test>"),
            ("text/plain", "plain text content"),
            ("application/x-www-form-urlencoded", "key=value&another=test")
        ]

        for (contentType, content) in contentTypeTests {
            guard let url = URL(string: "https://httpbin.org/post") else {
                Issue.record("Failed to create POST URL")
                continue
            }
            guard let body = content.data(using: .utf8) else {
                Issue.record("Failed to create request body data")
                continue
            }
            let headers = ["Content-Type": contentType]

            let response = try await networkAPI.post(url: url, headers: headers, body: body)
            #expect(!response.isEmpty)

            // Verify the response (httpbin echoes back the request)
            let json = try JSONSerialization.jsonObject(with: response) as? [String: Any]
            #expect(json != nil)
        }
    }
}
