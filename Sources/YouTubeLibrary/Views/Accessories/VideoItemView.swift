import SwiftData
import SwiftUI
import UIComponentsLibrary

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let fade: Bool
    private let width: CGFloat
    private let style: VideoStyle

    init(
        style: VideoStyle,
        video: VideoDB,
        width: CGFloat = .infinity,
        fade: Bool = false,
        selectedVideo: Binding<VideoDB?>
    ) {
        self.style = style
        self.video = video
        self.fade = fade
        self.width = width
        _selectedVideo = selectedVideo
    }

    var body: some View {
        Button(action: {
            selectedVideo = video
        }, label: {
            if let imageUrl = video.url {
                ZStack {
                    if fade {
                        CachedAsyncImage(image: imageUrl, contentMode: .fill)
                            .overlay(.ultraThinMaterial)
                    }

                    VStack(spacing: 0) {
                        thumbnail(with: imageUrl)
                            .if(width != .infinity) { content in
                                content
                                    .frame(height: width * 9 / 16)
                            }

                        videoContentView
                    }
                }
                .limitTo(width: width)
            } else {
                videoContentView
            }
        })
    }

    @ViewBuilder
    private func thumbnail(with imageUrl: URL) -> some View {
#if canImport(UIKit)
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: .top,
                  corners: [.topLeft, .topRight])
#else
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: .top)
#endif
    }

    @ViewBuilder
    private var videoContentView: some View {
        AnyView(style.makeBody(data: video, width: width))
            .cornerRadius()
    }
}

#Preview {
    ZStack {
        Color.brown.ignoresSafeArea()

        VStack {
            VideoItemView(
                style: ModernStyle(),
                video: YouTubeAPIPreview.preview,
                width: 360,
                fade: true,
                selectedVideo: .constant(nil)
            )

            VideoItemView(
                style: ClassicStyle(),
                video: YouTubeAPIPreview.preview,
                width: 320,
                selectedVideo: .constant(nil)
            )
            .frame(height: 320)
        }
    }
}
