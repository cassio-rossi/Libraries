import Foundation

/// Struct to hold data to filter content.
public struct Filter: Codable, Sendable {
    /// Video title contais.
    let title: [String]
    /// Video duration in formatted string (e.g., "04:13").
    let duration: String
}
