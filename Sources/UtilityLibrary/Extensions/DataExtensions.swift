import Foundation

/// Extension providing data conversion and debugging utilities.
public extension Data {
	/// A debug-friendly string representation of the data.
	///
	/// Returns UTF-8 string if valid, otherwise hex dump.
	var debugString: String {
		return self.asString ?? self.asHexString
	}

	/// The data converted to a UTF-8 string.
	var asString: String? {
		return String(data: self, encoding: .utf8)
	}

	/// A compact hexadecimal representation with 4-byte groups.
	var asHexStr: String {
		var buffer = ""
		for index in self.startIndex ..< self.endIndex {
			if index % 4 == 0 && index > 0 {
				buffer += " "
			}
			buffer += String(format: "%02X", self[index])
		}

		return buffer
	}

	/// A formatted hex dump with ASCII representation.
	///
	/// Non-printable characters appear as dots.
	var asHexString: String {
		var hexBuffer = ""
		var asciiBuffer = ""
		var buffer: [String] = []

		for index in startIndex ..< endIndex {
			let offset = index - startIndex
			if offset % 4 == 0 && offset > 0 {
				buffer.append(hexBuffer + " " + asciiBuffer)
				hexBuffer = ""
				asciiBuffer = ""
			}
			hexBuffer += String(format: "%02X", self[index])
			if self[index] >= 0x20 && self[index] < 0x7F {
				asciiBuffer += String(format: "%C", self[index])
			} else {
				asciiBuffer += "."
			}
		}

		if hexBuffer.isEmpty {
			while hexBuffer.count % 4 != 0 {
				hexBuffer += " "
			}
			buffer.append(hexBuffer + " " + asciiBuffer)
		}

		return buffer.joined(separator: "\n")
	}

    /// Decodes the data into a decodable object.
    ///
    /// - Returns: The decoded object, or `nil` if decoding fails.
    func asObject<T: Decodable>() -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}
