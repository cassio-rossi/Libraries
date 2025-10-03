import Foundation

extension Data {
	/// Convert a Data object into a readable string - either plain or hexadecimal
	public var debugString: String {
		return self.asString ?? self.asHexString
	}

	/// Convert a Data object into a readable string
	public var asString: String? {
		return String(data: self, encoding: .utf8)
	}

	public var asHexStr: String {
		var buffer = ""
		for index in self.startIndex ..< self.endIndex {
			if index % 4 == 0 && index > 0 {
				buffer += " "
			}
			buffer += String(format: "%02X", self[index])
		}

		return buffer
	}

	/// Convert a Data object into a readable hexadecimal string
	public var asHexString: String {
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
}
