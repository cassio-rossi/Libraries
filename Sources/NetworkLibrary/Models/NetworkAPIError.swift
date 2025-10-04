import Foundation

// MARK: - Network Strings -

enum L10n: String {
    case noNetwork
    case errorFetching
    case errorDecoding
    case errorFetchingWith

    var string: String {
        self.rawValue.localized(bundle: .module)
    }
}

// MARK: - Network Errors -

public enum NetworkAPIError: Error, Equatable {
    case noNetwork
    case network
    case decoding
    case error(reason: Data?)
    case couldNotBeMock
}

extension NetworkAPIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noNetwork: return L10n.noNetwork.string
        case .network: return L10n.errorFetching.string
        case .decoding: return L10n.errorDecoding.string
        case .couldNotBeMock: return ""
        case .error(let reason):
            guard let reason = reason,
                  let data = reason.asString else {
                return L10n.errorFetching.string
            }
            return String.localizedStringWithFormat(L10n.errorFetchingWith.string, data)
        }
    }
}
