import Foundation

/// Provides debugging and string conversion utilities for ``Foundation/Data``.
///
/// This extension adds methods to convert binary data into human-readable
/// representations, including plain text, hexadecimal, and formatted hex dumps.
/// These utilities are particularly useful for debugging network protocols,
/// file formats, and binary data streams.
///
/// ## Topics
///
/// ### String Conversion
/// - ``asString``
/// - ``debugString``
///
/// ### Hexadecimal Representation
/// - ``asHexStr``
/// - ``asHexString``
///
/// ## Usage
///
/// ```swift
/// let data = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F]) // "Hello"
///
/// // Plain text
/// print(data.asString ?? "")
/// // "Hello"
///
/// // Compact hex
/// print(data.asHexStr)
/// // "48656C6C 6F"
///
/// // Formatted hex dump
/// print(data.asHexString)
/// // "48656C6C 6F Hello"
/// ```
extension Data {
	/// Returns a debug-friendly string representation of the data.
	///
	/// This property attempts to convert the data to a UTF-8 string first.
	/// If that fails (indicating the data is not valid text), it returns
	/// a formatted hexadecimal dump instead.
	///
	/// ```swift
	/// // Text data
	/// let textData = "Hello".data(using: .utf8)!
	/// print(textData.debugString)
	/// // "Hello"
	///
	/// // Binary data
	/// let binaryData = Data([0x00, 0x01, 0xFF, 0xFE])
	/// print(binaryData.debugString)
	/// // "0001FFFE .... (formatted hex)"
	/// ```
	///
	/// - Returns: A UTF-8 string if the data is valid text, otherwise a formatted
	///   hexadecimal representation.
	///
	/// - SeeAlso: ``asString`` for plain text conversion, ``asHexString`` for hex dumps.
	public var debugString: String {
		return self.asString ?? self.asHexString
	}

	/// Converts the data to a UTF-8 encoded string.
	///
	/// Use this property when you know the data represents text and want to
	/// convert it to a readable string.
	///
	/// ```swift
	/// let data = "Hello, World!".data(using: .utf8)!
	/// if let text = data.asString {
	///     print(text) // "Hello, World!"
	/// }
	///
	/// let invalidData = Data([0xFF, 0xFE]) // Invalid UTF-8
	/// print(invalidData.asString == nil) // true
	/// ```
	///
	/// - Returns: A UTF-8 string representation of the data, or `nil` if the data
	///   cannot be decoded as valid UTF-8.
	public var asString: String? {
		return String(data: self, encoding: .utf8)
	}

	/// Returns a compact hexadecimal string representation of the data.
	///
	/// This property formats the data as hexadecimal bytes with spaces every
	/// 4 bytes for improved readability. Unlike ``asHexString``, this format
	/// does not include ASCII representation.
	///
	/// ```swift
	/// let data = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64])
	/// print(data.asHexStr)
	/// // "48656C6C 6F20576F 726C64"
	/// ```
	///
	/// - Returns: A space-separated hexadecimal string with groups of 4 bytes.
	///
	/// - SeeAlso: ``asHexString`` for a hex dump with ASCII representation.
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

	/// Returns a formatted hexadecimal dump with ASCII representation.
	///
	/// This property creates a classic hex dump format showing both the hexadecimal
	/// bytes and their ASCII representation. Non-printable characters (outside the
	/// range 0x20-0x7E) are displayed as dots.
	///
	/// Each line shows 4 bytes in hex, followed by their ASCII representation:
	///
	/// ```swift
	/// let data = Data([
	///     0x48, 0x65, 0x6C, 0x6C,  // "Hell"
	///     0x6F, 0x20, 0x57, 0x6F,  // "o Wo"
	///     0x72, 0x6C, 0x64, 0x21,  // "rld!"
	///     0x00, 0xFF              // Non-printable
	/// ])
	///
	/// print(data.asHexString)
	/// // 48656C6C Hell
	/// // 6F20576F o Wo
	/// // 726C6421 rld!
	/// // 00FF     ..
	/// ```
	///
	/// - Returns: A multi-line string with hexadecimal bytes and ASCII representation,
	///   formatted in 4-byte groups.
	///
	/// - Note: Non-printable characters (< 0x20 or >= 0x7F) are displayed as dots (.).
	///
	/// - SeeAlso: ``asHexStr`` for compact hex without ASCII, ``debugString`` for automatic format selection.
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
