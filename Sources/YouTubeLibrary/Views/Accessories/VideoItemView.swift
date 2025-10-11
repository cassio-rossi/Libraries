import SwiftData
import SwiftUI
import UIComponentsLibrary

struct VideoItemView: View {
    @Environment(\.modelContext) private var context
    @Bindable var video: VideoDB
	@Binding var selectedVideo: VideoDB?

	private var fade: Bool
	private var width: CGFloat

	enum ViewType {
		case showAll
		case hideTop
		case hideBottom
	}

	init(video: VideoDB,
		 width: CGFloat = .infinity,
		 fade: Bool = false,
		 selectedVideo: Binding<VideoDB?>) {
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
						Thumbnail(imageUrl: imageUrl,
								  duration: video.duration,
								  position: .top,
								  corners: [.topLeft, .topRight])
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
	private var buttons: some View {
		HStack(spacing: 10) {
            favorite
            share
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
        .padding(.top, 4)
        .padding(.bottom, 8)
        .padding([.leading, .trailing], 20)
    }

    @ViewBuilder
    private var share: some View {
        share(video: video)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .padding([.leading, .trailing], 20)
    }

    @ViewBuilder
	private var videoContentView: some View {
		VStack(spacing: 0) {
			HStack(alignment: .center, spacing: 4) {
				Text(video.pubDate.formattedDate)
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
		.cornerRadius(12, corners: [.bottomLeft, .bottomRight])
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
                      width: 320,
                      fade: true,
                      selectedVideo: .constant(nil))

        VideoItemView(video: YouTubeAPIPreview.preview,
                      width: 320,
                      selectedVideo: .constant(nil))
        .frame(height: 320)
    }
}
