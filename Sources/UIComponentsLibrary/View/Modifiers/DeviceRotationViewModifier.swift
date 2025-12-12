#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit

extension View {
    /// Adds an action to perform when the device orientation changes.
    ///
    /// - Parameter action: The action to perform, receiving the new device orientation.
    /// - Returns: A view that responds to device rotation changes.
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

/// A view modifier that observes device rotation changes and executes an action.
public struct DeviceRotationViewModifier: ViewModifier {
    var action: (UIDeviceOrientation) -> Void

    /// Creates a new device rotation view modifier.
    ///
    /// - Parameter action: The action to perform when device orientation changes.
    public init(action: @escaping (UIDeviceOrientation) -> Void) {
        self.action = action
    }

    /// Applies the device rotation observer to the content view.
    public func body(content: Content) -> some View {
        content
			.onAppear()
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { notification in
				action((notification.object as? UIDevice)?.orientation ?? .unknown)
            }
    }
}
#endif
