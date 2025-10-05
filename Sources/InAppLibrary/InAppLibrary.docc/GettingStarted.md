# Getting Started with InAppLibrary

Learn how to integrate and use InAppLibrary for in-app purchases in your Swift projects.

## Overview

InAppLibrary provides a straightforward interface for implementing in-app purchases using StoreKit 2. It handles product fetching, purchase flows, transaction verification, and purchase restoration with a modern async/await API.

## Installation

Add InAppLibrary to your project using Swift Package Manager:

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
        .product(name: "InApp", package: "Libraries")
    ]
)
```

## Requirements

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / visionOS 1.0+
- Swift 5.5+
- StoreKit 2

## App Store Connect Setup

Before using InAppLibrary, ensure your products are configured in App Store Connect:

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create your products (subscriptions, consumables, non-consumables)
5. Note the product identifiers for use in your code

## Basic Setup

### Creating the Manager

Initialize InAppManager in your app or view model:

```swift
import InAppLibrary
import Combine

class StoreManager: ObservableObject {
    let inAppManager = InAppManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        observePurchaseStatus()
    }

    private func observePurchaseStatus() {
        inAppManager.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatus(status)
            }
            .store(in: &cancellables)
    }
}
```

### Fetching Products

Retrieve product information from the App Store:

```swift
func loadProducts() async {
    let productIdentifiers = [
        "com.myapp.premium",
        "com.myapp.coins_100",
        "com.myapp.monthly_subscription"
    ]

    do {
        let products = try await inAppManager.getProducts(for: productIdentifiers)

        for product in products {
            print("Product: \(product.displayName)")
            print("Price: \(product.displayPrice)")
            print("Description: \(product.description ?? "")")
        }
    } catch {
        print("Failed to load products: \(error)")
    }
}
```

### Making a Purchase

Initiate a purchase for a selected product:

```swift
func purchaseProduct(_ product: InAppProduct) async {
    // Check if purchases are allowed
    guard inAppManager.canPurchase else {
        showAlert("Purchases are not available")
        return
    }

    // Initiate the purchase
    await inAppManager.purchase(product)

    // Status updates will be delivered via the status publisher
}
```

### Handling Purchase Status

Respond to purchase status changes:

```swift
func handleStatus(_ status: InAppStatus) {
    switch status {
    case .purchased(let identifier):
        // Purchase succeeded
        unlockFeature(for: identifier)
        showAlert("Purchase successful!")

    case .pending:
        // Purchase pending (e.g., Ask to Buy)
        showAlert("Purchase pending approval")

    case .cancelled:
        // User cancelled
        print("Purchase cancelled by user")

    case .error(let reason):
        // Purchase failed
        showAlert("Purchase failed: \(reason.localizedDescription)")

    case .unknown:
        // Initial or indeterminate state
        break
    }
}
```

## Advanced Usage

### Restoring Purchases

Implement a restore purchases button:

```swift
@IBAction func restorePurchasesButtonTapped(_ sender: UIButton) {
    Task {
        await inAppManager.restore()

        // Status updates will indicate restored purchases
        // Handle them in your status observer
    }
}
```

### Subscription Management

Check subscription expiration dates:

```swift
func checkSubscriptionExpiration(for product: InAppProduct) {
    let expirationDate = product.expirationDate

    if expirationDate > Date() {
        print("Subscription active until: \(expirationDate)")
    } else {
        print("Subscription expired")
    }
}
```

### SwiftUI Integration

Use InAppManager in SwiftUI views:

```swift
import SwiftUI
import InAppLibrary

struct StoreView: View {
    @StateObject private var storeManager = StoreManager()
    @State private var products: [InAppProduct] = []
    @State private var isPurchasing = false

    var body: some View {
        List(products, id: \.identifier) { product in
            ProductRow(product: product) {
                Task {
                    isPurchasing = true
                    await storeManager.inAppManager.purchase(product)
                }
            }
        }
        .task {
            await loadProducts()
        }
        .alert("Purchase Status", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    func loadProducts() async {
        let ids = ["com.myapp.premium"]
        products = (try? await storeManager.inAppManager.getProducts(for: ids)) ?? []
    }
}
```

## Error Handling

InAppLibrary provides comprehensive error information:

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

## Best Practices

### Check Purchase Capability

Always verify purchases are available before showing store UI:

```swift
if inAppManager.canPurchase {
    // Show store interface
} else {
    // Show appropriate message
    showAlert("Purchases are disabled on this device")
}
```

### Handle All Status Cases

Ensure you handle all possible status values:

```swift
func handleStatus(_ status: InAppStatus) {
    switch status {
    case .purchased(let identifier):
        // Unlock content
    case .pending:
        // Show pending indicator
    case .cancelled:
        // Clear purchase UI
    case .error(let reason):
        // Show error to user
    case .unknown:
        // Reset to initial state
    }
}
```

### Test with StoreKit Configuration

Use Xcode's StoreKit configuration file for testing:

1. Create a StoreKit Configuration file in Xcode
2. Add test products matching your App Store Connect setup
3. Run your app with the configuration file active
4. Test purchase flows without real transactions

### Provide Purchase Restoration

Always offer a way to restore purchases:

```swift
Button("Restore Purchases") {
    Task {
        await inAppManager.restore()
    }
}
```

## Testing

### Local Testing

Use StoreKit Testing in Xcode:

1. **File** → **New** → **File** → **StoreKit Configuration File**
2. Add products matching your identifiers
3. Enable StoreKit Testing in scheme settings
4. Test purchase flows locally

### Sandbox Testing

Test with real Apple IDs in sandbox mode:

1. Create sandbox test accounts in App Store Connect
2. Sign in with sandbox account on device
3. Test real purchase flows
4. Verify receipt validation

## Troubleshooting

### Products Not Loading

- Verify product identifiers match App Store Connect exactly
- Ensure products are approved and available
- Check that products are available in your test region
- Confirm agreement and banking information in App Store Connect

### Purchases Not Completing

- Check network connectivity
- Verify StoreKit configuration is correct
- Ensure sandbox test account is signed in (for testing)
- Review system console for StoreKit errors

### Verification Failures

- Confirm your app is properly signed
- Verify bundle identifier matches App Store Connect
- Check that StoreKit Testing configuration is correct
- Ensure you're testing on a real device for production testing

## Next Steps

- Explore ``InAppManager`` for the complete API
- Review ``InAppProduct`` for product information
- Check ``InAppStatus`` for status handling details
