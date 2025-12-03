import SwiftUI

extension View {
    /// Presents a custom full-screen cover with configurable transition and background color.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the cover is shown.
    ///   - transition: The transition animation to use. Default is .opacity.
    ///   - color: Optional background color for the cover.
    ///   - content: A closure that returns the content to display in the cover.
    /// - Returns: A view with the full-screen cover applied.
    public func customFullScreenCover<Content>(isPresented: Binding<Bool>,
                                               transition: AnyTransition = .opacity,
                                               color: Color? = nil,
                                               content: @escaping () -> Content) -> some View where Content: View {
        ZStack {
            self

            ZStack { // for correct work of transition animation
                if isPresented.wrappedValue {
                    FullScreenCover(isPresented: isPresented, color: color, content: content)
                        .transition(transition)
                }
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var dismiss: Dismiss = Dismiss()
}

struct FullScreenCover<Content: View>: View {
    @Binding var isPresented: Bool
    let color: Color?
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            color?.edgesIgnoringSafeArea(.all)

            content
                .environment(\.dismiss, Dismiss {
                    isPresented = false
                })
        }
    }
}

struct Dismiss {
    private var action: () -> Void

	func callAsFunction() {
        action()
    }

    init(action: @escaping () -> Void = { }) {
        self.action = action
    }
}
