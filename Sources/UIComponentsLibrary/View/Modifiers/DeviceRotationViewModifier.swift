#if canImport(UIKit)
import SwiftUI
import UIKit

extension View {
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

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
#endif
