# Getting Started with AnalyticsLibrary

Integrate Firebase Analytics into your Swift projects with type-safe event tracking.

## Overview

AnalyticsLibrary provides a clean, type-safe interface for tracking user interactions and app events with Firebase Analytics.

## Installation

Add AnalyticsLibrary to your project using Swift Package Manager:

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
        .product(name: "Analytics", package: "Libraries")
    ]
)
```

## Firebase Setup

### 1. Configure Firebase

First, set up Firebase in your app. Add your `GoogleService-Info.plist` to your project and configure Firebase:

```swift
import FirebaseCore
import AnalyticsLibrary

@main
struct MyApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Create Analytics Manager

```swift
import AnalyticsLibrary

let analytics = AnalyticsManager()
```

## Basic Usage

### Tracking Screen Views

```swift
analytics.track(
    .screenView(current: "Home", previous: nil),
    providers: [.firebase]
)
```

### Tracking User Interactions

```swift
analytics.track(
    .buttonTap(id: "add_to_cart", screen: "ProductDetail"),
    providers: [.firebase]
)
```

### Tracking Purchases

```swift
// When purchase starts
analytics.track(
    .purchaseInitiated(productId: "premium_monthly", price: 9.99),
    providers: [.firebase]
)

// When purchase completes
analytics.track(
    .purchaseCompleted(transactionId: "TX123456", revenue: 9.99),
    providers: [.firebase]
)
```

### Tracking Errors

```swift
analytics.track(
    .error(code: "network", message: "Failed to connect", screen: "Home"),
    providers: [.firebase]
)
```

## SwiftUI Integration

### Automatic Screen Tracking

Use the `trackScreen` modifier to automatically log screen views:

```swift
import SwiftUI
import AnalyticsLibrary

struct ProductListView: View {
    @EnvironmentObject var analytics: AnalyticsManager

    var body: some View {
        List {
            // Your content
        }
        .trackScreen("product_list", previous: "home", analytics: analytics)
    }
}
```

### Tracking Button Taps

```swift
@EnvironmentObject var analytics: AnalyticsManager

Button("Add to Cart") {
    viewModel.addToCart()
}
.trackTap("add_to_cart_button", screen: "product_detail", analytics: analytics)
```

### Tracking Navigation

AnalyticsLibrary provides two convenient modifiers for tracking navigation in NavigationStack:

#### Method 1: Track Specific Destinations

Use `trackNavigation` to track navigation to specific destinations:

```swift
import SwiftUI
import AnalyticsLibrary

enum Destination: String {
    case profile = "Profile"
    case settings = "Settings"
}

struct ContentView: View {
    @EnvironmentObject var analytics: AnalyticsManager
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Profile", value: Destination.profile)
                NavigationLink("Settings", value: Destination.settings)
            }
            .navigationTitle("Home")
            .navigationDestination(for: Destination.self) { destination in
                DestinationView(destination: destination)
                    .trackNavigation(
                        value: destination,
                        origin: "Home",
                        destinationMapper: { $0.rawValue },
                        analytics: analytics,
                        providers: [.firebase]
                    )
            }
        }
    }
}
```

This logs events like:
```swift
.navigation(origin: "Home", destination: "Profile")
.navigation(origin: "Home", destination: "Settings")
```

#### Method 2: Track Navigation Depth

Use `trackNavigationPath` to track how deep users navigate in your stack:

```swift
@EnvironmentObject var analytics: AnalyticsManager
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    ContentView()
}
.trackNavigationPath(
    path: path,
    origin: "Home",
    analytics: analytics,
    providers: [.firebase]
)
```

This logs events based on navigation depth:
```swift
.navigation(origin: "Home", destination: "depth_1")
.navigation(origin: "Home", destination: "depth_2")
```

#### Combining Navigation Tracking

You can use both modifiers together for comprehensive tracking:

```swift
NavigationStack(path: $path) {
    MainView()
        .trackScreen("Main", analytics: analytics)
        .navigationDestination(for: Screen.self) { screen in
            ScreenView(screen: screen)
                .trackScreen(screen.rawValue, previous: "Main", analytics: analytics)
                .trackNavigation(
                    value: screen,
                    origin: "Main",
                    destinationMapper: { $0.rawValue },
                    analytics: analytics
                )
        }
}
.trackNavigationPath(path: path, origin: "Main", analytics: analytics)
```

## Available Events

### App Lifecycle

```swift
analytics.track(.app(.open), providers: [.firebase])
analytics.track(.app(.close), providers: [.firebase])
```

### Tutorial Progress

```swift
analytics.track(.tutorial(.begin), providers: [.firebase])
analytics.track(.tutorial(.complete), providers: [.firebase])
```

### User Authentication

```swift
analytics.track(
    .login(system: "google", success: true),
    providers: [.firebase]
)
```

### Navigation

Track navigation manually:

```swift
analytics.track(
    .navigation(origin: "Home", destination: "ProductDetail"),
    providers: [.firebase]
)
```

Or use the convenient SwiftUI modifiers (recommended):

```swift
// Track specific destinations
.trackNavigation(value: destination, origin: "Home", analytics: analytics)

// Track navigation depth
.trackNavigationPath(path: path, origin: "Home", analytics: analytics)
```

See [Tracking Navigation](#Tracking-Navigation) for detailed examples.

### Search

```swift
analytics.track(
    .searchPerformed(query: "running shoes", resultsCount: 42),
    providers: [.firebase]
)
```

### Item Selection

```swift
analytics.track(
    .itemSelected(itemId: "SKU123", itemType: "product", position: 5),
    providers: [.firebase]
)
```

### Form Submissions

```swift
analytics.track(
    .formSubmit(formName: "contact_form", success: true),
    providers: [.firebase]
)
```

## Session Tracking

Sessions are tracked automatically when the app becomes active or resigns active. The library manages:

- Session ID generation
- Event sequencing
- Session duration tracking
- Platform information

All events include these common parameters automatically:
- `session_id`: Unique identifier for the current session
- `event_sequence`: Sequential number for event ordering
- `timestamp`: ISO 8601 formatted timestamp
- `platform`: Always "iOS"

## Best Practices

### Use Descriptive IDs

```swift
// ✅ Good
analytics.track(.buttonTap(id: "checkout_button", screen: "cart"))

// ❌ Avoid
analytics.track(.buttonTap(id: "btn1", screen: "scr"))
```

### Track Meaningful Events

```swift
// ✅ Track important user actions
analytics.track(.purchaseCompleted(...))
analytics.track(.searchPerformed(...))

// ❌ Avoid tracking trivial events
// Don't track every minor UI interaction
```

### Enable Only in Production

```swift
#if DEBUG
let analytics = AnalyticsManager(isEnabled: false)
#else
let analytics = AnalyticsManager(isEnabled: true)
#endif
```

### Use Consistent Naming

```swift
// Use snake_case for consistency with Firebase
.screenView(current: "product_detail", previous: "product_list")
.buttonTap(id: "add_to_cart", screen: "product_detail")
```

## Advanced Configuration

### Custom Logger

Provide a custom logger for debugging:

```swift
import LoggerLibrary

let logger = Logger(category: "Analytics")
let analytics = AnalyticsManager(logger: logger)
```

### Multiple Providers

The architecture supports multiple analytics providers:

```swift
// Future support for additional providers
analytics.track(.screenView(name: "Home"), providers: [.firebase, .mixpanel])
```

## Complete Example

```swift
import SwiftUI
import FirebaseCore
import AnalyticsLibrary

@main
struct ShoppingApp: App {
    @StateObject private var analyticsManager = AnalyticsManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(analyticsManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var analytics: AnalyticsManager
    @State private var path = NavigationPath()

    enum Screen: String {
        case productList = "ProductList"
        case productDetail = "ProductDetail"
        case cart = "Cart"
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Products", value: Screen.productList)
                NavigationLink("Cart", value: Screen.cart)
            }
            .navigationTitle("Home")
            .trackScreen("home", analytics: analytics)
            .navigationDestination(for: Screen.self) { screen in
                destinationView(for: screen)
                    .trackNavigation(
                        value: screen,
                        origin: "Home",
                        destinationMapper: { $0.rawValue },
                        analytics: analytics
                    )
            }
        }
        .trackNavigationPath(path: path, origin: "Home", analytics: analytics)
    }

    @ViewBuilder
    func destinationView(for screen: Screen) -> some View {
        switch screen {
        case .productList:
            ProductListView()
        case .productDetail:
            ProductDetailView(product: Product(name: "iPhone"))
        case .cart:
            CartView()
        }
    }
}

struct ProductDetailView: View {
    @EnvironmentObject var analytics: AnalyticsManager
    let product: Product

    var body: some View {
        VStack {
            Text(product.name)
                .font(.largeTitle)

            Button("Add to Cart") {
                addToCart()
            }
            .trackTap("add_to_cart", screen: "product_detail", analytics: analytics)
        }
        .trackScreen("product_detail", previous: "product_list", analytics: analytics)
    }

    private func addToCart() {
        analytics.track(
            .buttonTap(buttonId: "add_to_cart", screen: "product_detail"),
            providers: [.firebase]
        )

        // Add to cart logic
    }
}

struct Product {
    let name: String
}

struct ProductListView: View {
    var body: some View {
        Text("Product List")
    }
}

struct CartView: View {
    var body: some View {
        Text("Shopping Cart")
    }
}
```

## Firebase Analytics Dashboard

After implementing AnalyticsLibrary, view your analytics in the Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to Analytics → Events
4. View real-time events and user engagement metrics

Events appear in Firebase within a few hours and in real-time debug view immediately when using a debug build.

## Troubleshooting

### Events Not Appearing

1. Verify Firebase is configured: `FirebaseApp.configure()`
2. Check `GoogleService-Info.plist` is in your project
3. Ensure analytics is enabled: `AnalyticsManager(isEnabled: true)`
4. Use Firebase DebugView for real-time verification

### Parameter Limits

Firebase enforces limits:
- Maximum 25 parameters per event
- Maximum 40 characters per parameter key
- Maximum 100 characters per string value

AnalyticsLibrary automatically sanitizes parameters to comply with these limits.
