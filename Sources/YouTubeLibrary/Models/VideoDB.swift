import Foundation
import SwiftData

/// Persistent model representing a YouTube video with playback state.
///
/// Stores video metadata, statistics, and user-specific data such as
/// playback position and favorite status.
@Model
public final class VideoDB {
	/// URL string for the video thumbnail image.
    public var artworkURL: String = ""
	/// Current playback position in seconds.
    public var current: Double = 0.0
	/// Video duration in formatted string (e.g., "04:13").
    public var duration: String = ""
	/// Whether the user has marked this video as a favorite.
    public var favorite: Bool = false
	/// Number of likes as a formatted string.
    public var likes: String = ""
	/// Publication date in ISO 8601 format.
    public var pubDate: String = ""
	/// Video title.
    public var title: String = ""
	/// YouTube video identifier.
    public var videoId: String = ""
	/// Number of views as a formatted string.
    public var views: String = ""

	/// Creates a new video database entry.
	///
	/// - Parameters:
	///   - artworkURL: URL string for the video thumbnail.
	///   - current: Current playback position in seconds.
	///   - duration: Video duration in ISO 8601 format.
	///   - favorite: Whether the video is marked as favorite.
	///   - likes: Number of likes as a formatted string.
	///   - pubDate: Publication date in ISO 8601 format.
	///   - title: Video title.
	///   - videoId: YouTube video identifier.
	///   - views: Number of views as a formatted string.
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
	/// Convenience property to convert the artwork URL string to a URL object.
    public var url: URL? { URL(string: artworkURL) }
}
