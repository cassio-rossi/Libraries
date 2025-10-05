import Foundation

/// Predefined date format patterns for consistent date formatting.
///
/// This enum provides a collection of commonly used date format strings
/// that can be used with ``Foundation/DateFormatter`` for consistent date
/// representation throughout your application.
///
/// ## Topics
///
/// ### Date Formats
/// - ``dateOnly``
/// - ``sortedDate``
/// - ``dateTime``
/// - ``live``
/// - ``hourOnly``
///
/// ## Usage
///
/// ```swift
/// let date = Date()
/// let formatted = date.format(using: .dateOnly)
/// // "26/02/2019"
/// ```
public enum DateFormat: String {
    /// Date-only format: "dd/MM/yyyy"
    ///
    /// Use this format for displaying dates without time information.
    ///
    /// Example: "26/02/2019"
    case dateOnly = "dd/MM/yyyy"

    /// Sortable date format: "yyyyMMdd"
    ///
    /// Use this format when you need dates in a sortable string format,
    /// such as for file names or database keys.
    ///
    /// Example: "20190226"
    case sortedDate = "yyyyMMdd"

    /// Date and time format: "dd/MM/yyyy HH:mm"
    ///
    /// Use this format for displaying both date and time information
    /// in a user-friendly format.
    ///
    /// Example: "26/02/2019 14:30"
    case dateTime = "dd/MM/yyyy HH:mm"

    /// Live event date format: "yyyy/MM/dd HH:mm"
    ///
    /// Use this format for live events or timestamps where the year
    /// takes precedence.
    ///
    /// Example: "2019/02/26 14:30"
    case live = "yyyy/MM/dd HH:mm"

    /// Time-only format: "HH:mm"
    ///
    /// Use this format for displaying only the time portion in 24-hour format.
    ///
    /// Example: "14:30"
    case hourOnly = "HH:mm"
}

/// Provides date formatting utilities for ``Foundation/Date`` objects.
///
/// This extension adds convenient methods to format dates using predefined
/// ``DateFormat`` patterns or custom format strings with locale and timezone support.
///
/// ## Topics
///
/// ### Time Components
/// - ``hour``
///
/// ### Formatting Methods
/// - ``format(using:)-5n3mu``
/// - ``format(using:locale:timezone:)-6hu0v``
///
/// ## Usage
///
/// ```swift
/// let date = Date()
///
/// // Using predefined format
/// let dateString = date.format(using: .dateOnly)
/// // "26/02/2019"
///
/// // Using custom format with locale
/// let customString = date.format(
///     using: "dd 'de' MMMM 'de' yyyy",
///     locale: Locale(identifier: "pt_BR")
/// )
/// // "26 de fevereiro de 2019"
/// ```
public extension Date {
    /// Formats the date as a time string in the current time zone.
    ///
    /// This property returns the hour and minute portion of the date
    /// formatted as "HH:mm" using the device's current time zone.
    ///
    /// ```swift
    /// let now = Date()
    /// print(now.hour) // "14:30"
    /// ```
    ///
    /// - Returns: A string representing the time in "HH:mm" format.
    var hour: String { self.format(using: DateFormat.hourOnly.rawValue, timezone: TimeZone.current) }

    /// Formats the date using a predefined ``DateFormat`` pattern.
    ///
    /// This is a convenience method that uses a ``DateFormat`` enum case
    /// to format the date with the associated pattern.
    ///
    /// ```swift
    /// let date = Date()
    ///
    /// let dateOnly = date.format(using: .dateOnly)
    /// // "26/02/2019"
    ///
    /// let dateTime = date.format(using: .dateTime)
    /// // "26/02/2019 14:30"
    ///
    /// let sortable = date.format(using: .sortedDate)
    /// // "20190226"
    /// ```
    ///
    /// - Parameter format: The ``DateFormat`` pattern to use. Defaults to ``DateFormat/dateOnly``.
    ///
    /// - Returns: A formatted date string using the specified format.
    ///
    /// - Note: This method uses BRT (Brazilian Time) as the default time zone.
    func format(using format: DateFormat = .dateOnly) -> String {
        self.format(using: format.rawValue)
	}

    /// Formats the date using a custom format string with optional locale and timezone.
    ///
    /// This method provides full control over date formatting, allowing you to specify
    /// a custom format string along with locale and timezone preferences.
    ///
    /// ```swift
    /// let date = Date()
    ///
    /// // Custom format with default timezone (BRT)
    /// let custom = date.format(using: "dd/MM/yyyy 'at' HH:mm")
    /// // "26/02/2019 at 14:30"
    ///
    /// // With Portuguese locale
    /// let ptBR = date.format(
    ///     using: "EEEE, dd 'de' MMMM 'de' yyyy",
    ///     locale: Locale(identifier: "pt_BR")
    /// )
    /// // "terça-feira, 26 de fevereiro de 2019"
    ///
    /// // With specific timezone
    /// let utc = date.format(
    ///     using: "yyyy-MM-dd HH:mm:ss",
    ///     timezone: TimeZone(abbreviation: "UTC")
    /// )
    /// // "2019-02-26 17:30:00"
    /// ```
    ///
    /// - Parameters:
    ///   - format: The custom date format string following ``Foundation/DateFormatter`` patterns.
    ///   - locale: The locale for formatting localized elements like month and day names.
    ///     If `nil`, uses the system's current locale. Defaults to `nil`.
    ///   - timezone: The timezone for the formatted date. Defaults to BRT (Brazilian Time).
    ///
    /// - Returns: A formatted date string according to the specified parameters.
    ///
    /// - SeeAlso: ``format(using:)-5n3mu`` for predefined format patterns.
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
