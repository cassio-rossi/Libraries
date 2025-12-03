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
	/// Applies a negative (inverted) style to the view, typically for use on dark backgrounds.
	///
	/// This modifier sets the negative environment value to true, which affects the appearance
	/// of buttons and other styled components to provide appropriate contrast on dark backgrounds.
	///
	/// - Returns: A view with the negative environment value set to true.
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

/// A primary button with filled background and uppercase text.
///
/// Primary buttons are designed to highlight the main action in a UI. They feature
/// a filled background with contrasting text color and support both light and dark themes
/// through the `negative()` modifier.
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

	/// Creates a primary button with a non-localized title.
	///
	/// - Parameters:
	///   - title: The button's title text.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

	/// Creates a primary button with a localized title.
	///
	/// - Parameters:
	///   - key: The localized string key for the button's title.
	///   - tableName: The name of the string table to search. Defaults to `nil`.
	///   - bundle: The bundle containing the strings file. Defaults to `nil`.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

/// A secondary button with outline style and uppercase text.
///
/// Secondary buttons provide a less prominent alternative to primary buttons. They feature
/// an outline border with transparent or lightly filled background and support both light
/// and dark themes through the `negative()` modifier.
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

	/// Creates a secondary button with a non-localized title.
	///
	/// - Parameters:
	///   - title: The button's title text.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

	/// Creates a secondary button with a localized title.
	///
	/// - Parameters:
	///   - key: The localized string key for the button's title.
	///   - tableName: The name of the string table to search. Defaults to `nil`.
	///   - bundle: The bundle containing the strings file. Defaults to `nil`.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

/// A tertiary button with distinctive red styling for destructive or warning actions.
///
/// Tertiary buttons are typically used for destructive or less common actions. They feature
/// red accent colors and support both light and dark themes through the `negative()` modifier.
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

	/// Creates a tertiary button with a non-localized title.
	///
	/// - Parameters:
	///   - title: The button's title text.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

	/// Creates a tertiary button with a localized title.
	///
	/// - Parameters:
	///   - key: The localized string key for the button's title.
	///   - tableName: The name of the string table to search. Defaults to `nil`.
	///   - bundle: The bundle containing the strings file. Defaults to `nil`.
	///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
	///   - style: The text style to apply to the title. Defaults to `.callout`.
	///   - action: The action to perform when the button is tapped.
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

/// A button that displays an image with customizable size and color.
///
/// Image buttons provide a simple way to create icon-based buttons with consistent styling.
/// They automatically adjust opacity based on the enabled state.
public struct ImageButton: View {
	@Environment(\.isEnabled) private var isEnabled: Bool

	var image: Image
	var size: CGSize
	var color: Color?
	let action: () -> Void

	/// Creates an image button.
	///
	/// - Parameters:
	///   - image: The image to display in the button.
	///   - size: Optional size for the image. Defaults to 50x50 points.
	///   - color: Optional tint color for the image. Defaults to the app's blue accent color.
	///   - action: The action to perform when the button is tapped.
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

/// A specialized button that displays a back arrow icon for navigation.
///
/// Back buttons provide a consistent way to implement back navigation with the standard
/// back arrow icon from the image asset library.
public struct BackButton: View {
	let action: () -> Void

	/// Creates a back button.
	///
	/// - Parameter action: The action to perform when the button is tapped, typically navigation to the previous screen.
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
