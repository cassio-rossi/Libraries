import SwiftUI

struct DimmingOverlayViewModifier: ViewModifier {
    @Binding var dimmed: Bool
    let allowInteraction: Bool
    let radius: CGFloat
    let color: Color
    let opacity: CGFloat

    func body(content: Content) -> some View {
        content
            .if(dimmed) { view in
                ZStack {
                    view
                        .blur(radius: radius)
                    color
                        .opacity(opacity)
                        .ignoresSafeArea()
                }
                .if(allowInteraction) { view in
                    view
                        .onTapGesture { withAnimation { dimmed = false } }
                }
            }
    }
}

extension View {
    public func dimmingOverlay(show: Binding<Bool>,
                               allowInteraction: Bool = true,
                               radius: CGFloat = 4.0,
                               color: Color = .black,
                               opacity: CGFloat = 0.35) -> some View {
        modifier(DimmingOverlayViewModifier(dimmed: show,
                                            allowInteraction: allowInteraction,
                                            radius: radius,
                                            color: color,
                                            opacity: opacity))
    }
}

// MARK: - PREVIEW -

struct DimmingOverlayView: View {
    @State var dimmed: Bool = false
    var radius: CGFloat = 4.0
    var color: Color = .black
    var opacity: CGFloat = 0.35

    var body: some View {
        PrimaryButton("Dimm View") { dimmed = true }
            .padding()
            .dimmingOverlay(show: $dimmed,
                            radius: radius,
                            color: color,
                            opacity: opacity)
    }
}

struct DimmingOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        DimmingOverlayView()
            .previewDisplayName("Normal")
        DimmingOverlayView(dimmed: true)
            .previewDisplayName("Dimmed")
        DimmingOverlayView(dimmed: true, radius: 1.0)
            .previewDisplayName("Dimmed Less")
        DimmingOverlayView(dimmed: true, color: .yellow)
            .previewDisplayName("Dimmed Colored")
        DimmingOverlayView(dimmed: true, opacity: 0.7)
            .previewDisplayName("Dimmed More Opaque")
    }
}
