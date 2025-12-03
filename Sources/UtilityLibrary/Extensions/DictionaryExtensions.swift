import Foundation

/// Extension providing dictionary debugging utilities.
public extension Dictionary {
    /// A human-readable debug string of key-value pairs.
    var debugString: String {
        let debug: [String] = self.compactMap {
            return "\($0.key): \($0.value)"
        }
        return debug.joined(separator: ", ")
    }
}
