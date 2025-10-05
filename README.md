![Build Status](https://app.bitrise.io/app/a58275fc-4164-46e9-93c5-c70ca7acdd0f/status.svg?token=5EQ_0F2eKe6vxG7O47IvtQ&branch=main)

# KSLibrary

A comprehensive collection of Swift libraries for iOS, macOS, watchOS, and visionOS development, providing essential functionality for modern Apple platform applications.

## 📦 Available Libraries

### [Logger](Sources/LoggerLibrary/LoggerLibrary.docc/LoggerLibrary.md)
Structured logging with multiple levels, category-based filtering, and Console.app integration.
- **[Getting Started](Sources/LoggerLibrary/LoggerLibrary.docc/GettingStarted.md)** - Quick start guide with examples
- Multiple log levels (error, warning, info, debug) with emoji indicators
- File filtering and source location tracking
- Real-time enable/disable control

### [Utilities](Sources/UtilityLibrary/UtilityLibrary.docc/UtilityLibrary.md)
Convenient extensions for common Swift types and data obfuscation utilities.
- **[Getting Started](Sources/UtilityLibrary/UtilityLibrary.docc/GettingStarted.md)** - Usage examples and best practices
- String, Date, Data, Dictionary, and Bundle extensions
- Obfuscator for sensitive data protection
- Codable utilities for JSON handling

### [Storage](Sources/StorageLibrary/StorageLibrary.docc/StorageLibrary.md)
Type-safe wrappers for UserDefaults, Keychain, and HTTP Cookies.
- **[Getting Started](Sources/StorageLibrary/StorageLibrary.docc/GettingStarted.md)** - Installation and basic usage
- **[Biometric Storage](Sources/StorageLibrary/StorageLibrary.docc/BiometricStorage.md)** - Secure storage with Touch ID/Face ID
- Keychain with biometric authentication support
- Persistent cookie management

### [InApp](Sources/InAppLibrary/InAppLibrary.docc/InAppLibrary.md)
StoreKit 2 wrapper for in-app purchases and subscriptions.
- **[Getting Started](Sources/InAppLibrary/InAppLibrary.docc/GettingStarted.md)** - Complete purchase flow guide
- Async/await API with Combine status updates
- Automatic transaction verification
- Purchase restoration support

### [Network](Sources/NetworkLibrary/NetworkLibrary.docc/NetworkLibrary.md)
Modern async/await networking layer with mocking and environment support.
- **[Getting Started](Sources/NetworkLibrary/NetworkLibrary.docc/GettingStarted.md)** - Environment setup and usage
- Protocol-oriented with dependency injection
- Built-in mocking for testing
- Comprehensive error handling

## 🚀 Installation

Add KSLibrary to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]
```

Then add the specific libraries you need to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Logger", package: "Libraries"),
        .product(name: "Utilities", package: "Libraries"),
        .product(name: "Storage", package: "Libraries"),
        .product(name: "InApp", package: "Libraries"),
        .product(name: "Network", package: "Libraries")
    ]
)
```

## 📖 Quick Examples

### Logger
```swift
import LoggerLibrary

let logger = Logger(category: "MyApp")
logger.info("User logged in successfully")
logger.error("Failed to fetch data: \(error)")
```

### Utilities
```swift
import UtilityLibrary

let dateString = "20/03/2024"
let date = dateString.toDate()
let formatted = Date().toString(format: .dateOnly)
```

### Storage
```swift
import StorageLibrary

let storage = DefaultStorage()
storage.save("John Doe", for: "username")
let name: String? = storage.read(for: "username")
```

### InApp
```swift
import InAppLibrary

let inAppManager = InAppManager()
let products = try await inAppManager.getProducts(for: ["com.myapp.premium"])
await inAppManager.purchase(products.first!)
```

### Network
```swift
import NetworkLibrary

let network = NetworkAPI()
let host = CustomHost(host: "api.example.com", path: "/v1")
let endpoint = Endpoint(customHost: host, api: "/users")
let data = try await network.get(url: endpoint.url)
```

## 📚 Documentation

Each library includes comprehensive DocC documentation with:
- Detailed API reference
- Getting started guides
- Usage examples
- Best practices
- Troubleshooting tips

Click on any library name above to access its documentation.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## 📄 License

See the LICENSE file for details.
