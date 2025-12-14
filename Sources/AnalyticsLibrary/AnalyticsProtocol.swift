import Foundation

/// A protocol for tracking analytics events throughout the application.
///
/// Provides a unified interface for recording user interactions, screen views,
/// and important business events. The implementation can be swapped for different
/// analytics providers (e.g., Firebase, Mixpanel, custom backend) without changing
/// the call sites.
///
/// ```swift
/// let analytics = Analytics()
/// analytics.track(.screenView(name: "Accounts"))
/// analytics.track(.buttonTap(name: "add_to_goal"))
/// ```
///
/// ## Topics
///
/// ### Tracking Events
/// - ``track(_:)``
/// - ``AnalyticsEvent``
public protocol AnalyticsProtocol {
    /// Records an analytics event.
    ///
    /// - Parameter event: The event to track with its associated data.
    /// - Parameter providers: A list of providers to send the event to.
    func track(_ event: AnalyticsEvent, providers: [AnalyticsProviderType])
}
