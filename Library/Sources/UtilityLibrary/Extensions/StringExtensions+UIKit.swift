#if canImport(UIKit)
import Foundation
import UIKit

extension String {
    /// Calculates the height required to render the string.
    ///
    /// - Parameters:
    ///   - width: The maximum width for text wrapping.
    ///   - font: The font for rendering.
    /// - Returns: The calculated height in points.
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize,
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           attributes: [.font: font],
                                           context: nil)
        return actualSize.height
    }

    /// The string with HTML entities decoded and tags removed.
    ///
    /// - Important: This operation is relatively expensive. Cache the result when possible.
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
#endif
