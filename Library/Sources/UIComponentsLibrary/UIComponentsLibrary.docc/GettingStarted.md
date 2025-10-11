# Getting Started with UIComponents

Learn how to use the UIComponents library in your SwiftUI applications.

## Overview

UIComponents provides a set of commonly used SwiftUI views that work across all Apple platforms. The components are designed to be drop-in replacements for common UI patterns with enhanced functionality.

## Installation

Add UIComponents to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "UIComponents", package: "Libraries")
    ]
)
```

## Basic Usage

### Cached Async Images

Display remote images with automatic caching using Kingfisher:

```swift
import UIComponents
import SwiftUI

struct ProfileView: View {
    let avatarURL: URL

    var body: some View {
        CachedAsyncImage(
            url: avatarURL,
            placeholder: Image(systemName: "person.circle.fill")
        )
        .frame(width: 100, height: 100)
        .clipShape(Circle())
    }
}
```

### Circular Progress Indicators

Show determinate progress with a customizable circular indicator:

```swift
import UIComponents
import SwiftUI

struct DownloadView: View {
    @State private var progress: Double = 0.0

    var body: some View {
        VStack {
            CircularProgressView(
                progress: progress,
                lineWidth: 8,
                color: .blue
            )
            .frame(width: 120, height: 120)

            Text("\(Int(progress * 100))%")
                .font(.headline)
        }
    }
}
```

### Error Views

Display user-friendly error messages with retry functionality:

```swift
import UIComponents
import SwiftUI

struct ContentView: View {
    @State private var hasError = false

    var body: some View {
        if hasError {
            ErrorView(
                message: "Failed to load data",
                systemImage: "exclamationmark.triangle",
                retryAction: {
                    // Retry loading data
                    loadData()
                }
            )
        } else {
            // Normal content
        }
    }

    func loadData() {
        // Load data implementation
    }
}
```

## Platform Compatibility

All UIComponents work seamlessly across:
- iOS 18+
- macOS 15+
- watchOS 11+
- visionOS 2+

## Next Steps

Explore the individual component documentation to learn about all available customization options and advanced features.
