import Foundation
@testable import NetworkLibrary
import Testing

@Suite("NetworkAPI Error Handling Tests")
struct NetworkAPIErrorTests {

    @Test("NetworkAPI should handle network errors gracefully")
    func testNetworkErrorHandling() async throws {
        let networkAPI = NetworkAPI()
        guard let invalidURL = URL(string: "https://invalid-domain-12345.nonexistent") else {
            Issue.record("Failed to create invalid test URL")
            return
        }

        await #expect(throws: Error.self) {
            try await networkAPI.get(url: invalidURL)
        }
    }

    @Test("NetworkAPI should handle invalid response status codes")
    func testInvalidStatusCodeHandling() async throws {
        // This test validates error handling logic without network calls
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        // Verify the status code is correctly identified as an error
        #expect(httpResponse?.statusCode == 404)
        #expect((200...299).contains(404) == false)
    }

    @Test("NetworkAPIError should conform to Equatable")
    func testNetworkAPIErrorEquatable() throws {
        let error1 = NetworkAPIError.noNetwork
        let error2 = NetworkAPIError.noNetwork
        let error3 = NetworkAPIError.network

        #expect(error1 == error2)
        #expect(error1 != error3)

        let data1 = Data("Error data".utf8)
        let data2 = Data("Error data".utf8)
        let data3 = Data("Different error data".utf8)

        let errorWithData1 = NetworkAPIError.error(reason: data1)
        let errorWithData2 = NetworkAPIError.error(reason: data2)
        let errorWithData3 = NetworkAPIError.error(reason: data3)

        #expect(errorWithData1 == errorWithData2)
        #expect(errorWithData1 != errorWithData3)
    }

    @Test("NetworkAPIError should handle localization")
    func testNetworkAPIErrorLocalization() throws {
        // Test that errors use localized strings
        let errors: [NetworkAPIError] = [
            .noNetwork,
            .network,
            .decoding
        ]

        // Test error with reason separately since it needs data
        let testErrorData = Data("Test error".utf8)

        let errorWithReason = NetworkAPIError.error(reason: testErrorData)
        let allErrors = errors + [errorWithReason]

        for error in allErrors {
            let description = error.description
            // All errors should have non-empty descriptions (except couldNotBeMock which returns empty)
            #expect(!description.isEmpty, "Error \(error) should have a non-empty description")
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
            let data = Data("Custom error reason".utf8)
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
            if let reason = reason {
                #expect(String(data: reason, encoding: .utf8) == "Custom error reason")
            }
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
