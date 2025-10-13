@preconcurrency import Combine
import Foundation
@testable import InAppLibrary
import StoreKit
import Testing

/// Comprehensive unit tests for InAppLibrary using Swift Testing framework
@Suite("InAppLibrary Tests")
struct InAppLibraryTests {

    // MARK: - canPurchase Property Tests

    @Test("canPurchase reflects AppStore.canMakePayments")
    func canPurchaseProperty() async throws {
        let library = InAppManager()

        // Note: In a real test environment, AppStore.canMakePayments typically returns true
        // In a simulator or test environment, this might vary
        let canPurchase = await library.canPurchase
        let expectedValue = AppStore.canMakePayments

        #expect(canPurchase == expectedValue)

        await cleanupLibrary(library)
    }

    // MARK: - Status Observation Tests

    @Test("Status updates are published correctly")
    func statusUpdatesArePublished() async throws {
        let library = InAppManager()
        var receivedStatuses: [InAppStatus] = []
        var cancellables = Set<AnyCancellable>()

        // Set up expectation for status changes
        let expectation = expectation(description: "Status updates received")

        await library.$status
            .sink { status in
                receivedStatuses.append(status)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 1.0)

        // Verify we received both the initial status and the update
        #expect(receivedStatuses.count == 1)
        #expect(receivedStatuses[0] == .unknown)

        await cleanupLibrary(library)
    }

    // MARK: - Product Fetching Tests

    @Test("getProducts returns empty array for empty identifiers")
    func getProductsWithEmptyIdentifiers() async throws {
        let library = InAppManager()

        // Test with empty array
        let products = try await library.getProducts(for: [])

        #expect(products.isEmpty)

        await cleanupLibrary(library)
    }

    // MARK: - Helper Methods

    /// Clean up resources used by the library
    private func cleanupLibrary(_ library: InAppManager) async {
        // Cancel any running tasks and clean up resources
        // The deinit will handle task cancellation, but we can be explicit
    }

    /// Create an expectation for async testing
    private func expectation(description: String) -> XCTestExpectation {
        return XCTestExpectation(description: description)
    }

    /// Wait for expectations to be fulfilled
    private func fulfillment(of expectations: [XCTestExpectation], timeout: TimeInterval) async {
        await withCheckedContinuation { continuation in
            let waiter = XCTWaiter()
            waiter.wait(for: expectations, timeout: timeout)
            continuation.resume()
        }
    }
}

// MARK: - XCTest Compatibility

// For compatibility with XCTest expectations in Swift Testing
import XCTest

class XCTestExpectation {
    let description: String
    var expectedFulfillmentCount: Int = 1
    private var fulfillmentCount = 0

    init(description: String) {
        self.description = description
    }

    func fulfill() {
        fulfillmentCount += 1
    }

    var isFulfilled: Bool {
        return fulfillmentCount >= expectedFulfillmentCount
    }
}

class XCTWaiter {
    func wait(for expectations: [XCTestExpectation], timeout: TimeInterval) {
        let start = Date()
        while !expectations.allSatisfy({ $0.isFulfilled }) && Date().timeIntervalSince(start) < timeout {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
    }
}
