import SwiftUI

@MainActor
public struct ModernStyle: VideoStyle {
    public let fade: Bool
    public let position: TimePosition
    public let overlap: CGFloat

    public init(
        fade: Bool = false,
        position: TimePosition = .top,
        overlap: CGFloat = 0
    ) {
        self.fade = fade
        self.position = position
        self.overlap = overlap
    }

    public func makeBody(data: VideoDB) -> some View {
        ModernVideoCard(data: data)
    }
}

@MainActor
struct ModernVideoCard: View {
    let data: VideoDB

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
            selectedVideo: .constant(nil)
        )
    }
}
