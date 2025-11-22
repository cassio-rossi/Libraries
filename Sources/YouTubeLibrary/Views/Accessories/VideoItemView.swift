import SwiftData
import SwiftUI
import UIComponentsLibrary

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
    @Binding var selectedVideo: VideoDB?

    private let fade: Bool
    private let width: CGFloat
    private let type: ViewType
    private let theme: Themeable?

    init(video: VideoDB,
         theme: Themeable? = nil,
         width: CGFloat = .infinity,
         type: ViewType,
         fade: Bool = false,
         selectedVideo: Binding<VideoDB?>) {
        self.video = video
        self.theme = theme
        self.type = type
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
                .if(width != .infinity) { content in
                    content
                        .frame(width: width)
                }
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
    private var buttons: some View {
        HStack(alignment: .center, spacing: 10) {
            favorite
                .padding(.top, 4)
                .padding(.bottom, 8)
                .padding([.leading, .trailing], 20)

            share
                .padding(.top, 4)
                .padding(.bottom, 8)
                .padding([.leading, .trailing], 20)
        }
        .tint(.white)
    }

    @ViewBuilder
    private var favorite: some View {
        Button {
            video.favorite.toggle()
            try? context.save()
        } label: {
            Image(systemName: "star\(video.favorite ? ".fill" : "")")
        }
    }

    @ViewBuilder
    private var share: some View {
        share(video: video)
    }

    @ViewBuilder
    private var videoContentView: some View {
        switch type {
        case .modern: modernView
        case .classic: classicView
        }
    }

    private var modernView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Text(video.pubDate.formattedDate())
                Text("•")
                Text("\((video.views).formattedBigNumber) views")
                Spacer()
            }
            .font(.footnote)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 2)
            .padding(.bottom, 4)

            HStack {
                Text(video.title)
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
        .cornerRadius()
        .if(width != .infinity) { content in
            content
                .frame(width: width)
        }
    }

    private var classicView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(video.pubDate.formattedDate(using: "dd/MM/yyyy HH:mm"))
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.primary)
            .padding(.bottom, 4)

            HStack {
                Text(video.title)
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
                        Text("\((video.views).formattedBigNumber)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                        Text("\((video.likes).formattedBigNumber)")
                    }
                }
                    .font(.footnote)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 20) {
                    favorite
                    share
                }
                .tint(theme?.button.primary.asColor ?? .blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .padding(.bottom, 2)
        .background(.background)
        .cornerRadius()
        .if(width != .infinity) { content in
            content
                .frame(width: width)
        }
    }
}

extension VideoItemView {
    @ViewBuilder
    private func share(video: VideoDB) -> some View {
        let youTubeURL = "https://www.youtube.com/watch?v="

        if let url = URL(string: "\(youTubeURL)\(video.videoId)"),
           !video.title.isEmpty {

            ShareLink(item: url,
                      subject: Text(video.title)) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

#Preview {
    VStack {
        VideoItemView(video: YouTubeAPIPreview.preview,
                      width: 360,
                      type: .modern,
                      fade: true,
                      selectedVideo: .constant(nil))

        VideoItemView(video: YouTubeAPIPreview.preview,
                      width: 320,
                      type: .classic,
                      selectedVideo: .constant(nil))
        .frame(height: 320)
    }
    .background(.brown)
}

extension View {
    public func cornerRadius() -> some View {
        self.modifier(CornerRadius())
    }
}

public struct CornerRadius: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
#if canImport(UIKit)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
#endif
    }
}
