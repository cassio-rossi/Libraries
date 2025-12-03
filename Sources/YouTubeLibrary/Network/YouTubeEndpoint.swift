import Foundation
import NetworkLibrary

/// Sort order options for YouTube search results.
enum SearchingSortOrder: Sendable {
	/// Sort by publication date (newest first).
	case date
	/// Sort by rating (highest rated first).
	case rating
	/// Sort by relevance to the search query.
	case relevance
}

enum Definitions {
	static let scheme = "https"
	static let host = "www.googleapis.com"
	static let path = "/youtube/v3"

	static let keyParam = "key"

	static let sort = ("order", "date")

	static let playlistItems = "/playlistItems"
	static let playlistPart = ("part", "snippet")

	static let playlistIdParam = "playlistId"

	static let maxResults = "maxResults"
	static let pageToken = "pageToken"

	static let statistics = "/videos"
	static let statisticsPart = ("part", "statistics,contentDetails")
	static let videoId = "id"

	static let videoSearch = "/search"
	static let videoSearchPart = ("part", "snippet")
	static let videoQuery = "q"
	static let videoSearchSortDate = ("order", "date")
	static let videoSearchSortRating = ("order", "rating")

	static let channel = "channelId"

	static let videoLike = "/videos/rate"
	static let rating = "rating"
}

extension Endpoint {
	/// Creates an endpoint for fetching videos from a YouTube playlist.
	///
	/// - Parameters:
	///   - customHost: Optional custom host configuration for testing.
	///   - credentials: YouTube API credentials.
	///   - token: Pagination token for retrieving subsequent pages.
	/// - Returns: Configured endpoint for the playlist items API.
	static func videos(customHost: CustomHost? = nil,
					   credentials: YouTubeCredentials,
					   token: String? = nil) -> Self {

		var query = [
			URLQueryItem(name: Definitions.playlistPart.0, value: Definitions.playlistPart.1),
			URLQueryItem(name: Definitions.playlistIdParam, value: credentials.playlist),
			URLQueryItem(name: Definitions.keyParam, value: credentials.key),
			URLQueryItem(name: Definitions.maxResults, value: "50"),
			URLQueryItem(name: Definitions.sort.0, value: Definitions.sort.1)
		]
		if let token = token,
		   !token.isEmpty {
			query.append(URLQueryItem(name: Definitions.pageToken, value: token))
		}
		return Endpoint(customHost: customHost ?? CustomHost(host: Definitions.host, path: Definitions.path),
						api: customHost?.api ?? Definitions.playlistItems,
						queryItems: customHost?.queryItems ?? query)
	}

	/// Creates an endpoint for fetching video statistics for specific videos.
	///
	/// - Parameters:
	///   - customHost: Optional custom host configuration for testing.
	///   - credentials: YouTube API credentials.
	///   - videos: Array of video IDs to fetch statistics for.
	///   - token: Pagination token for retrieving subsequent pages.
	/// - Returns: Configured endpoint for the videos API.
	static func statistics(customHost: CustomHost? = nil,
						   credentials: YouTubeCredentials,
						   videos: [String],
						   token: String? = nil) -> Self {

		var query = [
			URLQueryItem(name: Definitions.statisticsPart.0, value: Definitions.statisticsPart.1),
			URLQueryItem(name: Definitions.keyParam, value: credentials.key),
			URLQueryItem(name: Definitions.videoId, value: videos.joined(separator: ","))
		]
		if let token = token,
		   !token.isEmpty {
			query.append(URLQueryItem(name: Definitions.pageToken, value: token))
		}
		return Endpoint(customHost: customHost ?? CustomHost(host: Definitions.host, path: Definitions.path),
						api: customHost?.api ?? Definitions.statistics,
						queryItems: customHost?.queryItems ?? query)
	}

	/// Creates an endpoint for fetching video statistics without specific video IDs.
	///
	/// - Parameters:
	///   - customHost: Optional custom host configuration for testing.
	///   - credentials: YouTube API credentials.
	///   - token: Pagination token for retrieving subsequent pages.
	/// - Returns: Configured endpoint for the videos API.
	static func statistics(customHost: CustomHost? = nil,
						   credentials: YouTubeCredentials,
						   token: String? = nil) -> Self {

		var query = [
			URLQueryItem(name: Definitions.statisticsPart.0, value: Definitions.statisticsPart.1),
			URLQueryItem(name: Definitions.keyParam, value: credentials.key)
		]
		if let token = token,
		   !token.isEmpty {
			query.append(URLQueryItem(name: Definitions.pageToken, value: token))
		}
		return Endpoint(customHost: customHost ?? CustomHost(host: Definitions.host, path: Definitions.path),
						api: customHost?.api ?? Definitions.statistics,
						queryItems: customHost?.queryItems ?? query)
	}

	/// Creates an endpoint for searching videos on YouTube.
	///
	/// - Parameters:
	///   - customHost: Optional custom host configuration for testing.
	///   - credentials: YouTube API credentials.
	///   - text: Search query text.
	///   - sortBy: Sort order for search results (default: .date).
	/// - Returns: Configured endpoint for the search API.
	static func search(customHost: CustomHost? = nil,
					   credentials: YouTubeCredentials,
					   text: String,
					   sortBy: SearchingSortOrder = .date) -> Self {
		var query = [
			URLQueryItem(name: Definitions.videoSearchPart.0, value: Definitions.videoSearchPart.1),
			URLQueryItem(name: Definitions.keyParam, value: credentials.key),
			URLQueryItem(name: Definitions.channel, value: credentials.channel),
			URLQueryItem(name: Definitions.maxResults, value: "16"),
			URLQueryItem(name: Definitions.videoQuery, value: text)
		]
		switch sortBy {
		case .date:
			query.append(URLQueryItem(name: Definitions.videoSearchSortDate.0, value: Definitions.videoSearchSortDate.1))
		case .rating:
			query.append(URLQueryItem(name: Definitions.videoSearchSortRating.0, value: Definitions.videoSearchSortRating.1))
		default:
			break
		}

		return Endpoint(customHost: customHost ?? CustomHost(host: Definitions.host, path: Definitions.path),
						api: customHost?.api ?? Definitions.videoSearch,
						queryItems: customHost?.queryItems ?? query)
	}

	/// Creates an endpoint for liking a YouTube video.
	///
	/// - Parameters:
	///   - customHost: Optional custom host configuration for testing.
	///   - credentials: YouTube API credentials.
	///   - video: Video ID to like.
	/// - Returns: Configured endpoint for the video rating API.
	static func like(customHost: CustomHost? = nil,
					 credentials: YouTubeCredentials,
					 video: String) -> Self {

		let query = [
			URLQueryItem(name: Definitions.keyParam, value: credentials.key),
			URLQueryItem(name: Definitions.rating, value: "like"),
			URLQueryItem(name: Definitions.videoId, value: video)
		]
		return Endpoint(customHost: customHost ?? CustomHost(host: Definitions.host, path: Definitions.path),
						api: customHost?.api ?? Definitions.videoLike,
						queryItems: customHost?.queryItems ?? query)
	}
}
