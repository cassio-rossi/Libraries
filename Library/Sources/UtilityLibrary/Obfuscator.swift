import Foundation

/// Obfuscates sensitive strings using XOR cipher.
///
/// Use ``Obfuscator`` to hide string values in your app's binary, making them less visible to casual inspection.
///
/// - Important: This is obfuscation, not encryption. Do not use as the sole security measure for highly sensitive data.
public final class Obfuscator {

    // MARK: - Variables

    /// The salt used for XOR operations.
    private var salt: String

    // MARK: - Initialization

    /// Creates an obfuscator with the specified salt.
    ///
    /// - Parameter salt: The cipher key for XOR operations.
    public init(with salt: String) {
        self.salt = salt
    }

    // MARK: - Instance Methods

    /// Obfuscates a string using XOR cipher.
    ///
    /// - Parameter string: The string to obfuscate.
    /// - Returns: A byte array containing the obfuscated data.
    func bytesByObfuscatingString(string: String) -> [UInt8] {
        let text = [UInt8](string.utf8)
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var encrypted = [UInt8]()

        for text in text.enumerated() {
            encrypted.append(text.element ^ cipher[text.offset % length])
        }

        return encrypted
    }

    /// Reveals the original string from obfuscated data.
    ///
    /// - Parameter key: The obfuscated byte array from ``bytesByObfuscatingString(string:)``.
    /// - Returns: The original string, or an empty string if decoding fails.
    public func reveal(key: [UInt8]) -> String {
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var decrypted = [UInt8]()

        for key in key.enumerated() {
            decrypted.append(key.element ^ cipher[key.offset % length])
        }

        guard let revealedString = String(bytes: decrypted, encoding: .utf8) else {
            return ""
        }
        return revealedString
    }

}
