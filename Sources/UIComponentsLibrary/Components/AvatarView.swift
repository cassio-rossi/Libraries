import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension String {
	/// Converts a name string to initials suitable for avatar display.
	///
	/// This property extracts the first letter of the first name and the first letter
	/// of the last name (if present) and combines them into a string.
	///
	/// Example:
	/// ```swift
	/// "John Doe".toAvatar // Returns "JD"
	/// "Jane".toAvatar // Returns "J"
	/// ```
	///
	/// - Returns: A string containing one or two letters representing the name.
    public var toAvatar: String {
        let names = self.split(separator: " ")
        var firstLetter = ""
        var lastLetter = ""
        if let first = names.first?.first {
            firstLetter = "\(first)"
        }
        if names.count > 1,
           let last = names.last?.first {
            lastLetter = "\(last)"
        }
        return firstLetter + lastLetter
    }
}

#if canImport(UIKit)
extension String {
	/// Converts a Base64 encoded string to a UIImage.
	///
	/// - Returns: A `UIImage` if the string is valid Base64 image data, otherwise `nil`.
    public var asBase64Image: UIImage? {
        guard let imageData = Data.init(base64Encoded: self,
                                        options: .init(rawValue: 0)) else { return nil }
        return UIImage(data: imageData)
    }
}
extension UIImage {
	/// Converts the UIImage to a Base64 encoded string.
	///
	/// - Returns: A Base64 encoded string representation of the image's PNG data, or `nil` if conversion fails.
    public var asBase64String: String? {
        self.pngData()?.base64EncodedString()
    }
}
#endif

/// A customizable circular avatar view that displays either an image or initials.
///
/// `AvatarView` provides a flexible way to display user avatars with support for:
/// - Image display (from asset names or Base64 encoded strings)
/// - Text initials with customizable styling
/// - Configurable size, colors, and fill options
/// - Stroke borders with customizable colors
public struct AvatarView: View {
	/// The image to display. Can be an asset name or Base64 encoded image string.
    let image: String?

	/// The text to display (typically initials) when no image is provided.
    let avatar: String?

	/// The foreground color for the avatar text.
    let foregroundColor: Color?

	/// The background color for the avatar circle.
    let color: Color?

	/// The diameter of the avatar circle.
    let size: CGFloat

	/// Whether to fill the background with the specified color.
    let fill: Bool

	/// The color of the stroke border around the avatar.
    let stroke: Color

	/// Creates a new avatar view with customizable appearance.
	///
	/// - Parameters:
	///   - image: Optional image to display. Can be an asset name or Base64 encoded string.
	///   - avatar: Optional text (typically initials) to display when no image is provided.
	///   - foregroundColor: The color of the avatar text. Defaults to `.primary`.
	///   - color: The background color of the avatar circle. Defaults to `nil` (orange if fill is true).
	///   - size: The diameter of the avatar circle. Defaults to `32`.
	///   - fill: Whether to fill the background with color. Defaults to `true`.
	///   - stroke: The color of the border stroke. Defaults to `.white`.
    public init(image: String? = nil,
                avatar: String? = nil,
                foregroundColor: Color? = .primary,
                color: Color? = nil,
                size: CGFloat = 32,
                fill: Bool = true,
                stroke: Color = .white) {

        self.image = image
        self.avatar = avatar
        self.foregroundColor = foregroundColor
        self.color = color
        self.size = size
        self.fill = fill
        self.stroke = stroke
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(fill ? color ?? Color.orange : .clear)
                .frame(width: size, height: size)
                .overlay(
                    Text(avatar ?? "")
                        .font(.system(size: size * 0.55))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(foregroundColor)
                        .minimumScaleFactor(0.005)
                        .padding(size / 16)
                )
                .overlay(Circle().stroke(fill ? stroke : Color.clear,
                                         lineWidth: 2))
                .padding(fill ? size / 16 : 0)

            if let photo = generateImage(from: image) {
                photo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size + (fill ? 0 : 8),
                           height: size + (fill ? 0 : 8),
                           alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(fill ? stroke : Color.clear, lineWidth: 2))
                    .padding(fill ? size / 16 : 0)
            }
        }
    }
}

extension AvatarView {
	/// Generates an Image from a string.
	///
	/// This method attempts to create an `Image` by first trying to decode a Base64
	/// encoded UIImage (on UIKit platforms), then falls back to treating the string
	/// as an asset name.
	///
	/// - Parameter text: The string to convert to an image. Can be a Base64 encoded image or asset name.
	/// - Returns: An `Image` if successful, otherwise `nil`.
    func generateImage(from text: String?) -> Image? {
#if canImport(UIKit)
        if let photo = text?.asBase64Image {
            return Image(uiImage: photo)
        }
#endif

        if let photo = text {
            return Image(photo)
        }
        return nil
    }
}

#Preview {
    VStack {
        AvatarView(avatar: "CR", size: 96)
        AvatarView(avatar: "A", color: .blue)
        AvatarView(image: "mock",
                   avatar: "CR",
                   size: 64)
        AvatarView(image: "mock")
    }
}

#if canImport(UIKit)
#Preview {
    VStack {
        AvatarView(image: UIImage(named: "mock", in: .module, with: nil)?.asBase64String ?? "mock",
                   size: 200,
                   fill: false)
        AvatarView(image: UIImage(named: "mock", in: .module, with: nil)?.asBase64String ?? "mock",
                   size: 200,
                   fill: false)
        .overlay(Circle().stroke(.black, lineWidth: 2))
    }
}
#endif
