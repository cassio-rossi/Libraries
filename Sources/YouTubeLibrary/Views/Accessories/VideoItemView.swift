import SwiftData
import SwiftUI
import UIComponentsLibrary

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let style: any VideoStyle
    private let width: CGFloat

    init(
        style: any VideoStyle,
        video: VideoDB,
        width: CGFloat = .infinity,
        selectedVideo: Binding<VideoDB?>
    ) {
        self.style = style
        self.video = video
        self.width = width
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
                        thumbnail(with: imageUrl, position: style.position)
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
    private func thumbnail(with imageUrl: URL, position: TimePosition) -> some View {
#if canImport(UIKit)
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: position,
                  corners: [.topLeft, .topRight])
#else
        Thumbnail(imageUrl: imageUrl,
                  duration: video.duration,
                  position: position)
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
