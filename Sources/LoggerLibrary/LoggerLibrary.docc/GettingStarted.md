# Getting Started with LoggerLibrary

Learn how to integrate and use LoggerLibrary for structured logging in your Swift projects.

## Overview

LoggerLibrary provides a flexible logging system with multiple log levels and filtering capabilities. It integrates seamlessly with Xcode's console and macOS Console.app for easy debugging and monitoring.

## Installation

Add LoggerLibrary to your project using Swift Package Manager:

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
        .product(name: "Logger", package: "Libraries")
    ]
)
```

## Basic Usage

### Creating a Logger

Initialize a logger with a category for easy identification:

```swift
import LoggerLibrary

let logger = Logger(category: "MyApp")
```

### Logging Messages

Use the appropriate log level for your message:

```swift
// Error messages (‼️)
logger.error("Failed to load user data")

// Warning messages (⚠️)
logger.warning("Low memory warning")

// Info messages (ℹ️)
logger.info("User logged in successfully")

// Debug messages (💬)
logger.debug("Current state: \(appState)")
```

### Filtering Logs

Control which files produce logs:

```swift
// Exclude specific files from logging
logger.setup(exclude: ["AppDelegate", "SceneDelegate"])

// Or include only specific files
logger.setup(include: ["NetworkManager", "DataController"])
```

### Enabling/Disabling Logging

Toggle logging at runtime:

```swift
// Disable all logging
logger.isLoggingEnabled = false

// Re-enable logging
logger.isLoggingEnabled = true
```

## Advanced Features

### Custom Categories

Override the default category for specific messages:

```swift
logger.info("Network request completed", category: "Networking")
logger.error("Database error", category: "Database")
```

### Subsystem Organization

Group logs by subsystem for better organization in Console.app:

```swift
let logger = Logger(
    category: "Authentication",
    subsystem: "com.myapp.auth"
)
```

### Custom Configuration

Configure truncation and file logging:

```swift
let config = Logger.Config(
    truncationLength: 2048,      // Max message length
    separator: "...",             // Truncation indicator
    filename: "app.log"          // Log file name
)

let logger = Logger(
    category: "MyApp",
    subsystem: "com.myapp",
    config: config
)
```

### Source Location Tracking

The logger automatically captures source information:

```swift
logger.info("User action performed")
// Output: ℹ️ [ViewController.swift:42 - viewDidLoad()] User action performed
```

## Console.app Integration

View your logs in macOS Console.app:

1. Open Console.app
2. Select your device or simulator
3. Filter by subsystem or category
4. Search for specific log messages

## Best Practices

### Use Appropriate Log Levels

- **Error**: Use for failures and exceptions
- **Warning**: Use for potential issues
- **Info**: Use for important events
- **Debug**: Use for detailed debugging information

### Category Organization

```swift
// Organize by feature
let authLogger = Logger(category: "Authentication")
let networkLogger = Logger(category: "Networking")
let dataLogger = Logger(category: "DataLayer")
```

### Performance Considerations

```swift
// Disable logging in production builds
#if DEBUG
logger.isLoggingEnabled = true
#else
logger.isLoggingEnabled = false
#endif
```

### Avoid Logging Sensitive Data

```swift
// ❌ Don't log passwords or tokens
logger.debug("Password: \(password)")

// ✅ Log sanitized information
logger.debug("Authentication attempt for user: \(username)")
```

## Example: Complete Setup

```swift
import LoggerLibrary

class AppLogger {
    static let shared = Logger(
        category: "MyApp",
        subsystem: "com.example.myapp"
    )

    static func configure() {
        #if DEBUG
        shared.isLoggingEnabled = true
        shared.setup(exclude: ["ThirdPartySDK"])
        #else
        shared.isLoggingEnabled = false
        #endif
    }
}

// In your app initialization
AppLogger.configure()

// Usage throughout your app
AppLogger.shared.info("App launched successfully")
AppLogger.shared.error("Failed to fetch data: \(error)")
```

## Next Steps

- Explore ``LoggerProtocol`` for custom logger implementations
- Check ``Logger/Config`` for configuration options
- Review ``Logger`` for the complete API
