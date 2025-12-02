import SwiftData
import SwiftUI
import UIComponentsLibrary

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let style: any VideoStyle

    init(
        style: any VideoStyle,
        video: VideoDB,
        selectedVideo: Binding<VideoDB?>
    ) {
        self.style = style
        self.video = video
        _selectedVideo = selectedVideo
    }

    var body: some View {
        Button(action: {
            selectedVideo = video
        }, label: {
            if let imageUrl = video.url {
                ZStack {
                    if style.fade {
                        CachedAsyncImage(image: imageUrl, contentMode: .fill)
                            .overlay(.ultraThinMaterial)
                    }

                    VStack(spacing: 0) {
                        thumbnail(with: imageUrl, position: style.position, overlap: style.overlap)

                        videoContentView
                            .cornerRadius(corners: [.bottomLeft, .bottomRight])
                            .zIndex(1)
                    }
                }
            } else {
                videoContentView
                    .cornerRadius(corners: .allCorners)
            }
        })
    }

    @ViewBuilder
    private func thumbnail(
        with imageUrl: URL,
        position: TimePosition,
        overlap: CGFloat
    ) -> some View {
#if canImport(UIKit)
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: position,
                  overlap: overlap,
                  corners: [.topLeft, .topRight])
#else
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: position,
                  overlap: overlap)
#endif
    }

    @ViewBuilder
    private var videoContentView: some View {
        AnyView(style.makeBody(data: video))
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()

        VStack {
            VideoItemView(
                style: ModernStyle(),
                video: YouTubeAPIPreview.preview,
                selectedVideo: .constant(nil)
            )

            VideoItemView(
                style: ClassicStyle(),
                video: YouTubeAPIPreview.preview,
                selectedVideo: .constant(nil)
            )
            .frame(height: 320)
        }
    }
}
