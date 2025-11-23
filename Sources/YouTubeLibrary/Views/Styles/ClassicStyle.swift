import SwiftUI

@MainActor
public struct ClassicStyle: VideoStyle {
    let buttonColor: Color?
    let errorColor: Color?

    public init(
        buttonColor: Color? = nil,
        errorColor: Color? = nil
    ) {
        self.buttonColor = buttonColor
        self.errorColor = errorColor
    }

    public func makeBody(data: VideoDB, width: CGFloat) -> some View {
        ClassicVideoCard(
            data: data,
            width: width,
            buttonColor: buttonColor
        )
    }
}

@MainActor
struct ClassicVideoCard: View {
    let data: VideoDB
    let width: CGFloat
    let buttonColor: Color?

    var body: some View {
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
        .limitTo(width: width)
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()
        VStack {
            VideoItemView(
                style: ClassicStyle(),
                video: YouTubeAPIPreview.preview,
                width: 360,
                selectedVideo: .constant(nil)
            )
        }
    }
}
