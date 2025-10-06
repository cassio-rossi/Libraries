# Getting Started

Integrate and use StorageLibrary in your app.

## Overview

StorageLibrary provides three storage solutions: ``DefaultStorage`` for UserDefaults, ``SecureStorage`` for keychain operations, and ``Cookies`` for HTTP cookie management.

## Installation

Add StorageLibrary to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Storage", package: "Libraries")
    ]
)
```

## Basic Usage

### UserDefaults Storage

```swift
let storage = DefaultStorage(nil)
storage.save(object: "John Doe", key: "userName")
if let name = storage.get(key: "userName") as? String {
    print(name)
}
storage.delete(key: "userName")
```

### Secure Keychain Storage

```swift
let storage = SecureStorage(service: "com.myapp.keychain")
let token = Data("secret".utf8)
try storage.save(token, key: "apiToken", synchronizable: false, accessible: kSecAttrAccessibleWhenUnlocked)
let retrieved = try storage.read(key: "apiToken", synchronizable: false, accessible: kSecAttrAccessibleWhenUnlocked)
```

### Cookie Management

```swift
let storage = DefaultStorage("com.myapp.cookies")
let manager = Cookies(storage: storage)
manager.save(cookies: HTTPCookieStorage.shared.cookies ?? [])
let restored = manager.restore()
```

## Next Steps

- <doc:BiometricStorage> for Touch ID/Face ID protected storage
- ``SecureStorage`` for advanced keychain operations
- ``KeychainError`` for error handling
