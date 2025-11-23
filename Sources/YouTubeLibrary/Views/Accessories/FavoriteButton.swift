import SwiftData
import SwiftUI

public struct FavoriteButton: View {
    @Environment(\.modelContext) private var context

    let content: VideoDB

    public init(content: VideoDB) {
        self.content = content
    }

    public var body: some View {
        Button {
            content.favorite.toggle()
            try? context.save()
        } label: {
            Image(systemName: "star\(content.favorite ? ".fill" : "")")
        }
    }
}
