import SwiftUI
import UIComponentsLibrary

enum TimePosition: Sendable {
	case top
	case bottom
	case center
	case none
}

struct Thumbnail: View {
	let imageUrl: URL
	let duration: String
	let position: TimePosition
    #if canImport(UIKit)
	let corners: UIRectCorner
    #endif

#if canImport(UIKit)
    init(imageUrl: URL,
		 duration: String,
		 position: TimePosition = .bottom,
		 corners: UIRectCorner = .allCorners) {
		self.imageUrl = imageUrl
		self.duration = duration
		self.position = position
		self.corners = corners
	}
#else
    init(imageUrl: URL,
         duration: String,
         position: TimePosition = .bottom) {
        self.imageUrl = imageUrl
        self.duration = duration
        self.position = position
    }
#endif

	var body: some View {
		ZStack {
			GeometryReader { geo in
				CachedAsyncImage(image: imageUrl, contentMode: .fill)
					.frame(height: geo.size.width * 9 / 16)
                    #if canImport(UIKit)
					.cornerRadius(12, corners: corners)
                    #else
                    .cornerRadius(12)
                    #endif
			}

			if position != .none {
				VStack {
					if position == .bottom {
						Spacer()
					}
					HStack {
						Spacer()

						Text(duration)
							.font(.caption)
							.padding(6)
							.foregroundColor(.white)
							.background(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.80))
							.cornerRadius(6)
					}
					if position == .top {
						Spacer()
					}
				}
				.padding([.top, .bottom, .trailing], 10)
			}
		}
		.aspectRatio(16 / 9, contentMode: .fit)
	}
}

struct ButtonGeneric: View {
	var text: String?
	let image: String
	var theme: Themeable?
	var color: Color?
	let action: () -> Void

	var body: some View {
		Button(action: action, label: {
			if let text = text {
				Text(text)
			}
			Image(systemName: image)
		})
		.foregroundColor(.white)
		.shadow(color: .black, radius: 1)
	}
}

// swiftlint:disable force_unwrapping
#Preview {
    VStack {
        Thumbnail(imageUrl: URL(string: "https://i.ytimg.com/vi/ZNZ8Ij79vQk/hqdefault.jpg")!,
                  duration: "PT4M46S".formattedYTDuration)

#if canImport(UIKit)
        Thumbnail(imageUrl: URL(string: "https://i.ytimg.com/vi/ZNZ8Ij79vQk/hqdefault.jpg")!,
                  duration: "PT4M46S".formattedYTDuration,
                  position: .top,
                  corners: [.topLeft, .topRight])
#endif
    }
    .padding()
}
// swiftlint:enable force_unwrapping
