import Foundation
@testable import NetworkLibrary
import Testing

// Test implementation of Network protocol for testing
class TestNetworkImplementation: Network {
    var customHost: CustomHost?

    init(customHost: CustomHost? = nil) {
        self.customHost = customHost
    }

    func get(url: URL, headers: [String: String]?) async throws -> Data {
        return Data("GET response".utf8)
    }

    func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data {
        return Data("POST response".utf8)
    }

    func ping(url: URL) async throws {
        // Mock implementation - does nothing
    }
}

@Suite("Network Protocol Tests")
struct NetworkProtocolTests {

    @Test("Network protocol default methods should use correct parameters")
    func testNetworkProtocolDefaultMethods() async throws {
        let network = TestNetworkImplementation()
        guard let url = URL(string: "https://api.example.com/test") else {
            Issue.record("Failed to create test URL")
            return
        }
        let headers = ["Authorization": "Bearer token"]
        let body = Data("test body".utf8)

        // Test GET with default headers parameter
        let getResponse = try await network.get(url: url)
        #expect(!getResponse.isEmpty)

        // Test GET with headers
        let getResponseWithHeaders = try await network.get(url: url, headers: headers)
        #expect(!getResponseWithHeaders.isEmpty)

        // Test POST with default headers parameter
        let postResponse = try await network.post(url: url, body: body)
        #expect(!postResponse.isEmpty)

        // Test POST with headers
        let postResponseWithHeaders = try await network.post(url: url, headers: headers, body: body)
        #expect(!postResponseWithHeaders.isEmpty)
    }
}

@Suite("Network Protocol Bundle Tests")
struct NetworkProtocolBundleTests {

    @Test("Network protocol should extract filename from file URL correctly")
    func testFilenameExtraction() throws {
        let testCases = [
            ("file:///path/to/data.json", "data.json"),
            ("file:///simple.json", "simple.json"),
            ("file:///complex/nested/path/file.json", "file.json"),
            ("file:///file-with-dashes.json", "file-with-dashes.json"),
            ("file:///file_with_underscores.json", "file_with_underscores.json")
        ]

        for (urlString, expectedFilename) in testCases {
            guard let url = URL(string: urlString) else {
                Issue.record("Failed to create URL from: \(urlString)")
                continue
            }
            let components = url.absoluteString.components(separatedBy: "/")
            let extractedFilename = components.last

            #expect(extractedFilename == expectedFilename, "Failed to extract '\(expectedFilename)' from '\(urlString)'")
        }
    }
}

// Test implementation that allows creating mock files for testing
class NetworkImplementationWithMockFiles: Network {
    var customHost: CustomHost?
    private let mockFiles: [String: Data]

    init(customHost: CustomHost? = nil, mockFiles: [String: Data] = [:]) {
        self.customHost = customHost
        self.mockFiles = mockFiles
    }

    func get(url: URL, headers: [String: String]?) async throws -> Data {
        return Data("GET response".utf8)
    }

    func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data {
        return Data("POST response".utf8)
    }

    func ping(url: URL) async throws {
        // Mock implementation
    }

    // Override the load method to use mock files
    func load(file: String, bundle: Bundle?) throws -> Data {
        if let mockData = mockFiles[file] {
            return mockData
        }
        throw NetworkAPIError.network
    }
}

@Suite("Network Protocol Mock File Tests")
struct NetworkProtocolMockFileTests {

    @Test("Network protocol should load mock files successfully")
    func testNetworkProtocolMockFileLoading() throws {
        let mockData = Data("{\"message\": \"test data\"}".utf8)
        let mockFiles = ["test_file": mockData]
        let network = NetworkImplementationWithMockFiles(mockFiles: mockFiles)

        let loadedData = try network.load(file: "test_file", bundle: nil)
        #expect(loadedData == mockData)

        let dataString = String(data: loadedData, encoding: .utf8)
        #expect(dataString == "{\"message\": \"test data\"}")
    }

    @Test("Network protocol should throw error for non-existent mock files")
    func testNetworkProtocolNonExistentMockFiles() throws {
        let mockFiles: [String: Data] = [:]
        let network = NetworkImplementationWithMockFiles(mockFiles: mockFiles)

        do {
            _ = try network.load(file: "missing_file", bundle: nil)
            #expect(Bool(false), "Should throw error for missing file")
        } catch NetworkAPIError.network {
            // Expected
        }
    }
}
