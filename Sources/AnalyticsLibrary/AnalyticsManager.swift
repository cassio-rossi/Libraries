import Foundation
import LoggerLibrary
import UIKit

/// Default analytics implementation with console logging.
///
/// This implementation provides a foundation for analytics tracking that can be
/// easily extended or replaced with a real analytics provider (Firebase, Mixpanel, etc.).
///
/// In production, this class would integrate with your chosen analytics SDK.
/// For now, it logs events to the console for debugging and verification.
///
/// ```swift
/// let analytics = AnalyticsManager()
/// analytics.track(.screenView(name: "Accounts"))
/// analytics.track(.buttonTap(name: "add_to_goal", screen: "Accounts"))
/// ```
///
/// ## Topics
///
/// ### Creating an Analytics Instance
/// - ``init(isEnabled:)``
///
/// ### Configuration
/// - ``isEnabled``
///
/// ### Tracking Events
/// - ``track(_:)``
public final class AnalyticsManager: AnalyticsProtocol {

    // MARK: - Properties -

    /// Controls whether analytics events are tracked.
    ///
    /// Set to `false` to disable analytics tracking entirely.
    /// Useful for testing, debugging, or user privacy preferences.
    public var isEnabled: Bool

    private let logger: LoggerProtocol

    private var sessionId: String?
    private var sessionStartTime: Date?
    private var eventSequence: Int = 0

    // MARK: - Common set of parameters -

    /// Common parameters included with every analytics event.
    ///
    /// Provides session context, event sequencing, and platform information
    /// automatically added to all tracked events.
    ///
    /// - Returns: A dictionary of common parameters for analytics events.
    var commonParameters: [String: Any] {
        [
            "session_id": sessionId ?? "",
            "event_sequence": eventSequence,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "platform": "iOS"
        ]
    }

    // MARK: - Initialization -

    /// Creates an analytics instance.
    ///
    /// - Parameter isEnabled: Whether analytics tracking is enabled. Defaults to `true`.
    /// - Parameter logger: A custom logger conforming to ``LoggerProtocol``. Defaults to a logger with category "com.cassiorossi.inapplibrary".
    public init(isEnabled: Bool = true,
                logger: LoggerProtocol? = nil) {
        self.isEnabled = isEnabled
        self.logger = logger ?? Logger(category: "com.cassiorossi.analyticslibrary",
                                       subsystem: "analyticslibrary")

        setupLifecycleObservers()
    }

    // MARK: - Public Methods -

    /// Records an analytics event to the specified providers.
    ///
    /// Sends the event to all specified analytics providers along with
    /// common parameters like session ID and event sequence number.
    ///
    /// ```swift
    /// analytics.track(
    ///     .buttonTap(id: "add_to_cart", screen: "product_detail"),
    ///     providers: [.firebase]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - event: The analytics event to track.
    ///   - providers: Array of provider types to send the event to.
    public func track(
        _ event: AnalyticsEvent,
        providers: [AnalyticsProviderType]
    ) {
        for type in providers {
            type.provider.log(event: event, parameters: commonParameters, logger: logger)
        }
    }
}

// MARK: - Session Lifecycle -

private extension AnalyticsManager {
    /// Sets up observers for application lifecycle notifications.
    ///
    /// Automatically tracks session start/end events when the app
    /// becomes active or resigns active state.
    func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.startSession()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.endSession()
        }
    }

    /// Starts a new analytics session.
    ///
    /// Generates a new session ID, resets the event sequence counter,
    /// and logs a session start event to all providers.
    func startSession() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        eventSequence = 0

        for type in AnalyticsProviderType.allCases {
            type.provider.log(event: .session(.start), parameters: commonParameters, logger: logger)
        }
    }

    /// Ends the current analytics session.
    ///
    /// Calculates session duration and logs a session end event
    /// with duration information to all providers.
    func endSession() {
        guard let sessionId,
              let startTime = sessionStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        let parameters = commonParameters.merge(["duration_seconds": duration])

        for type in AnalyticsProviderType.allCases {
            type.provider.log(event: .session(.end), parameters: parameters, logger: logger)
        }

        self.sessionId = nil
        self.sessionStartTime = nil
        self.eventSequence = 0
    }
}
