# Getting Started with UtilityLibrary

Integrate and use UtilityLibrary extensions in your Swift projects.

## Overview

UtilityLibrary extends standard Swift types to reduce boilerplate. Import the library to access all extensions.

## Installation

Add UtilityLibrary using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]

.target(
    name: "YourTarget",
    dependencies: [.product(name: "Utilities", package: "Libraries")]
)
```

## Usage

### String Extensions

```swift
import UtilityLibrary

// Date conversion
let date = "20/03/2024".toDate()
let dateTime = "20/03/2024 14:30".toDate(format: .dateTime)

// Base64 encoding
let encoded = "Hello".base64Encode  // "SGVsbG8sIFdvcmxkIQ=="
let decoded = encoded?.base64Decode  // "Hello"

// URL encoding
let formatted = "swift programming".webQueryFormatted
```

### Date Extensions

```swift
let date = Date()
let formatted = date.format(using: .dateOnly)  // "20/03/2024"
let dateTime = date.format(using: .dateTime)  // "20/03/2024 14:30"
let custom = date.format(using: "EEEE, MMM d, yyyy")
```

### Data Extensions

```swift
let data = Data([72, 101, 108, 108, 111])
let string = data.asString  // "Hello"
let hexDump = data.asHexString
```

### Bundle Extensions

```swift
let version = Bundle.version  // "1.0.0"
let build = Bundle.build  // "42"
let bundleId = Bundle.mainBundleIdentifier
```

### Obfuscator

```swift
let obfuscator = Obfuscator(with: "mySecretSalt")
let obfuscated = obfuscator.bytesByObfuscatingString(string: "secret-key")
let revealed = obfuscator.reveal(key: obfuscated)
```

### Codable Extensions

```swift
struct User: Encodable {
    let name: String
    let age: Int
}

let user = User(name: "John", age: 30)
let dict = user.asDictionary
let debug = user.debugString  // Pretty-printed JSON
```

## See Also

- ``Swift/String`` - String extensions
- ``Swift/Date`` and ``DateFormat`` - Date formatting
- ``Obfuscator`` - String obfuscation
- ``Swift/Data`` - Data utilities
