import SwiftUI

extension View {
	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder
	public func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
		if condition() {
			transform(self)
		} else {
			self
		}
	}

	/// Sync bindable booleans where the `published` is declared as @EnvironmentObject and `binding` is @State
	/// - Parameters:
	///   - published: The @EnvironmentObject @Published property
	///   - binding: The @State property used locally on the view
	public func sync(_ published: Binding<Bool>, with binding: Binding<Bool>) -> some View {
		self
			.onChange(of: published.wrappedValue) { _, newValue in
				binding.wrappedValue = newValue
			}
			.onChange(of: binding.wrappedValue) { _, newValue in
				published.wrappedValue = newValue
			}
			.onAppear {
				binding.wrappedValue = published.wrappedValue
			}
	}

	/// Execute an action on view without a transaction
	public func withoutTransaction(action: @escaping () -> Void) {
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			action()
		}
	}
}
