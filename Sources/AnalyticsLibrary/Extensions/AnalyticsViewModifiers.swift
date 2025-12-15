import SwiftUI

/// View extensions for analytics tracking.
extension View {
    /// Tracks when this view appears on screen.
    ///
    /// Automatically logs a screen view event when the view appears.
    ///
    /// ```swift
    /// struct ProductListView: View {
    ///     @EnvironmentObject var analytics: AnalyticsManager
    ///
    ///     var body: some View {
    ///         List { /* content */ }
    ///             .trackScreen("product_list", previous: "home", analytics: analytics)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - current: The screen identifier for analytics.
    ///   - previous: Optional previous screen identifier for navigation tracking.
    ///   - analytics: The analytics manager to use for tracking.
    ///   - providers: Array of analytics providers to send events to. Defaults to `[.firebase]`.
    /// - Returns: A view that tracks screen appearances.
    public func trackScreen(
        _ current: String,
        previous: String? = nil,
        analytics: AnalyticsProtocol,
        providers: [AnalyticsProviderType] = [.firebase]
    ) -> some View {
        modifier(AnalyticsScreenModifier(
            analytics: analytics,
            providers: providers,
            current: current,
            previous: previous
        ))
    }

    /// Tracks tap interactions on this view.
    ///
    /// Logs an analytics event when the view is tapped.
    ///
    /// ```swift
    /// @EnvironmentObject var analytics: AnalyticsManager
    ///
    /// Button("Add to Cart") {
    ///     viewModel.addToCart()
    /// }
    /// .trackTap("add_to_cart_button", screen: "product_detail", analytics: analytics)
    /// ```
    ///
    /// - Parameters:
    ///   - buttonId: The button identifier for analytics.
    ///   - screen: The screen where the tap occurred.
    ///   - analytics: The analytics manager to use for tracking.
    ///   - providers: Array of analytics providers to send events to. Defaults to `[.firebase]`.
    /// - Returns: A view that tracks tap interactions.
    public func trackTap(
        _ buttonId: String,
        screen: String,
        analytics: AnalyticsProtocol,
        providers: [AnalyticsProviderType] = [.firebase]
    ) -> some View {
        modifier(AnalyticsButtonTapModifier(
            analytics: analytics,
            providers: providers,
            buttonId: buttonId,
            screen: screen
        ))
    }

    /// Tracks navigation events when a value changes.
    ///
    /// Automatically logs navigation events when the provided value changes,
    /// useful for tracking NavigationStack destinations.
    ///
    /// ```swift
    /// @EnvironmentObject var analytics: AnalyticsManager
    /// @State private var path = NavigationPath()
    ///
    /// NavigationStack(path: $path) {
    ///     ContentView()
    ///         .navigationDestination(for: Destination.self) { destination in
    ///             DestinationView(destination: destination)
    ///                 .trackNavigation(
    ///                     value: destination,
    ///                     origin: "Home",
    ///                     analytics: analytics
    ///                 )
    ///         }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The navigation value to track changes for.
    ///   - origin: The source screen identifier.
    ///   - destinationMapper: Optional closure to map the value to a destination string. If nil, uses String(describing:).
    ///   - analytics: The analytics manager to use for tracking.
    ///   - providers: Array of analytics providers to send events to. Defaults to `[.firebase]`.
    /// - Returns: A view that tracks navigation events.
    public func trackNavigation<T: Equatable>(
        value: T,
        origin: String,
        destinationMapper: ((T) -> String)? = nil,
        analytics: AnalyticsProtocol,
        providers: [AnalyticsProviderType] = [.firebase]
    ) -> some View {
        modifier(AnalyticsNavigationModifier(
            analytics: analytics,
            providers: providers,
            origin: origin,
            value: value,
            destinationMapper: destinationMapper
        ))
    }

    /// Tracks navigation events when a NavigationPath changes.
    ///
    /// Automatically logs navigation events when the NavigationPath changes,
    /// tracking when items are pushed or popped from the stack.
    ///
    /// ```swift
    /// @EnvironmentObject var analytics: AnalyticsManager
    /// @State private var path = NavigationPath()
    ///
    /// NavigationStack(path: $path) {
    ///     ContentView()
    /// }
    /// .trackNavigationPath(
    ///     path: path,
    ///     origin: "Home",
    ///     analytics: analytics
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - path: The NavigationPath to track changes for.
    ///   - origin: The source screen identifier.
    ///   - analytics: The analytics manager to use for tracking.
    ///   - providers: Array of analytics providers to send events to. Defaults to `[.firebase]`.
    /// - Returns: A view that tracks navigation path changes.
    public func trackNavigationPath(
        path: NavigationPath,
        origin: String,
        analytics: AnalyticsProtocol,
        providers: [AnalyticsProviderType] = [.firebase]
    ) -> some View {
        modifier(AnalyticsNavigationPathModifier(
            analytics: analytics,
            providers: providers,
            origin: origin,
            path: path
        ))
    }
}

/// A view modifier that automatically tracks screen views.
///
/// Logs an analytics event when a view appears, capturing the current screen
/// and optional previous screen for navigation tracking.
struct AnalyticsScreenModifier: ViewModifier {
    /// The analytics manager to use for tracking.
    let analytics: AnalyticsProtocol
    /// Array of analytics providers to send events to.
    let providers: [AnalyticsProviderType]
    /// The current screen identifier.
    let current: String
    /// Optional previous screen identifier for navigation tracking.
    let previous: String?

    func body(content: Content) -> some View {
        content
            .onAppear {
                analytics.track(.screenView(current: current, previous: previous), providers: providers)
            }
    }
}

/// A view modifier that automatically tracks button tap interactions.
///
/// Logs an analytics event when a view is tapped, capturing the button
/// identifier and screen context.
struct AnalyticsButtonTapModifier: ViewModifier {
    /// The analytics manager to use for tracking.
    let analytics: AnalyticsProtocol
    /// Array of analytics providers to send events to.
    let providers: [AnalyticsProviderType]
    /// The button identifier for analytics.
    let buttonId: String
    /// The screen where the tap occurred.
    let screen: String

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
            TapGesture().onEnded {
                analytics.track(.buttonTap(buttonId: buttonId, screen: screen), providers: providers)
            }
        )
    }
}

/// A view modifier that automatically tracks navigation events.
///
/// Logs an analytics event when the provided value changes, useful for
/// tracking NavigationStack destinations via `.navigationDestination(for:)`.
struct AnalyticsNavigationModifier<T: Equatable>: ViewModifier {
    /// The analytics manager to use for tracking.
    let analytics: AnalyticsProtocol
    /// Array of analytics providers to send events to.
    let providers: [AnalyticsProviderType]
    /// The source screen identifier.
    let origin: String
    /// The navigation value to track.
    let value: T
    /// Optional closure to convert the value to a destination string.
    let destinationMapper: ((T) -> String)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                let destination = destinationMapper?(value) ?? String(describing: value)
                analytics.track(.navigation(origin: origin, destination: destination), providers: providers)
            }
    }
}

/// A view modifier that automatically tracks NavigationPath changes.
///
/// Logs an analytics event when the NavigationPath count changes,
/// tracking navigation depth within a NavigationStack.
struct AnalyticsNavigationPathModifier: ViewModifier {
    /// The analytics manager to use for tracking.
    let analytics: AnalyticsProtocol
    /// Array of analytics providers to send events to.
    let providers: [AnalyticsProviderType]
    /// The source screen identifier.
    let origin: String
    /// The NavigationPath to monitor.
    let path: NavigationPath

    func body(content: Content) -> some View {
        content
            .onChange(of: path.count) { oldValue, newValue in
                if newValue > oldValue {
                    analytics.track(.navigation(origin: origin, destination: "depth_\(newValue)"), providers: providers)
                }
            }
    }
}
