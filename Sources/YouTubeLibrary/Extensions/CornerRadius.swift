import SwiftUI

public struct LibraryCorner: OptionSet, Sendable {
    public let rawValue: UInt

    static public let topLeft = LibraryCorner(rawValue: 1 << 0)
    static public let topRight = LibraryCorner(rawValue: 1 << 1)
    static public let bottomLeft = LibraryCorner(rawValue: 1 << 2)
    static public let bottomRight = LibraryCorner(rawValue: 1 << 3)
    static public let allCorners = LibraryCorner(rawValue: 1 << 4)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

#if canImport(UIKit)
    var toUIRectCorner: UIRectCorner {
        if self == .allCorners { return .allCorners }
        return UIRectCorner(rawValue: self.rawValue)
    }
#endif
}

extension View {
    public func cornerRadius(corners: LibraryCorner) -> some View {
        self.modifier(CornerRadius(corners: corners))
    }
}

#if canImport(UIKit)
public struct CornerRadius: ViewModifier {
    let corners: UIRectCorner

    public init(corners: LibraryCorner) {
        self.corners = corners.toUIRectCorner
    }

    public func body(content: Content) -> some View {
        content
            .cornerRadius(12, corners: corners)
    }
}
#else
public struct CornerRadius: ViewModifier {
    public init(corners: LibraryCorner) {}
    public func body(content: Content) -> some View {
        content.cornerRadius(12)
    }
}
#endif
