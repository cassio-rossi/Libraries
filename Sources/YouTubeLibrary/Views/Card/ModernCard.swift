import SwiftUI
import UIComponentsLibrary

/// Style options for background fade effects.
public enum FadeStyle {
	/// No fade effect applied.
    case none
	/// Blurred fade with specified width.
	/// - Parameter width: The width of the fade effect.
    case fade(width: CGFloat)
}

/// Modern video card style with overlay design and gradient effects.
///
/// Features thumbnail with overlay information, statistics, and action buttons
/// in a visually appealing dark-themed design.
@MainActor
public struct ModernCard: VideoCard {
    public let accessibilityLabels: [CardLabel]?
    public let accessibilityButtons: [CardButton]?

    private let fade: FadeStyle
    private let position: TimePosition

	/// Creates a modern card style.
	///
	/// - Parameters:
	///   - fade: The fade style to apply (default: .none).
	///   - position: Position of the duration label (default: .bottom).
    ///   - accessibilityLabels: Optional accessibility labels to follow custom VideoCard order.
    ///   - accessibilityButtons: Optional accessibility buttons to follow custom VideoCard order.
    public init(
        fade: FadeStyle = .none,
        position: TimePosition = .bottom,
        accessibilityLabels: [CardLabel]? = nil,
        accessibilityButtons: [CardButton]? = nil
    ) {
        self.fade = fade
        self.position = position
        self.accessibilityLabels = accessibilityLabels
        self.accessibilityButtons = accessibilityButtons
    }

	/// Creates the view for the video card.
	///
	/// - Parameter data: The video data to display.
	/// - Returns: A view representing the modern video card.
    public func makeBody(data: VideoDB) -> some View {
        ModernVideoCard(data: data, fade: fade, position: position)
    }
}

@MainActor
struct ModernVideoCard: View {
    let data: VideoDB
    let fade: FadeStyle
    let position: TimePosition

    var body: some View {
        if let imageUrl = data.url {
            ZStack {
                if case let .fade(width) = fade {
                    CachedAsyncImage(image: imageUrl, contentMode: .fill)
                        .overlay(.ultraThinMaterial)
                        .frame(width: width)
                }

                VStack(spacing: 0) {
                    ThumbnailFactory.make(with: imageUrl, duration: data.duration, position: position)
                    content.cornerRadius(corners: [.bottomLeft, .bottomRight])
                }
            }
        } else {
            content.cornerRadius(corners: .allCorners)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Text(data.pubDate.formattedDate())
                Text("•")
                Text("\((data.views).formattedBigNumber) views")
                Spacer()
            }
            .font(.footnote)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 2)
            .padding(.bottom, 4)

            HStack {
                Text(data.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                Spacer()
            }
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1)
            .padding(.bottom, 12)

            buttons
        }
        .padding([.leading, .trailing])
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.black.opacity(0.6))
    }
}

private extension ModernVideoCard {
    var buttons: some View {
        HStack(alignment: .center, spacing: 10) {
            FavoriteButton(content: data)
                .padding(.top, 4)
                .padding(.bottom, 8)
                .padding([.leading, .trailing], 20)

            ShareButton(content: data)
                .padding(.top, 4)
                .padding(.bottom, 8)
                .padding([.leading, .trailing], 20)
        }
        .tint(.white)
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()
        VideoItemView(
            card: ModernCard(fade: .fade(width: 280)),
            video: YouTubeAPIPreview.preview,
            selectedVideo: .constant(nil)
        )
        .frame(width: 320)
    }
}
