import Foundation

extension Encodable {
	/// Converts a codable object into a Dictionary
	public var asDictionary: [String: Any] {
		return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
	}

	/// Convert a Data object into a readable string - either plain or hexadecimal
	public var debugString: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		let encoded = try? encoder.encode(self)
		return encoded?.asString ?? encoded?.asHexString ?? "failed to encode"
	}
}
