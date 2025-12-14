import Foundation

/// Represents the types of analytics events that can be tracked.
///
/// Each event type carries relevant context through associated values,
/// enabling detailed analysis while maintaining type safety.
public enum AnalyticsEvent {
    /// Application lifecycle event types.
    public enum AppType {
        /// Application opened.
        case open
        /// Application closed.
        case close
    }

    /// Tutorial progress event types.
    public enum TutorialType {
        /// Tutorial started.
        case begin
        /// Tutorial completed.
        case complete
    }

    /// Session lifecycle event types.
    public enum SessionType {
        /// Session started.
        case start
        /// Session ended.
        case end
    }

    /// Tracks application lifecycle events.
    ///
    /// - Parameter type: The application event type (open or close).
    case app(AppType)

    /// Tracks tutorial progress.
    ///
    /// - Parameter type: The tutorial event type (begin or complete).
    case tutorial(TutorialType)

    /// Tracks user session lifecycle.
    ///
    /// - Parameter type: The session event type (start or end).
    case session(SessionType)

    /// Tracks when a screen is displayed to the user.
    ///
    /// - Parameter current: The screen identifier (e.g., "Accounts", "Goals").
    /// - Parameter previous: Optional previous screen identifier (e.g., "Accounts", "Goals").
    case screenView(current: String, previous: String?)

    /// Tracks navigation between screens.
    ///
    /// - Parameters:
    ///   - from: The source screen.
    ///   - to: The destination screen.
    case navigation(from: String, to: String)

    /// Tracks user interactions with UI elements.
    ///
    /// - Parameters:
    ///   - name: The button/action identifier (e.g., "add_to_goal", "create_goal").
    ///   - screen: Screen context where the tap occurred.
    case buttonTap(id: String, screen: String)

    /// Tracks user login attempts.
    ///
    /// - Parameters:
    ///   - system: The authentication system used (e.g., "email", "google", "apple").
    ///   - success: Whether the login attempt succeeded.
    case login(system: String, success: Bool)

    /// Tracks form submission events.
    ///
    /// - Parameters:
    ///   - formName: The identifier of the submitted form.
    ///   - success: Whether the submission succeeded.
    case formSubmit(formName: String, success: Bool)

    /// Tracks when a user initiates a purchase.
    ///
    /// - Parameters:
    ///   - productId: The product identifier.
    ///   - price: The product price.
    case purchaseInitiated(productId: String, price: Decimal)

    /// Tracks completed purchases.
    ///
    /// - Parameters:
    ///   - transactionId: The unique transaction identifier.
    ///   - revenue: The transaction revenue amount.
    case purchaseCompleted(transactionId: String, revenue: Decimal)

    /// Tracks errors encountered during operations.
    ///
    /// - Parameters:
    ///   - code: The error category (e.g., "network", "parsing").
    ///   - message: Brief error description.
    ///   - screen: Screen context where the tap occurred.
    case error(code: String, message: String, screen: String)

    /// Tracks search operations.
    ///
    /// - Parameters:
    ///   - query: The search query text.
    ///   - resultsCount: The number of results returned.
    case searchPerformed(query: String, resultsCount: Int)

    /// Tracks when a user selects an item from a list.
    ///
    /// - Parameters:
    ///   - itemId: The unique item identifier.
    ///   - itemType: The type or category of the item.
    ///   - position: The item's position in the list (0-indexed).
    case itemSelected(itemId: String, itemType: String, position: Int)
}
