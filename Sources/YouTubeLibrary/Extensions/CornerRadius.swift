import SwiftUI

extension View {
    public func cornerRadius() -> some View {
        self.modifier(CornerRadius())
    }
}

public struct CornerRadius: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
#if canImport(UIKit)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
#endif
    }
}
