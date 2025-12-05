import SwiftData
import SwiftUI

/// Button for toggling a video's favorite status.
///
/// Displays a star icon that fills when the video is marked as favorite.
/// Persists changes using SwiftData.
public struct FavoriteButton: View {
    @Environment(\.modelContext) private var context

    @Bindable var content: VideoDB

	/// Creates a favorite button.
	///
	/// - Parameter content: The video to mark as favorite or unfavorite.
    public init(content: VideoDB) {
        self.content = content
    }

    public var body: some View {
        Button(action: {
            content.favorite.toggle()
            try? context.save()
            UIAccessibility.post(
                notification: .announcement,
                argument: content.favorite ? "Video favoritado." : "Video não favoritado."
            )

        }, label: {
            Image(systemName: "star\(content.favorite ? ".fill" : "")")
        })
        .accessibilityLabel("Favoritar o video.")
        .accessibilityValue(content.favorite ? "Favoritado." : "Não favoritado.")
    }
}
