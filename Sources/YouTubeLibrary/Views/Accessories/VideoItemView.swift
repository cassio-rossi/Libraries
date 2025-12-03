import SwiftData
import SwiftUI

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let card: any VideoCard

    init(
        card: any VideoCard,
        video: VideoDB,
        selectedVideo: Binding<VideoDB?>
    ) {
        self.card = card
        self.video = video
        _selectedVideo = selectedVideo
    }

    var body: some View {
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
