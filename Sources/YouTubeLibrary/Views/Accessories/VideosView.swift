import SwiftData
import SwiftUI
import UIComponentsLibrary

#if canImport(UIKit)
struct VideosView: View {
    @Bindable private var api: YouTubeAPI

    @Query private var videos: [VideoDB]

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
        let retryAction: () -> Void = {
            Task {
                try? await api.getVideos()
            }
        }

        CollectionView(
            title: "Vídeo",
            status: api.status,
            usesDensity: usesDensity,
            scrollPosition: $scrollPosition,
            favorite: favorite,
            isSearching: !searchTerm.isEmpty,
            quantity: searchTerm.isEmpty ? videos.count : api.searchResult.count,
            content: {
                content
            },
            retryAction: favorite ? nil : retryAction)

        // Opens YT player - ID prevents recreation on rotation
        .background(
            YouTubePlayerView(api: api, action: $action)
                .opacity(0)
                .id("youtube-player-stable")
        )

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

        .onChange(of: api.selectedVideo) { _, newValue in
            guard let videoId = newValue?.videoId else {
                action = .idle
                return
            }
            action = .cue(videoId, newValue?.current ?? 0)
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
                default: break
                }
            }
        }
    }
}

private extension VideosView {
    @ViewBuilder
    var content: some View {
        if searchTerm.isEmpty {
            videosView
        } else if api.status.reason == nil {
            searchView
        }
    }

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
        usesDensity: Bool = true,
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
