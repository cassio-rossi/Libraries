import Combine
import Foundation
import LoggerLibrary
import StoreKit

/// A comprehensive library for managing in-app purchases and subscriptions using StoreKit 2.
/// 
/// `InAppManager` provides a Swift-first, async/await interface for handling in-app purchases,
/// product fetching, transaction verification, and purchase restoration. The library automatically
/// manages transaction verification, purchase state tracking, and background transaction monitoring.
///
/// ## Key Features
/// - **Product Management**: Fetch and display product information from App Store Connect
/// - **Purchase Handling**: Complete purchase flow with automatic transaction verification
/// - **Transaction Monitoring**: Background monitoring of all transaction updates
/// - **Purchase Restoration**: Restore previously purchased non-consumables and subscriptions
/// - **State Management**: Observable status updates using Combine publishers
/// - **Error Handling**: Comprehensive error reporting with detailed failure reasons
///
/// ## Basic Setup
/// ```swift
/// import InAppLibrary
/// import Combine
/// 
/// class PurchaseManager: ObservableObject {
///     private let inAppLibrary = InAppManager()
///     private var cancellables = Set<AnyCancellable>()
///     
///     init() {
///         setupPurchaseMonitoring()
///     }
///     
///     private func setupPurchaseMonitoring() {
///         inAppLibrary.$status
///             .receive(on: DispatchQueue.main)
///             .sink { [weak self] status in
///                 self?.handlePurchaseStatus(status)
///             }
///             .store(in: &cancellables)
///     }
/// }
/// ```
///
/// ## Complete Purchase Flow
/// ```swift
/// func purchasePremiumFeatures() async {
///     // 1. Check if purchases are available
///     guard inAppLibrary.canPurchase else {
///         showAlert("Purchases are not available on this device")
///         return
///     }
///     
///     do {
///         // 2. Fetch available products
///         let products = try await inAppLibrary.getProducts(for: [
///             "com.myapp.premium",
///             "com.myapp.pro_subscription"
///         ])
///         
///         // 3. Present products to user and get selection
///         guard let selectedProduct = await presentProductSelection(products) else {
///             return
///         }
///         
///         // 4. Initiate purchase
///         await inAppLibrary.purchase(selectedProduct)
///         
///         // 5. Status updates will be delivered via the status publisher
///         
///     } catch {
///         showAlert("Failed to load products: \(error.localizedDescription)")
///     }
/// }
/// 
/// func handlePurchaseStatus(_ status: InAppStatus) {
///     switch status {
///     case .purchased(let identifier):
///         unlockFeature(for: identifier)
///         showAlert("Purchase successful!")
///         
///     case .error(let reason):
///         showAlert("Purchase failed: \(reason.localizedDescription)")
///         
///     case .pending:
///         showAlert("Purchase pending approval...")
///         
///     case .cancelled:
///         // User cancelled, no action needed
///         break
///         
///     case .unknown:
///         // Initial state, no action needed
///         break
///     }
/// }
/// ```
///
/// ## Restoring Purchases
/// ```swift
/// @IBAction func restorePurchasesButtonTapped(_ sender: UIButton) {
///     Task {
///         await inAppLibrary.restore()
///         // Status updates will indicate restored purchases
///     }
/// }
/// ```
///
/// - Important: This library requires StoreKit 2 and iOS 15.0 or later.
/// - Note: The library automatically handles transaction verification and background monitoring.
///   Ensure your App Store Connect configuration is properly set up with valid product identifiers.
public final actor InAppManager: ObservableObject {
    /// The current status of in-app purchase operations.
    /// 
    /// This published property provides real-time updates about purchase transactions,
    /// restoration processes, and any errors that occur. Subscribe to this property
    /// using Combine to receive status updates in your UI.
    ///
    /// ## Status Values
    /// - `.unknown`: Initial state or indeterminate status
    /// - `.purchased(identifier)`: A product was successfully purchased
    /// - `.pending`: Purchase is waiting for approval (e.g., Ask to Buy)
    /// - `.cancelled`: User cancelled the purchase
    /// - `.error(reason)`: An error occurred during the operation
    ///
    /// ## Example Usage
    /// ```swift
    /// inAppLibrary.$status
    ///     .receive(on: DispatchQueue.main)
    ///     .sink { status in
    ///         switch status {
    ///         case .purchased(let identifier):
    ///             self.handleSuccessfulPurchase(identifier)
    ///         case .error(let reason):
    ///             self.showError(reason.localizedDescription)
    ///         case .pending:
    ///             self.showPendingIndicator()
    ///         case .cancelled:
    ///             self.hidePurchaseIndicator()
    ///         case .unknown:
    ///             break
    ///         }
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    @Published public var status = InAppStatus.unknown
    let logger: LoggerProtocol
    var updateListenerTask: Task<Void, Never>?

    /// A Boolean value indicating whether the user can make purchases.
    /// 
    /// This property reflects the system's capability to make payments, considering factors like:
    /// - Device restrictions or parental controls
    /// - Apple ID payment methods
    /// - Regional availability
    /// 
    /// Check this property before attempting to purchase products or presenting purchase UI.
    ///
    /// ## Example Usage
    /// ```swift
    /// if inAppLibrary.canPurchase {
    ///     // Present purchase options
    ///     let products = try await inAppLibrary.getProducts(for: productIdentifiers)
    /// } else {
    ///     // Show appropriate message to user
    ///     showAlert("Purchases are not available on this device")
    /// }
    /// ```
    public var canPurchase: Bool { AppStore.canMakePayments }

    /// Initializes a new instance of `InAppLibrary`.
    /// 
    /// Creates a new in-app purchase library instance and sets up transaction monitoring.
    /// The library automatically begins listening for transaction updates upon initialization.
    ///
    /// - Parameter logger: An optional logger conforming to `LoggerProtocol`. 
    ///   If not provided, a default logger with category "com.cassiorossi.inapplibrary" will be used.
    ///
    /// ## Example Usage
    /// ```swift
    /// // Using default logger
    /// let inAppLibrary = InAppLibrary()
    /// 
    /// // Using custom logger
    /// let customLogger = MyCustomLogger()
    /// let inAppLibrary = InAppLibrary(logger: customLogger)
    /// ```
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
    /// Fetches products for the given identifiers.
    /// 
    /// Retrieves product information from the App Store for the specified product identifiers.
    /// This method communicates with StoreKit to fetch current pricing, availability, and
    /// localized product information.
    ///
    /// - Parameter identifiers: An array of product identifiers to fetch. These should match
    ///   the product IDs configured in App Store Connect.
    /// 
    /// - Returns: An array of `InAppProduct` objects representing the fetched products.
    ///   Products are returned in the same order as requested when possible.
    ///
    /// - Throws: An error if the product fetch fails, such as:
    ///   - Network connectivity issues
    ///   - Invalid product identifiers
    ///   - StoreKit configuration problems
    ///
    /// ## Example Usage
    /// ```swift
    /// let productIds = ["com.myapp.premium", "com.myapp.coins_100"]
    /// 
    /// do {
    ///     let products = try await inAppLibrary.getProducts(for: productIds)
    ///     
    ///     for product in products {
    ///         print("\(product.displayName): \(product.displayPrice)")
    ///     }
    /// } catch {
    ///     print("Failed to fetch products: \(error)")
    /// }
    /// ```
    ///
    /// - Important: Only products that are properly configured in App Store Connect and
    ///   available in the user's region will be returned. Missing products in the result
    ///   may indicate configuration issues.
    func getProducts(for identifiers: [String]) async throws -> [InAppProduct] {
        guard !identifiers.isEmpty else { return [] }
        let products = try await Product.products(for: identifiers)
        logger.debug("Fetched products: \(products.map { "\($0.displayName) for \($0.displayPrice)" })")
        return products.map { $0.toInAppProduct }
    }
}

// MARK: - Purchase Methods -

public extension InAppManager {
    /// Restores previously purchased products.
    /// 
    /// Iterates through the user's current entitlements and processes each verified transaction.
    /// This method is essential for restoring non-consumable products and active subscriptions
    /// when users reinstall your app or use it on a new device.
    ///
    /// The restore process:
    /// 1. Retrieves all current entitlements from StoreKit
    /// 2. Verifies each transaction's authenticity
    /// 3. Processes only non-revoked transactions
    /// 4. Updates the purchase status accordingly
    ///
    /// ## When to Call This Method
    /// - When the user taps a "Restore Purchases" button
    /// - On app launch for users who should have active entitlements
    /// - After account sign-in to restore purchases for that Apple ID
    ///
    /// ## Example Usage
    /// ```swift
    /// @IBAction func restorePurchasesButtonTapped(_ sender: UIButton) {
    ///     Task {
    ///         await inAppLibrary.restore()
    ///         
    ///         // Observe status changes to provide user feedback
    ///         // The status publisher will emit updates as entitlements are processed
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method processes transactions asynchronously and may take some time
    ///   to complete. Monitor the `status` property to provide appropriate user feedback.
    ///
    /// - Important: Only transactions that haven't been revoked (`revocationDate == nil`)
    ///   will be processed and restored.
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
    /// Presents the system purchase dialog and handles the transaction flow for the given product.
    /// This method manages the complete purchase lifecycle, from user confirmation through
    /// transaction verification and completion.
    ///
    /// - Parameter product: The `InAppProduct` to purchase. This should be obtained from
    ///   a previous call to `getProducts(for:)`.
    ///
    /// ## Purchase Flow
    /// The method handles various purchase outcomes:
    /// - **Success**: Transaction is verified and completed, status updates to `.purchased`
    /// - **Pending**: Purchase requires additional approval (e.g., Ask to Buy), status updates to `.pending`
    /// - **Cancelled**: User cancelled the purchase, status updates to `.cancelled`
    /// - **Error**: Purchase failed, status updates to `.error` with details
    ///
    /// ## Example Usage
    /// ```swift
    /// // Get products first
    /// let products = try await inAppLibrary.getProducts(for: ["com.myapp.premium"])
    /// 
    /// if let premiumProduct = products.first {
    ///     // Initiate purchase
    ///     await inAppLibrary.purchase(premiumProduct)
    ///     
    ///     // Monitor status for completion
    ///     // Use Combine or async observation of the status property
    /// }
    /// ```
    ///
    /// ## Status Monitoring
    /// ```swift
    /// // Using Combine
    /// inAppLibrary.$status
    ///     .sink { status in
    ///         switch status {
    ///         case .purchased(let identifier):
    ///             // Handle successful purchase
    ///             print("Purchased: \(identifier)")
    ///         case .error(let reason):
    ///             // Handle purchase error
    ///             print("Error: \(reason.localizedDescription)")
    ///         case .pending:
    ///             // Show pending state to user
    ///             print("Purchase pending approval")
    ///         case .cancelled:
    ///             // Handle user cancellation
    ///             print("Purchase cancelled by user")
    ///         default:
    ///             break
    ///         }
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Important: Always check `canPurchase` before calling this method to ensure
    ///   the device supports in-app purchases.
    ///
    /// - Note: This method automatically finishes successful transactions. The transaction
    ///   will be marked as complete in StoreKit after verification.
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
                status = .pending

            case .userCancelled:
                status = .cancelled

            default:
                status = .unknown
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

        status = .purchased(identifier: transaction.productID)
    }

    func handle(_ error: Error) async {
        let reason = InAppStatus.InAppErrorStatus.unknown(reason: error.localizedDescription)
        await self.handle(reason)
    }

    func handle(_ error: InAppStatus.InAppErrorStatus) async {
        logger.error("Transaction failed: \(error.localizedDescription)")
        status = .error(reason: error)
    }
}
