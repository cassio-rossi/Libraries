import Foundation

/// Provides debugging utilities for ``Swift/Dictionary``.
///
/// This extension adds convenient methods for converting dictionaries into
/// human-readable string representations, particularly useful for logging
/// and debugging purposes.
///
/// ## Topics
///
/// ### Debug Output
/// - ``debugString``
///
/// ## Usage
///
/// ```swift
/// let userInfo = ["name": "John", "age": 30, "city": "New York"]
/// print(userInfo.debugString)
/// // "name: John, age: 30, city: New York"
///
/// let config: [String: Any] = [
///     "timeout": 30,
///     "retries": 3,
///     "verbose": true
/// ]
/// print(config.debugString)
/// // "timeout: 30, retries: 3, verbose: true"
/// ```
public extension Dictionary {
    /// Returns a human-readable debug string representation of the dictionary.
    ///
    /// This property converts the dictionary into a comma-separated string
    /// of "key: value" pairs. It's particularly useful for quick inspection
    /// of dictionary contents in logs or debug output.
    ///
    /// ```swift
    /// let settings = ["theme": "dark", "fontSize": 14, "notifications": true]
    /// print(settings.debugString)
    /// // "theme: dark, fontSize: 14, notifications: true"
    ///
    /// let emptyDict: [String: String] = [:]
    /// print(emptyDict.debugString)
    /// // ""
    /// ```
    ///
    /// - Returns: A string containing all key-value pairs formatted as "key: value",
    ///   separated by commas and spaces. Returns an empty string for empty dictionaries.
    ///
    /// - Note: The order of key-value pairs in the output is not guaranteed to match
    ///   the dictionary's internal order, as dictionaries are unordered collections.
    ///
    /// - Complexity: O(n), where n is the number of key-value pairs in the dictionary.
    var debugString: String {
        let debug: [String] = self.compactMap {
            return "\($0.key): \($0.value)"
        }
        return debug.joined(separator: ", ")
    }
}
