import Foundation

extension OSStatus {
	var error: NSError? {
		guard self != errSecSuccess else { return nil }
		let message = SecCopyErrorMessageString(self, nil) as String? ?? "Unknown error"
		return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: [NSLocalizedDescriptionKey: message])
	}
}
