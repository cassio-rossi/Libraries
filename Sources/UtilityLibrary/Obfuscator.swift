import Foundation

public final class Obfuscator {

    // MARK: - Variables

    /// The salt used to obfuscate and reveal the string.
    private var salt: String

    // MARK: - Initialization

    public init(with salt: String) {
        self.salt = salt
    }

    // MARK: - Instance Methods

    /**
     This method obfuscates the string passed in using the salt
     that was used when the Obfuscator was initialized.

     - parameter string: the string to obfuscate
     - returns: the obfuscated string in a byte array
     */
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

    /**
     This method reveals the original string from the obfuscated
     byte array passed in. The salt must be the same as the one
     used to encrypt it in the first place.

     - parameter key: the byte array to reveal
     - returns: the original string
     */
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
