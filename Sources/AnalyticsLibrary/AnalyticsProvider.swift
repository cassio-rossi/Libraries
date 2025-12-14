import Foundation
import LoggerLibrary

/// Available analytics provider implementations.
///
/// Defines the analytics backends that can receive events.
/// Multiple providers can be used simultaneously to send events to different platforms.
///
/// ```swift
/// analytics.track(.screenView(name: "Home"), providers: [.firebase])
/// ```
public enum AnalyticsProviderType: CaseIterable {
    /// Firebase Analytics provider.
    case firebase

    /// Returns the provider implementation for this type.
    var provider: AnalyticsProviderProtocol {
        switch self {
        case .firebase: FirebaseProvider()
        }
    }
}

/// Protocol for analytics provider implementations.
///
/// Implement this protocol to add support for new analytics platforms.
/// Each provider handles platform-specific event formatting and transmission.
public protocol AnalyticsProviderProtocol {
    /// Logs an analytics event to the provider's backend.
    ///
    /// - Parameters:
    ///   - event: The analytics event to log.
    ///   - parameters: Common parameters to include with the event.
    ///   - logger: Optional logger for debugging event transmission.
    func log(
        event: AnalyticsEvent,
        parameters: [String: Any],
        logger: LoggerProtocol?)
}
