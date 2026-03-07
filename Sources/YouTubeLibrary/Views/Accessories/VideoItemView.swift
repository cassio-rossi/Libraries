import SwiftData
import SwiftUI

public struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let card: any VideoCard

    public init(
        card: any VideoCard,
        video: VideoDB,
        selectedVideo: Binding<VideoDB?>
    ) {
        self.card = card
        self.video = video
        _selectedVideo = selectedVideo
    }

    public var body: some View {
        Button(action: {
            selectedVideo = video
        }, label: {
            videoContentView
                .cornerRadius(corners: .allCorners)
        })
    }

    @ViewBuilder
    private var videoContentView: some View {
        AnyView(card.makeBody(data: video))
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()

        VStack {
            VideoItemView(
                card: ModernCard(),
                video: YouTubeAPIPreview.preview,
                selectedVideo: .constant(nil)
            )

            VideoItemView(
                card: ClassicCard(),
                video: YouTubeAPIPreview.preview,
                selectedVideo: .constant(nil)
            )
            .frame(height: 320)
        }
    }
}
