import SwiftUI

/// Classic video card style with a clean, information-focused layout.
///
/// Features thumbnail, publication date, title, statistics, and action buttons.
@MainActor
public struct ClassicCard: VideoCard {
    let buttonColor: Color?
    let errorColor: Color?

	/// Creates a classic card style.
	///
	/// - Parameters:
	///   - buttonColor: Optional custom color for buttons (default: primary color).
	///   - errorColor: Optional custom color for error states.
    public init(
        buttonColor: Color? = nil,
        errorColor: Color? = nil
    ) {
        self.buttonColor = buttonColor
        self.errorColor = errorColor
    }

	/// Creates the view for the video card.
	///
	/// - Parameter data: The video data to display.
	/// - Returns: A view representing the classic video card.
    public func makeBody(data: VideoDB) -> some View {
        ClassicVideoCard(
            data: data,
            buttonColor: buttonColor
        )
    }
}

@MainActor
struct ClassicVideoCard: View {
    let data: VideoDB
    let buttonColor: Color?

    var body: some View {
        if let imageUrl = data.url {
            ZStack {
                VStack(spacing: 0) {
                    ThumbnailFactory.make(with: imageUrl, duration: data.duration, position: .top)
                    content.cornerRadius(corners: [.bottomLeft, .bottomRight])
                }
            }
        } else {
            content.cornerRadius(corners: .allCorners)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(data.pubDate.formattedDate(using: "dd/MM/yyyy HH:mm"))
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.primary)
            .padding(.bottom, 4)

            HStack {
                Text(data.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                Spacer()
            }
            .foregroundColor(.primary)
            .padding(.bottom, 8)

            HStack(alignment: .center) {
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar")
                        Text("\((data.views).formattedBigNumber)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                        Text("\((data.likes).formattedBigNumber)")
                    }
                }
                .font(.footnote)
                .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 20) {
                    FavoriteButton(content: data)
                    ShareButton(content: data)
                }
                .tint(buttonColor ?? .primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .padding(.bottom, 2)
        .background(.background)
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()
        VStack {
            VideoItemView(
                card: ClassicCard(),
                video: YouTubeAPIPreview.preview,
                selectedVideo: .constant(nil)
            )
        }
    }
}
