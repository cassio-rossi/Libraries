#if canImport(UIKit)
import Foundation
import UIKit

/// Provides UIKit-specific string utilities for rendering and HTML processing.
///
/// This extension adds UIKit-dependent functionality for calculating text dimensions
/// and decoding HTML entities. These methods are only available when UIKit is present.
///
/// ## Topics
///
/// ### Text Rendering
/// - ``height(withWidth:font:)``
///
/// ### HTML Processing
/// - ``htmlDecoded``
///
/// ## Availability
/// This extension is only available on platforms where UIKit is available (iOS, tvOS, watchOS).
extension String {
    /// Calculates the height required to render the string with the specified width and font.
    ///
    /// Use this method to determine how much vertical space a string will occupy
    /// when rendered in a label, text view, or other text container with a fixed width.
    /// This is particularly useful for dynamic cell sizing in table views and collection views.
    ///
    /// ```swift
    /// let text = "This is a long string that will wrap across multiple lines"
    /// let font = UIFont.systemFont(ofSize: 16)
    /// let width: CGFloat = 300
    ///
    /// let height = text.height(withWidth: width, font: font)
    /// // Use height to configure cell or view constraints
    /// ```
    ///
    /// - Parameters:
    ///   - width: The maximum width available for rendering the string. The height
    ///     calculation accounts for text wrapping at this width.
    ///   - font: The font that will be used to render the string.
    ///
    /// - Returns: The calculated height in points (``CoreGraphics/CGFloat``) required
    ///   to display the entire string.
    ///
    /// - Note: This method uses ``Foundation/NSString/boundingRect(with:options:attributes:context:)``
    ///   with `usesLineFragmentOrigin` and `usesFontLeading` options for accurate multi-line calculation.
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize,
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           attributes: [.font: font],
                                           context: nil)
        return actualSize.height
    }

    /// Decodes HTML entities and tags in the string to plain text.
    ///
    /// This property converts HTML-encoded strings (such as those from web APIs)
    /// to their plain text representation. It handles HTML entities like `&amp;`,
    /// `&lt;`, `&gt;`, `&quot;`, and removes HTML tags.
    ///
    /// ```swift
    /// let html = "Hello &amp; welcome to &lt;b&gt;iOS&lt;/b&gt;"
    /// print(html.htmlDecoded)
    /// // "Hello & welcome to iOS"
    ///
    /// let encoded = "&quot;Swift&quot; &mdash; Modern &amp; Safe"
    /// print(encoded.htmlDecoded)
    /// // "\"Swift\" — Modern & Safe"
    /// ```
    ///
    /// - Returns: The decoded plain text string with HTML entities converted and tags removed,
    ///   or the original string if HTML decoding fails.
    ///
    /// - Important: This property uses ``Foundation/NSAttributedString`` HTML document parsing,
    ///   which is relatively expensive. For performance-critical code or large strings,
    ///   consider caching the result.
    ///
    /// - Note: Uses UTF-8 encoding for the HTML document interpretation.
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
#endif
