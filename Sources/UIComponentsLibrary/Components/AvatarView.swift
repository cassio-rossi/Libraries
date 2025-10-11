import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension String {
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
    public var asBase64Image: UIImage? {
        guard let imageData = Data.init(base64Encoded: self,
                                        options: .init(rawValue: 0)) else { return nil }
        return UIImage(data: imageData)
    }
}
extension UIImage {
    public var asBase64String: String? {
        self.pngData()?.base64EncodedString()
    }
}
#endif

public struct AvatarView: View {
    let image: String?
    let avatar: String?
    let foregroundColor: Color?
    let color: Color?
    let size: CGFloat
    let fill: Bool
    let stroke: Color

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

#Preview {
    VStack {
        AvatarView(image: UIImage(named: "mock", in: .module, with: nil)?.asBase64String ?? "mock",
                   size: 200,
                   fill: false)
        AvatarView(image: UIImage(named: "mock", in: .module, with: nil)?.asBase64String ?? "mock",
                   size: 200,
                   fill: false)
        .overlay(Circle().stroke(.white, lineWidth: 2))
    }
}
