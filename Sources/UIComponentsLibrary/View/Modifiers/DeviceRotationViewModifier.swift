import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 18.0, *)
@available(macOS, unavailable)
@available(visionOS, unavailable)
extension View {
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

@available(iOS 18.0, *)
@available(macOS, unavailable)
@available(visionOS, unavailable)
public struct DeviceRotationViewModifier: ViewModifier {
    var action: (UIDeviceOrientation) -> Void

    public init(action: @escaping (UIDeviceOrientation) -> Void) {
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
			.onAppear()
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { notification in
				action((notification.object as? UIDevice)?.orientation ?? .unknown)
            }
    }
}
