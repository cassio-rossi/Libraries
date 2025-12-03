import Foundation

/// Root response structure from YouTube Data API v3.
///
/// Contains metadata, pagination tokens, and an array of video or playlist items.
public struct YouTube: Decodable, Sendable {
	/// Resource type identifier (e.g., "youtube#playlistItemListResponse").
	public var kind: String?
	/// ETag for cache validation.
	public var etag: String?
	/// Token for retrieving the next page of results.
	public var nextPageToken: String?
	/// Array of video or playlist items.
	public var items: [Item]?
	/// Pagination information about the result set.
	public var pageInfo: PageInfo?
	/// Region code for localized results.
	public var regionCode: String?
}

/// Information about pagination in the API response.
public struct PageInfo: Decodable, Sendable {
	/// The total number of results available.
	public var totalResults: Int?
	/// The number of results included in this response.
	public var resultsPerPage: Int?
}

/// Represents a single video or playlist item from the YouTube API.
///
/// Handles both video list responses (where id is a String) and search responses
/// (where id is a ResourceId object).
public struct Item: Decodable, Sendable {
	/// Resource type identifier.
	public var kind: String?
	/// ETag for cache validation.
	public var etag: String?
	/// Basic metadata about the video.
	public var snippet: Snippet?
	/// View counts, likes, and other statistics.
	public var statistics: Statistics?
	/// Duration, definition, and other content details.
	public var contentDetails: Details?

	/// Video identifier (used in video list responses).
	public var id: String?
	/// Video resource identifier (used in search responses).
	public var resourceId: ResourceId?

	enum CodingKeys: String, CodingKey {
		case kind, etag, snippet, statistics, contentDetails, id
	}

	/// Custom decoder to handle polymorphic id field.
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		kind = try? container.decode(String.self, forKey: .kind)
		etag = try? container.decode(String.self, forKey: .etag)
		snippet = try? container.decode(Snippet.self, forKey: .snippet)
		statistics = try? container.decode(Statistics.self, forKey: .statistics)
		contentDetails = try? container.decode(Details.self, forKey: .contentDetails)

		id = try? container.decode(String.self, forKey: .id)
		resourceId = try? container.decode(ResourceId.self, forKey: .id)
	}
}

/// Basic metadata about a video including title, description, and thumbnails.
public struct Snippet: Decodable, Sendable {
	/// ISO 8601 formatted publication date and time.
	public var publishedAt: String?
	/// Unique identifier for the channel.
	public var channelId: String?
	/// Video title.
	public var title: String?
	/// Video description text.
	public var description: String?
	/// Available thumbnail images at different resolutions.
	public var thumbnails: Thumbnails?
	/// Name of the channel.
	public var channelTitle: String?
	/// Playlist identifier if this is a playlist item.
	public var playlistId: String?
	/// Position in the playlist.
	public var position: Int?
	/// Resource identifier for the video.
	public var resourceId: ResourceId?
	/// Title of the video owner's channel.
	public var videoOwnerChannelTitle: String?
	/// Identifier of the video owner's channel.
	public var videoOwnerChannelId: String?
	/// Indicates if the video is a live broadcast.
	public var liveBroadcastContent: String?
}

/// Identifies a YouTube resource (video, channel, or playlist).
public struct ResourceId: Decodable, Sendable {
	/// Resource type identifier.
	public var kind: String?
	/// YouTube video identifier.
	public var videoId: String?
}

/// Collection of thumbnail images at various resolutions.
public struct Thumbnails: Decodable, Sendable {
	/// Default resolution thumbnail (120x90).
	public var original: MediaInfo?
	/// Medium resolution thumbnail (320x180).
	public var medium: MediaInfo?
	/// High resolution thumbnail (480x360).
	public var high: MediaInfo?
	/// Standard resolution thumbnail (640x480).
	public var standard: MediaInfo?
	/// Maximum resolution thumbnail (1280x720).
	public var maxres: MediaInfo?

    private enum CodingKeys: String, CodingKey {
        case original = "default", medium, high, standard, maxres
    }
}

/// Information about a thumbnail image.
public struct MediaInfo: Decodable, Sendable {
	/// URL to the image resource.
	public var url: String?
	/// Image width in pixels.
	public var width: Int
	/// Image height in pixels.
	public var height: Int
}

/// Engagement statistics for a video.
public struct Statistics: Decodable, Sendable {
	/// Total number of views as a string.
	public var viewCount: String?
	/// Total number of likes as a string.
	public var likeCount: String?
	/// Total number of dislikes as a string (deprecated by YouTube).
	public var dislikeCount: String?
	/// Number of users who marked this as a favorite.
	public var favoriteCount: String?
	/// Total number of comments.
	public var commentCount: String?
}

/// Technical details about video content.
public struct Details: Decodable, Sendable {
	/// Video duration in ISO 8601 format (e.g., "PT4M13S").
	public var duration: String?
	/// Video dimension (2d or 3d).
	public var dimension: String?
	/// Video definition quality (hd or sd).
	public var definition: String?
	/// Indicates whether captions are available.
	public var caption: String?
	/// Whether the video represents licensed content.
	public var licensedContent: Bool?
	/// Video projection type (rectangular or 360).
	public var projection: String?
}
