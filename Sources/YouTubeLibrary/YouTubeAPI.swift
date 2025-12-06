import FirebaseAnalytics
import Foundation
import NetworkLibrary
import StorageLibrary
import SwiftData

/// Errors that can occur during API operations.
enum APIError: Error, Sendable {
	/// The requested video could not be found.
    case videoNotFound
}

/// Main interface for interacting with the YouTube Data API v3.
///
/// `YouTubeAPI` provides functionality for fetching, searching, and managing YouTube videos
/// from a specified playlist. It handles API requests, local storage via SwiftData,
/// and state management for UI integration.
@MainActor
public class YouTubeAPI: ObservableObject {
	/// The current status of API operations.
    @Published public var status: Status = .idle
	/// The currently selected video for playback.
    @Published public var selectedVideo: VideoDB?
	/// Results from the most recent search operation.
    @Published public var searchResult: [VideoDB] = []

	/// Represents the current state of API operations.
	public enum Status: Equatable, Sendable {
        /// Initial state.
        case idle
		/// The API is currently loading data.
		case loading
		/// The API operation has completed successfully.
		case done
		/// The API operation failed with an error.
		/// - Parameter reason: A description of the error that occurred.
		case error(reason: String)

		/// Returns the error reason if the status is an error, otherwise nil.
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

	/// Creates a new YouTube API client.
	///
	/// - Parameters:
	///   - customHost: Custom endpoint configuration for testing or alternative hosts.
	///   - credentials: YouTube API credentials including API key and playlist ID.
	///   - mock: Mock network data for testing purposes.
	///   - containerIdentifier: SwiftData container identifier.
	///   - inMemory: Whether to use in-memory storage instead of persistent storage.
	///   - language: Language code for localized content.
	public init(customHost: CustomHost? = nil,
				credentials: YouTubeCredentials? = nil,
				mock: [NetworkMockData]? = nil,
                storage: Database? = nil,
                containerIdentifier: String? = nil,
				inMemory: Bool = false,
                language: String = "") {
		self.customHost = customHost
		self.credentials = credentials
		self.mock = mock
        self.language = language
        self.storage = storage ?? Database(models: [VideoDB.self], inMemory: inMemory)
	}

	/// Fetches videos from the configured YouTube playlist.
	///
	/// Loads video metadata and statistics, saving them to local storage.
	/// Updates `status` to reflect the current operation state.
	///
	/// - Parameters:
	///   - isRefreshing: Whether this is a pull-to-refresh operation. If true, status won't be set to loading.
	/// - Throws: Network or parsing errors during the fetch operation.
	public func getVideos(status: Status? = nil) async throws {
		do {
			if let status {
                self.status = status
			}
			let (videos, statistics) = try await load()
			storage.save(playlist: videos, statistics: statistics)
            selectedVideo = nil
            nextPageToken = videos.nextPageToken
            self.status = .done
		} catch {
            self.status = .error(reason: (error as? NetworkAPIError)?.description ?? error.localizedDescription)
		}
	}

	/// Returns the total number of videos stored locally.
	///
	/// - Returns: Count of videos in the local database.
	public func numberOfVideos() -> Int {
		storage.numberOfVideos()
	}

	/// Loads more videos if the user has scrolled to a pagination threshold.
	///
	/// - Parameter index: The current index in the video list.
	func loadMoreIfNeeded(index: Int) {
        if index > 0,
           lastIndex <= index,
           index % threshold == 0 {
            lastIndex = index
            Task {
                try await getVideos()
            }
        }
	}
}

extension YouTubeAPI {
	/// Searches for videos by text query.
	///
	/// First checks local storage for cached results, then queries the YouTube API if needed.
	///
	/// - Parameter video: The search query text.
	/// - Throws: Network or parsing errors during search.
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

	/// Performs a YouTube API search and stores results.
	///
	/// - Parameter text: The search query text.
	/// - Throws: Network or parsing errors during search.
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
            let service = NetworkFactory.make(
                host: customHost,
                mapper: mock
            )
            let data = try await service.get(url: url, headers: nil)
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
	/// Updates the playback position for a specific video.
	///
	/// - Parameters:
	///   - videoId: The YouTube video identifier.
	///   - current: The current playback time in seconds.
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
