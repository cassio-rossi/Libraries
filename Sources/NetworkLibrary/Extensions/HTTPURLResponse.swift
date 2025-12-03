import Foundation

/// Extension providing status code validation helpers.
extension HTTPURLResponse {
    /// Returns `true` if the status code is in the success range (200-299).
    ///
    /// Use this property to quickly validate if an HTTP response indicates success.
    ///
    /// ```swift
    /// guard httpResponse.hasSuccessStatusCode else {
    ///     throw NetworkAPIError.error(reason: data)
    /// }
    /// ```
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
