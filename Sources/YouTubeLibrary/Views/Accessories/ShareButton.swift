import SwiftUI

public struct ShareButton: View {
    let content: VideoDB

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
