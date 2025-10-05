import Foundation
import StoreKit
import UtilityLibrary

// MARK: - Products -

/// A platform-independent representation of an in-app purchase product.
///
/// ``InAppProduct`` wraps StoreKit 2's `Product` type, providing a simplified interface
/// for displaying product information to users and initiating purchases. It supports both
/// one-time purchases and auto-renewable subscriptions.
///
/// ## Overview
///
/// Products are fetched from the App Store using ``InAppManager/getProducts(for:)`` and
/// contain all the information needed to display a product in your store UI:
/// - Localized display name and description
/// - Formatted price in the user's currency
/// - Product identifier for purchase tracking
/// - Subscription period information (for subscriptions)
///
/// ## Example Usage
///
/// ```swift
/// // Fetch products
/// let products = try await inAppManager.getProducts(for: ["com.myapp.premium"])
///
/// // Display product information
/// if let product = products.first {
///     print("Name: \(product.displayName)")
///     print("Price: \(product.displayPrice)")
///     print("Description: \(product.description ?? "")")
///
///     // Initiate purchase
///     await inAppManager.purchase(product)
/// }
/// ```
///
/// ## Subscription Products
///
/// For subscription products, you can access the expiration date:
///
/// ```swift
/// if let product = products.first(where: { $0.subscription != nil }) {
///     let expirationDate = product.expirationDate
///     print("Subscription expires: \(expirationDate)")
/// }
/// ```
///
/// - Note: This struct is `Sendable`, making it safe to pass across concurrency boundaries.
public struct InAppProduct: Sendable, CustomDebugStringConvertible {
    /// The localized display name of the product.
    ///
    /// This is the name configured in App Store Connect, localized for the user's region.
    /// Use this for displaying the product in your UI.
    ///
    /// Example: "Premium Membership", "100 Coins Pack"
    public let title: String?

    /// The localized description of the product.
    ///
    /// This is the full product description configured in App Store Connect, localized
    /// for the user's region. Use this to provide detailed information about the product.
    ///
    /// Example: "Unlock all premium features with unlimited access"
    public let description: String?

    /// The localized, formatted price of the product.
    ///
    /// This string includes the currency symbol and is formatted according to the user's
    /// locale. Display this price directly in your UI.
    ///
    /// Example: "$4.99", "€3.99", "¥500"
    public let price: String?

    /// The unique product identifier.
    ///
    /// This identifier matches the product ID configured in App Store Connect.
    /// Use this to track which product was purchased and unlock the appropriate content.
    ///
    /// Example: "com.myapp.premium", "com.myapp.coins_100"
    public let identifier: String?

    /// Subscription period information, if this is a subscription product.
    ///
    /// For subscription products, this contains information about the billing period.
    /// For non-subscription products, this will be empty or `nil`.
    public let subscription: String?

    /// The underlying StoreKit 2 product.
    ///
    /// This property holds the original StoreKit `Product` instance, used internally
    /// for purchase operations. You typically won't need to access this directly.
    let storeKitProduct: Product?

    /// Creates a new in-app product instance.
    ///
    /// You typically won't create `InAppProduct` instances manually. Instead, use
    /// ``InAppManager/getProducts(for:)`` to fetch products from the App Store.
    ///
    /// - Parameters:
    ///   - title: The localized product name.
    ///   - description: The localized product description.
    ///   - price: The localized, formatted price string.
    ///   - identifier: The unique product identifier from App Store Connect.
    ///   - subscription: Subscription period information, if applicable.
    ///   - storeKitProduct: The underlying StoreKit 2 `Product` instance.
    public init(title: String?,
                description: String?,
                price: String?,
                identifier: String?,
                subscription: String?,
                storeKitProduct: Product? = nil) {
        self.title = title
        self.description = description
        self.price = price
        self.identifier = identifier
        self.subscription = subscription
        self.storeKitProduct = storeKitProduct
    }

    /// The calculated expiration date for subscription products.
    ///
    /// For subscription products, this property calculates when the subscription will
    /// expire based on the subscription period (day, week, month, or year). The date
    /// is calculated from the current date plus the subscription duration.
    ///
    /// For non-subscription products or if subscription information is unavailable,
    /// this returns the current date.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let product = // ... fetch subscription product
    /// let expirationDate = product.expirationDate
    ///
    /// if expirationDate > Date() {
    ///     print("Subscription active until: \(expirationDate)")
    /// } else {
    ///     print("Subscription expired")
    /// }
    /// ```
    ///
    /// - Returns: The date when the subscription will expire, or the current date
    ///   if this is not a subscription product.
    ///
    /// - Note: This calculates a future expiration date based on the subscription period.
    ///   For actual subscription status, check the transaction state in StoreKit.
    public var expirationDate: Date {
        guard let subscription = self.storeKitProduct?.subscription else {
            return Date()
        }

        var components = DateComponents()
        let value = subscription.subscriptionPeriod.value
        switch subscription.subscriptionPeriod.unit {
        case .day: components.day = value
        case .week: components.day = 7 * value
        case .month: components.month = value
        case .year: components.year = value
        @unknown default: break
        }

        return Calendar.current.date(byAdding: components, to: Date()) ?? Date()
    }
}

/// Extension for debug output support.
extension InAppProduct {
    /// A detailed string representation of the product for debugging purposes.
    ///
    /// This property provides a formatted string containing all product properties,
    /// useful for logging and debugging during development.
    ///
    /// ## Example Output
    ///
    /// ```
    /// InAppProduct(title: "Premium Membership", description: "Unlock all features",
    ///              price: "$4.99", identifier: "com.myapp.premium", subscription: "",
    ///              product: Product(...))
    /// ```
    public var debugDescription: String {
        var params = [String: String]()
        params["title"] = title
        params["description"] = description
        params["price"] = price
        params["identifier"] = identifier
        params["subscription"] = subscription
        params["product"] = storeKitProduct.debugDescription

        return "\(type(of: self))(" + params.debugString + ")"
    }
}

/// Extension for converting StoreKit products to InAppProduct instances.
extension Product {
    /// Converts a StoreKit 2 `Product` to an `InAppProduct`.
    ///
    /// This internal conversion method extracts the relevant properties from a StoreKit
    /// product and creates a platform-independent `InAppProduct` instance.
    ///
    /// - Returns: An `InAppProduct` representation of this StoreKit product.
    var toInAppProduct: InAppProduct {
        .init(title: self.displayName,
              description: self.description,
              price: self.displayPrice,
              identifier: self.id,
              subscription: "",
              storeKitProduct: self)
    }
}
