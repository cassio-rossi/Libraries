import Foundation

/// Represents the current status of in-app purchase operations.
///
/// ``InAppStatus`` provides comprehensive state tracking for purchase transactions,
/// allowing you to respond appropriately to different purchase outcomes. This enum
/// is published by ``InAppManager`` and can be observed using Combine.
///
/// ## Overview
///
/// Purchase operations can result in various states that your app needs to handle:
/// - Successful purchases that unlock content
/// - Pending purchases awaiting approval
/// - User-cancelled purchases
/// - Errors during purchase or verification
/// - Unknown or initial states
///
/// ## Example Usage
///
/// ```swift
/// inAppManager.$status
///     .receive(on: DispatchQueue.main)
///     .sink { status in
///         switch status {
///         case .purchased(let identifier):
///             // Unlock the purchased feature
///             self.unlockFeature(identifier)
///             self.showSuccessMessage()
///
///         case .pending:
///             // Show waiting indicator
///             self.showPendingAlert()
///
///         case .cancelled:
///             // User cancelled, dismiss UI
///             self.dismissPurchaseFlow()
///
///         case .error(let reason):
///             // Handle error
///             self.showError(reason.localizedDescription)
///
///         case .unknown:
///             // Initial or indeterminate state
///             break
///         }
///     }
///     .store(in: &cancellables)
/// ```
///
/// ## Topics
///
/// ### Status Cases
/// - ``unknown``
/// - ``purchased(identifier:)``
/// - ``pending``
/// - ``cancelled``
/// - ``error(reason:)``
///
/// ### Error Types
/// - ``InAppErrorStatus``
public enum InAppStatus: Error {
    /// Specific error types that can occur during in-app purchase operations.
    ///
    /// This enum provides detailed information about purchase failures, allowing
    /// you to provide appropriate user feedback and handle different error scenarios.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// if case .error(let reason) = status {
    ///     switch reason {
    ///     case .failedVerification:
    ///         showAlert("Unable to verify purchase. Please try again.")
    ///
    ///     case .unknown(let message):
    ///         showAlert("Purchase failed: \(message)")
    ///     }
    /// }
    /// ```
    public enum InAppErrorStatus: Error {
        /// Transaction verification failed.
        ///
        /// This error occurs when StoreKit cannot verify the authenticity of a transaction.
        /// The transaction may be fraudulent or the verification process failed.
        ///
        /// **Recommended Action**: Do not unlock content. Inform the user that the
        /// purchase could not be verified and suggest contacting support if the problem persists.
        case failedVerification

        /// An unknown error occurred with an associated reason message.
        ///
        /// This case covers all other error scenarios not explicitly handled by the library.
        /// The associated `reason` string provides details about what went wrong.
        ///
        /// - Parameter reason: A human-readable description of the error.
        ///
        /// **Common Reasons**:
        /// - Network connectivity issues
        /// - StoreKit configuration problems
        /// - Apple ID authentication failures
        /// - Regional restrictions
        case unknown(reason: String)
    }

    /// The initial or indeterminate state.
    ///
    /// This is the default status before any purchase operations begin or when
    /// the current state cannot be determined. No action is typically required
    /// for this status.
    case unknown

    /// A purchase was completed successfully.
    ///
    /// This status indicates that a product was purchased, the transaction was verified,
    /// and the transaction has been finalized with StoreKit. You should unlock the
    /// purchased content when receiving this status.
    ///
    /// - Parameter identifier: The product identifier that was purchased (e.g., "com.myapp.premium").
    ///
    /// ## Example
    ///
    /// ```swift
    /// case .purchased(let identifier):
    ///     switch identifier {
    ///     case "com.myapp.premium":
    ///         unlockPremiumFeatures()
    ///     case "com.myapp.coins_100":
    ///         addCoins(amount: 100)
    ///     default:
    ///         break
    ///     }
    /// ```
    case purchased(identifier: String)

    /// The purchase is pending approval.
    ///
    /// This status occurs when a purchase requires additional approval before completion,
    /// such as when "Ask to Buy" is enabled for a family member's account. The purchase
    /// may complete later when approval is granted.
    ///
    /// **Recommended Action**: Inform the user that their purchase is awaiting approval
    /// and will be processed once approved.
    ///
    /// ## Example
    ///
    /// ```swift
    /// case .pending:
    ///     showAlert("Your purchase is awaiting approval. You'll be notified when it's complete.")
    /// ```
    case pending

    /// The user cancelled the purchase.
    ///
    /// This status indicates the user dismissed the purchase dialog without completing
    /// the transaction. This is a normal flow and typically requires no special handling
    /// beyond dismissing any purchase-related UI.
    ///
    /// ## Example
    ///
    /// ```swift
    /// case .cancelled:
    ///     dismissPurchaseSheet()
    ///     // No alert needed - user intentionally cancelled
    /// ```
    case cancelled

    /// An error occurred during the purchase process.
    ///
    /// This status indicates that the purchase failed due to an error. The associated
    /// ``InAppErrorStatus`` provides details about what went wrong.
    ///
    /// - Parameter reason: An ``InAppErrorStatus`` describing the specific error.
    ///
    /// ## Example
    ///
    /// ```swift
    /// case .error(let reason):
    ///     let message: String
    ///     switch reason {
    ///     case .failedVerification:
    ///         message = "Unable to verify your purchase. Please try again."
    ///     case .unknown(let details):
    ///         message = "Purchase failed: \(details)"
    ///     }
    ///     showAlert(message)
    /// ```
    case error(reason: InAppStatus.InAppErrorStatus)
}
