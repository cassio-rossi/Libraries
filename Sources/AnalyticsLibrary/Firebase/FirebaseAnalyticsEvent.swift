#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
import FirebaseCore
import Foundation

/// Firebase-specific event name and parameter mappings.
///
/// Converts generic analytics events to Firebase Analytics event names
/// and parameter dictionaries, utilizing Firebase's predefined constants
/// where available for better integration with Firebase dashboards.
extension AnalyticsEvent {
    /// The Firebase Analytics event name for this event.
    ///
    /// Uses Firebase's predefined event constants (e.g., `AnalyticsEventScreenView`,
    /// `AnalyticsEventPurchase`) when available to ensure proper integration
    /// with Firebase's automatic reports and dashboards.
    var name: String {
        switch self {
        case let .app(type): type == .open ? AnalyticsEventAppOpen : "app_close"
        case let .tutorial(type): type == .begin ? AnalyticsEventTutorialBegin : AnalyticsEventTutorialComplete
        case .screenView: AnalyticsEventScreenView
        case .buttonTap: "button_tap"
        case .formSubmit: "form_submit"
        case .purchaseInitiated: "inapp_begin"
        case .purchasePending: "inapp_pending"
        case .purchaseCancelled: "inapp_cancelled"
        case .purchaseCompleted: AnalyticsEventInAppPurchase
        case .error: "error_occurred"
        case .searchPerformed: AnalyticsEventSearch
        case .itemSelected: AnalyticsEventSelectContent
        case .navigation: "navigation"
        case .login: AnalyticsEventLogin
        case let .session(type): type == .start ? "session_start" : "session_end"
        case let .generic(name, _): "generic_data_\(name)"
        }
    }

    /// The Firebase Analytics parameters for this event.
    ///
    /// Converts event-specific data into Firebase parameter dictionaries,
    /// using Firebase's predefined parameter constants (e.g., `AnalyticsParameterScreenName`,
    /// `AnalyticsParameterItemID`) for standard event types.
    ///
    /// - Returns: A dictionary of parameters formatted for Firebase Analytics.
    var parameters: [String: Any] {
        switch self {
        case .session: return [:]

        case let .app(type):
            return [AnalyticsParameterValue: type]

        case let .tutorial(type):
            return [AnalyticsParameterValue: type]

        case let .navigation(origin, destination):
            return [
                "origin": origin,
                AnalyticsParameterDestination: destination
            ]

        case let .login(system, success):
            return [
                "system": system,
                "success": success
            ]

        case let .screenView(current, previous):
            var params: [String: Any] = [
                AnalyticsParameterScreenName: current
            ]
            if let previous = previous {
                params["previous_screen"] = previous
            }
            return params

        case let .buttonTap(buttonId, screen):
            return [
                "button_id": buttonId,
                "screen_name": screen
            ]

        case let .formSubmit(formName, success):
            return [
                "form_name": formName,
                "success": success
            ]

        case let .purchaseInitiated(productId, price):
            return [
                AnalyticsParameterItemID: productId,
                AnalyticsParameterPrice: price
            ]

        case .purchasePending: return [:]
        case .purchaseCancelled: return [:]

        case let .purchaseCompleted(productId, revenue):
            return [
                AnalyticsParameterTransactionID: productId,
                AnalyticsParameterValue: revenue
            ]

        case let .error(code, message, screen):
            return [
                "error_code": code,
                "error_message": message,
                "screen_name": screen
            ]

        case let .searchPerformed(query, resultsCount):
            return [
                AnalyticsParameterSearchTerm: query,
                "results_count": resultsCount
            ]

        case let .itemSelected(itemId, itemType, position):
            return [
                AnalyticsParameterItemID: itemId,
                AnalyticsParameterContentType: itemType,
                "position": position
            ]

        case let .generic(name, item):
            return [
                "generic_data_\(name)": item
            ]
        }
    }
}
#endif
