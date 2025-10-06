import SwiftUI

/// Set the backgeround of any SwiftUI View to transparent
public struct TransparentView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = nil
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}

public struct OpaqueView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .systemBackground
        }
        return view
    }

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

struct TransparenttUIView_Previews: PreviewProvider {
    static var previews: some View {
        TransparenttUIView(transparent: true, tinted: false)
            .previewDisplayName("Transparent")
        TransparenttUIView(transparent: false, tinted: true)
            .previewDisplayName("Color")
    }
}
