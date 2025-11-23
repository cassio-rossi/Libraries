import SwiftUI

extension View {
    func limitTo(width: CGFloat) -> some View {
        self.modifier(LimitToWidthModifier(width: width))
    }
}

struct LimitToWidthModifier: ViewModifier {
    let width: CGFloat

    func body(content: Content) -> some View {
        if width != .infinity {
            content.frame(width: width)
        } else {
            content
        }
    }
}
