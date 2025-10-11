import XCTest
@testable import YouTubeLibrary

// swiftlint:disable force_unwrapping
final class YouTubeModelTests: XCTestCase {

    // MARK: - Playlist Video Decoding Tests

    func testDecodePlaylistVideoResponse() throws {
        // Given: Real YouTube API playlist response JSON
        let json = try loadJSON(file: "video_example")

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Top-level properties are correct
        XCTAssertEqual(response.kind, "youtube#playlistItemListResponse")
        XCTAssertEqual(response.etag, "SK2IsKJOtDohwem_6l318ztECPA")
        XCTAssertEqual(response.nextPageToken, "CAEQAA")
        XCTAssertNotNil(response.items)
        XCTAssertFalse(response.items!.isEmpty)
    }

    func testDecodePlaylistVideoItem() throws {
        // Given: Real YouTube API playlist response
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the first video item
        let firstItem = try XCTUnwrap(response.items?.first)

        // Then: Video metadata is correctly decoded
        XCTAssertEqual(firstItem.kind, "youtube#playlistItem")
        XCTAssertEqual(firstItem.id, "VVVBel9Fc3prM1lqcVZMdzZvWGJTS1FBLmJxMDJMTWpjQ25z")

        // And: Snippet data is correct
        let snippet = try XCTUnwrap(firstItem.snippet)
        XCTAssertEqual(snippet.publishedAt, "2021-02-17T20:45:21Z")
        XCTAssertEqual(snippet.channelId, "UCAz_Eszk3YjqVLw6oXbSKQA")
        XCTAssertEqual(snippet.title, "Como Usar WhatsApp No iPad")
        XCTAssertEqual(snippet.playlistId, "UUAz_Eszk3YjqVLw6oXbSKQA")

        // And: ResourceId is correct
        let resourceId = try XCTUnwrap(snippet.resourceId)
        XCTAssertEqual(resourceId.kind, "youtube#video")
        XCTAssertEqual(resourceId.videoId, "bq02LMjcCns")
    }

    func testDecodeThumbnails() throws {
        // Given: Real YouTube API playlist response
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access thumbnails
        let thumbnails = try XCTUnwrap(response.items?.first?.snippet?.thumbnails)

        // Then: All thumbnail sizes are available
        XCTAssertNotNil(thumbnails.original)
        XCTAssertNotNil(thumbnails.medium)
        XCTAssertNotNil(thumbnails.high)
        XCTAssertNotNil(thumbnails.standard)
        XCTAssertNotNil(thumbnails.maxres)

        // And: Maxres thumbnail has correct properties
        let maxres = try XCTUnwrap(thumbnails.maxres)
        XCTAssertEqual(maxres.url, "https://i.ytimg.com/vi/bq02LMjcCns/maxresdefault.jpg")
        XCTAssertEqual(maxres.width, 1280)
        XCTAssertEqual(maxres.height, 720)

        // And: Default thumbnail is mapped correctly (CodingKey: "default" -> "original")
        let original = try XCTUnwrap(thumbnails.original)
        XCTAssertEqual(original.url, "https://i.ytimg.com/vi/bq02LMjcCns/default.jpg")
    }

    // MARK: - Statistics Decoding Tests

    func testDecodeStatisticsResponse() throws {
        // Given: Real YouTube API statistics response JSON
        let json = try loadJSON(file: "stats_example")

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Top-level properties are correct
        XCTAssertEqual(response.kind, "youtube#videoListResponse")
        XCTAssertNotNil(response.items)
        XCTAssertFalse(response.items!.isEmpty)
    }

    func testDecodeVideoStatistics() throws {
        // Given: Real YouTube API statistics response
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the first video's statistics
        let firstItem = try XCTUnwrap(response.items?.first)
        let statistics = try XCTUnwrap(firstItem.statistics)

        // Then: All statistics are correctly decoded
        XCTAssertEqual(statistics.viewCount, "5663")
        XCTAssertEqual(statistics.likeCount, "782")
        XCTAssertEqual(statistics.dislikeCount, "10")
        XCTAssertEqual(statistics.favoriteCount, "0")
        XCTAssertEqual(statistics.commentCount, "73")
    }

    func testDecodeContentDetails() throws {
        // Given: Real YouTube API statistics response
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access content details
        let contentDetails = try XCTUnwrap(response.items?.first?.contentDetails)

        // Then: Duration and other details are correct
        XCTAssertEqual(contentDetails.duration, "PT4M46S")
        XCTAssertEqual(contentDetails.dimension, "2d")
        XCTAssertEqual(contentDetails.definition, "hd")
        XCTAssertEqual(contentDetails.caption, "false")
        XCTAssertEqual(contentDetails.licensedContent, true)
        XCTAssertEqual(contentDetails.projection, "rectangular")
    }

    // MARK: - Dual ID Decoding Test (String and ResourceId)

    func testItemIDDecodesAsString() throws {
        // Given: Statistics response where ID is a string
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the ID
        let firstItem = try XCTUnwrap(response.items?.first)

        // Then: ID is decoded as String (not ResourceId)
        XCTAssertEqual(firstItem.id, "bq02LMjcCns")
        XCTAssertNil(firstItem.resourceId)
    }

    func testItemIDDecodesAsResourceId() throws {
        // Given: Playlist response where ID contains ResourceId in snippet
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the snippet's resource ID
        let firstItem = try XCTUnwrap(response.items?.first)
        let snippet = try XCTUnwrap(firstItem.snippet)
        let resourceId = try XCTUnwrap(snippet.resourceId)

        // Then: ResourceId contains the video ID
        XCTAssertEqual(resourceId.videoId, "bq02LMjcCns")
        XCTAssertEqual(firstItem.id, "VVVBel9Fc3prM1lqcVZMdzZvWGJTS1FBLmJxMDJMTWpjQ25z")
    }

    // MARK: - Page Info Tests

    func testDecodePageInfo() throws {
        // Given: Statistics response with page info
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access page info
        let pageInfo = try XCTUnwrap(response.pageInfo)

        // Then: Page info is correct
        XCTAssertEqual(pageInfo.totalResults, 1)
        XCTAssertEqual(pageInfo.resultsPerPage, 1)
    }

    // MARK: - Snake Case Conversion Tests

    func testSnakeCaseConversion() throws {
        // Given: JSON with snake_case keys
        let content = """
        {
            "next_page_token": "TEST_TOKEN",
            "page_info": {
                "total_results": 100,
                "results_per_page": 50
            }
        }
        """
        let json = Data(content.utf8)

        // When: We decode with snake case strategy
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Snake case keys are properly converted to camelCase
        XCTAssertEqual(response.nextPageToken, "TEST_TOKEN")
        XCTAssertEqual(response.pageInfo?.totalResults, 100)
        XCTAssertEqual(response.pageInfo?.resultsPerPage, 50)
    }

    // MARK: - Edge Cases

    func testDecodeEmptyItemsArray() throws {
        // Given: Response with empty items array
        let content = """
        {
            "kind": "youtube#playlistItemListResponse",
            "items": []
        }
        """
        let json = Data(content.utf8)

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Items array exists but is empty
        XCTAssertNotNil(response.items)
        XCTAssertTrue(response.items!.isEmpty)
    }

    func testDecodeWithMissingOptionalFields() throws {
        // Given: Minimal valid JSON with only required fields
        let content = """
        {
            "kind": "youtube#playlistItemListResponse"
        }
        """
        let json = Data(content.utf8)

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Optional fields are nil, but decoding succeeds
        XCTAssertEqual(response.kind, "youtube#playlistItemListResponse")
        XCTAssertNil(response.items)
        XCTAssertNil(response.nextPageToken)
        XCTAssertNil(response.pageInfo)
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
// swiftlint:enable force_unwrapping
