import Combine
import Foundation
import LoggerLibrary
import StoreKit

/// Manages in-app purchases and subscriptions using StoreKit 2.
///
/// ``InAppManager`` provides an async/await interface for product fetching, purchases, transaction verification, and restoration.
/// The manager automatically handles transaction verification and background monitoring.
///
/// Use ``getProducts(for:)`` to fetch products, ``purchase(_:)`` to initiate purchases, and ``restore()`` to restore previous purchases.
/// Subscribe to the ``status`` property to receive purchase updates.
///
/// - Important: Requires StoreKit 2 and iOS 15.0 or later.
public final actor InAppManager: ObservableObject {
    /// The current status of purchase operations.
    ///
    /// Subscribe to this property using Combine to receive real-time updates about purchases, restorations, and errors.
    @MainActor @Published public var status = InAppStatus.unknown
    let logger: LoggerProtocol
    var updateListenerTask: Task<Void, Never>?

    /// A Boolean value indicating whether the user can make purchases.
    ///
    /// Check this property before presenting purchase UI or attempting purchases.
    public var canPurchase: Bool { AppStore.canMakePayments }

    /// Creates a new in-app purchase manager and begins monitoring transactions.
    ///
    /// - Parameter logger: A custom logger conforming to ``LoggerProtocol``. Defaults to a logger with category "com.cassiorossi.inapplibrary".
    public init(logger: LoggerProtocol? = nil) {
        self.logger = logger ?? Logger(category: "com.cassiorossi.inapplibrary",
                                       subsystem: "inapplibrary")
        Task {
            await setup()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }
}

private extension InAppManager {
    func setup() {
        updateListenerTask = Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.handle(transaction)
                } catch let error as InAppStatus.InAppErrorStatus {
                    await self.handle(error)
                } catch {
                    await self.handle(error)
                }
            }
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw InAppStatus.InAppErrorStatus.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
}

// MARK: - Products Methods -

public extension InAppManager {
    /// Fetches products for the specified identifiers from the App Store.
    ///
    /// - Parameter identifiers: Product identifiers configured in App Store Connect.
    /// - Returns: An array of ``InAppProduct`` objects with localized pricing and information.
    /// - Throws: An error if fetching fails due to network issues or invalid identifiers.
    func getProducts(for identifiers: [String]) async throws -> [InAppProduct] {
        guard !identifiers.isEmpty else { return [] }
        let products = try await Product.products(for: identifiers)
        logger.debug("Fetched products: \(products.map { "\($0.displayName) for \($0.displayPrice)" })")
        return products.map { $0.toInAppProduct }
    }
}

// MARK: - Purchase Methods -

public extension InAppManager {
    /// Restores previously purchased non-consumable products and active subscriptions.
    ///
    /// Iterates through current entitlements and processes verified, non-revoked transactions.
    /// Monitor ``status`` for restoration updates.
    func restore() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            logger.debug("Transaction \(transaction)")

            if transaction.revocationDate == nil {
                await handle(transaction)
            }
        }
    }

    /// Initiates a purchase for the specified product.
    ///
    /// Presents the system purchase dialog and handles the complete transaction flow.
    /// Monitor ``status`` to receive purchase outcome updates.
    ///
    /// - Parameter product: The product to purchase, obtained from ``getProducts(for:)``.
    func purchase(_ product: InAppProduct) async {
        #if os(visionOS)
        status = .unknown
        #else
        do {
            let result = try await product.storeKitProduct?.purchase()
            switch result {
            case let .success(.verified(transaction)):
                await handle(transaction)

            case let .success(.unverified(_, error)):
                await handle(error)

            case .pending:
                Task { @MainActor in
                    status = .pending
                }

            case .userCancelled:
                Task { @MainActor in
                    status = .cancelled
                }

            default:
                Task { @MainActor in
                    status = .unknown
                }
            }
        } catch {
            let reason = InAppStatus.InAppErrorStatus.unknown(reason: error.localizedDescription)
            await self.handle(reason)
        }
        #endif
    }
}

private extension InAppManager {
    func handle(_ transaction: Transaction) async {
        logger.debug("Purchased \(transaction.productID)")

        // Always finish a transaction.
        await transaction.finish()
        Task { @MainActor in
            status = .purchased(identifier: transaction.productID)
        }
    }

    func handle(_ error: Error) async {
        let reason = InAppStatus.InAppErrorStatus.unknown(reason: error.localizedDescription)
        await self.handle(reason)
    }

    func handle(_ error: InAppStatus.InAppErrorStatus) async {
        logger.error("Transaction failed: \(error.localizedDescription)")
        Task { @MainActor in
            status = .error(reason: error)
        }
    }
}
