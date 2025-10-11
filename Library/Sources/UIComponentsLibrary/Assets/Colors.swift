import SwiftUI

// MARK: -

public struct TextColor {
	public let primaryTab: String
	public let primary: String
	public let secondary: String
	public let terciary: String
	public let error: String

	public init(primaryTab: String, primary: String, secondary: String, terciary: String, error: String) {
		self.primaryTab = primaryTab
		self.primary = primary
		self.secondary = secondary
		self.terciary = terciary
		self.error = error
	}
}

public struct MainColor {
	public let background: String
	public let navigation: String
	public let tint: String
	public let shadow: String

	public init(background: String, navigation: String, tint: String, shadow: String) {
		self.background = background
		self.navigation = navigation
		self.tint = tint
		self.shadow = shadow
	}
}

public struct SecondaryColor {
	public let background: String

	public init(background: String) {
		self.background = background
	}
}

public struct ButtonColor {
	public let primary: String
	public let secondary: String
	public let terciary: String
	public let destructive: String

	public init(primary: String, secondary: String, terciary: String, destructive: String) {
		self.primary = primary
		self.secondary = secondary
		self.terciary = terciary
		self.destructive = destructive
	}
}

// MARK: -

public protocol Themeable {
	var main: MainColor { get }
	var secondary: SecondaryColor { get }
	var tertiary: SecondaryColor { get }
	var text: TextColor { get }
	var button: ButtonColor { get }
}

extension String {
	public var asColorInModule: Color? {
		return Color(self, bundle: .module)
	}

	public var asColor: Color? {
		return Color(self, bundle: .main)
	}
}

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

	public init() {}
}

extension EnvironmentValues {
    @Entry var theme: Themeable = DefaultTheme()
}

extension View {
	public func theme(_ value: Themeable) -> some View {
		environment(\.theme, value)
	}
}
