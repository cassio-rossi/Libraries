import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 18.0, *)
@available(macOS, unavailable)
@available(visionOS, unavailable)
extension View {
	public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(RoundedCorner(radius: radius, corners: corners))
	}
}

@available(iOS 18.0, *)
@available(macOS, unavailable)
@available(visionOS, unavailable)
public struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners

	public init(radius: CGFloat, corners: UIRectCorner) {
		self.radius = radius
		self.corners = corners
	}

	public func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: corners,
								cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}
