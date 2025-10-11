# Getting Started with LoggerLibrary

Integrate structured logging into your Swift projects.

## Overview

LoggerLibrary provides flexible logging with multiple severity levels and file filtering.

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

```swift
import LoggerLibrary

let logger = Logger(category: "MyApp")
```

### Logging Messages

```swift
logger.error("Failed to load user data")
logger.warning("Low memory warning")
logger.info("User logged in")
logger.debug("Current state: \(appState)")
```

### Filtering Logs

```swift
logger.setup(exclude: ["AppDelegate", "SceneDelegate"])
logger.setup(include: ["NetworkManager", "DataController"])
```

## Advanced Features

### Custom Configuration

```swift
let config = Logger.Config(
    truncationLength: 2048,
    separator: "...",
    filename: "app.log"
)

let logger = Logger(
    category: "MyApp",
    subsystem: "com.myapp",
    config: config
)
```

### Category Override

```swift
logger.info("Network request completed", category: "Networking")
logger.error("Database error", category: "Database")
```

## Best Practices

### Disable in Production

```swift
#if DEBUG
logger.isLoggingEnabled = true
#else
logger.isLoggingEnabled = false
#endif
```

### Organize by Feature

```swift
let authLogger = Logger(category: "Authentication")
let networkLogger = Logger(category: "Networking")
let dataLogger = Logger(category: "DataLayer")
```

### Avoid Sensitive Data

```swift
// ❌ Don't log passwords or tokens
logger.debug("Password: \(password)")

// ✅ Log sanitized information
logger.debug("Authentication attempt for user: \(username)")
```

## Complete Example

```swift
import LoggerLibrary

class AppLogger {
    static let shared = Logger(category: "MyApp")

    static func configure() {
        #if DEBUG
        shared.isLoggingEnabled = true
        shared.setup(exclude: ["ThirdPartySDK"])
        #else
        shared.isLoggingEnabled = false
        #endif
    }
}

AppLogger.configure()
AppLogger.shared.info("App launched")
```
