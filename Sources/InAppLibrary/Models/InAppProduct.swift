import Foundation
import StoreKit
import UtilityLibrary

// MARK: - Products -

/// Represents an in-app product, which can be a subscription or a one-time purchase.
/// This struct encapsulates the product's title, description, price, identifier, and subscription details.
/// It also provides methods to retrieve the expiration date for subscriptions.
public struct InAppProduct: Sendable, CustomDebugStringConvertible {
    public let title: String?
    public let description: String?
    public let price: String?
    public let identifier: String?
    public let subscription: String?
    let storeKitProduct: Product?

    /// Initializes a new instance of `InAppProduct`.
    /// - Parameters:
    /// - title: The localized title of the product.
    /// - description: The localized description of the product.
    /// - price: The localized price of the product.
    /// - identifier: The unique identifier for the product.
    /// - subscription: The subscription type or details, if applicable.
    /// - product: An optional `Product` instance representing the product in StoreKit 2.
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

    /// Returns the expiration date for the subscription product.
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
    /// Returns the localized price of the product.
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
    var toInAppProduct: InAppProduct {
        .init(title: self.displayName,
              description: self.description,
              price: self.displayPrice,
              identifier: self.id,
              subscription: "",
              storeKitProduct: self)
    }
}
