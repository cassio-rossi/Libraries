import Foundation

public struct Video: Codable, Sendable {
	let title: String
	let videoId: String
	let pubDate: String
	let artworkURL: String
	let views: String
	let likes: String
	let duration: String
}
