# UtilityLibrary

A lightweight set of utilities to expited your development.

## Requirements

- Xcode 26.0+
- Swift 6.0+
- iOS 18.0+
- watchOS 11.0+
- visionOS 2.0+
- macOS 15.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]
```

# UtilityLibrary

A lightweight utility extension to improve your code readability.

## Features

### Extensions
- String
- Date
- Dictionary

# LoggerLibrary

A lightweight logging system for applications that provides structured logging to both Xcode console and Console.app.

## Features

### Logging System
- Multiple log levels (error, warning, info, debug)
- Category-based logging
- File filtering (include/exclude specific files)
- Source file, method, and line number tracking
- Support for Console.app integration
- Enable/disable logging at runtime

## Usage

### Basic

```swift
let logger = Logger(category: "MyApp")

// Configure which files to include/exclude from logging
logger.setup(include: nil,
             exclude: ["AppDelegate", "SceneDelegate"])
```

### Logging Messages

```swift
// Log different types of messages
logger.info("User logged in successfully")
logger.error("Failed to load data")
logger.debug("Current value: \(someVariable)")
logger.warning("Low memory warning")

// Log with custom category
logger.info("Network request completed", category: "Networking")
```

### Control Logging

```swift
// Enable/disable logging
logger.isLoggingEnabled = true  // Enable logging
logger.isLoggingEnabled = false // Disable logging
```

### Custom Setup

```swift
final class MyCustomLogger: LoggerProtocol {
    // Implement protocol requirements
}

let logger = MyCustomLogger(category: "MyApp")
```

## Protocol Requirements

### Properties

- isLoggingEnabled: Bool - Controls whether logging is active.

### Methods

- func setup(include: [String]?, exclude: [String]?) - configure which files to include or exclude from logging.
- @discardableResult func error(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
- @discardableResult func warning(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
- @discardableResult func info(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
- @discardableResult func debug(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

# InAppLibrary

All you need to make InApp Purchases in your App.

## Features
- Check available products
- Purchase
- Restore
- Check previous purchases

## Usage

```swift
let inAppLibrary = InAppLibrary()

// Add a listener for purchase status
Task.detached {
    await self.inAppLibrary.$status
    .receive(on: RunLoop.main)
    .sink { status in
        // Check status and handle purchase
        ...
    }
    .store(in: &self.cancellables)
}

// Check if purchases are allowed
if inAppLibrary.canPurchase {
    // Fetch products
    let products = try await inAppLibrary.getProducts(for: ["com.example.product1", "com.example.product2"])
    // Purchase products
    await inAppLibrary.purchase(products[0])
} else {
    // Handle case where purchases are not allowed
}
```
