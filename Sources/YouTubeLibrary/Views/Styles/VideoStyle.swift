import SwiftUI

@MainActor
public protocol VideoStyle {
    associatedtype Content: View

    var fade: Bool { get }
    var position: TimePosition { get }

    @ViewBuilder
    func makeBody(data: VideoDB, width: CGFloat) -> Content
}
