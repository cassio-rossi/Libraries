import Foundation
import UtilityLibrary

/// Securely stores obfuscated YouTube API credentials.
///
/// Uses byte array obfuscation to protect API keys, playlist IDs, and channel IDs.
public struct YouTubeCredentials: Sendable {
    let salt: String
    let keys: [[UInt8]]
    let playlistId: [UInt8]
    let channelId: [UInt8]

	/// Creates new YouTube credentials with obfuscated values.
	///
	/// - Parameters:
	///   - salt: Salt value for obfuscation.
	///   - keys: Array of obfuscated API keys (rotated for rate limiting).
	///   - playlistId: Obfuscated playlist identifier.
	///   - channelId: Obfuscated channel identifier.
    public init(salt: String,
                keys: [[UInt8]],
                playlistId: [UInt8],
                channelId: [UInt8]) {
        self.salt = salt
        self.keys = keys
        self.playlistId = playlistId
        self.channelId = channelId
    }

	/// Returns a randomly selected API key from the available keys.
	///
	/// Rotates through multiple keys to distribute API quota usage.
    var key: String {
        let random = Int.random(in: 0..<keys.count)
        return Obfuscator(with: salt).reveal(key: keys[random])
    }

	/// Returns the deobfuscated playlist identifier.
    var playlist: String {
        return Obfuscator(with: salt).reveal(key: playlistId)
    }

	/// Returns the deobfuscated channel identifier.
    var channel: String {
        return Obfuscator(with: salt).reveal(key: channelId)
    }
}
