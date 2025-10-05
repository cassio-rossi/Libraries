import CryptoKit
import Foundation

/// A protocol that enables conversion between CryptoKit keys and Security framework `SecKey` objects.
///
/// This protocol provides the necessary interface for converting cryptographic keys to and from
/// the X9.63 representation format, which is required when storing keys in the keychain with
/// biometric authentication.
///
/// The X9.63 format is a standard way to represent elliptic curve cryptographic keys as byte sequences.
/// This format is compatible with both Apple's CryptoKit framework and the Security framework's
/// `SecKey` type, enabling seamless interoperability.
///
/// ## Overview
///
/// Types conforming to `SecKeyConvertible` can be:
/// - Converted to `SecKey` objects for storage in the keychain
/// - Reconstructed from keychain data back into their original CryptoKit form
/// - Safely logged without exposing sensitive key material
///
/// ## Topics
///
/// ### Creating Keys from Data
/// - ``init(x963Representation:)``
///
/// ### Accessing Key Representations
/// - ``x963Representation``
///
/// ### Conforming Types
/// CryptoKit's P256 private keys automatically conform to this protocol:
/// - `P256.Signing.PrivateKey`
/// - `P256.KeyAgreement.PrivateKey`
///
/// ## Example
///
/// ```swift
/// import CryptoKit
///
/// // Create a new signing key
/// let privateKey = P256.Signing.PrivateKey()
///
/// // Convert to X9.63 representation for storage
/// let keyData = privateKey.x963Representation
///
/// // Later, reconstruct the key from stored data
/// let restoredKey = try P256.Signing.PrivateKey(x963Representation: keyData)
/// ```
///
/// - Note: This protocol includes `CustomStringConvertible` to provide safe string representations
///   of keys that don't expose sensitive cryptographic material.
///
/// - SeeAlso: ``SecureStorage``
public protocol SecKeyConvertible: CustomStringConvertible {
    /// Creates a cryptographic key from its X9.63 representation.
    ///
    /// This initializer reconstructs a key from its binary X9.63 format, which is the standard
    /// representation used when storing elliptic curve keys in the keychain.
    ///
    /// - Parameter x963Representation: The X9.63 representation of the key as a contiguous byte sequence.
    ///
    /// - Throws: An error if the provided data is not a valid X9.63 representation or if the key
    ///   cannot be constructed from the given bytes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let storedKeyData: Data = // ... retrieved from keychain
    /// let privateKey = try P256.Signing.PrivateKey(x963Representation: storedKeyData)
    /// ```
    init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes

    /// The X9.63 representation of the cryptographic key.
    ///
    /// This property returns the key in X9.63 format, which is the standard binary representation
    /// for elliptic curve cryptographic keys. This format is suitable for:
    /// - Storage in the keychain
    /// - Transmission between systems
    /// - Conversion to `SecKey` objects
    ///
    /// - Returns: A `Data` object containing the X9.63 representation of the key.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let privateKey = P256.Signing.PrivateKey()
    /// let keyData = privateKey.x963Representation
    /// // Store keyData in keychain
    /// ```
    ///
    /// - Important: The returned data contains sensitive cryptographic material.
    ///   Handle it securely and avoid logging or transmitting it over insecure channels.
    var x963Representation: Data { get }
}

extension SecKeyConvertible {
    /// A string representation of the key that safely describes it without exposing sensitive data.
    ///
    /// This implementation provides a safe way to log or display key information for debugging
    /// purposes without revealing the actual cryptographic key material. It only indicates the
    /// size of the key representation in bytes.
    ///
    /// - Returns: A string describing the number of bytes in the key's X9.63 representation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let privateKey = P256.Signing.PrivateKey()
    /// print(privateKey) // Prints: "Key representation contains 32 bytes."
    /// ```
    ///
    /// - Important: Never log the actual key data using `x963Representation` directly.
    ///   Always use this `description` property for logging purposes.
    public var description: String {
        return self.x963Representation.withUnsafeBytes { bytes in
            return "Key representation contains \(bytes.count) bytes."
        }
    }
}

// Assert that the keys are convertible.
extension P256.Signing.PrivateKey: @retroactive CustomStringConvertible {}
extension P256.Signing.PrivateKey: SecKeyConvertible {}
extension P256.KeyAgreement.PrivateKey: @retroactive CustomStringConvertible {}
extension P256.KeyAgreement.PrivateKey: SecKeyConvertible {}
