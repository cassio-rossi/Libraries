# Getting Started with UtilityLibrary

Learn how to integrate and use UtilityLibrary extensions in your Swift projects.

## Overview

UtilityLibrary provides convenient extensions to standard Swift types, eliminating boilerplate code and improving readability. All extensions are available automatically when you import the library.

## Installation

Add UtilityLibrary to your project using Swift Package Manager:

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
        .product(name: "Utilities", package: "Libraries")
    ]
)
```

## Basic Usage

### String Extensions

#### Date Conversion

Convert strings to dates effortlessly:

```swift
import UtilityLibrary

let dateString = "20/03/2024"
let date = dateString.toDate()  // Uses default dd/MM/yyyy format

let sortedDate = "20240320".toDate(format: .sortedDate)  // yyyyMMdd
let dateTime = "20/03/2024 14:30".toDate(format: .dateTime)  // dd/MM/yyyy HH:mm
```

#### Base64 Encoding

```swift
let text = "Hello, World!"
let encoded = text.base64Encode  // "SGVsbG8sIFdvcmxkIQ=="
let decoded = encoded?.base64Decode  // "Hello, World!"
```

#### Web Formatting

```swift
let url = "https://example.com/search?q=iOS Development"
let formatted = url.webQueryFormatted  // Properly URL-encoded
```

### Date Extensions

Format dates with predefined formats:

```swift
import UtilityLibrary

let date = Date()

// Use predefined formats
let formatted = date.toString(format: .dateOnly)  // "20/03/2024"
let sortedFormat = date.toString(format: .sortedDate)  // "20240320"
let dateTime = date.toString(format: .dateTime)  // "20/03/2024 14:30"

// Custom format
let custom = date.toString(Format("EEEE, MMM d, yyyy"))  // "Wednesday, Mar 20, 2024"
```

### Data Extensions

Convert data to strings easily:

```swift
import UtilityLibrary

let data = Data([72, 101, 108, 108, 111])
let string = data.string  // "Hello"

// JSON conversion
let jsonString = data.jsonString  // Pretty-printed JSON string
```

### Dictionary Extensions

Safe access to dictionary values:

```swift
import UtilityLibrary

let dict = ["name": "John", "age": 30] as [String: Any]

// Safe string access
let name = dict.string(for: "name")  // Optional("John")
let missing = dict.string(for: "missing")  // nil

// Safe numeric access
let age = dict.int(for: "age")  // Optional(30)
```

### Bundle Extensions

Access bundle information easily:

```swift
import UtilityLibrary

// App version information
let version = Bundle.main.releaseVersion  // "1.0.0"
let build = Bundle.main.buildVersion  // "42"
```

### Obfuscator

Protect sensitive strings from casual inspection:

```swift
import UtilityLibrary

// Initialize with a salt
let obfuscator = Obfuscator(with: "mySecretSalt")

// Obfuscate a string
let apiKey = "secret-api-key-12345"
let obfuscated = obfuscator.bytesByObfuscatingString(string: apiKey)

// Later, reveal the original
let revealed = obfuscator.reveal(key: obfuscated)  // "secret-api-key-12345"
```

## Advanced Features

### Accessibility Strings

Generate accessibility-friendly date/time descriptions:

```swift
let dateTime = "15/06/2024 14:30"
let accessible = dateTime.accessibilityDateTime
// "15 de junho de 2024 às 14 horas e 30 minutos"
```

### Codable Extensions

Simplified JSON encoding/decoding:

```swift
struct User: Codable {
    let name: String
    let age: Int
}

let user = User(name: "John", age: 30)

// Encode to dictionary
let dict = try? user.dictionary()

// Encode to JSON data
let jsonData = try? user.jsonData()
```

## Next Steps

- Explore ``Swift/String`` for all string extensions
- Check ``Swift/Date`` and ``Format`` for date utilities
- Review ``Obfuscator`` for data protection strategies
- See ``Swift/Dictionary`` for collection utilities
