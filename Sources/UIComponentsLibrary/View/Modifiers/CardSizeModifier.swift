import SwiftUI

extension View {
    public func cardSize(onUpdate: @escaping (CGFloat) -> Void) -> some View {
        modifier(CardSizeModifier(onUpdate: onUpdate))
    }
}

private struct CardSizeModifier: ViewModifier {
    let onUpdate: (CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { onUpdate(geo.size.width) }
                        .onChange(of: geo.size) { _, newValue in
                            onUpdate(newValue.width)
                        }
                }
            )
    }
}
