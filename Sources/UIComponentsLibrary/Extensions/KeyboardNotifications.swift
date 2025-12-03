#if os(iOS)
import Combine
import SwiftUI
import UIKit

/// Publisher to read keyboard changes.
public protocol KeyboardNotifications {
	var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardNotifications {
	/// A publisher that emits `true` when the keyboard will show and `false` when it will hide.
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
	/// Dismisses the keyboard if it is currently visible.
	public func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
#endif
