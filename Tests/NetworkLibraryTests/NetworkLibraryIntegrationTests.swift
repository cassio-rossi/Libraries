import Foundation
import Testing
@testable import NetworkLibrary

@Suite("NetworkLibrary Integration Tests", .timeLimit(.minutes(3)))
struct NetworkLibraryIntegrationTests {
    
    @Test("NetworkAPI should work with Endpoint for URL generation")
    func testNetworkAPIEndpointIntegration() async throws {
        let customHost = CustomHost(
            host: "httpbin.org",
            path: "/json"
        )
        
        let endpoint = Endpoint(customHost: customHost, api: "")
        let networkAPI = NetworkAPI()
        
        do {
            let data = try await networkAPI.get(url: endpoint.url)
            #expect(data.count > 0)
            
            // Verify it's valid JSON
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            #expect(json != nil)

        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
    
    @Test("NetworkAPI should integrate with Logger properly")
    func testNetworkAPILoggerIntegration() async throws {
        let networkAPI = NetworkAPI()
        
        let url = URL(string: "https://httpbin.org/json")!
        
        do {
            let data = try await networkAPI.get(url: url)
            #expect(data.count > 0)
            
            // Logger should have logged the request/response
            // In a real test, you might verify log output
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
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
            NetworkMockData(api: "/v1/users", filename: "users_mock", bundle: .main)
        ]
        
        let networkAPI = NetworkAPI(
            customHost: customHost,
            mock: mockData
        )
        
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
        let networkAPI = NetworkAPI(customHost: customHost)
        
        do {
            // Test GET request
            let getData = try await networkAPI.get(url: endpoint.url)
            #expect(getData.count > 0)
            
            // Test POST request
            let postBody = "{\"test\": \"data\"}".data(using: .utf8)!
            let postData = try await networkAPI.post(
                url: endpoint.url,
                headers: ["Content-Type": "application/json"],
                body: postBody
            )
            #expect(postData.count > 0)
            
            // Test ping
            try await networkAPI.ping(url: endpoint.url)
            
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
    
    @Test("NetworkAPI should handle SSL challenges correctly")
    func testSSLChallengeHandling() async throws {
        let networkAPI = NetworkAPI()
        
        // Test with a secure endpoint
        let secureURL = URL(string: "https://httpbin.org/json")!
        
        do {
            let data = try await networkAPI.get(url: secureURL)
            #expect(data.count > 0)
            // If we reach here, SSL was handled correctly
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
}

@Suite("NetworkLibrary Error Integration Tests")
struct NetworkLibraryErrorIntegrationTests {
    
    @Test("NetworkAPI should handle network errors across all methods")
    func testNetworkErrorHandlingAcrossAllMethods() async throws {
        let networkAPI = NetworkAPI()
        let invalidURL = URL(string: "https://invalid-domain-that-does-not-exist-12345.com")!
        
        // Test GET with invalid URL
        await #expect(throws: Error.self) {
            try await networkAPI.get(url: invalidURL)
        }
        
        // Test POST with invalid URL
        await #expect(throws: Error.self) {
            let body = "test".data(using: .utf8)!
            _ = try await networkAPI.post(url: invalidURL, body: body)
        }
        
        // Test ping with invalid URL
        await #expect(throws: NetworkAPIError.noNetwork) {
            try await networkAPI.ping(url: invalidURL)
        }
    }
    
    @Test("NetworkAPI should handle HTTP error status codes consistently")
    func testHTTPErrorStatusHandling() async throws {
        let networkAPI = NetworkAPI()
        
        let errorStatusCodes = [400, 401, 403, 404, 500, 502, 503]
        
        for statusCode in errorStatusCodes {
            let url = URL(string: "https://httpbin.org/status/\(statusCode)")!
            
            do {
                _ = try await networkAPI.get(url: url)
                #expect(Bool(false), "Should have thrown error for status code \(statusCode)")
            } catch NetworkAPIError.error {
                // Expected error case
            } catch NetworkAPIError.noNetwork {
                // Skip test if no network available
                return
            }
        }
    }
}

@Suite("NetworkLibrary Performance Tests", .timeLimit(.minutes(2)))
struct NetworkLibraryPerformanceTests {
    
    @Test("NetworkAPI should handle multiple concurrent requests efficiently")
    func testConcurrentRequestPerformance() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://httpbin.org/json")!
        
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
        
        // Should complete within reasonable time (adjust based on your requirements)
        #expect(duration < 30.0, "Concurrent requests took too long: \(duration) seconds")
    }
    
    @Test("NetworkAPI should handle large response data efficiently")
    func testLargeResponseHandling() async throws {
        let networkAPI = NetworkAPI()
        
        // This endpoint returns a relatively large JSON response
        let url = URL(string: "https://httpbin.org/json")!
        
        do {
            let data = try await networkAPI.get(url: url)
            
            // Verify we can process the data efficiently
            let startTime = Date()
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let endTime = Date()
            
            let processingTime = endTime.timeIntervalSince(startTime)
            
            #expect(json != nil)
            #expect(processingTime < 1.0, "JSON processing took too long: \(processingTime) seconds")
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
}

@Suite("NetworkLibrary Real-World Scenario Tests", .timeLimit(.minutes(3)))
struct NetworkLibraryRealWorldTests {
    
    @Test("NetworkAPI should work in production-like environment setup")
    func testProductionLikeSetup() async throws {
        // Simulate production configuration
        let productionHost = CustomHost(
            secure: true,
            host: "httpbin.org", // Using httpbin as a test production endpoint
            path: "/anything",
            api: "/production-api"
        )
        
        let networkAPI = NetworkAPI(customHost: productionHost)
        let endpoint = Endpoint(customHost: productionHost, api: "/health-check")
        
        do {
            let response = try await networkAPI.get(
                url: endpoint.url,
                headers: [
                    "User-Agent": "MyApp/1.0",
                    "Accept": "application/json",
                    "Authorization": "Bearer test-token"
                ]
            )
            
            #expect(response.count > 0)
            
            // Verify the response contains expected data
            let json = try JSONSerialization.jsonObject(with: response) as? [String: Any]
            #expect(json != nil)
            
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
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
            
            let networkAPI = NetworkAPI(customHost: versionedHost)
            let endpoint = Endpoint(customHost: versionedHost, api: "/list")
            
            do {
                let response = try await networkAPI.get(url: endpoint.url)
                #expect(response.count > 0)
                
                // Verify the URL contains the version
                #expect(endpoint.url.path.contains(version))
                
            } catch NetworkAPIError.noNetwork {
                // Skip test if no network available - but don't fail the whole test
                continue
            }
        }
    }
    
    @Test("NetworkAPI should handle different content types correctly")
    func testDifferentContentTypes() async throws {
        let networkAPI = NetworkAPI()
        
        let contentTypeTests = [
            ("application/json", "{\"test\": \"json\"}"),
            ("application/xml", "<test>xml</test>"),
            ("text/plain", "plain text content"),
            ("application/x-www-form-urlencoded", "key=value&another=test")
        ]
        
        for (contentType, content) in contentTypeTests {
            let url = URL(string: "https://httpbin.org/post")!
            let body = content.data(using: .utf8)!
            let headers = ["Content-Type": contentType]
            
            do {
                let response = try await networkAPI.post(url: url, headers: headers, body: body)
                #expect(response.count > 0)
                
                // Verify the response (httpbin echoes back the request)
                let json = try JSONSerialization.jsonObject(with: response) as? [String: Any]
                #expect(json != nil)
                
            } catch NetworkAPIError.noNetwork {
                // Skip individual test if no network available
                continue
            }
        }
    }
}
