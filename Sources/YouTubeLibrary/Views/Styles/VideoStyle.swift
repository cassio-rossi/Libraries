import SwiftUI

@MainActor
public protocol VideoStyle {
    associatedtype Content: View

    var fade: Bool { get }
    var position: TimePosition { get }
    var overlap: CGFloat { get }

    @ViewBuilder
    func makeBody(data: VideoDB) -> Content
}
