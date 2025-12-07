import SwiftUI

/// Represents the current state of API operations.
public enum APIStatus: Equatable, Sendable {
    /// Initial state.
    case idle
    /// The API is currently loading data.
    case loading
    /// The API operation has completed successfully.
    case done
    /// The API operation failed with an error.
    /// - Parameter reason: A description of the error that occurred.
    case error(reason: String)

    /// Returns the error reason if the status is an error, otherwise nil.
    public var reason: String? {
        switch self {
        case .error(let reason):
            return reason
        default:
            return nil
        }
    }
}

public struct LoadingAndErrorView: View {
    let title: String
    let status: APIStatus
    let favorite: Bool
    let isSearching: Bool
    let quantity: Int
    let color: Color?
    let retryAction: (() -> Void)?

    public init(
        title: String,
        status: APIStatus,
        favorite: Bool = false,
        isSearching: Bool = false,
        quantity: Int = 0,
        color: Color? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.status = status
        self.favorite = favorite
        self.isSearching = isSearching
        self.quantity = quantity
        self.color = color
        self.retryAction = retryAction
    }

    public var body: some View {
        if status == .loading {
            ProgressView().padding(.vertical, 20)

        } else if favorite || isSearching {

            if quantity == 0 {
                error(
                    title: favorite ? "Favoritos" : "Busca",
                    reason: "Nenhum \(title.lowercased()) \(favorite ? "favoritado" : "encontrado").",
                    icon: favorite ? "star.fill" : "exclamationmark.magnifyingglass",
                    action: retryAction
                )
            } else if let reason = status.reason {
                error(
                    title: "Ocorreu um erro",
                    reason: reason,
                    icon: "exclamationmark.triangle.fill",
                    action: retryAction
                )
            }

        } else if quantity == 0 {
            error(title: title,
                  reason: "Nenhum \(title.lowercased()) disponível ou problema de rede.",
                  icon: "exclamationmark.triangle.fill",
                  action: retryAction
            )
        }
    }

    @ViewBuilder
    private func error(
        title: String,
        reason: String,
        icon: String,
        action: (() -> Void)? = nil
    ) -> some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(reason).font(.title3)
        )
        if let action {
            Button(action: action,
                   label: {
                Text("Tentar novamente")
            })
            .tint(.primary)
        }
    }
}

#Preview {
    List {
        LoadingAndErrorView(title: "Vídeo", status: .loading)
        LoadingAndErrorView(title: "Vídeo", status: .done, favorite: true)
        LoadingAndErrorView(title: "Vídeo", status: .error(reason: "Error"), isSearching: true, quantity: 10)
        LoadingAndErrorView(title: "Vídeo", status: .error(reason: "Error"), quantity: 10)
        LoadingAndErrorView(title: "Vídeo", status: .error(reason: "Error"), quantity: 10) {}
    }
}
