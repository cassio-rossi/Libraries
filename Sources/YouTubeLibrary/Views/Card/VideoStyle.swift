import SwiftUI

/// Protocol defining the interface for custom video card views.
///
/// Implement this protocol to create custom video card layouts for the Videos view.
@MainActor
public protocol VideoCard {
	/// The type of view returned by makeBody.
    associatedtype Content: View

	/// Creates the view for a video card.
	///
	/// - Parameter data: The video data to display.
	/// - Returns: A view representing the video card.
    @ViewBuilder
    func makeBody(data: VideoDB) -> Content
}
