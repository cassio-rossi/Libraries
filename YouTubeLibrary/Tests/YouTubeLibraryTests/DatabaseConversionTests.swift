import XCTest
import StorageLibrary
@testable import YouTubeLibrary

@MainActor
final class DatabaseConversionTests: XCTestCase {

    var database: Database!

    override func setUp() async throws {
        // Use in-memory database for testing
        database = Database(models: [VideoDB.self], inMemory: true)
    }

    // MARK: - Video Conversion Tests

    func testConvertPlaylistItemToVideo() throws {
        // Given: Real playlist and statistics responses
        let playlistJSON = try loadJSON(file: "video_example")
        let statsJSON = try loadJSON(file: "stats_example")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let playlist = try decoder.decode(YouTube.self, from: playlistJSON)
        let statistics = try decoder.decode(YouTube.self, from: statsJSON)

        // When: We convert playlist items to videos
        let videos = database.convert(playlist: playlist, statistics: statistics, search: false)

        // Then: Video is correctly converted
        XCTAssertEqual(videos.count, 1)
        let video = try XCTUnwrap(videos.first)

        XCTAssertEqual(video.videoId, "bq02LMjcCns")
        XCTAssertEqual(video.title, "Como Usar WhatsApp No iPad")
        XCTAssertEqual(video.pubDate, "2021-02-17T20:45:21Z")
        XCTAssertEqual(video.artworkURL, "https://i.ytimg.com/vi/bq02LMjcCns/maxresdefault.jpg")

        // And: Statistics are merged correctly
        XCTAssertEqual(video.views, "5663")
        XCTAssertEqual(video.likes, "782")
        XCTAssertEqual(video.duration, "04:46") // Formatted from PT4M46S
    }

    func testConvertWithHTMLDecodedTitle() throws {
        // Given: Item with HTML encoded title
        let jsonWithHTML = """
        {
            "items": [{
                "snippet": {
                    "title": "Test &amp; Video &#8211; Special",
                    "publishedAt": "2021-02-17T20:45:21Z",
                    "resourceId": {
                        "videoId": "test123"
                    },
                    "thumbnails": {
                        "maxres": {
                            "url": "https://example.com/image.jpg",
                            "width": 1280,
                            "height": 720
                        }
                    }
                }
            }]
        }
        """.data(using: .utf8)!

        let statsJSON = """
        {
            "items": [{
                "id": "test123",
                "statistics": {
                    "viewCount": "100",
                    "likeCount": "10"
                },
                "contentDetails": {
                    "duration": "PT1M30S"
                }
            }]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let playlist = try decoder.decode(YouTube.self, from: jsonWithHTML)
        let statistics = try decoder.decode(YouTube.self, from: statsJSON)

        // When: We convert the video
        let videos = database.convert(playlist: playlist, statistics: statistics, search: false)

        // Then: Title is HTML decoded
        let video = try XCTUnwrap(videos.first)
        XCTAssertEqual(video.title, "Test & Video – Special")
    }

    func testConvertUsesHighThumbnailWhenMaxresUnavailable() throws {
        // Given: Item with only high thumbnail (no maxres)
        let jsonWithoutMaxres = """
        {
            "items": [{
                "snippet": {
                    "title": "Test Video",
                    "publishedAt": "2021-02-17T20:45:21Z",
                    "resourceId": {
                        "videoId": "test123"
                    },
                    "thumbnails": {
                        "high": {
                            "url": "https://example.com/high.jpg",
                            "width": 480,
                            "height": 360
                        }
                    }
                }
            }]
        }
        """.data(using: .utf8)!

        let statsJSON = """
        {
            "items": [{
                "id": "test123",
                "statistics": { "viewCount": "100", "likeCount": "10" },
                "contentDetails": { "duration": "PT1M" }
            }]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let playlist = try decoder.decode(YouTube.self, from: jsonWithoutMaxres)
        let statistics = try decoder.decode(YouTube.self, from: statsJSON)

        // When: We convert the video
        let videos = database.convert(playlist: playlist, statistics: statistics, search: false)

        // Then: Falls back to high thumbnail
        let video = try XCTUnwrap(videos.first)
        XCTAssertEqual(video.artworkURL, "https://example.com/high.jpg")
    }

    func testConvertFiltersOutItemsWithoutVideoId() throws {
        // Given: Playlist with item missing videoId
        let jsonMissingVideoId = """
        {
            "items": [
                {
                    "snippet": {
                        "title": "Valid Video",
                        "publishedAt": "2021-02-17T20:45:21Z",
                        "resourceId": {
                            "videoId": "valid123"
                        },
                        "thumbnails": {
                            "high": { "url": "https://example.com/1.jpg", "width": 480, "height": 360 }
                        }
                    }
                },
                {
                    "snippet": {
                        "title": "Invalid Video - No VideoId",
                        "publishedAt": "2021-02-17T20:45:21Z",
                        "thumbnails": {
                            "high": { "url": "https://example.com/2.jpg", "width": 480, "height": 360 }
                        }
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        let statsJSON = """
        {
            "items": [{
                "id": "valid123",
                "statistics": { "viewCount": "100", "likeCount": "10" },
                "contentDetails": { "duration": "PT1M" }
            }]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let playlist = try decoder.decode(YouTube.self, from: jsonMissingVideoId)
        let statistics = try decoder.decode(YouTube.self, from: statsJSON)

        // When: We convert
        let videos = database.convert(playlist: playlist, statistics: statistics, search: false)

        // Then: Only valid video is returned
        XCTAssertEqual(videos.count, 1)
        XCTAssertEqual(videos.first?.videoId, "valid123")
    }

    // MARK: - Database Save Tests

    func testSaveCreatesNewVideos() async throws {
        // Given: Video data
        let videos = [
            Video(title: "Test Video 1",
                  videoId: "video1",
                  pubDate: "2021-02-17T20:45:21Z",
                  artworkURL: "https://example.com/1.jpg",
                  views: "1000",
                  likes: "100",
                  duration: "PT5M")
        ]

        // When: We save videos
        database.save(videos)

        // Then: Video is persisted
        let count = database.numberOfVideos()
        XCTAssertEqual(count, 1)

        // And: Video properties are correctly stored
        let predicate = #Predicate<VideoDB> { $0.videoId == "video1" }
        let saved = database.fetch(VideoDB.self, predicate: predicate)
        XCTAssertEqual(saved.count, 1)

        let video = try XCTUnwrap(saved.first)
        XCTAssertEqual(video.title, "Test Video 1")
        XCTAssertEqual(video.videoId, "video1")
        XCTAssertEqual(video.views, "1000")
        XCTAssertEqual(video.likes, "100")
        XCTAssertEqual(video.duration, "05:00") // Formatted from PT5M
        XCTAssertEqual(video.favorite, false)
        XCTAssertEqual(video.current, 0.0)
    }

    func testSaveUpdatesExistingVideos() async throws {
        // Given: Existing video in database
        let existing = VideoDB(artworkURL: "https://example.com/old.jpg",
                              current: 42.0,
                              duration: "05:00",
                              favorite: true,
                              likes: "100",
                              pubDate: "2021-01-01T00:00:00Z",
                              title: "Old Title",
                              videoId: "video1",
                              views: "500")
        database.context.insert(existing)
        try database.context.save()

        // When: We save updated video data
        let updated = [
            Video(title: "New Title",
                  videoId: "video1",
                  pubDate: "2021-02-17T20:45:21Z",
                  artworkURL: "https://example.com/new.jpg",
                  views: "1000",
                  likes: "200",
                  duration: "PT6M")
        ]
        database.save(updated)

        // Then: Video is updated, not duplicated
        XCTAssertEqual(database.numberOfVideos(), 1)

        // And: Properties are updated
        let predicate = #Predicate<VideoDB> { $0.videoId == "video1" }
        let saved = database.fetch(VideoDB.self, predicate: predicate)
        let video = try XCTUnwrap(saved.first)

        XCTAssertEqual(video.title, "New Title")
        XCTAssertEqual(video.views, "1000")
        XCTAssertEqual(video.likes, "200")
        XCTAssertEqual(video.duration, "06:00")

        // But: User-specific data is preserved
        XCTAssertEqual(video.favorite, true)
        XCTAssertEqual(video.current, 42.0)
    }

    func testSaveFiltersOutZeroDurationVideos() async throws {
        // Given: Mix of valid and zero-duration videos
        let videos = [
            Video(title: "Valid Video",
                  videoId: "valid1",
                  pubDate: "2021-02-17T20:45:21Z",
                  artworkURL: "https://example.com/1.jpg",
                  views: "1000",
                  likes: "100",
                  duration: "PT5M"),
            Video(title: "Zero Duration Video",
                  videoId: "invalid1",
                  pubDate: "2021-02-17T20:45:21Z",
                  artworkURL: "https://example.com/2.jpg",
                  views: "500",
                  likes: "50",
                  duration: "00") // This should be filtered
        ]

        // When: We save videos
        database.save(videos)

        // Then: Only valid video is saved
        XCTAssertEqual(database.numberOfVideos(), 1)

        let saved = database.fetch(VideoDB.self, predicate: nil)
        XCTAssertEqual(saved.first?.videoId, "valid1")
    }

    // MARK: - Search Conversion Tests

    func testConvertSearchResults() throws {
        // Given: Search results (different structure than playlist)
        let searchJSON = """
        {
            "items": [{
                "id": {
                    "videoId": "search123"
                },
                "snippet": {
                    "title": "Search Result Video",
                    "publishedAt": "2021-02-17T20:45:21Z",
                    "thumbnails": {
                        "high": {
                            "url": "https://example.com/search.jpg",
                            "width": 480,
                            "height": 360
                        }
                    }
                }
            }]
        }
        """.data(using: .utf8)!

        let statsJSON = """
        {
            "items": [{
                "id": "search123",
                "statistics": { "viewCount": "5000", "likeCount": "500" },
                "contentDetails": { "duration": "PT10M" }
            }]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let searchResults = try decoder.decode(YouTube.self, from: searchJSON)
        let statistics = try decoder.decode(YouTube.self, from: statsJSON)

        // When: We convert search results
        let videos = database.convertSearch(playlist: searchResults, statistics: statistics)

        // Then: Videos are converted correctly
        XCTAssertEqual(videos.count, 1)
        let video = try XCTUnwrap(videos.first)

        XCTAssertEqual(video.videoId, "search123")
        XCTAssertEqual(video.title, "Search Result Video")
        XCTAssertEqual(video.views, "5000")
        XCTAssertEqual(video.duration, "10:00")
        XCTAssertEqual(video.favorite, false)
        XCTAssertEqual(video.current, 0.0)
    }

    // MARK: - Update Tests

    func testUpdateVideoPlaybackPosition() async throws {
        // Given: Existing video in database
        let video = VideoDB(artworkURL: "https://example.com/1.jpg",
                           current: 0.0,
                           duration: "10:00",
                           favorite: false,
                           likes: "100",
                           pubDate: "2021-02-17T20:45:21Z",
                           title: "Test Video",
                           videoId: "video1",
                           views: "1000")
        database.context.insert(video)
        try database.context.save()

        // When: We update playback position
        database.update(videoId: "video1", current: 123.45)

        // Then: Current position is updated
        let predicate = #Predicate<VideoDB> { $0.videoId == "video1" }
        let updated = database.fetch(VideoDB.self, predicate: predicate)
        let updatedVideo = try XCTUnwrap(updated.first)

        XCTAssertEqual(updatedVideo.current, 123.45)

        // And: Other properties remain unchanged
        XCTAssertEqual(updatedVideo.title, "Test Video")
        XCTAssertEqual(updatedVideo.views, "1000")
    }

    func testUpdateNonExistentVideoDoesNotCrash() {
        // When: We try to update a video that doesn't exist
        // Then: Should not crash
        XCTAssertNoThrow(database.update(videoId: "nonexistent", current: 50.0))
    }

    // MARK: - Search Tests

    func testSearchVideos() async throws {
        // Given: Multiple videos in database
        let videos = [
            VideoDB(artworkURL: "", current: 0, duration: "05:00", favorite: false,
                   likes: "100", pubDate: "2021-02-17T20:45:21Z",
                   title: "Swift Programming Tutorial", videoId: "swift1", views: "1000"),
            VideoDB(artworkURL: "", current: 0, duration: "10:00", favorite: false,
                   likes: "200", pubDate: "2021-02-18T20:45:21Z",
                   title: "Kotlin Development Guide", videoId: "kotlin1", views: "2000"),
            VideoDB(artworkURL: "", current: 0, duration: "15:00", favorite: false,
                   likes: "300", pubDate: "2021-02-19T20:45:21Z",
                   title: "Advanced Swift Techniques", videoId: "swift2", views: "3000")
        ]

        videos.forEach { database.context.insert($0) }
        try database.context.save()

        // When: We search for "Swift"
        let results = await database.search(text: "Swift")

        // Then: Only Swift videos are returned
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.title.contains("Swift") })

        // And: Results are sorted by date (newest first)
        XCTAssertEqual(results.first?.videoId, "swift2")
        XCTAssertEqual(results.last?.videoId, "swift1")
    }

    // MARK: - Helper Methods

    private func loadJSON(file: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: file, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load \(file).json from bundle")
            throw NSError(domain: "TestError", code: 1)
        }
        return data
    }
}
