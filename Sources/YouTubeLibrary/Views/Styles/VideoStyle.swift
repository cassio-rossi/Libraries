import SwiftUI

@MainActor
public protocol VideoStyle {
    associatedtype Content: View

    @ViewBuilder
    func makeBody(data: VideoDB, width: CGFloat) -> Content
}
