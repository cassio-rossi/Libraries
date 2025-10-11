import Foundation
import StoreKit
import UtilityLibrary

// MARK: - Products -

/// A platform-independent representation of an in-app purchase product.
///
/// ``InAppProduct`` wraps StoreKit 2's `Product` type, providing localized pricing and product information.
/// Fetch products using ``InAppManager/getProducts(for:)`` and pass them to ``InAppManager/purchase(_:)`` to initiate purchases.
public struct InAppProduct: Sendable, CustomDebugStringConvertible {
    /// The localized display name of the product.
    public let title: String?

    /// The localized description of the product.
    public let description: String?

    /// The localized, formatted price string including currency symbol.
    public let price: String?

    /// The unique product identifier from App Store Connect.
    public let identifier: String?

    /// Subscription period information for subscription products.
    public let subscription: String?

    /// The underlying StoreKit 2 product used for purchase operations.
    let storeKitProduct: Product?

    /// Creates a new in-app product instance.
    ///
    /// - Parameters:
    ///   - title: The localized product name.
    ///   - description: The localized product description.
    ///   - price: The formatted price string.
    ///   - identifier: The product identifier.
    ///   - subscription: Subscription period information.
    ///   - storeKitProduct: The underlying StoreKit 2 product.
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
    /// Returns the current date plus the subscription period, or the current date for non-subscription products.
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

extension InAppProduct {
    /// A string representation of the product for debugging.
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

extension Product {
    /// Converts this StoreKit 2 product to an ``InAppProduct``.
    var toInAppProduct: InAppProduct {
        .init(title: self.displayName,
              description: self.description,
              price: self.displayPrice,
              identifier: self.id,
              subscription: "",
              storeKitProduct: self)
    }
}
