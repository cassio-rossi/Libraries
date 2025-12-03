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
    private let card: any VideoCard

    /// Creates a new videos view.
	///
	/// - Parameters:
    ///   - card: Optional custom card view conforming to VideoCard protocol. Default to ModernCard
	///   - api: YouTube API instance managing data and state.
    ///   - scrollPosition: Allow tap to top.
	///   - favorite: Whether to filter for favorite videos only.
	///   - search: Search term to filter videos.
    public init(
        card: any VideoCard = ModernCard(),
        api: YouTubeAPI,
        scrollPosition: Binding<ScrollPosition>,
        favorite: Bool = false,
        search: String = ""
    ) {
        self.card = card
        self.api = api
        self.favorite = favorite
        self.search = search
        _scrollPosition = scrollPosition
    }

    public var body: some View {
        VideosView(
            card: card,
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
            card: ClassicCard(buttonColor: .red),
            api: api,
            scrollPosition: scrollPosition
        )
        Spacer()
    }
    .background(.brown)
}
