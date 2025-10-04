[![Build Status](https://app.bitrise.io/app/a58275fc-4164-46e9-93c5-c70ca7acdd0f/status.svg?token=5EQ_0F2eKe6vxG7O47IvtQ&branch=main)]

# KSLibrary

This repository serves as a central location for hosting multiple Swift libraries. Each library is managed as a separate target and can be integrated independently into your projects.

## Structure

- Each library is included as a target in the Swift Package.
- Libraries are distributed as binary frameworks for easy integration.
- Every library has its own directory and a dedicated `README.md` file with specific usage instructions.

## Available Libraries

- **Logger**: A library for logging functionality.
- **Utilities**: A library with several extensions useful on our daily tasks.
- **InApp**: A library to handle InApp Purchases for within your App.
- **Storage**: A library with wrappers to storage systems like UserDefaults, Cookies and Keychain.

## Usage

To use a library, add this package to your `Package.swift` dependencies and specify the desired product.

Example:
```swift
.package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
```

## Library Documentation

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

# Utilities

A lightweight utility extension to improve your code readability.

## Features
- Obscurate data

### Extensions
- String
- Date
- Dictionary
- Bundle
- Data

# InAppLibrary

All you need to make InApp Purchases in your App.

## Features
- Check available products
- Purchase
- Restore
- Check previous purchases

## Usage

```swift
let inAppLibrary = InAppManager()

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

# Storage

Wrappers to help you managing storage as Cookies, UserDefaults, and Keychain.

## Features

- Methods to access the keychain
- Cookies
- UserDefaults

Feel free to contribute new libraries or improvements!

