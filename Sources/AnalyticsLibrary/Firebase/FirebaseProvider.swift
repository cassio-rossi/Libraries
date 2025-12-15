#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
import FirebaseCore
import Foundation
import LoggerLibrary

/// Firebase Analytics provider implementation.
///
/// Sends analytics events to Firebase Analytics, handling platform-specific
/// constraints such as parameter limits and character restrictions.
///
/// Firebase Analytics enforces:
/// - Maximum 25 parameters per event
/// - Maximum 40 characters per parameter key
/// - Maximum 100 characters per string value
final class FirebaseProvider: AnalyticsProviderProtocol {
    /// Logs an analytics event to Firebase Analytics.
    ///
    /// Sanitizes parameters to comply with Firebase limits before transmission.
    /// Events are also logged locally if a logger is provided.
    ///
    /// - Parameters:
    ///   - event: The analytics event to log.
    ///   - parameters: Common parameters to merge with event-specific data.
    ///   - logger: Optional logger for debugging.
    func log(
        event: AnalyticsEvent,
        parameters: [String: Any],
        logger: LoggerProtocol? = nil
    ) {
        let parameters = sanitize(parameters, merging: event)
        Analytics.logEvent(event.name, parameters: parameters)
        logger?.info([event.name: parameters])
    }
}

private extension FirebaseProvider {
    /// Sanitizes parameters to comply with Firebase Analytics limits.
    ///
    /// Firebase enforces a 100-character limit on parameter keys
    /// and a 25 parameter limit per event. This method filters
    /// and truncates the parameter dictionary accordingly.
    ///
    /// - Parameters:
    ///   - common: Common parameters to include with all events.
    ///   - event: The event containing event-specific parameters.
    /// - Returns: A sanitized parameter dictionary compliant with Firebase limits.
    func sanitize(_ common: [String: Any], merging event: AnalyticsEvent) -> [String: Any] {
        // Remove parameters that exceed Firebase limits
        // Limit to 25 parameters
        var sanitizedSlice = common.merge(event.parameters).filter { key, value in
            // Firebase key limit
            key.count <= 40 && isValidParameterValue(value)
        }.prefix(25)

        return Dictionary(uniqueKeysWithValues: Array(sanitizedSlice))
    }

    /// Validates whether a parameter value meets Firebase requirements.
    ///
    /// Firebase accepts numbers, booleans, and strings up to 100 characters.
    /// This method filters out invalid values before sending to Firebase.
    ///
    /// - Parameter value: The parameter value to validate.
    /// - Returns: `true` if the value is valid for Firebase, `false` otherwise.
    func isValidParameterValue(_ value: Any) -> Bool {
        if let string = value as? String {
            return string.count <= 100 // Firebase string value limit
        }
        return value is NSNumber || value is Int || value is Double || value is Bool
    }
}
#else
import Foundation
import LoggerLibrary

final class FirebaseProvider: AnalyticsProviderProtocol {
    /// Logs an analytics event to Firebase Analytics.
    ///
    /// Sanitizes parameters to comply with Firebase limits before transmission.
    /// Events are also logged locally if a logger is provided.
    ///
    /// - Parameters:
    ///   - event: The analytics event to log.
    ///   - parameters: Common parameters to merge with event-specific data.
    ///   - logger: Optional logger for debugging.
    func log(
        event: AnalyticsEvent,
        parameters: [String: Any],
        logger: LoggerProtocol? = nil
    ) {
        logger?.info("\(event) \(parameters)")
    }
}
#endif
