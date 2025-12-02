import SwiftUI

/// Displays a grid of YouTube videos with search and filter capabilities.
///
/// Provides video playback integration and supports filtering by favorites
/// or search terms.
public struct Videos: View {
    @ObservedObject private var api: YouTubeAPI
    @Binding private var scrollPosition: ScrollPosition

    private var favorite: Bool = false
    private var search: String = ""
    private let style: any VideoStyle

    /// Creates a new videos view.
	///
	/// - Parameters:
    ///   - style: Optional style view.
	///   - api: YouTube API instance managing data and state.
    ///   - scrollPosition: Allow tap to top.
	///   - favorite: Whether to filter for favorite videos only.
	///   - search: Search term to filter videos.
    public init(
        style: any VideoStyle = ModernStyle(),
        api: YouTubeAPI,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool = false,
        search: String = ""
    ) {
        self.style = style
        self.api = api
        self.favorite = favorite
        self.search = search
        _scrollPosition = scrollPosition
    }

    public var body: some View {
        VideosView(
            style: style,
            api: api,
            scrollPosition: $scrollPosition,
            favorite: favorite,
            searchTerm: search
        )
        .modelContainer(api.storage.sharedModelContainer)
    }
}

#Preview {
    let api = YouTubeAPI()
    let scrollPosition = Binding(get: { ScrollPosition() }, set: { _ in })
    VStack {
        Videos(api: api, scrollPosition: scrollPosition)
        Videos(
            style: ClassicStyle(buttonColor: .red),
            api: api,
            scrollPosition: scrollPosition
        )
        Spacer()
    }
    .background(.brown)
}
