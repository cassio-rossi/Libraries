import Foundation
import NetworkLibrary

enum SearchingSortOrder: Sendable {
	case date
	case rating
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
