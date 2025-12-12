import SwiftUI

/// Defines the available font weights for styled text.
public enum FontWeight: String, CaseIterable {
	case regular
	case bold
}

extension Font {
	/// Creates a custom font with the specified weight relative to a text style.
	///
	/// - Parameters:
	///   - weight: The font weight to apply.
	///   - style: The text style to relate the font size to.
	/// - Returns: A font with the specified weight and relative sizing.
	public static func custom(
		_ weight: FontWeight,
		relativeTo style: Font.TextStyle
	) -> Font {
		let font = Font.system(style).bold()
		return weight == .bold ? font.bold() : font
	}
}

extension AttributedString {
	/// Creates an attributed string with support for bold formatting using '**' delimiters.
	///
	/// Text enclosed in '**' will be rendered in bold. For example: "This is **bold** text".
	///
	/// - Parameters:
	///   - string: The input string with optional '**' delimiters for bold text.
	///   - relativeTo: The text style to use for font sizing.
	public init(_ string: String, relativeTo: Font.TextStyle) {
		let separator = "**"	// BOLD
		let boldIsOdd = string.prefix(2) == separator

		// Divide the string up using the '**' separator
		let components = string.components(separatedBy: separator).compactMap { $0 }.filter { !$0.isEmpty }

		var formattedAttributedString = AttributedString()
		for index in 0..<components.count {
			var attributedString = AttributedString(components[index])

			if index % 2 == 0 {
				attributedString.font = .custom(boldIsOdd ? .bold : .regular, relativeTo: relativeTo)
			} else {
				attributedString.font = .custom(boldIsOdd ? .regular : .bold, relativeTo: relativeTo)
			}

			formattedAttributedString += attributedString
		}

		self = formattedAttributedString
	}
}

extension String {
	/// Converts the string to an attributed string styled as a large title heading.
	public var heading1: AttributedString { AttributedString(self, relativeTo: .title) }

	/// Converts the string to an attributed string styled as a title2 heading.
	public var heading2: AttributedString { AttributedString(self, relativeTo: .title2) }

	/// Converts the string to an attributed string styled as a title3 heading.
	public var heading3: AttributedString { AttributedString(self, relativeTo: .title3) }

	/// Converts the string to an attributed string styled as a headline.
	public var heading4: AttributedString { AttributedString(self, relativeTo: .headline) }

	/// Converts the string to an attributed string with body text styling.
	public var body: AttributedString { AttributedString(self, relativeTo: .body) }

	/// Converts the string to a bold attributed string with body text styling.
	public var bodyBold: AttributedString { AttributedString("**\(self)**", relativeTo: .body) }
}
