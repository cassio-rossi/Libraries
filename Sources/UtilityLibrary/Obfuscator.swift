import Foundation

/// A utility class for obfuscating sensitive strings using XOR cipher encryption.
///
/// ``Obfuscator`` provides a simple way to obscure string values in your app's binary,
/// making them less visible to casual inspection. It uses a reversible XOR cipher with
/// a user-provided salt.
///
/// ## Overview
///
/// This class is useful for storing API keys, secrets, or other sensitive strings in your
/// code without leaving them in plain text. The obfuscation makes it harder for someone
/// inspecting your app's binary to find these values, though it should not be considered
/// cryptographically secure.
///
/// ## Usage
///
/// ```swift
/// // Initialize with a secret salt
/// let obfuscator = Obfuscator(with: "mySecretSalt123")
///
/// // Obfuscate a sensitive string at compile time
/// let apiKey = "sk_live_abc123xyz"
/// let obfuscated = obfuscator.bytesByObfuscatingString(string: apiKey)
/// // Store 'obfuscated' in your code
///
/// // At runtime, reveal the original string
/// let originalKey = obfuscator.reveal(key: obfuscated)
/// // Use originalKey for API calls
/// ```
///
/// ## Security Considerations
///
/// - **Not cryptographically secure**: This is obfuscation, not encryption
/// - **Defense in depth**: Use as one layer in a security strategy
/// - **Protect the salt**: Keep your salt value secure and unique
/// - **Runtime protection**: Combine with other security measures
///
/// ## Topics
///
/// ### Creating an Obfuscator
/// - ``init(with:)``
///
/// ### Obfuscating Strings
/// - ``bytesByObfuscatingString(string:)``
///
/// ### Revealing Strings
/// - ``reveal(key:)``
///
/// - Important: This obfuscation technique should not be used as the sole security measure
///   for highly sensitive data. It's designed to prevent casual discovery of strings in
///   compiled binaries, not to protect against determined attackers.
public final class Obfuscator {

    // MARK: - Variables

    /// The salt used to obfuscate and reveal the string.
    ///
    /// This salt is combined with the input string using XOR operations to produce
    /// the obfuscated output. The same salt must be used for both obfuscation and revelation.
    private var salt: String

    // MARK: - Initialization

    /// Creates a new obfuscator with the specified salt.
    ///
    /// The salt is used as the cipher key for XOR operations. Use a unique, hard-to-guess
    /// salt value for better obfuscation. The same salt must be used when revealing
    /// obfuscated strings.
    ///
    /// - Parameter salt: A string to use as the cipher key. Longer salts provide better obfuscation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let obfuscator = Obfuscator(with: "kZ9#mQ2$pL5!")
    /// ```
    ///
    /// - Important: Keep your salt value secret and don't hardcode it directly in version control.
    ///   Consider generating it programmatically or storing it securely.
    public init(with salt: String) {
        self.salt = salt
    }

    // MARK: - Instance Methods

    /// Obfuscates a string using XOR cipher with the configured salt.
    ///
    /// This method converts the input string to a byte array and applies XOR operations with
    /// the salt to produce an obfuscated byte array. The result can be stored in your code
    /// and later revealed using ``reveal(key:)``.
    ///
    /// - Parameter string: The string to obfuscate.
    /// - Returns: A byte array (`[UInt8]`) containing the obfuscated data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let obfuscator = Obfuscator(with: "mySalt")
    /// let apiKey = "secret-key-12345"
    /// let obfuscated = obfuscator.bytesByObfuscatingString(string: apiKey)
    /// // Store obfuscated array: [93, 28, 12, ...]
    /// ```
    ///
    /// - Note: The same salt must be used when revealing the obfuscated data. The obfuscation
    ///   is deterministic - the same input and salt will always produce the same output.
    ///
    /// - SeeAlso: ``reveal(key:)``
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

    /// Reveals the original string from an obfuscated byte array.
    ///
    /// This method reverses the obfuscation performed by ``bytesByObfuscatingString(string:)``
    /// using XOR operations with the configured salt. The salt must match the one used during
    /// obfuscation.
    ///
    /// - Parameter key: The obfuscated byte array to reveal. This should be the output from
    ///   ``bytesByObfuscatingString(string:)``.
    /// - Returns: The original string, or an empty string if the data cannot be decoded as UTF-8.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let obfuscator = Obfuscator(with: "mySalt")
    ///
    /// // Obfuscated data stored in code
    /// let obfuscatedKey: [UInt8] = [93, 28, 12, 30, 67, ...]
    ///
    /// // Reveal at runtime
    /// let apiKey = obfuscator.reveal(key: obfuscatedKey)
    /// // Use apiKey for API calls
    /// ```
    ///
    /// ## Error Handling
    ///
    /// If the revealed bytes cannot be decoded as a valid UTF-8 string, an empty string is returned.
    /// This can happen if:
    /// - The wrong salt was used
    /// - The byte array was corrupted
    /// - The byte array wasn't created by ``bytesByObfuscatingString(string:)``
    ///
    /// - Important: Always use the same salt for obfuscation and revelation. Using a different
    ///   salt will produce gibberish or invalid UTF-8 sequences.
    ///
    /// - SeeAlso: ``bytesByObfuscatingString(string:)``
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
