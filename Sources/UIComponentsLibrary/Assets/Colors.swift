import SwiftUI

// MARK: -

/// Defines the color scheme for text elements in the application.
public struct TextColor {
	public let primaryTab: String
	public let primary: String
	public let secondary: String
	public let terciary: String
	public let error: String

	/// Creates a new text color configuration.
	///
	/// - Parameters:
	///   - primaryTab: The color name for primary tab text.
	///   - primary: The color name for primary text.
	///   - secondary: The color name for secondary text.
	///   - terciary: The color name for tertiary text.
	///   - error: The color name for error text.
	public init(primaryTab: String, primary: String, secondary: String, terciary: String, error: String) {
		self.primaryTab = primaryTab
		self.primary = primary
		self.secondary = secondary
		self.terciary = terciary
		self.error = error
	}
}

/// Defines the main color scheme for the application.
public struct MainColor {
	public let background: String
	public let navigation: String
	public let tint: String
	public let shadow: String

	/// Creates a new main color configuration.
	///
	/// - Parameters:
	///   - background: The color name for the background.
	///   - navigation: The color name for navigation elements.
	///   - tint: The color name for tint accents.
	///   - shadow: The color name for shadows.
	public init(background: String, navigation: String, tint: String, shadow: String) {
		self.background = background
		self.navigation = navigation
		self.tint = tint
		self.shadow = shadow
	}
}

/// Defines secondary color options for the application.
public struct SecondaryColor {
	public let background: String

	/// Creates a new secondary color configuration.
	///
	/// - Parameter background: The color name for the secondary background.
	public init(background: String) {
		self.background = background
	}
}

/// Defines the color scheme for button elements.
public struct ButtonColor {
	public let primary: String
	public let secondary: String
	public let terciary: String
	public let destructive: String

	/// Creates a new button color configuration.
	///
	/// - Parameters:
	///   - primary: The color name for primary buttons.
	///   - secondary: The color name for secondary buttons.
	///   - terciary: The color name for tertiary buttons.
	///   - destructive: The color name for destructive action buttons.
	public init(primary: String, secondary: String, terciary: String, destructive: String) {
		self.primary = primary
		self.secondary = secondary
		self.terciary = terciary
		self.destructive = destructive
	}
}

// MARK: -

/// A protocol defining a complete theme configuration for the application.
public protocol Themeable {
	var main: MainColor { get }
	var secondary: SecondaryColor { get }
	var tertiary: SecondaryColor { get }
	var text: TextColor { get }
	var button: ButtonColor { get }
}

extension String {
	/// Converts the string to a Color from the module's asset catalog.
	///
	/// - Returns: A Color if the named color exists in the module, nil otherwise.
	public var asColorInModule: Color? {
		return Color(self, bundle: .module)
	}

	/// Converts the string to a Color from the main bundle's asset catalog.
	///
	/// - Returns: A Color if the named color exists in the main bundle, nil otherwise.
	public var asColor: Color? {
		return Color(self, bundle: .main)
	}
}

/// The default theme implementation with predefined color schemes.
public class DefaultTheme: Themeable {
	public let main = MainColor(background: "WhiteBlack",
								navigation: "Blue",
								tint: "BlueWhite",
								shadow: "dark-grey")

	public let secondary = SecondaryColor(background: "Blue")
	public let tertiary = SecondaryColor(background: "WhiteBlue")

	public let text = TextColor(primaryTab: "Blue",
								primary: "BlueWhite",
								secondary: "dark-grey",
								terciary: "Green",
								error: "TabascoDracula")

	public let button = ButtonColor(primary: "ButtonBlue",
									secondary: "ButtonGreen",
									terciary: "ButtonPurple",
									destructive: "TabascoDracula")

	/// Creates a new instance of the default theme.
	public init() {}
}

extension EnvironmentValues {
    @Entry
    public var theme: Themeable = DefaultTheme()
}

extension View {
	/// Applies a custom theme to this view and its children.
	///
	/// - Parameter value: The theme to apply.
	/// - Returns: A view with the theme applied to its environment.
	public func theme(_ value: Themeable) -> some View {
		environment(\.theme, value)
	}
}
