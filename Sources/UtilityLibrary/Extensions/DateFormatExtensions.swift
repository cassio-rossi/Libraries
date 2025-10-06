import Foundation

/// Predefined date format patterns.
public enum DateFormat: String {
    /// Date-only format: "dd/MM/yyyy"
    case dateOnly = "dd/MM/yyyy"

    /// Sortable date format: "yyyyMMdd"
    case sortedDate = "yyyyMMdd"

    /// Date and time format: "dd/MM/yyyy HH:mm"
    case dateTime = "dd/MM/yyyy HH:mm"

    /// Live event format: "yyyy/MM/dd HH:mm"
    case live = "yyyy/MM/dd HH:mm"

    /// Time-only format: "HH:mm"
    case hourOnly = "HH:mm"
}

public extension Date {
    /// The time in "HH:mm" format.
    var hour: String { self.format(using: DateFormat.hourOnly.rawValue, timezone: TimeZone.current) }

    /// Formats the date using a predefined format.
    ///
    /// - Parameter format: The ``DateFormat`` to use. Defaults to ``DateFormat/dateOnly``.
    /// - Returns: The formatted date string.
    func format(using format: DateFormat = .dateOnly) -> String {
        self.format(using: format.rawValue)
	}

    /// Formats the date using a custom format string.
    ///
    /// - Parameters:
    ///   - format: The date format string.
    ///   - locale: The locale for formatting. Defaults to system locale.
    ///   - timezone: The timezone for formatting. Defaults to BRT.
    /// - Returns: The formatted date string.
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
