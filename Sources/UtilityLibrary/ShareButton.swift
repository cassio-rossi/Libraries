import SwiftUI

/// Button for sharing a video via the system share sheet.
public struct ShareButton: View {
    let title: String
    let url: URL

    /// Creates a share button.
    ///
    /// - Parameter title: The title to be presented while sharing.
    /// - Parameter url: The URL to share.
    public init(
        title: String,
        url: URL
    ) {
        self.title = title
        self.url = url
    }

    public var body: some View {
        ShareLink(item: url,
                  subject: Text(title)) {
            Image(systemName: "square.and.arrow.up")
        }.accessibilityLabel("Compartilhar")
    }
}
