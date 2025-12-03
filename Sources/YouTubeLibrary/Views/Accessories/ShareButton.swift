import SwiftUI

/// Button for sharing a video via the system share sheet.
///
/// Generates a YouTube URL and presents the native share interface with the video title.
public struct ShareButton: View {
    let content: VideoDB

	/// Creates a share button.
	///
	/// - Parameter content: The video to share.
    public init(content: VideoDB) {
        self.content = content
    }

    public var body: some View {
        let youTubeURL = "https://www.youtube.com/watch?v="

        if let url = URL(string: "\(youTubeURL)\(content.videoId)"),
           !content.title.isEmpty {

            ShareLink(item: url,
                      subject: Text(content.title)) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
