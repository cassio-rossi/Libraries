import SwiftData
import SwiftUI
import UIComponentsLibrary

public enum ViewType {
    case classic
    case modern
}

/// Displays a grid of YouTube videos with search and filter capabilities.
///
/// Provides video playback integration and supports filtering by favorites
/// or search terms.
public struct VideosView: View {
    @ObservedObject private var api: YouTubeAPI

    private var favorite: Bool = false
    private var search: String = ""
    private let theme: Themeable?
    private let type: ViewType

    /// Creates a new videos view.
	///
	/// - Parameters:
	///   - api: YouTube API instance managing data and state.
	///   - favorite: Whether to filter for favorite videos only.
	///   - search: Search term to filter videos.
	///   - theme: Optional theme configuration.
    ///   - type: Optional type view mode (modern or classic).
    public init(api: YouTubeAPI,
                favorite: Bool = false,
                search: String = "",
                theme: Themeable? = nil,
                type: ViewType = .modern) {
        self.favorite = favorite
        self.search = search
        self.theme = theme
        self.type = type
        self.api = api
    }

    public var body: some View {
        VideosFromLocalView(api: api,
                            favorite: favorite,
                            searchTerm: search,
                            theme: theme,
                            type: type)
        .modelContainer(api.storage.sharedModelContainer)
    }
}

#if canImport(UIKit)
public struct VideosFromLocalView: View {
    @ObservedObject private var api: YouTubeAPI

    @Query private var videos: [VideoDB]

    @State private var orientation = UIDeviceOrientation.unknown
    @State var isPresenting = false
    @State var action: YouTubePlayerAction = .idle

    private let type: ViewType
    private let theme: Themeable?
    private var favorite: Bool = false
    private var searchTerm: String = ""

    public init(api: YouTubeAPI,
                favorite: Bool,
                searchTerm: String,
                theme: Themeable? = nil,
                type: ViewType) {
        self.favorite = searchTerm.isEmpty ? favorite : false
        self.searchTerm = favorite ? "" : searchTerm
        self.api = api
        self.theme = theme
        self.type = type

        let predicate = #Predicate<VideoDB> {
            $0.favorite == favorite
        }
        _videos = Query(filter: favorite ? predicate : nil,
                        sort: \VideoDB.pubDate,
                        order: .reverse,
                        animation: .smooth)
    }

    public var body: some View {
        VStack {
            VideoErrorView(status: api.status,
                           favorite: favorite,
                           isSearching: !searchTerm.isEmpty,
                           quantity: searchTerm.isEmpty ? videos.count : api.searchResult.count,
                           theme: theme)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: orientation == .portrait ||
                                                       orientation == .portraitUpsideDown ? 280 : 360),
                                             alignment: .top)],
                          spacing: 20) {
                    if searchTerm.isEmpty {
                        videosView
                    } else if api.status.reason == nil {
                        searchView
                    }
                }.padding(.horizontal)
            }
        }

        .background(
            YouTubePlayerView(api: api, action: $action)
                .opacity(0)
                .transition(.opacity)
        )

        .task {
            try? await api.getVideos()
        }
        .onChange(of: searchTerm) { _, value in
            Task {
                try? await api.search(video: value)
            }
        }

        .onRotate { orientation in
            self.orientation = orientation
        }

        .onReceive(api.$selectedVideo) { value in
            guard let videoId = value?.videoId else {
                action = .idle
                return
            }
            withAnimation {
                action = .cue(videoId, value?.current ?? 0)
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

        .onAppear {
            action = .idle
            api.selectedVideo = nil
            api.nextPageToken = nil
        }
        .onDisappear {
            api.searchResult = []
            api.status = .done
        }
    }
}

extension VideosFromLocalView {
    private var videosView: some View {
        ForEach(0..<videos.count, id: \.self) { index in
            VideoItemView(video: videos[index],
                          type: type,
                          selectedVideo: $api.selectedVideo)
            .onAppear {
                if !favorite && searchTerm.isEmpty {
                    api.loadMoreIfNeeded(index: index)
                }
            }
        }
    }

    private var searchView: some View {
        ForEach(api.searchResult, id: \.self) { video in
            VideoItemView(video: video,
                          type: type,
                          selectedVideo: $api.selectedVideo)
        }
    }
}

#else
public struct VideosFromLocalView: View {
    public init(api: YouTubeAPI,
                favorite: Bool,
                searchTerm: String,
                theme: Themeable? = nil) {
    }

    public var body: some View {
        Text("Not supported ...")
    }
}
#endif

#Preview {
    let api = YouTubeAPI()
    VStack {
        VideosView(api: api, type: .modern)
        VideosView(api: api, type: .classic)
        Spacer()
    }
    .background(.brown)
}
