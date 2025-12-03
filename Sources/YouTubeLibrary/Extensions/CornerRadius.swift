import SwiftUI

/// Option set for specifying which corners should be rounded.
///
/// Provides cross-platform corner specification with UIKit compatibility.
public struct LibraryCorner: OptionSet, Sendable {
	/// The raw value representing the corner selection.
    public let rawValue: UInt

	/// Round the top-left corner.
    static public let topLeft = LibraryCorner(rawValue: 1 << 0)
	/// Round the top-right corner.
    static public let topRight = LibraryCorner(rawValue: 1 << 1)
	/// Round the bottom-left corner.
    static public let bottomLeft = LibraryCorner(rawValue: 1 << 2)
	/// Round the bottom-right corner.
    static public let bottomRight = LibraryCorner(rawValue: 1 << 3)
	/// Round all corners.
    static public let allCorners = LibraryCorner(rawValue: 1 << 4)

	/// Creates a corner option set with the specified raw value.
	///
	/// - Parameter rawValue: The raw integer value representing corner selections.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

#if canImport(UIKit)
	/// Converts to UIKit's UIRectCorner type.
    var toUIRectCorner: UIRectCorner {
        if self == .allCorners { return .allCorners }
        return UIRectCorner(rawValue: self.rawValue)
    }
#endif
}

extension View {
	/// Applies rounded corners to specific corners of the view.
	///
	/// - Parameter corners: The corners to round.
	/// - Returns: A view with the specified corners rounded.
    public func cornerRadius(corners: LibraryCorner) -> some View {
        self.modifier(CornerRadius(corners: corners))
    }
}

#if canImport(UIKit)
/// View modifier that applies corner radius to specific corners on UIKit platforms.
public struct CornerRadius: ViewModifier {
    let corners: UIRectCorner

	/// Creates a corner radius modifier for specific corners.
	///
	/// - Parameter corners: The corners to round.
    public init(corners: LibraryCorner) {
        self.corners = corners.toUIRectCorner
    }

	/// Applies the corner radius to the content view.
    public func body(content: Content) -> some View {
        content
            .cornerRadius(12, corners: corners)
    }
}
#else
/// View modifier that applies corner radius on non-UIKit platforms.
public struct CornerRadius: ViewModifier {
	/// Creates a corner radius modifier.
	///
	/// - Parameter corners: The corners to round (ignored on non-UIKit platforms).
    public init(corners: LibraryCorner) {}

	/// Applies a uniform corner radius to all corners.
    public func body(content: Content) -> some View {
        content.cornerRadius(12)
    }
}
#endif
