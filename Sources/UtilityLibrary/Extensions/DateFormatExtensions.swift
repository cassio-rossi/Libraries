import Foundation

/// A collection of date formats used throughout the application.
/// This enum provides a set of predefined date formats that can be used to format dates consistently.
public enum DateFormat: String {
    case dateOnly = "dd/MM/yyyy"
    case sortedDate = "yyyyMMdd"
    case dateTime = "dd/MM/yyyy HH:mm"
    case live = "yyyy/MM/dd HH:mm"
    case hourOnly = "HH:mm"
}

public extension Date {
    /// Formats the date using the default date format.
    var hour: String { self.format(using: DateFormat.hourOnly.rawValue, timezone: TimeZone.current) }

    /// Formats the date using the specified date format.
    /// - Parameter format: The date format to use. Defaults to `.dateOnly`.
    func format(using format: DateFormat = .dateOnly) -> String {
        self.format(using: format.rawValue)
	}

    /// Formats the date using a custom format string, locale, and timezone.
    /// - Parameters:
    ///   - format: The custom date format string to use.
    ///   - locale: The locale to use for formatting. Defaults to `nil`.
    ///   - timezone: The timezone to use for formatting. Defaults to "BRT".
    /// - Returns: A formatted date string.
	func format(using format: String, locale: Locale? = nil, timezone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone ?? TimeZone(abbreviation: "BRT")
        if let locale = locale {
            dateFormatter.locale = locale
        }
        return dateFormatter.string(from: self)
    }
}
