# InAppLibrary

All you need to make InApp Purchases in your App.

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