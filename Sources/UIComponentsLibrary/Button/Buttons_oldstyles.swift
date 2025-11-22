import SwiftUI

public struct FullSizeStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let fill: Color
    let corner: CGFloat
    let size: CGFloat?

    public init(color: Color,
                stroke: Color,
                fill: Color,
                corner: CGFloat,
                size: CGFloat?) {
        self.color = color
        self.stroke = stroke
        self.fill = fill
        self.corner = corner
        self.size = size
    }

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.bold))
            .foregroundColor(color)
            .frame(minWidth: 0, maxWidth: size)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(stroke)
                .background(RoundedRectangle(cornerRadius: corner)
                    .fill(fill))
            )
    }
}

#if canImport(UIKit)
public struct FullSizeCorneredStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let fill: Color
    let radius: CGFloat
    let corners: UIRectCorner
    let size: CGFloat?

    public init(color: Color,
                stroke: Color,
                fill: Color,
                radius: CGFloat,
                corners: UIRectCorner,
                size: CGFloat?) {
        self.color = color
        self.stroke = stroke
        self.fill = fill
        self.radius = radius
        self.corners = corners
        self.size = size
    }

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.bold))
            .foregroundColor(color)
            .frame(minWidth: 0, maxWidth: size)
            .padding(8)
            .background(RoundedCorner(radius: radius, corners: corners)
                .stroke(stroke)
                .background(RoundedCorner(radius: radius, corners: corners)
                    .fill(fill))
            )
    }
}
#endif

public struct FullSizeFilledButtonTextStyle: ViewModifier {
    let color: Color
    let fill: Color
    let corner: CGFloat

    public init(color: Color,
                fill: Color,
                corner: CGFloat) {
        self.color = color
        self.fill = fill
        self.corner = corner
    }

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.bold))
            .foregroundColor(color)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(fill))
    }
}

public struct FixedSizeButtonTextStyle: ViewModifier {
    let color: Color
    let fill: Color
    let padding: CGFloat
    let corner: CGFloat

    public init(color: Color,
                fill: Color,
                padding: CGFloat,
                corner: CGFloat) {
        self.color = color
        self.fill = fill
        self.padding = padding
        self.corner = corner
    }

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, padding)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: corner).fill(fill))
    }
}

public struct FixedSizeStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let lineWidth: CGFloat
    let fill: Color
    let corner: CGFloat

    public init(color: Color,
                stroke: Color,
                lineWidth: CGFloat,
                fill: Color,
                corner: CGFloat) {
        self.color = color
        self.stroke = stroke
        self.lineWidth = lineWidth
        self.fill = fill
        self.corner = corner
    }

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.bold))
            .foregroundColor(color)
            .padding([.leading, .trailing], 12)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: corner)
                .stroke(stroke, lineWidth: lineWidth)
                .background(RoundedRectangle(cornerRadius: corner)
                    .fill(fill))
            )
    }
}

extension Text {
    @MainActor
    public func rounded(color: Color = .white,
                        fill: Color = .green,
                        padding: CGFloat = 12,
                        corner: CGFloat = 30) -> some View {
        modifier(FixedSizeButtonTextStyle(color: color, fill: fill, padding: padding, corner: corner))
    }

    @MainActor
    public func roundedFullSize(color: Color = .white,
                                fill: Color = .green,
                                corner: CGFloat = 30) -> some View {
        modifier(FullSizeFilledButtonTextStyle(color: color, fill: fill, corner: corner))
    }

    @MainActor
    public func bordered(color: Color = .primary,
                         stroke: Color = .primary,
                         lineWidth: CGFloat = 1,
                         fill: Color = .clear,
                         corner: CGFloat = 30) -> some View {
        modifier(FixedSizeStrokedButtonTextStyle(color: color, stroke: stroke, lineWidth: lineWidth, fill: fill, corner: corner))
    }

    @MainActor
    public func borderedFullSize(color: Color = .primary,
                                 stroke: Color = .primary,
                                 fill: Color = .clear,
                                 corner: CGFloat = 30,
                                 size: CGFloat? = .infinity) -> some View {
        modifier(FullSizeStrokedButtonTextStyle(color: color, stroke: stroke, fill: fill, corner: corner, size: size))
    }

    @MainActor
    public func fullSize(color: Color = .white,
                         fill: Color = .green) -> some View {
        modifier(FullSizeFilledButtonTextStyle(color: color, fill: fill, corner: 0))
    }

#if canImport(UIKit)
    @MainActor
    public func borderedFullSize(color: Color = .primary,
                                 stroke: Color = .primary,
                                 fill: Color = .clear,
                                 corner: CGFloat = 12,
                                 corners: UIRectCorner,
                                 size: CGFloat? = .infinity) -> some View {
        modifier(FullSizeCorneredStrokedButtonTextStyle(color: color,
                                                        stroke: stroke,
                                                        fill: fill,
                                                        radius: corner,
                                                        corners: corners,
                                                        size: size))
    }
#endif
}
