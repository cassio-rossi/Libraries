import Foundation
import Testing
@testable import NetworkLibrary

// Test implementation of Network protocol for testing
class TestNetworkImplementation: Network {
    var customHost: CustomHost?
    var mock: [NetworkMockData]?
    
    init(customHost: CustomHost? = nil, mock: [NetworkMockData]? = nil) {
        self.customHost = customHost
        self.mock = mock
    }
    
    func get(url: URL, headers: [String : String]?) async throws -> Data {
        return "GET response".data(using: .utf8)!
    }
    
    func post(url: URL, headers: [String : String]?, body: Data) async throws -> Data {
        return "POST response".data(using: .utf8)!
    }
    
    func ping(url: URL) async throws {
        // Mock implementation - does nothing
    }
}

@Suite("Network Protocol Tests")
struct NetworkProtocolTests {
    
    @Test("Network protocol should provide default get implementation with file URL")
    func testNetworkProtocolFileGet() throws {
        let network = TestNetworkImplementation()
        let fileURL = URL(string: "file:///path/to/test.json")!
        
        // This should call the default implementation
        do {
            _ = try network.get(file: fileURL, bundle: nil)
            #expect(Bool(false), "Should throw error for non-existent file")
        } catch NetworkAPIError.network {
            // Expected for non-existent file
        }
    }
    
    @Test("Network protocol should provide default load implementation")
    func testNetworkProtocolLoad() throws {
        let network = TestNetworkImplementation()
        
        // Test with non-existent file
        do {
            _ = try network.load(file: "nonexistent", bundle: nil)
            #expect(Bool(false), "Should throw error for non-existent file")
        } catch NetworkAPIError.network {
            // Expected for non-existent file
        }
    }
    
    @Test("Network protocol should handle file URL parsing correctly")
    func testFileURLParsing() throws {
        let network = TestNetworkImplementation()
        
        // Test various file URL formats
        let fileURLs = [
            "file:///Users/test/Documents/data.json",
            "file://localhost/path/to/file.json",
            "file:///simple.json"
        ]
        
        for urlString in fileURLs {
            let url = URL(string: urlString)!
            
            do {
                _ = try network.get(file: url, bundle: nil)
                #expect(Bool(false), "Should throw error for non-existent file")
            } catch NetworkAPIError.network {
                // Expected for non-existent files
            }
        }
    }
    
    @Test("Network protocol should handle malformed file URLs")
    func testMalformedFileURLs() throws {
        let network = TestNetworkImplementation()
        
        // URLs that might cause parsing issues
        let problematicURLs = [
            "file://",
            "file:///",
            "file:///."
        ]
        
        for urlString in problematicURLs {
            let url = URL(string: urlString)!
            
            do {
                _ = try network.get(file: url, bundle: nil)
                #expect(Bool(false), "Should throw error for malformed URL")
            } catch NetworkAPIError.network {
                // Expected for malformed URLs
            }
        }
    }
    
    @Test("Network protocol default methods should use correct parameters")
    func testNetworkProtocolDefaultMethods() async throws {
        let network = TestNetworkImplementation()
        let url = URL(string: "https://api.example.com/test")!
        let headers = ["Authorization": "Bearer token"]
        let body = "test body".data(using: .utf8)!
        
        // Test GET with default headers parameter
        let getResponse = try await network.get(url: url)
        #expect(getResponse.count > 0)
        
        // Test GET with headers
        let getResponseWithHeaders = try await network.get(url: url, headers: headers)
        #expect(getResponseWithHeaders.count > 0)
        
        // Test POST with default headers parameter
        let postResponse = try await network.post(url: url, body: body)
        #expect(postResponse.count > 0)
        
        // Test POST with headers
        let postResponseWithHeaders = try await network.post(url: url, headers: headers, body: body)
        #expect(postResponseWithHeaders.count > 0)
    }
}

@Suite("Network Protocol Bundle Tests")
struct NetworkProtocolBundleTests {
    
    @Test("Network protocol should handle different bundle types")
    func testNetworkProtocolBundleHandling() throws {
        let network = TestNetworkImplementation()
        
        // Test with main bundle
        do {
            _ = try network.load(file: "nonexistent", bundle: .main)
            #expect(Bool(false), "Should throw error for non-existent file")
        } catch NetworkAPIError.network {
            // Expected
        }
        
        // Test with module bundle
        do {
            _ = try network.load(file: "nonexistent", bundle: .module)
            #expect(Bool(false), "Should throw error for non-existent file")
        } catch NetworkAPIError.network {
            // Expected
        }
        
        // Test with nil bundle (should default to main)
        do {
            _ = try network.load(file: "nonexistent", bundle: nil)
            #expect(Bool(false), "Should throw error for non-existent file")
        } catch NetworkAPIError.network {
            // Expected
        }
    }
    
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
            let url = URL(string: urlString)!
            let components = url.absoluteString.components(separatedBy: "/")
            let extractedFilename = components.last
            
            #expect(extractedFilename == expectedFilename, "Failed to extract '\(expectedFilename)' from '\(urlString)'")
        }
    }
}

@Suite("Network Protocol Error Handling Tests")
struct NetworkProtocolErrorHandlingTests {
    
    @Test("Network protocol should throw appropriate errors for invalid scenarios")
    func testNetworkProtocolErrorScenarios() throws {
        let network = TestNetworkImplementation()
        
        // Test empty file URL
        let emptyURL = URL(string: "file://")!
        
        do {
            _ = try network.get(file: emptyURL, bundle: nil)
            #expect(Bool(false), "Should throw error for empty file URL")
        } catch NetworkAPIError.network {
            // Expected
        }
        
        // Test file loading with various invalid filenames
        let invalidFilenames = ["", " ", "nonexistent", "missing.json", "../../../etc/passwd"]
        
        for filename in invalidFilenames {
            do {
                _ = try network.load(file: filename, bundle: .main)
                #expect(Bool(false), "Should throw error for invalid filename: \(filename)")
            } catch NetworkAPIError.network {
                // Expected
            }
        }
    }
    
    @Test("Network protocol should handle bundle resource loading edge cases")
    func testBundleResourceLoadingEdgeCases() throws {
        let network = TestNetworkImplementation()
        
        // Test with special characters in filename
        let specialFilenames = [
            "file with spaces",
            "file-with-dashes",
            "file_with_underscores",
            "file.with.dots",
            "file123numbers"
        ]
        
        for filename in specialFilenames {
            do {
                _ = try network.load(file: filename, bundle: .main)
                #expect(Bool(false), "Should throw error for non-existent file: \(filename)")
            } catch NetworkAPIError.network {
                // Expected for non-existent files
            }
        }
    }
}

// Test implementation that allows creating mock files for testing
class NetworkImplementationWithMockFiles: Network {
    var customHost: CustomHost?
    var mock: [NetworkMockData]?
    private let mockFiles: [String: Data]
    
    init(customHost: CustomHost? = nil, mock: [NetworkMockData]? = nil, mockFiles: [String: Data] = [:]) {
        self.customHost = customHost
        self.mock = mock
        self.mockFiles = mockFiles
    }
    
    func get(url: URL, headers: [String : String]?) async throws -> Data {
        return "GET response".data(using: .utf8)!
    }
    
    func post(url: URL, headers: [String : String]?, body: Data) async throws -> Data {
        return "POST response".data(using: .utf8)!
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
        let mockData = "{\"message\": \"test data\"}".data(using: .utf8)!
        let mockFiles = ["test_file": mockData]
        let network = NetworkImplementationWithMockFiles(mockFiles: mockFiles)
        
        let loadedData = try network.load(file: "test_file", bundle: nil)
        #expect(loadedData == mockData)
        
        let dataString = String(data: loadedData, encoding: .utf8)
        #expect(dataString == "{\"message\": \"test data\"}")
    }
    
    @Test("Network protocol should handle file URL with mock files")
    func testNetworkProtocolFileURLWithMockFiles() throws {
        let mockData = "{\"users\": []}".data(using: .utf8)!
        let mockFiles = ["users.json": mockData]
        let network = NetworkImplementationWithMockFiles(mockFiles: mockFiles)
        
        let fileURL = URL(string: "file:///path/to/users.json")!
        let loadedData = try network.get(file: fileURL, bundle: nil)
        
        #expect(loadedData == mockData)
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
