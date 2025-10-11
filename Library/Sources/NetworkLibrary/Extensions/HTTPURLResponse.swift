import Foundation

extension HTTPURLResponse {
    /// Returns `true` if the status code is in the success range (200-299).
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
