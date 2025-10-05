# Getting Started with StorageLibrary

Learn how to integrate and use StorageLibrary in your iOS, macOS, watchOS, or visionOS app.

## Overview

StorageLibrary provides three main storage solutions:
- **DefaultStorage** for simple UserDefaults operations
- **SecureStorage** for secure Keychain operations
- **Cookies** for HTTP cookie management

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

Use `DefaultStorage` for simple key-value storage:

```swift
import StorageLibrary

// Initialize with standard UserDefaults
let storage = DefaultStorage(nil)

// Save data
storage.save(object: "John Doe", key: "userName")
storage.save(object: 25, key: "userAge")

// Retrieve data
if let name = storage.get(key: "userName") as? String {
    print("User name: \(name)")
}

// Delete data
storage.delete(key: "userName")
```

### Custom UserDefaults Suite

Create a storage instance with a custom suite name:

```swift
let storage = DefaultStorage("com.myapp.settings")

storage.save(object: true, key: "darkModeEnabled")
```

### Secure Keychain Storage

Use `SecureStorage` for sensitive data:

```swift
import StorageLibrary

let secureStorage = SecureStorage(service: "com.myapp.keychain")

// Save secure data
let token = Data("secret-api-token".utf8)
try secureStorage.save(token,
                       key: "apiToken",
                       synchronizable: false,
                       accessible: kSecAttrAccessibleAfterFirstUnlock)

// Retrieve secure data
let retrieved = try secureStorage.read(
    key: "apiToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleAfterFirstUnlock
)

// Delete secure data
try secureStorage.delete(
    key: "apiToken",
    synchronizable: false,
    accessible: kSecAttrAccessibleAfterFirstUnlock
)
```

### Cookie Management

Manage HTTP cookies easily:

```swift
import StorageLibrary

let storage = DefaultStorage("com.myapp.cookies")
let cookieManager = Cookies(storage: storage)

// Save cookies
let cookies = HTTPCookieStorage.shared.cookies ?? []
cookieManager.save(cookies: cookies)

// Restore cookies
let restoredCookies = cookieManager.restore()
for cookie in restoredCookies {
    HTTPCookieStorage.shared.setCookie(cookie)
}
```

## Next Steps

- Learn about <doc:BiometricStorage> for Touch ID/Face ID protected storage
- Explore ``SecureStorage`` for advanced keychain operations
- Check ``KeychainError`` for error handling patterns
