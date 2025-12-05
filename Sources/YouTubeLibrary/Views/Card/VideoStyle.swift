import SwiftUI

/// Protocol defining the interface for custom video card views.
///
/// Implement this protocol to create custom video card layouts for the Videos view.
@MainActor
public protocol VideoCard {
    associatedtype Content: View

    /// Optional accessibility labels to follow custom VideoCard order
    var accessibilityLabels: [CardLabel]? { get }

    /// Optional accessibility buttons to follow custom VideoCard order
    var accessibilityButtons: [CardButton]? { get }

    /// Creates the view for a video card.
	///
	/// - Parameter data: The video data to display.
	/// - Returns: A view representing the video card.
    @ViewBuilder
    func makeBody(data: VideoDB) -> Content
}
