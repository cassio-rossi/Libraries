import SwiftUI

extension View {
    public func contentSize(onUpdate: @escaping (CGSize) -> Void) -> some View {
        modifier(ContentSizeModifier(onUpdate: onUpdate))
    }

    public func contentHeight(onUpdate: @escaping (CGFloat) -> Void) -> some View {
        modifier(
            ContentSizeModifier { size in
                onUpdate(size.height)
            }
        )
    }

    public func contentWidth(onUpdate: @escaping (CGFloat) -> Void) -> some View {
        modifier(
            ContentSizeModifier { size in
                onUpdate(size.width)
            }
        )
    }
}

private struct ContentSizeModifier: ViewModifier {
    let onUpdate: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { onUpdate(geo.size) }
                        .task(id: geo.size) {
                            onUpdate(geo.size)
                        }
                }
            )
    }
}
