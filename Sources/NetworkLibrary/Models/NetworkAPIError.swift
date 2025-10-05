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

/// Errors that can occur during network operations.
///
/// ``NetworkAPIError`` provides comprehensive error reporting for network requests,
/// including connectivity issues, server errors, and decoding failures.
///
/// ## Example Usage
///
/// ```swift
/// do {
///     let data = try await network.get(url: endpoint.url)
///     let users = try JSONDecoder().decode([User].self, from: data)
/// } catch NetworkAPIError.noNetwork {
///     showAlert("No internet connection")
/// } catch NetworkAPIError.network {
///     showAlert("Failed to fetch data")
/// } catch NetworkAPIError.decoding {
///     showAlert("Invalid response format")
/// } catch NetworkAPIError.error(let reason) {
///     if let errorData = reason,
///        let message = String(data: errorData, encoding: .utf8) {
///         showAlert("Server error: \(message)")
///     }
/// } catch {
///     showAlert("Unexpected error: \(error.localizedDescription)")
/// }
/// ```
public enum NetworkAPIError: Error, Equatable {
    /// No network connection is available.
    ///
    /// This error occurs when the device has no internet connectivity or
    /// cannot reach the specified host.
    case noNetwork

    /// A general network request failure.
    ///
    /// This error occurs when a request fails for reasons other than connectivity,
    /// such as invalid URLs, DNS resolution failures, or request cancellation.
    case network

    /// Failed to decode the response data.
    ///
    /// This error occurs when the response data cannot be decoded into the expected type,
    /// typically when using `JSONDecoder`.
    case decoding

    /// The server returned an error response.
    ///
    /// This error includes the response body data which may contain error details
    /// from the server (e.g., validation errors, business logic errors).
    ///
    /// - Parameter reason: Optional data containing the server's error response.
    case error(reason: Data?)

    /// The request could not be mocked.
    ///
    /// This internal error occurs when mock data is configured but cannot be loaded
    /// for the requested endpoint.
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
