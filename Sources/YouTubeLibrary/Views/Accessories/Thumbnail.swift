import SwiftUI
import UIComponentsLibrary

/// Position options for the duration label on a thumbnail.
public enum TimePosition: Sendable {
	/// Position at the top of the thumbnail.
	case top
	/// Position at the bottom of the thumbnail.
	case bottom
	/// Position at the center of the thumbnail.
	case center
	/// Hide the duration label.
	case none
}

/// Factory for creating thumbnail views with platform-specific configurations.
public struct ThumbnailFactory {
	/// Creates a thumbnail view.
	///
	/// - Parameters:
	///   - imageUrl: URL of the thumbnail image.
	///   - duration: Formatted duration string to display.
	///   - position: Position of the duration label.
	/// - Returns: Configured thumbnail view.
    public static func make(
        with imageUrl: URL,
        duration: String,
        position: TimePosition
    ) -> some View {
#if canImport(UIKit)
        Thumbnail(imageUrl: imageUrl,
                  duration: duration,
                  position: position,
                  corners: [.topLeft, .topRight])
#else
        Thumbnail(imageUrl: imageUrl,
                  duration: duration,
                  position: position)
#endif
    }
}

/// Video thumbnail view with duration overlay.
///
/// Displays a video thumbnail in 16:9 aspect ratio with an optional duration label.
public struct Thumbnail: View {
    let imageUrl: URL
	let duration: String
	let position: TimePosition

#if canImport(UIKit)
    let corners: UIRectCorner

	/// Creates a thumbnail view with custom corner rounding (UIKit platforms).
	///
	/// - Parameters:
	///   - imageUrl: URL of the thumbnail image.
	///   - duration: Formatted duration string to display.
	///   - position: Position of the duration label (default: .bottom).
	///   - corners: Which corners to round (default: .allCorners).
    public init(
        imageUrl: URL,
        duration: String,
        position: TimePosition = .bottom,
        corners: UIRectCorner = .allCorners
    ) {
        self.imageUrl = imageUrl
        self.duration = duration
        self.position = position
        self.corners = corners
    }
#else
	/// Creates a thumbnail view (non-UIKit platforms).
	///
	/// - Parameters:
	///   - imageUrl: URL of the thumbnail image.
	///   - duration: Formatted duration string to display.
	///   - position: Position of the duration label (default: .bottom).
    public init(
        imageUrl: URL,
        duration: String,
        position: TimePosition = .bottom
    ) {
        self.imageUrl = imageUrl
        self.duration = duration
        self.position = position
    }
#endif

	public var body: some View {
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
