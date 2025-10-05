import Foundation
import UtilityLibrary

/// Extensions to `String` for splitting long messages to avoid Console.app truncation.
///
/// Console.app truncates messages at approximately 1024 bytes. This extension provides
/// functionality to split longer strings into chunks with optional separators, ensuring
/// all content is visible in the console.
extension String {
    /// Splits a string into fixed-length chunks with optional separator markers.
    ///
    /// This method divides the string into chunks of the specified length. If a separator
    /// is provided and the string is split into multiple chunks, the separator is added:
    /// - At the end of the first chunk
    /// - At both ends of middle chunks
    /// - At the beginning of the last chunk
    ///
    /// This helps identify that a message was truncated and continues in subsequent chunks.
    ///
    /// - Parameters:
    ///   - length: The maximum length of each chunk. If `<= 0`, returns the original string.
    ///   - separator: An optional separator string to insert between chunks. Common values
    ///     are `"[...]"`, `"..."`, or similar indicators.
    ///
    /// - Returns: An array of string chunks. Returns a single-element array containing an
    ///   empty string if the original string is empty.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let longMessage = String(repeating: "A", count: 2500)
    /// let chunks = longMessage.split(by: 1000, separator: "[...]")
    /// // chunks[0] ends with "[...]"
    /// // chunks[1] starts and ends with "[...]"
    /// // chunks[2] starts with "[...]"
    /// ```
    ///
    /// ## Without Separator
    ///
    /// ```swift
    /// let message = "Hello World"
    /// let chunks = message.split(by: 5)
    /// // ["Hello", " Worl", "d"]
    /// ```
    ///
    /// ## With Separator
    ///
    /// ```swift
    /// let message = "Hello World"
    /// let chunks = message.split(by: 5, separator: "...")
    /// // ["Hello...", "... Worl...", "...d"]
    /// ```
    ///
    /// - Note: The separator length is not included in the chunk length calculation.
    ///   Each chunk will be exactly `length` characters, plus any separators added.
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
