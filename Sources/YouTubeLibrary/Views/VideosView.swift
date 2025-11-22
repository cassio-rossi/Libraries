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
    @Binding private var scrollPosition: ScrollPosition

    private var favorite: Bool = false
    private var search: String = ""
    private let buttonColor: Color?
    private let errorColor: Color?
    private let type: ViewType

    /// Creates a new videos view.
	///
	/// - Parameters:
	///   - api: YouTube API instance managing data and state.
    ///   - scrollPosition: Allow tap to top.
	///   - favorite: Whether to filter for favorite videos only.
	///   - search: Search term to filter videos.
    ///   - type: Optional type view mode (modern or classic).
	///   - buttonColor: Optional color for buttons.
    ///   - errorColor: Optional color for error messages.
    public init(api: YouTubeAPI,
                scrollPosition: Binding<ScrollPosition>,
                favorite: Bool = false,
                search: String = "",
                theme: Themeable? = nil,
                type: ViewType = .modern,
                buttonColor: Color? = nil,
                errorColor: Color? = nil) {
        self.favorite = favorite
        self.search = search
        self.buttonColor = buttonColor
        self.errorColor = errorColor
        self.type = type
        self.api = api
        _scrollPosition = scrollPosition
    }

    public var body: some View {
        VideosFromLocalView(api: api,
                            scrollPosition: $scrollPosition,
                            favorite: favorite,
                            searchTerm: search,
                            type: type,
                            buttonColor: buttonColor,
                            errorColor: errorColor
        )
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

    @Binding var scrollPosition: ScrollPosition

    private let type: ViewType
    private let buttonColor: Color?
    private let errorColor: Color?
    private var favorite: Bool = false
    private var searchTerm: String = ""

    public init(api: YouTubeAPI,
                scrollPosition: Binding<ScrollPosition>,
                favorite: Bool,
                searchTerm: String,
                type: ViewType,
                buttonColor: Color? = nil,
                errorColor: Color? = nil) {
        _scrollPosition = scrollPosition
        self.favorite = searchTerm.isEmpty ? favorite : false
        self.searchTerm = favorite ? "" : searchTerm
        self.api = api
        self.buttonColor = buttonColor
        self.errorColor = errorColor
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
                           color: errorColor)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280),
                                             alignment: .top)],
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
                          color: buttonColor,
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
                          color: buttonColor,
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
    let scrollPosition = Binding(get: { ScrollPosition() }, set: { _ in })
    VStack {
        VideosView(api: api, scrollPosition: scrollPosition, type: .modern)
        VideosView(api: api, scrollPosition: scrollPosition, type: .classic, buttonColor: .red)
        Spacer()
    }
    .background(.brown)
}
