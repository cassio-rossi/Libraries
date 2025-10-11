import Foundation

public struct YouTube: Decodable, Sendable {
	public var kind: String?
	public var etag: String?
	public var nextPageToken: String?
	public var items: [Item]?
	public var pageInfo: PageInfo?
	public var regionCode: String?
}

public struct PageInfo: Decodable, Sendable {
	public var totalResults: Int?
	public var resultsPerPage: Int?
}

public struct Item: Decodable, Sendable {
	public var kind: String?
	public var etag: String?
	public var snippet: Snippet?
	public var statistics: Statistics?
	public var contentDetails: Details?

	public var id: String?
	public var resourceId: ResourceId?
	//	public var id: T?	// String for all and ResourceId for search

	enum CodingKeys: String, CodingKey {
		case kind, etag, snippet, statistics, contentDetails, id
	}

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

public struct Snippet: Decodable, Sendable {
	public var publishedAt: String?
	public var channelId: String?
	public var title: String?
	public var description: String?
	public var thumbnails: Thumbnails?
	public var channelTitle: String?
	public var playlistId: String?
	public var position: Int?
	public var resourceId: ResourceId?
	public var videoOwnerChannelTitle: String?
	public var videoOwnerChannelId: String?
	public var liveBroadcastContent: String?
}

public struct ResourceId: Decodable, Sendable {
	public var kind: String?
	public var videoId: String?
}

public struct Thumbnails: Decodable, Sendable {
	public var original: MediaInfo?
	public var medium: MediaInfo?
	public var high: MediaInfo?
	public var standard: MediaInfo?
	public var maxres: MediaInfo?

    private enum CodingKeys: String, CodingKey {
        case original = "default", medium, high, standard, maxres
    }
}

public struct MediaInfo: Decodable, Sendable {
	public var url: String?
	public var width: Int
	public var height: Int
}

public struct Statistics: Decodable, Sendable {
	public var viewCount: String?
	public var likeCount: String?
	public var dislikeCount: String?
	public var favoriteCount: String?
	public var commentCount: String?
}

public struct Details: Decodable, Sendable {
	public var duration: String?
	public var dimension: String?
	public var definition: String?
	public var caption: String?
	public var licensedContent: Bool?
	public var projection: String?
}
