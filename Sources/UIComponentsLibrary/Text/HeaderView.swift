import SwiftUI

public struct HeaderView<Content: View>: View {
	private let title: String
	private let theme: Themeable?
	private let onClose: (() -> Void)?
	@ViewBuilder private let extraHeader: Content

	public init(title: String,
				theme: Themeable? = nil,
				extraHeader: Content = EmptyView(),
				onClose: (() -> Void)? = nil) {
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
