import Foundation
@testable import InAppLibrary
import StoreKit
import Testing

/// Comprehensive unit tests for InAppLibrary using Swift Testing framework
@Suite("InAppLibrary Tests")
@MainActor
struct InAppLibraryTests {

    // MARK: - canPurchase Property Tests

    @Test("canPurchase reflects AppStore.canMakePayments")
    func canPurchaseProperty() async throws {
        let library = InAppManager()

        // Note: In a real test environment, AppStore.canMakePayments typically returns true
        // In a simulator or test environment, this might vary
        let canPurchase = library.canPurchase
        let expectedValue = AppStore.canMakePayments

        #expect(canPurchase == expectedValue)

        await cleanupLibrary(library)
    }

    // MARK: - Status Property Tests

    @Test("Status is initialized to unknown")
    func statusInitialValue() async throws {
        let library = InAppManager()

        // Verify initial status
        #expect(library.status == .unknown)

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
}
