import SwiftData
import SwiftUI
import UIComponentsLibrary

#if canImport(UIKit)
struct VideosView: View {
    @ObservedObject private var api: YouTubeAPI

    @Query private var videos: [VideoDB]

    @State private var orientation = UIDeviceOrientation.unknown
    @State private var isPresenting = false
    @State private var action: YouTubePlayerAction = .idle

    @Binding var scrollPosition: ScrollPosition

    private let style: any VideoStyle
    private var favorite: Bool = false
    private var searchTerm: String = ""

    init(
        style: any VideoStyle,
        api: YouTubeAPI,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool,
        searchTerm: String
    ) {
        self.style = style
        self.api = api
        self.favorite = searchTerm.isEmpty ? favorite : false
        self.searchTerm = favorite ? "" : searchTerm

        _scrollPosition = scrollPosition

        let predicate = #Predicate<VideoDB> {
            $0.favorite == favorite
        }
        _videos = Query(filter: favorite ? predicate : nil,
                        sort: \VideoDB.pubDate,
                        order: .reverse,
                        animation: .smooth)
    }

    var body: some View {
        VStack {
            VideoErrorView(status: api.status,
                           favorite: favorite,
                           isSearching: !searchTerm.isEmpty,
                           quantity: searchTerm.isEmpty ? videos.count : api.searchResult.count,
                           color: nil)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16, alignment: .top)],
                          spacing: 16) {
                    if searchTerm.isEmpty {
                        videosView
                    } else if api.status.reason == nil {
                        searchView
                    }
                }.padding(.horizontal)
            }
            .scrollPosition($scrollPosition)
            .refreshable {
                if searchTerm.isEmpty {
                    api.nextPageToken = nil
                    try? await api.getVideos()
                }
            }
        }

        // Opens YT player
        .background(YouTubePlayerView(api: api, action: $action).opacity(0))

        .onAppear {
            action = .idle
            api.selectedVideo = nil
            api.nextPageToken = nil
        }
        .onDisappear {
            api.searchResult = []
            api.status = .done
        }

        .task {
            try? await api.getVideos()
        }

        .onRotate { orientation in
            self.orientation = orientation
        }

        .onReceive(api.$selectedVideo) { value in
            guard let videoId = value?.videoId else {
                action = .idle
                isPresenting = false
                return
            }
            action = .cue(videoId, value?.current ?? 0)
        }

        .onChange(of: searchTerm) { _, value in
            Task {
                try? await api.search(video: value)
            }
        }

        .onChange(of: action) { _, action in
            Task {
                switch action {
                case .paused(let videoId, let current):
                    await api.update(videoId: videoId, current: current)
                    api.selectedVideo = nil
                    self.action = .idle
                    isPresenting = false
                default: break
                }
            }
        }
    }
}

private extension VideosView {
    var videosView: some View {
        ForEach(0..<videos.count, id: \.self) { index in
            VideoItemView(style: style,
                          video: videos[index],
                          selectedVideo: $api.selectedVideo)
            .onAppear {
                if !favorite && searchTerm.isEmpty {
                    api.loadMoreIfNeeded(index: index)
                }
            }
        }
    }

    var searchView: some View {
        ForEach(api.searchResult, id: \.self) { video in
            VideoItemView(style: style,
                          video: video,
                          selectedVideo: $api.selectedVideo)
        }
    }
}

#else
struct VideosView: View {
    init(
        style: any VideoStyle,
        api: YouTubeAPI,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool,
        searchTerm: String
    ) {}

    var body: some View {
        Text("Not supported ...")
    }
}
#endif
