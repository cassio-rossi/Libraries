import Foundation
import UtilityLibrary

public struct YouTubeCredentials: Sendable {
    let salt: String
    let keys: [[UInt8]]
    let playlistId: [UInt8]
    let channelId: [UInt8]

    public init(salt: String,
                keys: [[UInt8]],
                playlistId: [UInt8],
                channelId: [UInt8]) {
        self.salt = salt
        self.keys = keys
        self.playlistId = playlistId
        self.channelId = channelId
    }

    var key: String {
        let random = Int.random(in: 0..<keys.count)
        return Obfuscator(with: salt).reveal(key: keys[random])
    }

    var playlist: String {
        return Obfuscator(with: salt).reveal(key: playlistId)
    }

    var channel: String {
        return Obfuscator(with: salt).reveal(key: channelId)
    }
}
