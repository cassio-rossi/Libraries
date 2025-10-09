import XCTest
import UtilityLibrary
@testable import YouTubeLibrary

final class YouTubeCredentialsTests: XCTestCase {

    let testSalt = "TestSalt123"

    // MARK: - Obfuscation Tests

    func testAPIKeyObfuscationAndReveal() {
        // Given: A real API key that we obfuscate
        let originalKey = "AIzaSyDummy1234567890Key"
        let obfuscator = Obfuscator(with: testSalt)
        let obfuscatedKey = obfuscator.bytesByObfuscating(string: originalKey)

        // When: We create credentials with the obfuscated key
        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: [obfuscatedKey],
            playlistId: [],
            channelId: []
        )

        // Then: The revealed key should match the original
        XCTAssertEqual(credentials.key, originalKey)
    }

    func testPlaylistIDObfuscationAndReveal() {
        // Given: A real playlist ID that we obfuscate
        let originalPlaylist = "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf"
        let obfuscator = Obfuscator(with: testSalt)
        let obfuscatedPlaylist = obfuscator.bytesByObfuscating(string: originalPlaylist)

        // When: We create credentials with the obfuscated playlist
        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: [],
            playlistId: obfuscatedPlaylist,
            channelId: []
        )

        // Then: The revealed playlist should match the original
        XCTAssertEqual(credentials.playlist, originalPlaylist)
    }

    func testChannelIDObfuscationAndReveal() {
        // Given: A real channel ID that we obfuscate
        let originalChannel = "UCuAXFkgsw1L7xaCfnd5JJOw"
        let obfuscator = Obfuscator(with: testSalt)
        let obfuscatedChannel = obfuscator.bytesByObfuscating(string: originalChannel)

        // When: We create credentials with the obfuscated channel
        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: [],
            playlistId: [],
            channelId: obfuscatedChannel
        )

        // Then: The revealed channel should match the original
        XCTAssertEqual(credentials.channel, originalChannel)
    }

    // MARK: - Multiple Key Rotation Tests

    func testMultipleAPIKeysRotation() {
        // Given: Multiple API keys for rotation
        let key1 = "AIzaSyKey1111111111111111"
        let key2 = "AIzaSyKey2222222222222222"
        let key3 = "AIzaSyKey3333333333333333"

        let obfuscator = Obfuscator(with: testSalt)
        let obfuscatedKeys = [
            obfuscator.bytesByObfuscating(string: key1),
            obfuscator.bytesByObfuscating(string: key2),
            obfuscator.bytesByObfuscating(string: key3)
        ]

        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: obfuscatedKeys,
            playlistId: [],
            channelId: []
        )

        // When: We access the key multiple times
        var retrievedKeys = Set<String>()
        for _ in 0..<100 {
            retrievedKeys.insert(credentials.key)
        }

        // Then: We should eventually see all keys being used (randomization)
        // Note: There's a very small chance this could fail due to randomness,
        // but with 100 iterations it's extremely unlikely
        XCTAssertTrue(retrievedKeys.count > 1, "Keys should rotate randomly")

        // And: All keys should be valid
        let validKeys = [key1, key2, key3]
        for key in retrievedKeys {
            XCTAssertTrue(validKeys.contains(key), "Retrieved key should be one of the original keys")
        }
    }

    func testSingleAPIKeyAlwaysReturnsSameKey() {
        // Given: Single API key
        let originalKey = "AIzaSySingleKey123456789"
        let obfuscator = Obfuscator(with: testSalt)
        let obfuscatedKey = obfuscator.bytesByObfuscating(string: originalKey)

        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: [obfuscatedKey],
            playlistId: [],
            channelId: []
        )

        // When: We access the key multiple times
        let keys = (0..<10).map { _ in credentials.key }

        // Then: All should be the same
        XCTAssertTrue(keys.allSatisfy { $0 == originalKey })
    }

    // MARK: - Security Tests

    func testDifferentSaltProducesDifferentObfuscation() {
        // Given: Same key with different salts
        let originalKey = "AIzaSySecretKey123456789"

        let salt1 = "Salt1"
        let salt2 = "Salt2"

        let obfuscator1 = Obfuscator(with: salt1)
        let obfuscator2 = Obfuscator(with: salt2)

        let obfuscated1 = obfuscator1.bytesByObfuscating(string: originalKey)
        let obfuscated2 = obfuscator2.bytesByObfuscating(string: originalKey)

        // Then: Obfuscated byte arrays should be different
        XCTAssertNotEqual(obfuscated1, obfuscated2)

        // But: Both should reveal back to the original with correct salt
        let credentials1 = YouTubeCredentials(salt: salt1, keys: [obfuscated1], playlistId: [], channelId: [])
        let credentials2 = YouTubeCredentials(salt: salt2, keys: [obfuscated2], playlistId: [], channelId: [])

        XCTAssertEqual(credentials1.key, originalKey)
        XCTAssertEqual(credentials2.key, originalKey)
    }

    func testWrongSaltProducesGarbage() {
        // Given: Key obfuscated with one salt
        let originalKey = "AIzaSyCorrectKey123456789"
        let correctSalt = "CorrectSalt"
        let wrongSalt = "WrongSalt"

        let obfuscator = Obfuscator(with: correctSalt)
        let obfuscatedKey = obfuscator.bytesByObfuscating(string: originalKey)

        // When: We try to reveal with wrong salt
        let credentialsWithWrongSalt = YouTubeCredentials(
            salt: wrongSalt,
            keys: [obfuscatedKey],
            playlistId: [],
            channelId: []
        )

        // Then: Revealed key should NOT match original
        XCTAssertNotEqual(credentialsWithWrongSalt.key, originalKey)
    }

    // MARK: - Full Integration Test

    func testCompleteCredentialsWorkflow() {
        // Given: Complete set of credentials
        let apiKey = "AIzaSyCompleteTest123456"
        let playlistId = "PLxxxxxxxxxxxxxxxxxxxxx"
        let channelId = "UCyyyyyyyyyyyyyyyyyyyyyy"

        let obfuscator = Obfuscator(with: testSalt)

        let credentials = YouTubeCredentials(
            salt: testSalt,
            keys: [
                obfuscator.bytesByObfuscating(string: apiKey)
            ],
            playlistId: obfuscator.bytesByObfuscating(string: playlistId),
            channelId: obfuscator.bytesByObfuscating(string: channelId)
        )

        // Then: All credentials should be properly revealed
        XCTAssertEqual(credentials.key, apiKey)
        XCTAssertEqual(credentials.playlist, playlistId)
        XCTAssertEqual(credentials.channel, channelId)
    }
}
