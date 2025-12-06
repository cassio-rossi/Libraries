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
    @State private var cardWidth = CGFloat.zero

    @Binding var scrollPosition: ScrollPosition

    private let card: any VideoCard
    private let usesDensity: Bool

    private var favorite: Bool = false
    private var searchTerm: String = ""
    private var density: CardDensity { .density(using: cardWidth) }

    private let grid = GridItem(
        .adaptive(minimum: 280),
        spacing: 20,
        alignment: .top
    )

    init(
        card: any VideoCard,
        usesDensity: Bool = true,
        api: YouTubeAPI,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool,
        searchTerm: String
    ) {
        self.card = card
        self.usesDensity = usesDensity
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
                LazyVGrid(columns: Array(repeating: grid, count: usesDensity ? density.columns : 1),
                          spacing: 20) {
                    if searchTerm.isEmpty {
                        videosView
                    } else if api.status.reason == nil {
                        searchView
                    }
                }.padding(.horizontal)
            }
            .scrollPosition($scrollPosition)
        }
        .cardSize { value in
            cardWidth = value
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

        .refreshable {
            if searchTerm.isEmpty {
                api.nextPageToken = nil
                try? await api.getVideos()
            }
        }
        .task {
            if api.status == .idle {
                try? await api.getVideos(status: .loading)
            }
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
            VideoItemView(card: card,
                          video: videos[index],
                          selectedVideo: $api.selectedVideo)
            .cardAccessibility(
                data: videos[index],
                labels: card.accessibilityLabels,
                buttons: card.accessibilityButtons
            )
            .onAppear {
                if !favorite && searchTerm.isEmpty {
                    api.loadMoreIfNeeded(index: index)
                }
            }
        }
    }

    var searchView: some View {
        ForEach(api.searchResult, id: \.self) { video in
            VideoItemView(card: card,
                          video: video,
                          selectedVideo: $api.selectedVideo)
        }
    }
}

#else
struct VideosView: View {
    init(
        card: any VideoCard,
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
