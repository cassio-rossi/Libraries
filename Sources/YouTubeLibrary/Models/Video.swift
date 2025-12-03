import Foundation

/// Simplified video data structure for lightweight use cases.
///
/// Contains essential video information without persistence or state management.
public struct Video: Codable, Sendable {
	/// Video title.
	let title: String
	/// YouTube video identifier.
	let videoId: String
	/// Publication date in ISO 8601 format.
	let pubDate: String
	/// URL to the video thumbnail image.
	let artworkURL: String
	/// Number of views as a string.
	let views: String
	/// Number of likes as a string.
	let likes: String
	/// Video duration in formatted string (e.g., "04:13").
	let duration: String
}
