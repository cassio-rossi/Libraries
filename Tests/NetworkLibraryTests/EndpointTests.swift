import Foundation
@testable import NetworkLibrary
import Testing

@Suite("CustomHost Tests")
struct CustomHostTests {

    @Test("CustomHost should initialize with secure defaults")
    func testCustomHostSecureDefaults() throws {
        let host = CustomHost(host: "api.example.com")

        #expect(host.secure == true)
        #expect(host.host == "api.example.com")
        #expect(host.port == nil)
        #expect(host.path == nil)
        #expect(host.api == nil)
        #expect(host.queryItems == nil)
    }

    @Test("CustomHost should initialize with all parameters")
    func testCustomHostFullInitialization() throws {
        let queryItems = [URLQueryItem(name: "version", value: "1.0")]
        let host = CustomHost(
            secure: false,
            host: "dev-api.example.com",
            port: 8080,
            path: "/v2",
            api: "/users",
            queryItems: queryItems
        )

        #expect(host.secure == false)
        #expect(host.host == "dev-api.example.com")
        #expect(host.port == 8080)
        #expect(host.path == "/v2")
        #expect(host.api == "/users")
        #expect(host.queryItems?.count == 1)
        #expect(host.queryItems?.first?.name == "version")
        #expect(host.queryItems?.first?.value == "1.0")
    }

    @Test("CustomHost should handle edge cases")
    func testCustomHostEdgeCases() throws {
        // Test with empty strings
        let hostWithEmptyStrings = CustomHost(
            host: "",
            path: "",
            api: ""
        )

        #expect(hostWithEmptyStrings.host.isEmpty)
        guard let path = hostWithEmptyStrings.path,
              let api = hostWithEmptyStrings.api else {
            Issue.record("…")
            return
        }
        #expect(path.isEmpty)
        #expect(api.isEmpty)

        // Test with special characters
        let hostWithSpecialChars = CustomHost(
            host: "api-test.example.co.uk",
            path: "/v1/special-chars",
            api: "/users_profile"
        )

        #expect(hostWithSpecialChars.host == "api-test.example.co.uk")
        #expect(hostWithSpecialChars.path == "/v1/special-chars")
        #expect(hostWithSpecialChars.api == "/users_profile")
    }

    @Test("CustomHost should be Sendable")
    func testCustomHostSendable() async throws {
        let host = CustomHost(host: "api.example.com", api: "/test")

        // Test that CustomHost can be used in async context
        await withCheckedContinuation { continuation in
            Task {
                let receivedHost = host
                #expect(receivedHost.host == "api.example.com")
                continuation.resume()
            }
        }
    }
}

@Suite("Endpoint Tests")
struct EndpointTests {

    @Test("Endpoint should initialize with CustomHost")
    func testEndpointInitialization() throws {
        let customHost = CustomHost(
            secure: true,
            host: "api.example.com",
            port: 443,
            path: "/v1",
            api: "/users"
        )

        let endpoint = Endpoint(customHost: customHost, api: "/override")

        #expect(endpoint.host == "api.example.com")
        #expect(endpoint.port == 443)
        #expect(endpoint.path == "/v1")
        #expect(endpoint.api == "/users") // Should use customHost.api, not the override
        #expect(endpoint.isSecure == true)
    }

    @Test("Endpoint should use override API when CustomHost API is nil")
    func testEndpointAPIOverride() throws {
        let customHost = CustomHost(host: "api.example.com", path: "/v1")
        let endpoint = Endpoint(customHost: customHost, api: "/posts")

        #expect(endpoint.api == "/posts")
    }

    @Test("Endpoint should handle path formatting")
    func testEndpointPathFormatting() throws {
        // Test path without leading slash
        let customHostNoSlash = CustomHost(host: "api.example.com", path: "v1")
        let endpointNoSlash = Endpoint(customHost: customHostNoSlash, api: "/users")

        #expect(endpointNoSlash.path == "/v1")

        // Test path with leading slash
        let customHostWithSlash = CustomHost(host: "api.example.com", path: "/v1")
        let endpointWithSlash = Endpoint(customHost: customHostWithSlash, api: "/users")

        #expect(endpointWithSlash.path == "/v1")

        // Test empty path
        let customHostEmpty = CustomHost(host: "api.example.com", path: "")
        let endpointEmpty = Endpoint(customHost: customHostEmpty, api: "/users")

        #expect(endpointEmpty.path == nil)
    }

    @Test("Endpoint should generate correct URLs")
    func testEndpointURLGeneration() throws {
        let customHost = CustomHost(
            secure: true,
            host: "api.example.com",
            port: nil,
            path: "/v1",
            api: "/users"
        )

        let endpoint = Endpoint(customHost: customHost, api: "/posts")
        let url = endpoint.url

        #expect(url.scheme == "https")
        #expect(url.host == "api.example.com")
        #expect(url.port == nil)
        #expect(url.path == "/v1/users")
        #expect(url.query == nil)
    }

    @Test("Endpoint should generate URLs with port")
    func testEndpointURLWithPort() throws {
        let customHost = CustomHost(
            secure: false,
            host: "localhost",
            port: 8080,
            path: "/api",
            api: "/test"
        )

        let endpoint = Endpoint(customHost: customHost, api: "/override")
        let url = endpoint.url

        #expect(url.scheme == "http")
        #expect(url.host == "localhost")
        #expect(url.port == 8080)
        #expect(url.path == "/api/test")
    }

    @Test("Endpoint should generate URLs with query items")
    func testEndpointURLWithQueryItems() throws {
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10")
        ]

        let customHost = CustomHost(
            host: "api.example.com",
            path: "/v1",
            api: "/users",
            queryItems: queryItems
        )

        let endpoint = Endpoint(customHost: customHost, api: "/posts")
        let url = endpoint.url

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.count == 2)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "page", value: "1")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "limit", value: "10")) == true)
    }

    @Test("Endpoint should override query items correctly")
    func testEndpointQueryItemsOverride() throws {
        let hostQueryItems = [URLQueryItem(name: "host_param", value: "host_value")]
        let endpointQueryItems = [URLQueryItem(name: "endpoint_param", value: "endpoint_value")]

        let customHost = CustomHost(
            host: "api.example.com",
            api: "/users",
            queryItems: hostQueryItems
        )

        let endpoint = Endpoint(
            customHost: customHost,
            api: "/posts",
            queryItems: endpointQueryItems
        )

        // Should use host query items, not endpoint query items
        #expect(endpoint.queryItems?.count == 1)
        #expect(endpoint.queryItems?.first?.name == "host_param")
    }

    @Test("Endpoint should generate correct REST API path")
    func testEndpointRestAPI() throws {
        let customHost = CustomHost(
            host: "api.example.com",
            path: "/v1",
            api: "/users"
        )

        let endpoint = Endpoint(customHost: customHost, api: "/posts")

        #expect(endpoint.restAPI == "/v1/users")

        // Test without path
        let customHostNoPath = CustomHost(host: "api.example.com", api: "/users")
        let endpointNoPath = Endpoint(customHost: customHostNoPath, api: "/posts")

        #expect(endpointNoPath.restAPI == "/users")
    }

    @Test("Endpoint URL generation should not crash with invalid components")
    func testEndpointURLValidation() throws {
        // Test that valid components always produce valid URLs
        let customHost = CustomHost(
            host: "valid-host.com",
            path: "/valid/path",
            api: "/valid-api"
        )

        let endpoint = Endpoint(customHost: customHost, api: "/valid-override")
        let url = endpoint.url

        #expect(!url.absoluteString.isEmpty)

        // Test edge case with special characters that should still be valid
        let customHostSpecial = CustomHost(
            host: "api-test.example.co.uk",
            path: "/v1.0",
            api: "/users-list"
        )

        let endpointSpecial = Endpoint(customHost: customHostSpecial, api: "/posts_archive")
        let urlSpecial = endpointSpecial.url

        #expect(!urlSpecial.absoluteString.isEmpty)
    }
}

@Suite("Endpoint Integration Tests")
struct EndpointIntegrationTests {

    @Test("Endpoint should work with real-world scenarios")
    func testEndpointRealWorldScenarios() throws {
        // Production-like configuration
        let productionHost = CustomHost(
            secure: true,
            host: "api.myapp.com",
            path: "/v2",
            api: "/users"
        )

        let userEndpoint = Endpoint(customHost: productionHost, api: "/profile")
        let userUrl = userEndpoint.url

        #expect(userUrl.absoluteString == "https://api.myapp.com/v2/users")

        // Development configuration with port
        let devHost = CustomHost(
            secure: false,
            host: "localhost",
            port: 3000,
            path: "/api/v1",
            api: "/test"
        )

        let devEndpoint = Endpoint(customHost: devHost, api: "/debug")
        let devUrl = devEndpoint.url

        #expect(devUrl.absoluteString == "http://localhost:3000/api/v1/test")

        // API with query parameters
        let queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "include", value: "metadata")
        ]

        let queryHost = CustomHost(
            host: "data.example.com",
            path: "/v3",
            api: "/reports",
            queryItems: queryItems
        )

        let queryEndpoint = Endpoint(customHost: queryHost, api: "/analytics")
        let queryUrl = queryEndpoint.url

        #expect(queryUrl.host == "data.example.com")
        #expect(queryUrl.path == "/v3/reports")
        #expect(queryUrl.query?.contains("format=json") == true)
        #expect(queryUrl.query?.contains("include=metadata") == true)
    }
}
