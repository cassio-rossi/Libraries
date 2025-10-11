# Getting Started with InAppLibrary

Learn how to integrate InAppLibrary for in-app purchases in your Swift projects.

## Overview

InAppLibrary provides a straightforward interface for implementing in-app purchases using StoreKit 2.

## Requirements

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / visionOS 1.0+
- Swift 5.5+
- StoreKit 2

## Installation

Add InAppLibrary using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]
```

Add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "InApp", package: "Libraries")
    ]
)
```

## App Store Connect Setup

Configure products in App Store Connect:

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create your products and note the product identifiers

## Basic Usage

### Initialize the Manager

```swift
import InAppLibrary
import Combine

class StoreManager: ObservableObject {
    let inAppManager = InAppManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        inAppManager.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleStatus($0) }
            .store(in: &cancellables)
    }
}
```

### Fetch Products

```swift
func loadProducts() async {
    do {
        let products = try await inAppManager.getProducts(for: [
            "com.myapp.premium",
            "com.myapp.monthly_subscription"
        ])
    } catch {
        print("Failed to load products: \(error)")
    }
}
```

### Purchase a Product

```swift
func purchaseProduct(_ product: InAppProduct) async {
    guard inAppManager.canPurchase else {
        showAlert("Purchases are not available")
        return
    }
    await inAppManager.purchase(product)
}
```

### Handle Status Updates

```swift
func handleStatus(_ status: InAppStatus) {
    switch status {
    case .purchased(let identifier):
        unlockFeature(for: identifier)
        showAlert("Purchase successful!")
    case .pending:
        showAlert("Purchase pending approval")
    case .cancelled:
        break
    case .error(let reason):
        showAlert("Purchase failed: \(reason.localizedDescription)")
    case .unknown:
        break
    }
}
```

### Restore Purchases

```swift
@IBAction func restorePurchasesButtonTapped(_ sender: UIButton) {
    Task {
        await inAppManager.restore()
    }
}
```

## SwiftUI Integration

```swift
import SwiftUI
import InAppLibrary

struct StoreView: View {
    @StateObject private var storeManager = StoreManager()
    @State private var products: [InAppProduct] = []

    var body: some View {
        List(products, id: \.identifier) { product in
            ProductRow(product: product) {
                Task {
                    await storeManager.inAppManager.purchase(product)
                }
            }
        }
        .task {
            await loadProducts()
        }
    }

    func loadProducts() async {
        products = (try? await storeManager.inAppManager.getProducts(
            for: ["com.myapp.premium"]
        )) ?? []
    }
}
```

## Error Handling

```swift
inAppManager.$status
    .sink { status in
        if case .error(let reason) = status {
            switch reason {
            case .failedVerification:
                print("Transaction verification failed")
            case .unknown(let message):
                print("Error: \(message)")
            }
        }
    }
    .store(in: &cancellables)
```

## Testing

### Local Testing

1. **File** → **New** → **File** → **StoreKit Configuration File**
2. Add products matching your identifiers
3. Enable StoreKit Testing in scheme settings
4. Test purchase flows locally

### Sandbox Testing

1. Create sandbox test accounts in App Store Connect
2. Sign in with sandbox account on device
3. Test real purchase flows
4. Verify receipt validation

## Best Practices

- Always check ``InAppManager/canPurchase`` before showing store UI
- Handle all ``InAppStatus`` cases in your status observer
- Provide a restore purchases button for users
- Use StoreKit Configuration files for local testing
- Test with sandbox accounts before release

## Next Steps

- Explore ``InAppManager`` for the complete API
- Review ``InAppProduct`` for product information
- Check ``InAppStatus`` for status handling details
