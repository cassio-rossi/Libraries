import Foundation

extension Encodable {
	/// The encodable object as a dictionary.
	public var asDictionary: [String: Any] {
		return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
	}

	/// A pretty-printed, sorted JSON debug string.
	public var debugString: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		let encoded = try? encoder.encode(self)
		return encoded?.asString ?? encoded?.asHexString ?? "failed to encode"
	}
}
