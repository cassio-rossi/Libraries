import SwiftUI

@MainActor
public struct ModernStyle: VideoStyle {
    public init() {}

    public func makeBody(data: VideoDB, width: CGFloat) -> some View {
        ModernVideoCard(data: data, width: width)
    }
}

@MainActor
struct ModernVideoCard: View {
    let data: VideoDB
    let width: CGFloat

    var body: some View {
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
        .limitTo(width: width)
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
            style: ModernStyle(),
            video: YouTubeAPIPreview.preview,
            width: 360,
            fade: true,
            selectedVideo: .constant(nil)
        )
    }
}
