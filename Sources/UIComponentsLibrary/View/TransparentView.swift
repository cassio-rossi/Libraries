#if canImport(UIKit) && !os(watchOS)
import SwiftUI

/// A view that makes the background of a SwiftUI view transparent.
///
/// `TransparentView` is useful for creating transparent overlays, particularly
/// in full screen covers where you want the underlying content to be visible.
///
/// Example usage:
/// ```swift
/// .fullScreenCover(isPresented: $showOverlay) {
///     MyOverlayContent()
///         .background(TransparentView())
/// }
/// ```
public struct TransparentView: UIViewRepresentable {
	/// Creates a transparent view.
    public init() {}

	/// Creates the underlying UIView that removes the background color.
	///
	/// - Parameter context: The view context.
	/// - Returns: A UIView configured to make its superview transparent.
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = nil
        }
        return view
    }

	/// Updates the UIView when SwiftUI state changes.
	///
	/// - Parameters:
	///   - uiView: The view to update.
	///   - context: The view context.
    public func updateUIView(_ uiView: UIView, context: Context) {}
}

/// A view that sets the background to the system's standard opaque background color.
///
/// `OpaqueView` is the counterpart to `TransparentView`, restoring the
/// default system background when needed.
public struct OpaqueView: UIViewRepresentable {
	/// Creates an opaque view.
    public init() {}

	/// Creates the underlying UIView that sets an opaque background.
	///
	/// - Parameter context: The view context.
	/// - Returns: A UIView configured to use the system background color.
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .systemBackground
        }
        return view
    }

	/// Updates the UIView when SwiftUI state changes.
	///
	/// - Parameters:
	///   - uiView: The view to update.
	///   - context: The view context.
    public func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - PREVIEW -

struct TransparenttUIView: View {
    @State var transparent: Bool
    @State var tinted: Bool

    var body: some View {
        ZStack {
            Color.red
            VStack {
                Text("Back View")
                    .padding()
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $transparent) {
            Text("Fullscreen Transparent View")
                .background(TransparentView())
        }
        .fullScreenCover(isPresented: $tinted) {
            Text("Fullscreen Tinted View")
                .background(.blue)
        }
    }
}

#Preview("Transparent") {
    TransparenttUIView(transparent: true, tinted: false)
}

#Preview("Color") {
    TransparenttUIView(transparent: false, tinted: true)
}
#endif
