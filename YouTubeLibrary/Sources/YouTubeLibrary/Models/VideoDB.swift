import Foundation
import SwiftData

@Model
public final class VideoDB {
    public var artworkURL: String = ""
    public var current: Double = 0.0
    public var duration: String = ""
    public var favorite: Bool = false
    public var likes: String = ""
    public var pubDate: String = ""
    public var title: String = ""
    public var videoId: String = ""
    public var views: String = ""

    public init(artworkURL: String,
                current: Double,
                duration: String,
                favorite: Bool,
                likes: String,
                pubDate: String,
                title: String,
                videoId: String,
                views: String) {
        self.artworkURL = artworkURL
        self.current = current
        self.duration = duration
        self.favorite = favorite
        self.likes = likes
        self.pubDate = pubDate
        self.title = title
        self.videoId = videoId
        self.views = views
    }
}

extension VideoDB {
    var url: URL? { URL(string: artworkURL) }
}
