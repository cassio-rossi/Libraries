import Foundation

/// Extension for converting Security framework status codes to errors.
///
/// Provides convenient error handling for keychain operations.
///
/// ## Topics
///
/// ### Converting Status Codes to Errors
/// - ``error``
extension OSStatus {
	/// Converts a status code to an error.
	///
	/// - Returns: An `NSError` with localized description, or `nil` if the status indicates success.
	var error: NSError? {
		guard self != errSecSuccess else { return nil }
		let message = SecCopyErrorMessageString(self, nil) as String? ?? "Unknown error"
		return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: [NSLocalizedDescriptionKey: message])
	}
}
