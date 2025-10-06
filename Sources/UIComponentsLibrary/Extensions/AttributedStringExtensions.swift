import SwiftUI

public enum FontWeight: String, CaseIterable {
	case regular
	case bold
}

extension Font {
	public static func custom(_ weight: FontWeight,
							  relativeTo style: Font.TextStyle) -> Font {
		let font = Font.system(style).bold()
		return weight == .bold ? font.bold() : font
	}
}

extension AttributedString {
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
	public var heading1: AttributedString { AttributedString(self, relativeTo: .title) }
	public var heading2: AttributedString { AttributedString(self, relativeTo: .title2) }
	public var heading3: AttributedString { AttributedString(self, relativeTo: .title3) }
	public var heading4: AttributedString { AttributedString(self, relativeTo: .headline) }
	public var body: AttributedString { AttributedString(self, relativeTo: .body) }
	public var bodyBold: AttributedString { AttributedString("**\(self)**", relativeTo: .body) }
}
