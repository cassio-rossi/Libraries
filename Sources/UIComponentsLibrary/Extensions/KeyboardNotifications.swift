#if os(iOS)
import Combine
import SwiftUI
import UIKit

/// Publisher to read keyboard changes.
public protocol KeyboardNotifications {
	var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardNotifications {
	public var keyboardPublisher: AnyPublisher<Bool, Never> {
		Publishers.Merge(
			NotificationCenter.default
				.publisher(for: UIResponder.keyboardWillShowNotification)
				.map { _ in true },

			NotificationCenter.default
				.publisher(for: UIResponder.keyboardWillHideNotification)
				.map { _ in false }
		)
		.eraseToAnyPublisher()
	}
}

extension View {
	public func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
#endif
