import Foundation
import UtilityLibrary

/// String splitting for Console.app truncation handling.
///
/// Extends `String` with methods to split long strings into manageable chunks
/// for logging systems with character limits.
public extension String {
    /// Splits string into fixed-length chunks with optional separators.
    ///
    /// Used to prevent Console.app truncation by splitting long messages.
    /// Separators are added at chunk boundaries to indicate continuation.
    ///
    /// ```swift
    /// let longMessage = "A" + String(repeating: "B", count: 2000) + "Z"
    /// let chunks = longMessage.split(by: 1000, separator: "[...]")
    /// // chunks[0]: "ABBB...[...]"
    /// // chunks[1]: "[...]BBB...[...]"
    /// // chunks[2]: "[...]BBBZ"
    /// ```
    ///
    /// - Parameters:
    ///   - length: Maximum chunk length. Returns original string if <= 0.
    ///   - separator: Optional separator inserted at chunk boundaries.
    /// - Returns: Array of string chunks, or single-element array with original string if length <= 0.
    func split(by length: Int,
               separator: String? = nil) -> [String] {
        if length <= 0 { return [self] }

        var startIndex = self.startIndex
        var results = [String]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex,
                                      offsetBy: length,
                                      limitedBy: self.endIndex) ?? self.endIndex
            results.append(String(self[startIndex..<endIndex]))
            startIndex = endIndex
        }

        // Add separator
        guard let separator = separator, results.count > 1 else {
            return results.isEmpty && self.isEmpty ? [""] : results
        }

        results[0] += "\(separator)"

        let last = results.count - 1
        results[last] = "\(separator)" + results[last]

        for index in 1..<last {
            results[index] = "\(separator)" + results[index] + "\(separator)"
        }

        return results
    }
}
