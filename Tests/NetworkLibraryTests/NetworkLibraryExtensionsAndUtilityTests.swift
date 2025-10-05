import Foundation
@testable import NetworkLibrary
import Testing
import UtilityLibrary

@Suite("NetworkLibrary Extensions Tests")
struct NetworkLibraryExtensionsTests {

    @Test("HTTPURLResponse should correctly identify success status codes")
    func testHTTPURLResponseSuccessStatusCodes() throws {
        guard let url = URL(string: "https://example.com") else {
            Issue.record("Failed to create test URL")
            return
        }

        let successCodes = [200, 201, 202, 204, 206, 299]

        for code in successCodes {
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            ) else {
                Issue.record("Failed to create HTTPURLResponse with status code \(code)")
                continue
            }

            #expect(response.hasSuccessStatusCode == true, "Status code \(code) should be success")
        }
    }

    @Test("HTTPURLResponse should correctly identify error status codes")
    func testHTTPURLResponseErrorStatusCodes() throws {
        guard let url = URL(string: "https://example.com") else {
            Issue.record("Failed to create test URL")
            return
        }

        let errorCodes = [100, 199, 300, 301, 400, 401, 404, 500, 502, 503]

        for code in errorCodes {
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            ) else {
                Issue.record("Failed to create HTTPURLResponse with status code \(code)")
                continue
            }

            #expect(response.hasSuccessStatusCode == false, "Status code \(code) should be error")
        }
    }

    @Test("Data should convert to string correctly")
    func testDataToStringConversion() throws {
        let testString = "Hello, World! 🌍"
        guard let testData = testString.data(using: .utf8) else {
            Issue.record("Failed to create test data from string")
            return
        }

        let convertedString = testData.asString
        #expect(convertedString == testString)

        // Test with empty data
        let emptyData = Data()
        guard let emptyString = emptyData.asString else {
            Issue.record("...")
            return
        }
        #expect(emptyString.isEmpty)

        // Test with invalid UTF-8 data
        let invalidData = Data([0xFF, 0xFE])
        let invalidString = invalidData.asString
        #expect(invalidString == nil)
    }

    @Test("Data string conversion should handle various encodings")
    func testDataStringConversionEncodings() throws {
        let testStrings = [
            "Simple ASCII text",
            "UTF-8 with émojis 🚀",
            "中文字符",
            "العربية",
            "Русский текст",
            "Mixed: ASCII + émojis 🎉 + 中文"
        ]

        for testString in testStrings {
            guard let data = testString.data(using: .utf8) else {
                Issue.record("Failed to create data from string: \(testString)")
                continue
            }
            let convertedString = data.asString

            #expect(convertedString == testString, "Failed for string: \(testString)")
        }
    }

    @Test("Data string conversion should handle special characters")
    func testDataStringConversionSpecialChars() throws {
        let specialChars = [
            "\n\r\t",
            "\"quotes\"",
            "'single quotes'",
            "\\backslashes\\",
            "{\"json\": \"value\"}",
            "<xml>content</xml>",
            "Line 1\nLine 2\rLine 3\tTabbed"
        ]

        for specialString in specialChars {
            guard let data = specialString.data(using: .utf8) else {
                Issue.record("Failed to create data from special string: \(specialString)")
                continue
            }
            let convertedString = data.asString

            #expect(convertedString == specialString, "Failed for special chars: \(specialString)")
        }
    }
}

@Suite("NetworkLibrary Utility Functions Tests")
struct NetworkLibraryUtilityTests {

    @Test("URL components should handle various URL formats")
    func testURLComponentsHandling() throws {
        let testURLs = [
            "https://example.com/path",
            "http://localhost:8080/api/v1",
            "https://api.subdomain.example.co.uk:443/v2/users?page=1",
            "https://192.168.1.1:3000/test",
            "https://[::1]:8080/ipv6"
        ]

        for urlString in testURLs {
            guard let url = URL(string: urlString) else {
                Issue.record("Failed to create URL from string: \(urlString)")
                continue
            }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

            #expect(components != nil, "Failed to parse URL: \(urlString)")
            #expect(components?.scheme != nil, "Missing scheme for URL: \(urlString)")
            #expect(components?.host != nil, "Missing host for URL: \(urlString)")
        }
    }

    @Test("URLRequest should handle various HTTP methods")
    func testURLRequestHTTPMethods() throws {
        guard let url = URL(string: "https://example.com/test") else {
            Issue.record("Failed to create test URL")
            return
        }
        let httpMethods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]

        for method in httpMethods {
            var request = URLRequest(url: url)
            request.httpMethod = method

            #expect(request.httpMethod == method)
            #expect(request.url == url)
        }
    }

    @Test("URLRequest should handle headers correctly")
    func testURLRequestHeaders() throws {
        guard let url = URL(string: "https://example.com/test") else {
            Issue.record("Failed to create test URL")
            return
        }
        var request = URLRequest(url: url)

        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer token123",
            "User-Agent": "TestApp/1.0",
            "Accept": "application/json, text/plain",
            "X-Custom-Header": "custom-value"
        ]

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        for (key, expectedValue) in headers {
            let actualValue = request.value(forHTTPHeaderField: key)
            #expect(actualValue == expectedValue, "Header \(key) mismatch")
        }
    }

    @Test("URLRequest should handle body data correctly")
    func testURLRequestBodyData() throws {
        guard let url = URL(string: "https://example.com/test") else {
            Issue.record("Failed to create test URL")
            return
        }
        var request = URLRequest(url: url)

        let simpleStringData = Data("Simple string".utf8)
        let jsonData = Data("{\"json\": \"data\"}".utf8)
        let emptyData = Data("".utf8)

        let testBodies = [
            simpleStringData,
            jsonData,
            Data([0x01, 0x02, 0x03, 0x04]), // Binary data
            emptyData // Empty data
        ]

        for testBody in testBodies {
            request.httpBody = testBody
            #expect(request.httpBody == testBody)
        }
    }
}

@Suite("NetworkLibrary URL Validation Tests")
struct NetworkLibraryURLValidationTests {

    @Test("URL validation should identify valid URLs")
    func testValidURLs() throws {
        let validURLs = [
            "https://example.com",
            "http://localhost",
            "https://api.example.com:443/v1/users",
            "http://192.168.1.1:8080/test",
            "https://subdomain.example.co.uk/path/to/resource",
            "https://example.com/path?param=value&other=test",
            "https://example.com/path#fragment"
        ]

        for urlString in validURLs {
            let url = URL(string: urlString)
            #expect(url != nil, "Should create valid URL for: \(urlString)")
        }
    }

    @Test("URL validation should handle edge cases")
    func testURLEdgeCases() throws {
        // These should still create valid URL objects
        let edgeCaseURLs = [
            "https://example.com/",
            "https://example.com:443",
            "https://example.com/path/",
            "https://example.com?",
            "https://example.com#"
        ]

        for urlString in edgeCaseURLs {
            let url = URL(string: urlString)
            #expect(url != nil, "Should handle edge case URL: \(urlString)")
        }
    }

    @Test("URL query parameter handling should work correctly")
    func testURLQueryParameters() throws {
        guard let baseURL = URL(string: "https://example.com/api") else {
            Issue.record("Failed to create base URL")
            return
        }
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            Issue.record("Failed to create URLComponents from base URL")
            return
        }

        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "sort", value: "name"),
            URLQueryItem(name: "filter", value: "active")
        ]

        components.queryItems = queryItems

        guard let finalURL = components.url else {
            Issue.record("Failed to generate final URL from components")
            return
        }
        guard let finalComponents = URLComponents(url: finalURL, resolvingAgainstBaseURL: false) else {
            Issue.record("Failed to create URLComponents from final URL")
            return
        }

        #expect(finalComponents.queryItems?.count == 4)

        for expectedItem in queryItems {
            let foundItem = finalComponents.queryItems?.first { $0.name == expectedItem.name }
            #expect(foundItem?.value == expectedItem.value)
        }
    }
}
