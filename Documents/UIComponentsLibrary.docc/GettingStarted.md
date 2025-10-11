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

### Lottie Animations

Display animated Lottie files with customizable playback:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

enum MyAnimations: String, LottieAssetProtocol {
    case loading
    case success
    case error

    var animationName: String { rawValue }
}

struct LoadingView: View {
    var body: some View {
        LottieView(
            asset: MyAnimations.loading,
            loopMode: .loop
        )
        .frame(width: 200, height: 200)
    }
}
```

### PDF Viewer

Display and interact with PDF documents:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct DocumentView: View {
    let pdfURL: URL

    var body: some View {
        PDFViewer(url: pdfURL)
            .navigationTitle("Document")
    }
}
```

### Web View

Embed web content with full WebKit functionality:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct WebContentView: View {
    @State private var isLoading = false

    var body: some View {
        Webview(
            url: URL(string: "https://example.com")!,
            isLoading: $isLoading
        )
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }
}
```

### Search Bar

Native iOS search bar with SwiftUI bindings:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        VStack {
            SearchBar(
                text: $searchText,
                placeholder: "Search items..."
            )

            List(filteredItems) { item in
                Text(item.name)
            }
        }
    }

    var filteredItems: [Item] {
        // Filter implementation
        []
    }
}
```

### Avatar View

Display user avatars with customizable styling:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct ProfileHeader: View {
    let user: User

    var body: some View {
        HStack {
            AvatarView(
                imageURL: user.avatarURL,
                size: 60,
                borderColor: .blue
            )

            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
            }
        }
    }
}
```

### Document Browser

Browse and select documents using iOS document picker:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct DocumentPickerView: View {
    @State private var showBrowser = false
    @State private var selectedURL: URL?

    var body: some View {
        VStack {
            Button("Select Document") {
                showBrowser = true
            }

            if let url = selectedURL {
                Text("Selected: \(url.lastPathComponent)")
            }
        }
        .sheet(isPresented: $showBrowser) {
            DocumentBrowser(
                allowedContentTypes: [.pdf, .plainText],
                onDocumentSelected: { url in
                    selectedURL = url
                    showBrowser = false
                }
            )
        }
    }
}
```

### Request App Review

Prompt users to review your app at the right moment:

```swift
import UIComponentsLibrarySpecial
import SwiftUI

struct CompletionView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Task Completed!")
                .font(.title)

            Button("Continue") {
                // Request review after positive experience
                RequestReview.request()
            }
        }
    }
}
```

## View Modifiers

### Device Rotation

Monitor and respond to device orientation changes:

```swift
.onDeviceRotation { orientation in
    print("Device rotated to: \(orientation)")
}
```

### Rounded Corners

Apply selective corner rounding:

```swift
Rectangle()
    .roundedCorner(radius: 16, corners: [.topLeft, .topRight])
```

### Screen Size

Access screen dimensions in your views:

```swift
.onAppear {
    print("Screen size: \(screenSize)")
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
