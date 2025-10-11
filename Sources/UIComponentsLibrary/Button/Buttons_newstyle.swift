import SwiftUI

struct NegativeKey: EnvironmentKey {
	static let defaultValue: Bool = false
}

extension EnvironmentValues {
	var negative: Bool {
		get { self[NegativeKey.self] }
		set { self[NegativeKey.self] = newValue }
	}
}

extension View {
	public func negative() -> some View {
		environment(\.negative, true)
	}
}

private struct ButtonStyle: ViewModifier {

	struct Style {
		let color: Color
		let stroke: Color
		let fill: Color
		let corner: CGFloat
	}

	enum ButtonType {
		case primary(negative: Bool, disabled: Bool)
		case secondary(negative: Bool, disabled: Bool)
		case tertiary(negative: Bool, disabled: Bool)

		var definition: Style {
			switch self {
			case .primary(let negative, let disabled):
				if negative {
					return Style(color: ColorAssetLibrary.blue.opacity(disabled ? 0.6 : 1),
								 stroke: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 fill: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 corner: 30)
				}
				return Style(color: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
							 stroke: ColorAssetLibrary.blue.opacity(disabled ? 0.3 : 1),
							 fill: ColorAssetLibrary.blue.opacity(disabled ? 0.3 : 1),
							 corner: 30)

			case .secondary(let negative, let disabled):
				if negative {
					return Style(color: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 stroke: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 fill: ColorAssetLibrary.blue.opacity(disabled ? 0.6 : 1),
								 corner: 30)
				}
				return Style(color: ColorAssetLibrary.blue.opacity(disabled ? 0.6 : 1),
							 stroke: ColorAssetLibrary.blue.opacity(disabled ? 0.3 : 1),
							 fill: ColorAssetLibrary.white.opacity(disabled ? 0.3 : 1),
							 corner: 30)

			case .tertiary(let negative, let disabled):
				if negative {
					return Style(color: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 stroke: ColorAssetLibrary.white.opacity(disabled ? 0.6 : 1),
								 fill: ColorAssetLibrary.red.opacity(disabled ? 0.6 : 1),
								 corner: 30)
				}
				return Style(color: ColorAssetLibrary.red.opacity(disabled ? 0.6 : 1),
							 stroke: ColorAssetLibrary.red.opacity(disabled ? 0.3 : 1),
							 fill: ColorAssetLibrary.white.opacity(disabled ? 0.3 : 1),
							 corner: 30)
			}
		}
	}

	let style: ButtonType
	let size: CGFloat?

	func body(content: Content) -> some View {
		content
			.foregroundColor(style.definition.color)
			.frame(minWidth: 0, maxWidth: size)
			.padding(8)
			.background(RoundedRectangle(cornerRadius: style.definition.corner,
										 style: .continuous)
				.stroke(style.definition.stroke)
				.background(RoundedRectangle(cornerRadius: style.definition.corner)
					.fill(style.definition.fill)
				)
			)
	}
}

extension View {
	fileprivate func style(_ style: ButtonStyle.ButtonType = .primary(negative: false,
																	  disabled: false),
						   size: CGFloat? = .infinity) -> some View {
		modifier(ButtonStyle(style: style,
							 size: size))
	}
}

public struct PrimaryButton: View {
	@Environment(\.isEnabled) private var isEnabled: Bool
	@Environment(\.negative) private var negative: Bool

	let title: String
	let key: LocalizedStringKey
	let tableName: String?
	let bundle: Bundle?
	var size: CGFloat?
	let style: Font.TextStyle
	let action: () -> Void

	public init(_ title: String,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = title
		self.key = ""
		self.tableName = nil
		self.bundle = nil
		self.size = size
		self.style = style
		self.action = action
	}

	public init(_ key: LocalizedStringKey,
				tableName: String? = nil,
				bundle: Bundle? = nil,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = ""
		self.key = key
		self.tableName = tableName
		self.bundle = bundle
		self.size = size
		self.style = style
		self.action = action
	}

	public var body: some View {
		Button(action: action,
			   label: {
			text
				.textCase(.uppercase)
				.font(.system(style))
				.padding([.top, .bottom], 6)
				.style(.primary(negative: negative, disabled: !isEnabled), size: size)
		})
	}

	@ViewBuilder
	private var text: some View {
		if title.isEmpty {
			Text(key, tableName: tableName, bundle: bundle)
		} else {
			Text(title)
		}
	}
}

public struct SecondaryButton: View {
	@Environment(\.isEnabled) private var isEnabled: Bool
	@Environment(\.negative) private var negative: Bool

	let title: String
	let key: LocalizedStringKey
	let tableName: String?
	let bundle: Bundle?
	var size: CGFloat?
	let style: Font.TextStyle
	let action: () -> Void

	public init(_ title: String,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = title
		self.key = ""
		self.tableName = nil
		self.bundle = nil
		self.size = size
		self.style = style
		self.action = action
	}

	public init(_ key: LocalizedStringKey,
				tableName: String? = nil,
				bundle: Bundle? = nil,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = ""
		self.key = key
		self.tableName = tableName
		self.bundle = bundle
		self.size = size
		self.style = style
		self.action = action
	}

	public var body: some View {
        Button(action: action,
			   label: {
			text
				.textCase(.uppercase)
				.font(.system(style))
				.padding([.top, .bottom], 6)
				.style(.secondary(negative: negative, disabled: !isEnabled), size: size)
		})
	}

	@ViewBuilder
	private var text: some View {
		if title.isEmpty {
			Text(key, tableName: tableName, bundle: bundle)
		} else {
			Text(title)
		}
	}
}

public struct TertiaryButton: View {
	@Environment(\.isEnabled) private var isEnabled: Bool
	@Environment(\.negative) private var negative: Bool

	let title: String
	let key: LocalizedStringKey
	let tableName: String?
	let bundle: Bundle?
	var size: CGFloat?
	let style: Font.TextStyle
	let action: () -> Void

	public init(_ title: String,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = title
		self.key = ""
		self.tableName = nil
		self.bundle = nil
		self.size = size
		self.style = style
		self.action = action
	}

	public init(_ key: LocalizedStringKey,
				tableName: String? = nil,
				bundle: Bundle? = nil,
				size: CGFloat? = .infinity,
				style: Font.TextStyle = .callout,
				action: @escaping () -> Void) {
		self.title = ""
		self.key = key
		self.tableName = tableName
		self.bundle = bundle
		self.size = size
		self.style = style
		self.action = action
	}

	public var body: some View {
        Button(action: action,
			   label: {
			text
				.textCase(.uppercase)
				.font(.system(style))
				.padding([.top, .bottom], 6)
				.style(.tertiary(negative: negative, disabled: !isEnabled), size: size)
		})
	}

	@ViewBuilder
	private var text: some View {
		if title.isEmpty {
			Text(key, tableName: tableName, bundle: bundle)
		} else {
			Text(title)
		}
	}
}

public struct ImageButton: View {
	@Environment(\.isEnabled) private var isEnabled: Bool

	var image: Image
	var size: CGSize
	var color: Color?
	let action: () -> Void

	public init(_ image: Image,
				size: CGSize? = nil,
				color: Color? = nil,
				action: @escaping () -> Void) {
		self.image = image
		self.size = size ?? CGSize(width: 50, height: 50)
		self.color = color
		self.action = action
	}

	public var body: some View {
        Button(action: action,
			   label: {
			image
				.resizable()
				.aspectRatio(contentMode: .fit)
		})
		.foregroundColor(color ?? ColorAssetLibrary.blue)
		.opacity(isEnabled ? 1 : 0.15)
		.frame(width: size.width, height: size.height)
	}
}

public struct BackButton: View {
	let action: () -> Void

	public init(action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		ImageButton(ImageAssetLibrary.Common.back, action: withAnimation { action })
	}
}

// MARK: - PREVIEW -

struct ButtonsView: View {
	var body: some View {
		ScrollView {
			VStack {
				Button(action: {},
					   label: { Text("Normal Button") })
				.padding(.bottom)

				Group {
					PrimaryButton("Primary Button", action: {})
					PrimaryButton("Disabled Button", action: {}).disabled(true)
					SecondaryButton("Secondary Button", action: {})
					TertiaryButton("Tertiary Button", action: {})
					TertiaryButton("Disabled Button", action: {}).disabled(true)

					HStack {
						PrimaryButton("Primary Button", style: .footnote, action: {})
						SecondaryButton("Secondary Button", style: .footnote, action: {})
					}

					TertiaryButton("Button", size: 60, style: .caption, action: {})

					HStack {
						ImageButton(ImageAssetLibrary.Common.menu,
									size: CGSize(width: 30, height: 30),
									action: {})
						ImageButton(ImageAssetLibrary.Common.add,
									size: CGSize(width: 50, height: 50),
									action: {})
						ImageButton(ImageAssetLibrary.Common.add,
									action: {})
						.disabled(true)
					}

					HStack {
						BackButton {}
						BackButton {}
							.disabled(true)
					}
				}
				.padding([.leading, .trailing])

				Group {
					HStack {
						PrimaryButton("Primary Button",
									  style: .footnote,
									  action: {}).negative()
						SecondaryButton("Secondary Button",
										style: .footnote,
										action: {}).negative()
						TertiaryButton("Tertiary Button",
									   style: .footnote,
									   action: {}).negative()
					}
					.padding([.leading, .trailing])
				}
				.padding([.top, .bottom])
				.background(.black)

				Group {
					HStack {
						PrimaryButton("Primary Button",
									  style: .footnote,
									  action: {}).negative().disabled(true)
						SecondaryButton("Secondary Button",
										style: .footnote,
										action: {}).negative().disabled(true)
						TertiaryButton("Tertiary Button",
									   style: .footnote,
									   action: {}).negative().disabled(true)
					}
					.padding([.leading, .trailing])
				}
				.padding([.top, .bottom])
				.background(.black)

				Spacer()
			}
		}
	}
}

struct ButtonsView_Previews: PreviewProvider {
	static var previews: some View {
		ButtonsView()
	}
}
