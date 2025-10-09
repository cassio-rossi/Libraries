import FirebaseAnalytics
import Foundation
import NetworkLibrary
import StorageLibrary
import SwiftData

enum APIError: Error, Sendable {
    case videoNotFound
}

@MainActor
public class YouTubeAPI: ObservableObject {
    @Published public var status: Status = .done
    @Published public var selectedVideo: VideoDB?
    @Published public var searchResult: [VideoDB] = []

	public enum Status: Equatable, Sendable {
		case loading
		case done
		case error(reason: String)

		var reason: String? {
			switch self {
			case .error(let reason):
				return reason
			default:
				return nil
			}
		}
	}

	let customHost: CustomHost?
	let credentials: YouTubeCredentials?
	let mock: [NetworkMockData]?
	let storage: Database
    let language: String

	private let threshold = 48
	private var lastIndex = 0
	var nextPageToken: String?

	public init(customHost: CustomHost? = nil,
				credentials: YouTubeCredentials? = nil,
				mock: [NetworkMockData]? = nil,
                containerIdentifier: String? = nil,
				inMemory: Bool = false,
                language: String = "") {
		self.customHost = customHost
		self.credentials = credentials
		self.mock = mock
        self.language = language
        self.storage = Database(models: [VideoDB.self], inMemory: inMemory)
	}

	public func getVideos() async throws {
		do {
			status = .loading
			selectedVideo = nil
			let (videos, statistics) = try await load()
			nextPageToken = videos.nextPageToken
			storage.save(playlist: videos, statistics: statistics)
			status = .done
		} catch {
			status = .error(reason: (error as? NetworkAPIError)?.description ?? error.localizedDescription)
		}
	}

	public func numberOfVideos() -> Int {
		storage.numberOfVideos()
	}

	func loadMoreIfNeeded(index: Int) {
		if lastIndex <= index,
		   index % threshold == 0 {
			lastIndex = index
            Task {
                try await getVideos()
            }
		}
	}
}

extension YouTubeAPI {
    func search(video: String) async throws {
        if video.isEmpty {
            searchResult = []
            status = .done

        } else {
            let results = await storage.search(text: video)
            if results.isEmpty {
                status = .loading
                try await searchVideos(text: video)
            } else {
                searchResult = results
                status = .done
            }
        }
    }

    func searchVideos(text: String) async throws {
        do {
            let (videos, statistics) = try await searchYT(text: text)
			searchResult = storage.convertSearch(playlist: videos, statistics: statistics)
			status = .done
        } catch NetworkAPIError.notFound {
            searchResult = []
            status = .done
        } catch {
            status = .error(reason: error.localizedDescription)
            throw error
        }
    }
}

extension YouTubeAPI {
    fileprivate func load() async throws -> (YouTube, YouTube) {
        do {
            let videos = try await loadVideos()

            guard let items = videos.items, !items.isEmpty else {
                throw NetworkAPIError.decoding
            }

            let videoIds: [String] = items.compactMap {
                return $0.snippet?.resourceId?.videoId
            }

            let statistics = try await loadStatistics(customHost: customHost, videos: videoIds)
            return (videos, statistics)

        } catch {
            throw error
        }
    }

    fileprivate func loadVideos() async throws -> YouTube {
        do {
            guard let credentials else {
                return try load(file: "video_example")
            }

            let endpoint = Endpoint.videos(customHost: customHost,
                                           credentials: credentials,
										   token: nextPageToken)
            return try await load(url: endpoint.url)
        } catch {
            throw error
        }
    }

    fileprivate func loadStatistics(customHost: CustomHost?, videos: [String]) async throws -> YouTube {
        do {
            guard let credentials else {
                return try load(file: "stats_example")
            }

            let endpoint = Endpoint.statistics(customHost: customHost,
                                               credentials: credentials,
											   videos: videos)
            return try await load(url: endpoint.url)
        } catch {
            throw error
        }
    }

    fileprivate func load(url: URL) async throws -> YouTube {
		Analytics.logEvent("YouTube", parameters: [
			"url": url.absoluteString.replacingOccurrences(of: url.query ?? "", with: "") as NSObject
		])
        do {
			let data = try await NetworkAPI(mock: mock).get(url: url)
            return try parse(data)

        } catch {
            throw error
        }
    }

    fileprivate func load(file: String) throws -> YouTube {
        do {
            guard let path = Bundle.module.path(forResource: file, ofType: "json"),
                  let content = FileManager.default.contents(atPath: path) else {
                throw NetworkAPIError.network
            }
            return try parse(content)

        } catch {
            throw error
        }
    }

    fileprivate func parse(_ data: Data) throws -> YouTube {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode(YouTube.self, from: data)

        } catch {
            throw error
        }
    }

    fileprivate func searchYT(text: String) async throws -> (YouTube, YouTube) {
        do {
            let videos = try await searchYTVideos(text: text)

            guard let items = videos.items else {
                throw NetworkAPIError.decoding
            }
            guard !items.isEmpty else {
                throw NetworkAPIError.notFound
            }

            let videoIds: [String] = items.compactMap {
                return $0.resourceId?.videoId
            }

            let statistics = try await loadStatistics(customHost: nil, videos: videoIds)
            return (videos, statistics)

        } catch {
            throw error
        }
    }

    fileprivate func searchYTVideos(text: String) async throws -> YouTube {
        do {
            guard let credentials else {
                return try load(file: "video_example")
            }

            let endpoint = Endpoint.search(credentials: credentials, text: text)
			// MockURLProtocol(bundle: .module).mock(api: endpoint.restAPI, file: mock?[endpoint.restAPI])
            return try await load(url: endpoint.url)
        } catch {
            throw error
        }
    }
}

extension YouTubeAPI {
	public func update(videoId: String, current: Double) async {
		self.storage.update(videoId: videoId, current: current)
	}
}

class YouTubeAPIPreview {
    static var preview: VideoDB {
        VideoDB(artworkURL: "https://i.ytimg.com/vi/bq02LMjcCns/maxresdefault.jpg",
                current: 0.0,
                duration: "PT4M46S".formattedYTDuration,
                favorite: false,
                likes: "782",
                pubDate: "2021-02-17T20:45:21Z",
                title: "Como Usar WhatsApp No iPad",
                videoId: "VVVBel9Fc3prM1lqcVZMdzZvWGJTS1FBLmJxMDJMTWpjQ25z",
                views: "5663")
    }
}
