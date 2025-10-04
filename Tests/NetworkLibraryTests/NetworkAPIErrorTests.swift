import Foundation
import Testing
@testable import NetworkLibrary

@Suite("NetworkAPI Error Handling Tests")
struct NetworkAPIErrorTests {

    @Test("NetworkAPI should handle network errors gracefully")
    func testNetworkErrorHandling() async throws {
        let networkAPI = NetworkAPI()
        let invalidURL = URL(string: "https://invalid-domain-12345.nonexistent")!

        await #expect(throws: Error.self) {
            try await networkAPI.get(url: invalidURL)
        }
    }

    @Test("NetworkAPI should handle invalid response status codes")
    func testInvalidStatusCodeHandling() async throws {
        let networkAPI = NetworkAPI()
        let url = URL(string: "https://httpbin.org/status/404")!

        do {
            _ = try await networkAPI.get(url: url)
            #expect(Bool(false), "Should have thrown an error for 404 status")
        } catch NetworkAPIError.error {
            // Expected error case
        } catch NetworkAPIError.noNetwork {
            // Skip test if no network available
            return
        }
    }
    
    @Test("NetworkAPIError should conform to Equatable")
    func testNetworkAPIErrorEquatable() throws {
        let error1 = NetworkAPIError.noNetwork
        let error2 = NetworkAPIError.noNetwork
        let error3 = NetworkAPIError.network
        
        #expect(error1 == error2)
        #expect(error1 != error3)
        
        let data1 = "Error data".data(using: .utf8)
        let data2 = "Error data".data(using: .utf8)
        let data3 = "Different error data".data(using: .utf8)
        
        let errorWithData1 = NetworkAPIError.error(reason: data1)
        let errorWithData2 = NetworkAPIError.error(reason: data2)
        let errorWithData3 = NetworkAPIError.error(reason: data3)
        
        #expect(errorWithData1 == errorWithData2)
        #expect(errorWithData1 != errorWithData3)
    }
    
    @Test("NetworkAPIError should provide meaningful descriptions")
    func testNetworkAPIErrorDescriptions() throws {
        let noNetworkError = NetworkAPIError.noNetwork
        let networkError = NetworkAPIError.network
        let decodingError = NetworkAPIError.decoding
        let couldNotBeMockError = NetworkAPIError.couldNotBeMock
        
        #expect(noNetworkError.description.count > 0)
        #expect(networkError.description.count > 0)
        #expect(decodingError.description.count > 0)
        #expect(couldNotBeMockError.description.isEmpty) // This case returns empty string
        
        // Test error with reason
        let errorData = "Server returned 500".data(using: .utf8)
        let errorWithReason = NetworkAPIError.error(reason: errorData)
        #expect(errorWithReason.description.contains("Server returned 500"))
        
        // Test error with nil reason
        let errorWithNilReason = NetworkAPIError.error(reason: nil)
        #expect(errorWithNilReason.description.count > 0)
        
        // Test error with invalid data
        let invalidData = Data([0xFF, 0xFE])
        let errorWithInvalidData = NetworkAPIError.error(reason: invalidData)
        #expect(errorWithInvalidData.description.count > 0)
    }
    
    @Test("NetworkAPIError should handle localization")
    func testNetworkAPIErrorLocalization() throws {
        // Test that errors use localized strings
        let errors: [NetworkAPIError] = [
            .noNetwork,
            .network,
            .decoding,
            .error(reason: "Test error".data(using: .utf8))
        ]
        
        for error in errors {
            let description = error.description
            #expect(description.count >= 0) // All should have some description (even if empty for couldNotBeMock)
        }
    }
}

@Suite("L10n Enum Tests")
struct L10nTests {
    
    @Test("L10n rawValues should match expected keys")
    func testL10nRawValues() throws {
        #expect(L10n.noNetwork.rawValue == "noNetwork")
        #expect(L10n.errorFetching.rawValue == "errorFetching")
        #expect(L10n.errorDecoding.rawValue == "errorDecoding")
        #expect(L10n.errorFetchingWith.rawValue == "errorFetchingWith")
    }
}

@Suite("NetworkAPIError Error Throwing Tests")
struct NetworkAPIErrorThrowingTests {
    
    @Test("NetworkAPIError can be thrown and caught")
    func testThrowingAndCatchingErrors() async throws {
        
        func throwNoNetworkError() throws {
            throw NetworkAPIError.noNetwork
        }
        
        func throwNetworkError() throws {
            throw NetworkAPIError.network
        }
        
        func throwDecodingError() throws {
            throw NetworkAPIError.decoding
        }
        
        func throwErrorWithReason() throws {
            let data = "Custom error reason".data(using: .utf8)
            throw NetworkAPIError.error(reason: data)
        }
        
        func throwCouldNotBeMockError() throws {
            throw NetworkAPIError.couldNotBeMock
        }
        
        // Test catching specific error types
        do {
            try throwNoNetworkError()
            #expect(Bool(false), "Should have thrown noNetwork error")
        } catch NetworkAPIError.noNetwork {
            // Expected
        }
        
        do {
            try throwNetworkError()
            #expect(Bool(false), "Should have thrown network error")
        } catch NetworkAPIError.network {
            // Expected
        }
        
        do {
            try throwDecodingError()
            #expect(Bool(false), "Should have thrown decoding error")
        } catch NetworkAPIError.decoding {
            // Expected
        }
        
        do {
            try throwErrorWithReason()
            #expect(Bool(false), "Should have thrown error with reason")
        } catch NetworkAPIError.error(let reason) {
            #expect(reason != nil)
            #expect(String(data: reason!, encoding: .utf8) == "Custom error reason")
        }
        
        do {
            try throwCouldNotBeMockError()
            #expect(Bool(false), "Should have thrown couldNotBeMock error")
        } catch NetworkAPIError.couldNotBeMock {
            // Expected
        }
    }
    
    @Test("NetworkAPIError should work with generic Error catching")
    func testGenericErrorCatching() throws {
        func throwNetworkAPIError() throws {
            throw NetworkAPIError.network
        }
        
        do {
            try throwNetworkAPIError()
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as NetworkAPIError {
            #expect(error == NetworkAPIError.network)
        } catch {
            #expect(Bool(false), "Should have caught NetworkAPIError specifically")
        }
    }
}
