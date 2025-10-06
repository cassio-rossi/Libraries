# Getting Started with UIComponentsLibrarySpecial

Learn how to integrate and use iOS-specific UI components in your applications.

## Overview

UIComponentsLibrarySpecial is an iOS-only package that provides advanced UI components leveraging iOS-specific frameworks like Lottie, PDFKit, and WebKit. This library is distributed as a separate package to maintain cross-platform compatibility in the main Libraries package.

## Installation

### Adding the Package

UIComponentsLibrarySpecial is distributed separately from the main Libraries package:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0"),
    .package(path: "path/to/UIComponentsSpecial")
]
```

### Target Configuration

Add the library to your iOS target:

```swift
.target(
    name: "YourIOSApp",
    dependencies: [
        .product(name: "UIComponentsLibrarySpecial", package: "UIComponentsSpecial")
    ]
)
```

## Platform Requirements

- **iOS 18.0+** (Required)
- UIKit and SwiftUI
- External dependencies: Lottie, Kingfisher

## Basic Usage

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

## Architecture

### Monorepo Structure

UIComponentsLibrarySpecial is part of a monorepo structure:

```
KSLibrary/
├── Package.swift                    # Main cross-platform package
├── UIComponentsSpecial/
│   └── Package.swift                # iOS-only package
└── Sources/
    └── UIComponentsLibrarySpecial/  # Shared source directory
```

This structure allows:
- Cross-platform development without iOS-only dependencies
- Shared codebase for the special components
- Independent versioning and deployment

### Dependencies

The library depends on:
- **Main Libraries Package**: For Utilities and UIComponents
- **Lottie**: For animation playback
- **Kingfisher**: For image caching in avatars

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

## Best Practices

1. **Animation Assets**: Organize Lottie files in your asset catalog and conform to `LottieAssetProtocol`
2. **PDF Performance**: Use `PDFViewer` for small to medium documents; consider custom solutions for large PDFs
3. **Web Content**: Always handle loading states and errors when using `Webview`
4. **Review Requests**: Call `RequestReview.request()` sparingly and after positive user experiences
5. **Search Performance**: Debounce search text changes for better performance

## Next Steps

Explore the individual component documentation for detailed API references, advanced configuration options, and platform-specific considerations.
