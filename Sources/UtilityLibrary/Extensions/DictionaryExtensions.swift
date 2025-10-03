import Foundation

public extension Dictionary {
    /// Returns a debug string representation of the dictionary.
    var debugString: String {
        let debug: [String] = self.compactMap {
            return "\($0.key): \($0.value)"
        }
        return debug.joined(separator: ", ")
    }
}
