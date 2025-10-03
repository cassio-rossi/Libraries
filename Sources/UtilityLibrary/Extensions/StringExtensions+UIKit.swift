#if canImport(UIKit)
import Foundation
import UIKit

extension String {
    /// Calculates the height of the string when rendered with the specified width and font.
    /// - Parameters:
    ///   - width: The maximum width for rendering the string.
    ///   - font: The font used for rendering.
    /// - Returns: The calculated height as a CGFloat.
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize,
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           attributes: [.font: font],
                                           context: nil)
        return actualSize.height
    }

    /// Decodes HTML entities in the string.
    /// - Returns: The decoded string, or the original string if decoding fails.
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
#endif
