import Foundation
import Testing
@testable import YouTubeLibrary

// swiftlint:disable force_unwrapping
@Suite("YouTube Model Tests")
struct YouTubeModelTests {

    // MARK: - Playlist Video Decoding Tests

    @Test("Decode playlist video response")
    func testDecodePlaylistVideoResponse() throws {
        // Given: Real YouTube API playlist response JSON
        let json = try loadJSON(file: "video_example")

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Top-level properties are correct
        #expect(response.kind == "youtube#playlistItemListResponse")
        #expect(response.etag == "SK2IsKJOtDohwem_6l318ztECPA")
        #expect(response.nextPageToken == "CAEQAA")
        #expect(response.items != nil)
        #expect(!response.items!.isEmpty)
    }

    @Test("Decode playlist video item")
    func testDecodePlaylistVideoItem() throws {
        // Given: Real YouTube API playlist response
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the first video item
        let firstItem = try #require(response.items?.first)

        // Then: Video metadata is correctly decoded
        #expect(firstItem.kind == "youtube#playlistItem")
        #expect(firstItem.id == "VVVBel9Fc3prM1lqcVZMdzZvWGJTS1FBLmJxMDJMTWpjQ25z")

        // And: Snippet data is correct
        let snippet = try #require(firstItem.snippet)
        #expect(snippet.publishedAt == "2021-02-17T20:45:21Z")
        #expect(snippet.channelId == "UCAz_Eszk3YjqVLw6oXbSKQA")
        #expect(snippet.title == "Como Usar WhatsApp No iPad")
        #expect(snippet.playlistId == "UUAz_Eszk3YjqVLw6oXbSKQA")

        // And: ResourceId is correct
        let resourceId = try #require(snippet.resourceId)
        #expect(resourceId.kind == "youtube#video")
        #expect(resourceId.videoId == "bq02LMjcCns")
    }

    @Test("Decode thumbnails")
    func testDecodeThumbnails() throws {
        // Given: Real YouTube API playlist response
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access thumbnails
        let thumbnails = try #require(response.items?.first?.snippet?.thumbnails)

        // Then: All thumbnail sizes are available
        #expect(thumbnails.original != nil)
        #expect(thumbnails.medium != nil)
        #expect(thumbnails.high != nil)
        #expect(thumbnails.standard != nil)
        #expect(thumbnails.maxres != nil)

        // And: Maxres thumbnail has correct properties
        let maxres = try #require(thumbnails.maxres)
        #expect(maxres.url == "https://i.ytimg.com/vi/bq02LMjcCns/maxresdefault.jpg")
        #expect(maxres.width == 1280)
        #expect(maxres.height == 720)

        // And: Default thumbnail is mapped correctly (CodingKey: "default" -> "original")
        let original = try #require(thumbnails.original)
        #expect(original.url == "https://i.ytimg.com/vi/bq02LMjcCns/default.jpg")
    }

    // MARK: - Statistics Decoding Tests

    @Test("Decode statistics response")
    func testDecodeStatisticsResponse() throws {
        // Given: Real YouTube API statistics response JSON
        let json = try loadJSON(file: "stats_example")

        // When: We decode it
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // Then: Top-level properties are correct
        #expect(response.kind == "youtube#videoListResponse")
        #expect(response.items != nil)
        #expect(!response.items!.isEmpty)
    }

    @Test("Decode video statistics")
    func testDecodeVideoStatistics() throws {
        // Given: Real YouTube API statistics response
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the first video's statistics
        let firstItem = try #require(response.items?.first)
        let statistics = try #require(firstItem.statistics)

        // Then: All statistics are correctly decoded
        #expect(statistics.viewCount == "5663")
        #expect(statistics.likeCount == "782")
        #expect(statistics.dislikeCount == "10")
        #expect(statistics.favoriteCount == "0")
        #expect(statistics.commentCount == "73")
    }

    @Test("Decode content details")
    func testDecodeContentDetails() throws {
        // Given: Real YouTube API statistics response
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access content details
        let contentDetails = try #require(response.items?.first?.contentDetails)

        // Then: Duration and other details are correct
        #expect(contentDetails.duration == "PT4M46S")
        #expect(contentDetails.dimension == "2d")
        #expect(contentDetails.definition == "hd")
        #expect(contentDetails.caption == "false")
        #expect(contentDetails.licensedContent == true)
        #expect(contentDetails.projection == "rectangular")
    }

    // MARK: - Dual ID Decoding Test (String and ResourceId)

    @Test("Item ID decodes as string")
    func testItemIDDecodesAsString() throws {
        // Given: Statistics response where ID is a string
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the ID
        let firstItem = try #require(response.items?.first)

        // Then: ID is decoded as String (not ResourceId)
        #expect(firstItem.id == "bq02LMjcCns")
        #expect(firstItem.resourceId == nil)
    }

    @Test("Item ID decodes as ResourceId")
    func testItemIDDecodesAsResourceId() throws {
        // Given: Playlist response where ID contains ResourceId in snippet
        let json = try loadJSON(file: "video_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access the snippet's resource ID
        let firstItem = try #require(response.items?.first)
        let snippet = try #require(firstItem.snippet)
        let resourceId = try #require(snippet.resourceId)

        // Then: ResourceId contains the video ID
        #expect(resourceId.videoId == "bq02LMjcCns")
        #expect(firstItem.id == "VVVBel9Fc3prM1lqcVZMdzZvWGJTS1FBLmJxMDJMTWpjQ25z")
    }

    // MARK: - Page Info Tests

    @Test("Decode page info")
    func testDecodePageInfo() throws {
        // Given: Statistics response with page info
        let json = try loadJSON(file: "stats_example")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(YouTube.self, from: json)

        // When: We access page info
        let pageInfo = try #require(response.pageInfo)

        // Then: Page info is correct
        #expect(pageInfo.totalResults == 1)
        #expect(pageInfo.resultsPerPage == 1)
    }

    // MARK: - Snake Case Conversion Tests

    @Test("Snake case conversion")
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
        #expect(response.nextPageToken == "TEST_TOKEN")
        #expect(response.pageInfo?.totalResults == 100)
        #expect(response.pageInfo?.resultsPerPage == 50)
    }

    // MARK: - Edge Cases

    @Test("Decode empty items array")
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
        #expect(response.items != nil)
        #expect(response.items!.isEmpty)
    }

    @Test("Decode with missing optional fields")
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
        #expect(response.kind == "youtube#playlistItemListResponse")
        #expect(response.items == nil)
        #expect(response.nextPageToken == nil)
        #expect(response.pageInfo == nil)
    }

    // MARK: - Helper Methods

    private func loadJSON(file: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: file, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            Issue.record("Failed to load \(file).json from bundle")
            throw NSError(domain: "TestError", code: 1)
        }
        return data
    }
}
// swiftlint:enable force_unwrapping
