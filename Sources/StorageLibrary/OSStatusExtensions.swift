import Foundation

/// Extension providing convenient error handling for Security framework status codes.
///
/// This extension adds utility methods to `OSStatus` for converting Security framework status codes
/// into user-friendly `NSError` objects with localized error messages.
///
/// ## Overview
///
/// The Security framework uses `OSStatus` codes to indicate the result of operations. These numeric
/// codes can be difficult to interpret. This extension provides a simple way to convert status codes
/// into descriptive error objects.
///
/// ## Topics
///
/// ### Converting Status Codes to Errors
/// - ``error``
///
/// ## Example
///
/// ```swift
/// let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
/// if let error = status.error {
///     print("Keychain operation failed: \(error.localizedDescription)")
/// } else {
///     print("Operation succeeded")
/// }
/// ```
extension OSStatus {
	/// Converts a Security framework status code to an `NSError` if it represents a failure.
	///
	/// This property examines the status code and returns `nil` if it indicates success (`errSecSuccess`).
	/// For all other status codes, it creates an `NSError` with:
	/// - A localized description obtained from `SecCopyErrorMessageString`
	/// - The `NSOSStatusErrorDomain` domain
	/// - The original status code as the error code
	///
	/// - Returns: An `NSError` describing the failure, or `nil` if the status indicates success.
	///
	/// ## Example
	///
	/// ```swift
	/// let status: OSStatus = SecItemDelete(query as CFDictionary)
	/// if let error = status.error {
	///     // Handle the error
	///     throw error
	/// }
	/// // Success - item was deleted
	/// ```
	///
	/// ## Common Status Codes
	///
	/// Some frequently encountered `OSStatus` values include:
	/// - `errSecSuccess` (0): Operation completed successfully (returns `nil`)
	/// - `errSecItemNotFound` (-25300): The specified item could not be found
	/// - `errSecDuplicateItem` (-25299): The item already exists
	/// - `errSecAuthFailed` (-25293): Authentication or authorization failed
	/// - `errSecUserCanceled` (-128): User canceled the operation
	///
	/// - Note: If the Security framework doesn't provide a specific error message for a status code,
	///   the error will contain "Unknown error" as its localized description.
	///
	/// - SeeAlso: `SecCopyErrorMessageString(_:_:)` for the underlying message retrieval function.
	var error: NSError? {
		guard self != errSecSuccess else { return nil }
		let message = SecCopyErrorMessageString(self, nil) as String? ?? "Unknown error"
		return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: [NSLocalizedDescriptionKey: message])
	}
}
