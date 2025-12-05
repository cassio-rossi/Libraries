import SwiftUI

/// Classic video card style with a clean, information-focused layout.
///
/// Features thumbnail, publication date, title, statistics, and action buttons.
@MainActor
public struct ClassicCard: VideoCard {
    /// Optional accessibility labels to follow custom VideoCard order
    public let accessibilityLabels: [CardLabel]?
    /// Optional accessibility buttons to follow custom VideoCard order
    public let accessibilityButtons: [CardButton]?
    let buttonColor: Color?
    let errorColor: Color?

	/// Creates a classic card style.
	///
	/// - Parameters:
	///   - buttonColor: Optional custom color for buttons (default: primary color).
	///   - errorColor: Optional custom color for error states.
    ///   - accessibilityLabels: Optional accessibility labels to follow custom VideoCard order.
    ///   - accessibilityButtons: Optional accessibility buttons to follow custom VideoCard order.
    public init(
        buttonColor: Color? = nil,
        errorColor: Color? = nil,
        accessibilityLabels: [CardLabel]? = nil,
        accessibilityButtons: [CardButton]? = nil
    ) {
        self.buttonColor = buttonColor
        self.errorColor = errorColor
        self.accessibilityLabels = accessibilityLabels
        self.accessibilityButtons = accessibilityButtons
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
    @Environment(\.dynamicTypeSize) private var typeSize

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
                Text(data.pubDate.formattedDate(using: typeSize >= .accessibility1 ? "dd/MM/yyyy" : "dd/MM/yyyy HH:mm"))
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

            bottomContent
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .padding(.bottom, 2)
        .background(.background)
    }
}

private extension ClassicVideoCard {
    @ViewBuilder
    var bottomContent: some View {
        let layout: AnyLayout = switch typeSize {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            AnyLayout(VStackLayout(spacing: 20))
        default:
            AnyLayout(HStackLayout(alignment: .center))
        }

        layout {
            statistics
            if typeSize < .accessibility1 {
                Spacer()
            }
            buttons
        }
    }

    @ViewBuilder
    var statistics: some View {
        let layout: AnyLayout = switch typeSize {
        case .accessibility4, .accessibility5:
            AnyLayout(VStackLayout(spacing: 20))
        default:
            AnyLayout(HStackLayout(spacing: 20))
        }

        layout {
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
    }

    var buttons: some View {
        HStack(spacing: 20) {
            FavoriteButton(content: data)
            ShareButton(content: data)
        }
        .tint(buttonColor ?? .primary)
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
