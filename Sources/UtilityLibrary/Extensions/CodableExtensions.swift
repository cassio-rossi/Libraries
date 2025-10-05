import Foundation

/// Provides serialization and debugging utilities for ``Swift/Encodable`` types.
///
/// This extension adds convenient methods for converting encodable objects
/// to dictionaries and creating formatted debug strings. These utilities are
/// particularly useful for logging, debugging, and working with JSON-based APIs.
///
/// ## Topics
///
/// ### Dictionary Conversion
/// - ``asDictionary``
///
/// ### Debug Output
/// - ``debugString``
///
/// ## Usage
///
/// ```swift
/// struct User: Encodable {
///     let name: String
///     let age: Int
///     let email: String
/// }
///
/// let user = User(name: "John", age: 30, email: "john@example.com")
///
/// // Convert to dictionary
/// let dict = user.asDictionary
/// // ["name": "John", "age": 30, "email": "john@example.com"]
///
/// // Pretty-printed debug string
/// print(user.debugString)
/// // {
/// //   "age" : 30,
/// //   "email" : "john@example.com",
/// //   "name" : "John"
/// // }
/// ```
extension Encodable {
	/// Converts the encodable object to a dictionary representation.
	///
	/// This property encodes the object to JSON data and then deserializes it
	/// into a dictionary. This is useful when you need to work with dictionary
	/// representations of your codable types, such as for API calls or persistence.
	///
	/// ```swift
	/// struct Configuration: Encodable {
	///     let apiKey: String
	///     let timeout: Int
	///     let retryCount: Int
	/// }
	///
	/// let config = Configuration(
	///     apiKey: "abc123",
	///     timeout: 30,
	///     retryCount: 3
	/// )
	///
	/// let dict = config.asDictionary
	/// // ["apiKey": "abc123", "timeout": 30, "retryCount": 3]
	///
	/// // Use with URLRequest
	/// var request = URLRequest(url: url)
	/// request.httpBody = try? JSONSerialization.data(withJSONObject: dict)
	/// ```
	///
	/// - Returns: A dictionary with string keys and `Any` values representing the
	///   encoded object, or an empty dictionary if encoding fails.
	///
	/// - Note: Complex types like nested objects and arrays are preserved in the
	///   dictionary structure.
	///
	/// - Important: Encoding failures are silently handled by returning an empty
	///   dictionary. Use ``debugString`` to diagnose encoding issues.
	public var asDictionary: [String: Any] {
		return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
	}

	/// Returns a formatted JSON debug string representation of the encodable object.
	///
	/// This property creates a pretty-printed, sorted JSON string that's perfect
	/// for logging and debugging. It uses multiple formatting options to create
	/// human-readable output.
	///
	/// The output includes:
	/// - Pretty printing with indentation
	/// - Sorted keys for consistent output
	/// - Unescaped slashes for better readability
	///
	/// ```swift
	/// struct Article: Encodable {
	///     let title: String
	///     let author: String
	///     let url: String
	///     let tags: [String]
	/// }
	///
	/// let article = Article(
	///     title: "Swift Best Practices",
	///     author: "Jane Doe",
	///     url: "https://example.com/article",
	///     tags: ["swift", "ios", "development"]
	/// )
	///
	/// print(article.debugString)
	/// // {
	/// //   "author" : "Jane Doe",
	/// //   "tags" : [
	/// //     "swift",
	/// //     "ios",
	/// //     "development"
	/// //   ],
	/// //   "title" : "Swift Best Practices",
	/// //   "url" : "https://example.com/article"
	/// // }
	/// ```
	///
	/// - Returns: A formatted JSON string representation, or "failed to encode" if
	///   encoding fails. If JSON encoding succeeds but string conversion fails,
	///   returns a hexadecimal representation of the JSON data.
	///
	/// - Note: Keys are sorted alphabetically in the output, making it easier to
	///   compare different debug outputs.
	///
	/// - SeeAlso: ``asDictionary`` for dictionary conversion.
	public var debugString: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		let encoded = try? encoder.encode(self)
		return encoded?.asString ?? encoded?.asHexString ?? "failed to encode"
	}
}
