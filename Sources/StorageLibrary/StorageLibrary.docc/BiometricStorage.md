# Biometric Storage

Secure your sensitive data with Touch ID or Face ID authentication.

## Overview

StorageLibrary provides biometric-protected storage using the keychain's built-in authentication capabilities. This allows you to store cryptographic keys that require user authentication (Touch ID, Face ID, or device passcode) to access.

## Requirements

- Device with Touch ID, Face ID, or passcode enabled
- Proper entitlements configured in your app

## Supported Key Types

The biometric storage supports P256 (NIST P-256) elliptic curve keys:
- `P256.Signing.PrivateKey` - For digital signatures
- `P256.KeyAgreement.PrivateKey` - For key exchange protocols

Both key types conform to the ``SecKeyConvertible`` protocol.

## Saving a Biometric-Protected Key

```swift
import CryptoKit
import LocalAuthentication
import StorageLibrary

let secureStorage = SecureStorage(service: "com.myapp.biometric")

// Generate a private key
let privateKey = P256.Signing.PrivateKey()

// Save with biometric protection
try secureStorage.save(
    biometric: privateKey,
    key: "userSigningKey",
    accessControl: .biometryAny
)
```

## Reading a Biometric-Protected Key

```swift
import LocalAuthentication

let context = LAContext()
context.localizedReason = "Authenticate to access your signing key"

do {
    let retrievedKey: P256.Signing.PrivateKey = try secureStorage.read(
        key: "userSigningKey",
        authenticationContext: context,
        accessControl: .biometryAny
    )

    // Use the key for signing
    let signature = try retrievedKey.signature(for: data)
} catch KeychainError.userCancelled {
    print("User cancelled authentication")
} catch KeychainError.biometricFailed {
    print("Biometric authentication failed")
} catch {
    print("Error: \(error)")
}
```

## Access Control Options

Choose the appropriate access control for your security needs:

- `.userPresence` - Requires any authentication (Touch ID, Face ID, or passcode)
- `.biometryAny` - Requires Touch ID or Face ID (allows new enrollments)
- `.biometryCurrentSet` - Requires Touch ID or Face ID (invalidated if biometrics change)

```swift
// Require current biometric enrollment
try secureStorage.save(
    biometric: privateKey,
    key: "sensitiveKey",
    accessControl: .biometryCurrentSet
)
```

## Deleting a Biometric-Protected Key

```swift
try secureStorage.delete(
    key: "userSigningKey",
    accessControl: .biometryAny
)
```

## Error Handling

Handle biometric-specific errors appropriately:

```swift
do {
    let key: P256.Signing.PrivateKey = try secureStorage.read(
        key: "userSigningKey",
        authenticationContext: context,
        accessControl: .biometryAny
    )
} catch KeychainError.itemNotFound {
    // Key doesn't exist, create a new one
} catch KeychainError.userCancelled {
    // User cancelled the authentication prompt
} catch KeychainError.biometricFailed {
    // Biometric authentication failed (no biometrics enrolled, etc.)
} catch {
    // Other errors
}
```

## Best Practices

1. **Provide Clear Prompts**: Set meaningful `localizedReason` on `LAContext`
2. **Handle Cancellation**: Always handle `userCancelled` errors gracefully
3. **Fallback Options**: Consider providing alternative authentication methods
4. **Key Lifecycle**: Delete keys when they're no longer needed
5. **Error Feedback**: Provide clear error messages to users

## Example: Complete Biometric Authentication Flow

```swift
import CryptoKit
import LocalAuthentication
import StorageLibrary

class BiometricKeyManager {
    private let storage = SecureStorage(service: "com.myapp.keys")
    private let keyIdentifier = "userSigningKey"

    func createKey() throws {
        let privateKey = P256.Signing.PrivateKey()
        try storage.save(
            biometric: privateKey,
            key: keyIdentifier,
            accessControl: .biometryAny
        )
    }

    func signData(_ data: Data) async throws -> P256.Signing.ECDSASignature {
        let context = LAContext()
        context.localizedReason = "Sign the transaction"

        let key: P256.Signing.PrivateKey = try storage.read(
            key: keyIdentifier,
            authenticationContext: context,
            accessControl: .biometryAny
        )

        return try key.signature(for: data)
    }

    func deleteKey() throws {
        try storage.delete(
            key: keyIdentifier,
            accessControl: .biometryAny
        )
    }
}
```

## See Also

- ``SecureStorage``
- ``SecKeyConvertible``
- ``KeychainError``
