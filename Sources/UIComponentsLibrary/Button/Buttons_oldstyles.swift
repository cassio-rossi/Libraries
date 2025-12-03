import SwiftUI

/// A view modifier that styles text as a full-size stroked button with customizable appearance.
///
/// This modifier creates a button-like appearance with bold caption text, a stroke border,
/// and a fill background, all with rounded corners. The width can span the entire available space.
public struct FullSizeStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let fill: Color
    let corner: CGFloat
    let size: CGFloat?

    /// Creates a full-size stroked button text style.
    ///
    /// - Parameters:
    ///   - color: The text color.
    ///   - stroke: The border stroke color.
    ///   - fill: The background fill color.
    ///   - corner: The corner radius for the rounded rectangle.
    ///   - size: Optional maximum width for the button. Pass `nil` or `.infinity` for full width.
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
/// A view modifier that styles text as a full-size stroked button with selective corner rounding.
///
/// This UIKit-specific modifier creates a button-like appearance with bold caption text, a stroke border,
/// and a fill background, with the ability to round only specific corners. The width can span the entire available space.
///
/// - Note: This modifier is only available on platforms that support UIKit.
public struct FullSizeCorneredStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let fill: Color
    let radius: CGFloat
    let corners: UIRectCorner
    let size: CGFloat?

    /// Creates a full-size cornered stroked button text style.
    ///
    /// - Parameters:
    ///   - color: The text color.
    ///   - stroke: The border stroke color.
    ///   - fill: The background fill color.
    ///   - radius: The corner radius for the rounded corners.
    ///   - corners: The specific corners to round (e.g., `.topLeft`, `.bottomRight`, or `.allCorners`).
    ///   - size: Optional maximum width for the button. Pass `nil` or `.infinity` for full width.
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

/// A view modifier that styles text as a full-size filled button with a solid background.
///
/// This modifier creates a button-like appearance with bold caption text and a filled background
/// with rounded corners. The button automatically expands to fill the available width.
public struct FullSizeFilledButtonTextStyle: ViewModifier {
    let color: Color
    let fill: Color
    let corner: CGFloat

    /// Creates a full-size filled button text style.
    ///
    /// - Parameters:
    ///   - color: The text color.
    ///   - fill: The background fill color.
    ///   - corner: The corner radius for the rounded rectangle.
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

/// A view modifier that styles text as a fixed-size filled button with customizable padding.
///
/// This modifier creates a button-like appearance with bold caption text and a filled background
/// with rounded corners. Unlike full-size variants, this button sizes based on its content and padding.
public struct FixedSizeButtonTextStyle: ViewModifier {
    let color: Color
    let fill: Color
    let padding: CGFloat
    let corner: CGFloat

    /// Creates a fixed-size filled button text style.
    ///
    /// - Parameters:
    ///   - color: The text color.
    ///   - fill: The background fill color.
    ///   - padding: The horizontal padding around the text.
    ///   - corner: The corner radius for the rounded rectangle.
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

/// A view modifier that styles text as a fixed-size stroked button with a border.
///
/// This modifier creates a button-like appearance with bold caption text, a stroke border,
/// and a fill background with rounded corners. The button sizes based on its content and padding.
public struct FixedSizeStrokedButtonTextStyle: ViewModifier {
    let color: Color
    let stroke: Color
    let lineWidth: CGFloat
    let fill: Color
    let corner: CGFloat

    /// Creates a fixed-size stroked button text style.
    ///
    /// - Parameters:
    ///   - color: The text color.
    ///   - stroke: The border stroke color.
    ///   - lineWidth: The width of the border stroke.
    ///   - fill: The background fill color.
    ///   - corner: The corner radius for the rounded rectangle.
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
    /// Applies a rounded fixed-size filled button style to the text.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.white`.
    ///   - fill: The background fill color. Defaults to `.green`.
    ///   - padding: The horizontal padding around the text. Defaults to `12`.
    ///   - corner: The corner radius for the rounded rectangle. Defaults to `30`.
    /// - Returns: A view with the rounded button text style applied.
    @MainActor
    public func rounded(color: Color = .white,
                        fill: Color = .green,
                        padding: CGFloat = 12,
                        corner: CGFloat = 30) -> some View {
        modifier(FixedSizeButtonTextStyle(color: color, fill: fill, padding: padding, corner: corner))
    }

    /// Applies a rounded full-size filled button style to the text.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.white`.
    ///   - fill: The background fill color. Defaults to `.green`.
    ///   - corner: The corner radius for the rounded rectangle. Defaults to `30`.
    /// - Returns: A view with the full-size rounded button text style applied.
    @MainActor
    public func roundedFullSize(color: Color = .white,
                                fill: Color = .green,
                                corner: CGFloat = 30) -> some View {
        modifier(FullSizeFilledButtonTextStyle(color: color, fill: fill, corner: corner))
    }

    /// Applies a bordered fixed-size stroked button style to the text.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.primary`.
    ///   - stroke: The border stroke color. Defaults to `.primary`.
    ///   - lineWidth: The width of the border stroke. Defaults to `1`.
    ///   - fill: The background fill color. Defaults to `.clear`.
    ///   - corner: The corner radius for the rounded rectangle. Defaults to `30`.
    /// - Returns: A view with the bordered button text style applied.
    @MainActor
    public func bordered(color: Color = .primary,
                         stroke: Color = .primary,
                         lineWidth: CGFloat = 1,
                         fill: Color = .clear,
                         corner: CGFloat = 30) -> some View {
        modifier(FixedSizeStrokedButtonTextStyle(color: color, stroke: stroke, lineWidth: lineWidth, fill: fill, corner: corner))
    }

    /// Applies a bordered full-size stroked button style to the text.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.primary`.
    ///   - stroke: The border stroke color. Defaults to `.primary`.
    ///   - fill: The background fill color. Defaults to `.clear`.
    ///   - corner: The corner radius for the rounded rectangle. Defaults to `30`.
    ///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
    /// - Returns: A view with the full-size bordered button text style applied.
    @MainActor
    public func borderedFullSize(color: Color = .primary,
                                 stroke: Color = .primary,
                                 fill: Color = .clear,
                                 corner: CGFloat = 30,
                                 size: CGFloat? = .infinity) -> some View {
        modifier(FullSizeStrokedButtonTextStyle(color: color, stroke: stroke, fill: fill, corner: corner, size: size))
    }

    /// Applies a full-size filled button style to the text without rounded corners.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.white`.
    ///   - fill: The background fill color. Defaults to `.green`.
    /// - Returns: A view with the full-size button text style applied (square corners).
    @MainActor
    public func fullSize(color: Color = .white,
                         fill: Color = .green) -> some View {
        modifier(FullSizeFilledButtonTextStyle(color: color, fill: fill, corner: 0))
    }

#if canImport(UIKit)
    /// Applies a bordered full-size stroked button style with selective corner rounding to the text.
    ///
    /// This UIKit-specific method allows you to round only specific corners of the button.
    ///
    /// - Parameters:
    ///   - color: The text color. Defaults to `.primary`.
    ///   - stroke: The border stroke color. Defaults to `.primary`.
    ///   - fill: The background fill color. Defaults to `.clear`.
    ///   - corner: The corner radius for the rounded corners. Defaults to `12`.
    ///   - corners: The specific corners to round (e.g., `.topLeft`, `.bottomRight`, or `.allCorners`).
    ///   - size: Optional maximum width for the button. Defaults to `.infinity` for full width.
    /// - Returns: A view with the full-size bordered button text style and selective corner rounding applied.
    /// - Note: This method is only available on platforms that support UIKit.
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
