import Foundation

extension Dictionary {
    /// Strategy for resolving conflicts when merging dictionaries with duplicate keys.
    enum UniqueType {
        /// Keep the value from the first dictionary.
        case first
        /// Keep the value from the second dictionary.
        case last
    }

    /// Merges another dictionary into this one, resolving key conflicts.
    ///
    /// When both dictionaries contain the same key, the `unique` parameter
    /// determines which value to keep.
    ///
    /// ```swift
    /// let dict1 = ["a": 1, "b": 2]
    /// let dict2 = ["b": 3, "c": 4]
    /// let merged = dict1.merge(dict2, unique: .first)
    /// // Result: ["a": 1, "b": 2, "c": 4]
    /// ```
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary to merge into this one.
    ///   - unique: Strategy for resolving conflicts. Defaults to `.first`.
    /// - Returns: A new dictionary containing entries from both dictionaries.
    func merge(_ dictionary: Dictionary, unique: UniqueType = .first) -> Dictionary {
        switch unique {
        case .first:
            self.merging(dictionary, uniquingKeysWith: { (first, _) in first })
        case .last:
            self.merging(dictionary, uniquingKeysWith: { (_, last) in last })
        }
    }
}
