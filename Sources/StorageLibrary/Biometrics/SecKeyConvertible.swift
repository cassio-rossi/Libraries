import CryptoKit
import Foundation

/// A protocol for converting between CryptoKit keys and Security framework `SecKey` objects.
///
/// Enables conversion to and from X9.63 representation for keychain storage with biometric authentication.
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
/// - `P256.Signing.PrivateKey`
/// - `P256.KeyAgreement.PrivateKey`
public protocol SecKeyConvertible: CustomStringConvertible {
    /// Creates a key from its X9.63 representation.
    ///
    /// - Parameter x963Representation: The X9.63 representation of the key.
    ///
    /// - Throws: An error if the data is not a valid X9.63 representation.
    init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes

    /// The X9.63 representation of the key.
    ///
    /// - Important: Contains sensitive cryptographic material. Handle securely.
    var x963Representation: Data { get }
}

extension SecKeyConvertible {
    /// A safe string representation of the key.
    ///
    /// - Returns: Description showing the key size in bytes without exposing sensitive data.
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
