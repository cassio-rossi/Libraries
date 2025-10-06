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

/// Errors that occur during network operations.
///
/// ```swift
/// do {
///     let data = try await network.get(url: endpoint.url)
/// } catch NetworkAPIError.noNetwork {
///     showAlert("No internet connection")
/// } catch NetworkAPIError.error(let reason) {
///     handleServerError(reason)
/// }
/// ```
public enum NetworkAPIError: Error, Equatable {
    /// No network connection available.
    case noNetwork

    /// Network request failure.
    case network

    /// Failed to decode response data.
    case decoding

    /// Server returned an error response.
    ///
    /// - Parameter reason: Server's error response data.
    case error(reason: Data?)

    /// Mock data could not be loaded.
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
