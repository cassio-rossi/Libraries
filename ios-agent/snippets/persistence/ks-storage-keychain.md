# KSLibrary StorageLibrary — UserDefaults & Keychain

Import: `import StorageLibrary`

---

## DefaultStorage — UserDefaults wrapper

```swift
// Never use UserDefaults directly. Always use DefaultStorage.

let storage: Storage = DefaultStorage(nil)  // nil = UserDefaults.standard

// Save
storage.save(object: "alice@example.com", key: "userEmail")
storage.save(object: true, key: "hasCompletedOnboarding")
storage.save(object: 42, key: "loginCount")

// Read
let email = storage.get(key: "userEmail") as? String
let onboarded = storage.get(key: "hasCompletedOnboarding") as? Bool ?? false

// Delete
storage.delete(key: "userEmail")
```

**Suite name** (for App Groups):
```swift
let sharedStorage = DefaultStorage("group.com.example.app")
```

---

## Type-safe storage keys (DRY pattern)

```swift
// Core/Constants/StorageKeys.swift
enum StorageKeys {
    static let userEmail = "userEmail"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let lastSyncDate = "lastSyncDate"
    static let preferredLanguage = "preferredLanguage"
}

// Usage
storage.save(object: email, key: StorageKeys.userEmail)
let email = storage.get(key: StorageKeys.userEmail) as? String
```

---

## SecureStorage — Keychain wrapper

```swift
// For secrets: tokens, passwords, biometric-protected data.
// NEVER store secrets in DefaultStorage (UserDefaults).

let secureStorage = SecureStorage(service: Bundle.main.bundleIdentifier)

// Save
let tokenData = accessToken.data(using: .utf8)!
try secureStorage.save(
    tokenData,
    key: "accessToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
)

// Read
let data = try secureStorage.read(
    key: "accessToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
)
let token = String(data: data, encoding: .utf8)

// Delete
try secureStorage.delete(
    key: "accessToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
)

// Update
try secureStorage.update(
    newTokenData,
    key: "accessToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
)
```

---

## Keychain accessibility options (choose appropriately)

| Constant | When accessible |
|---|---|
| `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | App in foreground, device unlocked. **Preferred for most tokens.** |
| `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | After first unlock post-boot. Good for background refresh tokens. |
| `kSecAttrAccessibleWhenUnlocked` | Unlocked, syncs via iCloud Keychain. |
| `kSecAttrAccessibleAlways` | Any time (deprecated in iOS 12, avoid). |

---

## Keychain error handling

```swift
do {
    let data = try secureStorage.read(
        key: "accessToken",
        synchronizable: false,
        accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    )
    return String(data: data, encoding: .utf8)
} catch KeychainError.itemNotFound {
    return nil  // First launch — token doesn't exist yet
} catch KeychainError.userCancelled {
    throw AppError.authCancelled
} catch {
    throw AppError.keychainFailure(error)
}
```

---

## Biometric storage (SecureStorage+Biometrics)

```swift
import StorageLibrary

// Save with Face ID / Touch ID protection
let bioStorage = SecureStorage(service: "com.example.app.bio")

// Uses SecAccessControlCreateWithFlags with .biometryCurrentSet
try bioStorage.saveBiometric(
    data: sensitiveData,
    key: "biometricProtectedKey",
    reason: "Authenticate to access your secure data"
)

let data = try await bioStorage.readBiometric(
    key: "biometricProtectedKey",
    reason: "Confirm your identity"
)
```
