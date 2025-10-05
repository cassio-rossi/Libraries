import Foundation

/// Extensions to `HTTPURLResponse` for convenient status code checking.
extension HTTPURLResponse {
    /// Returns `true` if the status code indicates a successful response (2xx).
    ///
    /// This property checks if the HTTP status code is in the success range (200-299),
    /// which includes:
    /// - 200 OK
    /// - 201 Created
    /// - 202 Accepted
    /// - 204 No Content
    /// - And other 2xx codes
    ///
    /// ## Example
    ///
    /// ```swift
    /// let (data, response) = try await URLSession.shared.data(for: request)
    ///
    /// if let httpResponse = response as? HTTPURLResponse,
    ///    httpResponse.hasSuccessStatusCode {
    ///     // Process successful response
    ///     return data
    /// } else {
    ///     throw NetworkAPIError.error(reason: data)
    /// }
    /// ```
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
