import Foundation

/// The current status of in-app purchase operations.
///
/// Published by ``InAppManager`` to track purchase outcomes including successes, pending approvals, cancellations, and errors.
public enum InAppStatus: Equatable {
    /// Specific error types for purchase failures.
    public enum InAppErrorStatus: Equatable, Error {
        /// Transaction verification failed.
        ///
        /// StoreKit could not verify the transaction's authenticity. Do not unlock content.
        case failedVerification

        /// An unknown error occurred.
        ///
        /// - Parameter reason: A description of the error.
        case unknown(reason: String)
    }

    /// The initial or indeterminate state.
    case unknown

    /// A purchase completed successfully.
    ///
    /// The transaction was verified and finalized. Unlock the purchased content.
    ///
    /// - Parameter identifier: The product identifier that was purchased.
    case purchased(identifier: String)

    /// The purchase is pending approval.
    ///
    /// Occurs when approval is required, such as with "Ask to Buy". The purchase may complete later.
    case pending

    /// The user cancelled the purchase.
    case cancelled

    /// An error occurred during the purchase.
    ///
    /// - Parameter reason: An ``InAppErrorStatus`` describing the error.
    case error(reason: InAppStatus.InAppErrorStatus)
}
