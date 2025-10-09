import SwiftUI
import UIComponentsLibrary

struct VideoErrorView: View {
    let status: YouTubeAPI.Status
    let favorite: Bool
    let isSearching: Bool
    let quantity: Int
    let theme: Themeable?

    var body: some View {
        if status == .loading {
            ProgressView()
        } else if favorite || isSearching {
            if quantity == 0 {
                error(reason: "Nenhum conteúdo \(favorite ? "favoritado" : "encontrado").")
            } else if let reason = status.reason {
                error(reason: reason)
            }
        } else {
            EmptyView()
        }
    }

    private func error(reason: String) -> some View {
        ErrorView(message: reason,
                  color: theme?.text.error.asColor ?? .red)
        .padding(.horizontal)
    }
}

#Preview {
    List {
        VideoErrorView(status: .loading, favorite: false, isSearching: false, quantity: 0, theme: nil)
        VideoErrorView(status: .done, favorite: true, isSearching: false, quantity: 0, theme: nil)
        VideoErrorView(status: .error(reason: "Error"), favorite: false, isSearching: true, quantity: 10, theme: nil)
        VideoErrorView(status: .error(reason: "Error"), favorite: false, isSearching: false, quantity: 10, theme: nil)
    }
}
