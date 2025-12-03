#if canImport(UIKit)
import SwiftUI
import UIKit

extension View {
	/// Applies corner rounding to specific corners of the view.
	///
	/// This UIKit-specific extension allows you to round only selected corners of a view,
	/// unlike the standard `cornerRadius` modifier which rounds all corners.
	///
	/// - Parameters:
	///   - radius: The corner radius to apply.
	///   - corners: The specific corners to round (e.g., `.topLeft`, `.bottomRight`, or `.allCorners`).
	/// - Returns: A view with the specified corners rounded.
	/// - Note: This method is only available on platforms that support UIKit.
	public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(RoundedCorner(radius: radius, corners: corners))
	}
}

/// A shape that represents a rectangle with selectively rounded corners.
///
/// `RoundedCorner` allows you to create a rounded rectangle where only specific corners
/// are rounded, providing more flexibility than the standard rounded rectangle shape.
/// This is particularly useful for custom UI designs that require asymmetric corner rounding.
///
/// - Note: This shape is only available on platforms that support UIKit.
public struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners

	/// Creates a rounded corner shape.
	///
	/// - Parameters:
	///   - radius: The corner radius to apply to the specified corners.
	///   - corners: The specific corners to round (e.g., `.topLeft`, `.bottomRight`, or `.allCorners`).
	public init(radius: CGFloat, corners: UIRectCorner) {
		self.radius = radius
		self.corners = corners
	}

	/// Creates the path for the rounded corner shape.
	///
	/// - Parameter rect: The rectangle in which to draw the shape.
	/// - Returns: A path representing the rounded corner shape.
	public func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: corners,
								cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}
#endif
