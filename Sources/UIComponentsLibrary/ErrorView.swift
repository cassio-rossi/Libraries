import SwiftUI

public struct ErrorView: View {
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

	public init?(message: String?,
				 position: Position = .left,
                 color: Color = .red) {
		guard let message = message else { return nil }
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
