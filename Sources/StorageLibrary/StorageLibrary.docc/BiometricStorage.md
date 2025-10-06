# Biometric Storage

Store cryptographic keys with Touch ID or Face ID authentication.

## Overview

Provides biometric-protected keychain storage for cryptographic keys requiring user authentication.

## Requirements

- Device with Touch ID, Face ID, or passcode
- Proper app entitlements

## Supported Key Types

P256 elliptic curve keys conforming to ``SecKeyConvertible``:
- `P256.Signing.PrivateKey`
- `P256.KeyAgreement.PrivateKey`

## Saving Keys

```swift
let storage = SecureStorage(service: "com.myapp.biometric")
let privateKey = P256.Signing.PrivateKey()
try storage.save(biometric: privateKey, key: "signingKey", accessControl: .biometryAny)
```

## Reading Keys

```swift
let context = LAContext()
context.localizedReason = "Authenticate to access your key"
let key: P256.Signing.PrivateKey = try storage.read(key: "signingKey", authenticationContext: context)
```

## Access Control Options

- `.userPresence` - Any authentication method
- `.biometryAny` - Biometric (allows new enrollments)
- `.biometryCurrentSet` - Biometric (invalidated if changed)

## Deleting Keys

```swift
try storage.delete(key: "signingKey", accessControl: .biometryAny)
```

## Error Handling

```swift
do {
    let key: P256.Signing.PrivateKey = try storage.read(key: "key", authenticationContext: context)
} catch KeychainError.itemNotFound {
    // Create new key
} catch KeychainError.userCancelled {
    // Handle cancellation
} catch KeychainError.biometricFailed {
    // Handle auth failure
}
```

## Best Practices

- Set meaningful `localizedReason` on `LAContext`
- Handle `userCancelled` errors gracefully
- Delete keys when no longer needed
- Provide clear error feedback to users

## Example

```swift
class KeyManager {
    private let storage = SecureStorage(service: "com.myapp.keys")

    func createKey() throws {
        let key = P256.Signing.PrivateKey()
        try storage.save(biometric: key, key: "signingKey", accessControl: .biometryAny)
    }

    func signData(_ data: Data) throws -> P256.Signing.ECDSASignature {
        let context = LAContext()
        context.localizedReason = "Sign transaction"
        let key: P256.Signing.PrivateKey = try storage.read(key: "signingKey", authenticationContext: context)
        return try key.signature(for: data)
    }
}
```

## See Also

- ``SecureStorage``
- ``SecKeyConvertible``
- ``KeychainError``
