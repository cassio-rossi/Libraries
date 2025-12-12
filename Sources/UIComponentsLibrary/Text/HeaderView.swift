import SwiftUI

/// A reusable header view with title, optional extra content, and optional close button.
public struct HeaderView<Content: View>: View {
	private let title: String
	private let theme: Themeable?
	private let onClose: (() -> Void)?
	@ViewBuilder private let extraHeader: Content

	/// Creates a new header view.
	///
	/// - Parameters:
	///   - title: The title text to display in the header.
	///   - theme: Optional theme to apply for colors. Default is nil.
	///   - extraHeader: Additional content to display in the header. Default is EmptyView.
	///   - onClose: Optional closure to call when the close button is tapped. When provided, displays a close button.
	public init(
		title: String,
		theme: Themeable? = nil,
		extraHeader: Content = EmptyView(),
		onClose: (() -> Void)? = nil
	) {
		self.title = title
		self.theme = theme
		self.onClose = onClose
		self.extraHeader = extraHeader
	}

	public var body: some View {
		HStack {
			Text(title.uppercased())
				.font(.headline)
				.foregroundColor(theme?.text.primary.asColor ?? .primary)
				.bold()
			Spacer()
			extraHeader
			if onClose != nil {
				Button(action: { withAnimation { onClose?() }
				}, label: {
					Image(systemName: "xmark.circle")
						.imageScale(.large)
						.foregroundColor(theme?.text.primary.asColor ?? .primary)
				})
				.padding(.leading)
			}
		}
	}
}

struct HeaderView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			HeaderView(title: "Header", extraHeader: Text("Extra"))
			HeaderView(title: "Action") {}
		}
	}
}
