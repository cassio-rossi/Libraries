import SwiftUI
import UIComponentsLibrary

struct VideoErrorView: View {
    let status: YouTubeAPI.Status
    let favorite: Bool
    let isSearching: Bool
    let quantity: Int
    let color: Color?

    var body: some View {
        if status == .loading {
            ProgressView().padding(.vertical, 20)
        } else if favorite || isSearching {
            if quantity == 0 {
                error(
                    title: favorite ? "Favoritos" : "Busca",
                    reason: "Nenhum vídeo \(favorite ? "favoritado" : "encontrado").",
                    icon: favorite ? "star.fill" : "exclamationmark.magnifyingglass")
            } else if let reason = status.reason {
                error(title: "Ocorreu um erro", reason: reason, icon: "exclamationmark.triangle.fill")
            }
        } else if quantity == 0 {
            ContentUnavailableView(
                "Vídeos",
                systemImage: "tv.slash",
                description: Text("Nenhum vídeo disponível ou problema de rede.").font(.title3)
            )
        }
    }

    private func error(title: String, reason: String, icon: String) -> some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(reason).font(.title3)
        )
    }
}

#Preview {
    List {
        VideoErrorView(status: .loading, favorite: false, isSearching: false, quantity: 0, color: nil)
        VideoErrorView(status: .done, favorite: true, isSearching: false, quantity: 0, color: nil)
        VideoErrorView(status: .error(reason: "Error"), favorite: false, isSearching: true, quantity: 10, color: nil)
        VideoErrorView(status: .error(reason: "Error"), favorite: false, isSearching: false, quantity: 10, color: nil)
    }
}
