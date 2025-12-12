import SwiftUI

/// A view that displays an error message with fade-in animation.
public struct ErrorView: View {
	/// Defines the horizontal alignment position for the error message.
	public enum Position {
		case left
		case right
		case center

        var aligment: Alignment {
            switch self {
            case .left: .leading
            case .right: .trailing
            case .center: .center
            }
        }
	}

	let message: String
	let position: Position
	let color: Color
	@State private var animate = false

	/// Creates a new error view.
	///
	/// - Parameters:
	///   - message: The error message to display. Returns nil if message is nil.
	///   - position: The horizontal alignment of the message. Default is .left.
	///   - color: The color of the error text. Default is .red.
	/// - Returns: An ErrorView instance, or nil if the message is nil.
	public init?(
		message: String?,
		position: Position = .left,
		color: Color = .red
	) {
		guard let message else { return nil }
		self.message = message
		self.position = position
		self.color = color
	}

    public var body: some View {
		HStack {
			Text(message)
				.font(.footnote)
				.foregroundColor(color)
		}
        .frame(maxWidth: .infinity, alignment: position.aligment)
		.opacity(animate ? 1.0 : 0.0)
		.onAppear {
			withAnimation(.easeIn(duration: 0.4)) {
				animate.toggle()
			}
		}
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
		List {
			ErrorView(message: "An error occurred.")
				.preferredColorScheme(.dark)
				.previewDisplayName("Default")
			ErrorView(message: "An error occurred.", position: .center)
				.preferredColorScheme(.light)
				.previewDisplayName("Center")
			ErrorView(message: "An error occurred.", position: .right)
				.previewDisplayName("Right")
			ErrorView(message: nil)
				.previewDisplayName("Empty")
		}
    }
}
