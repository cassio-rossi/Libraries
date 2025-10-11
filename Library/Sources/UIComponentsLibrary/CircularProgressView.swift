import SwiftUI

public struct CircularProgressView: View {
	let progress: Double
	let color: Color
	let lineWidth: CGFloat

	public init(progress: Double, lineWidth: CGFloat = 20, color: Color) {
		self.progress = progress
		self.lineWidth = lineWidth
		self.color = color
	}

	public var body: some View {
		ZStack {
			Circle()
				.stroke(color.opacity(0.5), lineWidth: lineWidth)

			Circle()
				.trim(from: 0, to: progress)
				.stroke(color,
						style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.easeOut, value: progress)
		}
	}
}

#Preview {
	VStack {
		CircularProgressView(progress: 0.4, lineWidth: 10, color: .blue)
			.frame(width: 60)

		CircularProgressView(progress: 0.4, color: .blue)
			.frame(width: 200)
	}
}
