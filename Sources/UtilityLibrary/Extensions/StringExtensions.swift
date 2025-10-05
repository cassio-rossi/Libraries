import Foundation

// MARK: - Basic -

/// Provides fundamental string manipulation and conversion utilities.
///
/// This extension adds basic string operations including data conversion,
/// web encoding, date parsing, and Base64 encoding/decoding.
public extension String {
    /// Converts the string to UTF-8 encoded data.
    ///
    /// Use this property when you need to convert a string to its binary representation,
    /// such as for network transmission or file storage.
    ///
    /// ```swift
    /// let text = "Hello, World!"
    /// if let data = text.asData {
    ///     print("Encoded \(data.count) bytes")
    /// }
    /// ```
    ///
    /// - Returns: A ``Foundation/Data`` representation of the string using UTF-8 encoding,
    ///   or `nil` if the string cannot be encoded.
    var asData: Data? { self.data(using: .utf8) }
}

// MARK: - Web related -

/// Provides web and URL-related string formatting utilities.
///
/// This extension adds methods for encoding strings for safe use in web contexts,
/// particularly in URL queries and parameters.
public extension String {
    /// Returns a percent-encoded string suitable for use in a URL query.
    ///
    /// This property encodes the string using percent encoding to ensure it's safe
    /// for use in URLs. Characters that have special meaning in URLs are converted
    /// to their percent-encoded equivalents.
    ///
    /// ```swift
    /// let searchTerm = "swift programming"
    /// let encoded = searchTerm.webQueryFormatted
    /// // Result: "swift%20programming"
    ///
    /// let url = "https://example.com/search?q=\(encoded)"
    /// ```
    ///
    /// - Returns: The percent-encoded string, or an empty string if encoding fails.
    ///
    /// - Note: This uses ``Foundation/CharacterSet/urlFragmentAllowed`` for encoding.
    var webQueryFormatted: String {
        guard let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return ""
        }
        return escapedString
    }
}

// MARK: - Dates -

/// Common date format strings for parsing dates from external sources.
///
/// This enum provides predefined format strings for parsing dates from
/// popular platforms and services like WordPress and YouTube.
///
/// ## Topics
///
/// ### Format Strings
/// - ``wordpress``
/// - ``youtube``
public enum Format: CaseIterable {
    /// WordPress date format: "EEE, dd MMM yyyy HH:mm:ss +0000"
    ///
    /// Example: "Tue, 26 Feb 2019 23:00:53 +0000"
    static let wordpress = "EEE, dd MMM yyyy HH:mm:ss +0000"

    /// YouTube ISO 8601 date format: "yyyy-MM-dd'T'HH:mm:ss'Z'"
    ///
    /// Example: "2019-02-26T23:00:53Z"
    static let youtube = "yyyy-MM-dd'T'HH:mm:ss'Z'"
}

/// Provides date parsing and formatting utilities for strings.
///
/// This extension adds methods to convert strings to dates using various formats
/// and to extract date components. It supports custom formats, time zones, and locales.
///
/// ## Topics
///
/// ### Date Conversion
/// - ``toDate(_:timeZone:locale:)``
/// - ``toDate(format:)``
///
/// ### Date Components
/// - ``hour``
///
/// ### Accessibility
/// - ``accessibilityDateTime``
/// - ``accessibilityEdicaoDate``
/// - ``accessibilityTime``
public extension String {
    /// Extracts the hour component from the string when formatted as "HH:mm".
    ///
    /// This property parses the string using ``DateFormat/hourOnly`` format
    /// and returns the hour portion formatted as "HH:mm".
    ///
    /// ```swift
    /// let timeString = "14:30"
    /// print(timeString.hour) // "14:30"
    /// ```
    ///
    /// - Returns: The hour portion of the date string in "HH:mm" format.
    var hour: String { self.toDate(format: DateFormat.hourOnly).hour }

    /// Converts the string to a date using the provided format, time zone, and locale.
    ///
    /// This method parses date strings from external sources like APIs, handling
    /// various format styles. It automatically removes ".000" millisecond suffixes
    /// that appear in some date formats.
    ///
    /// ```swift
    /// let dateString = "Tue, 26 Feb 2019 23:00:53 +0000"
    /// let date = dateString.toDate()
    ///
    /// // Custom format
    /// let isoString = "2019-02-26T23:00:53Z"
    /// let isoDate = isoString.toDate(Format.youtube, locale: "en_US")
    /// ```
    ///
    /// - Parameters:
    ///   - format: The date format string to use for parsing. Defaults to ``Format/wordpress``.
    ///   - timeZone: The time zone for the date. Defaults to UTC.
    ///   - locale: The locale identifier for date formatting. Defaults to "en_US".
    ///
    /// - Returns: The parsed ``Foundation/Date`` object, or the current date if parsing fails.
    ///
    /// - Note: If parsing fails, this method returns the current date rather than throwing an error.
    func toDate(_ format: String? = nil,
                timeZone: TimeZone? = TimeZone(abbreviation: "UTC"),
                locale: String = "en_US") -> Date {
        // Expected date format: "Tue, 26 Feb 2019 23:00:53 +0000"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format ?? Format.wordpress
        return dateFormatter.date(from: self.replacingOccurrences(of: ".000", with: "")) ?? Date()
    }

    /// Converts the string to a date using a predefined ``DateFormat``.
    ///
    /// This overload is optimized for parsing dates in Brazilian formats,
    /// using the BRT time zone by default.
    ///
    /// ```swift
    /// let dateString = "26/02/2019"
    /// let date = dateString.toDate(format: .dateOnly)
    ///
    /// let dateTimeString = "26/02/2019 14:30"
    /// let dateTime = dateTimeString.toDate(format: .dateTime)
    /// ```
    ///
    /// - Parameter format: The ``DateFormat`` to use for parsing. Defaults to ``DateFormat/dateOnly``.
    ///
    /// - Returns: The parsed ``Foundation/Date`` object, or the current date if parsing fails.
    ///
    /// - Note: Uses BRT (Brazilian Time) time zone by default.
    func toDate(format: DateFormat = .dateOnly) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }

    /// Returns a localized, accessible date-time string in extended Portuguese format.
    ///
    /// This property converts date-time strings to a fully spelled-out format
    /// suitable for VoiceOver and accessibility features in Portuguese (Brazil).
    ///
    /// ```swift
    /// let dateTime = "26/02/2019 14:30"
    /// print(dateTime.accessibilityDateTime)
    /// // "26 de fevereiro de 2019 às 14 horas e 30 minutos"
    /// ```
    ///
    /// - Returns: A formatted string like "26 de fevereiro de 2019 às 14 horas e 30 minutos",
    ///   or "Erro ao formatar a data." if the string cannot be parsed.
    ///
    /// - Note: This property expects the input format "dd/MM/yyyy HH:mm" and uses
    ///   the pt_BR locale with BRT time zone.
    var accessibilityDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"

        guard let date = dateFormatter.date(from: self) else {
            return "Erro ao formatar a data."
        }

        return date.format(using: "dd 'de' MMMM 'de' yyyy 'às' HH 'horas e' mm 'minutos'",
                           locale: dateFormatter.locale)
    }

    /// Returns a localized, accessible edition date in Portuguese.
    ///
    /// This property intelligently parses dates with varying levels of precision
    /// (day/month/year, month/year, or year only) and formats them for accessibility.
    ///
    /// The input format is automatically detected based on the number of segments:
    /// - 3 segments (dd/MM/yyyy): "26 de fevereiro de 2019"
    /// - 2 segments (MM/yyyy): "fevereiro de 2019"
    /// - 1 segment (yyyy): "2019"
    ///
    /// ```swift
    /// let fullDate = "26/02/2019"
    /// print(fullDate.accessibilityEdicaoDate)
    /// // "26 de fevereiro de 2019"
    ///
    /// let monthYear = "02/2019"
    /// print(monthYear.accessibilityEdicaoDate)
    /// // "fevereiro de 2019"
    /// ```
    ///
    /// - Returns: A formatted Portuguese date string, or "Erro ao formatar o tempo."
    ///   if parsing fails.
    ///
    /// - Note: Uses pt_BR locale and BRT time zone. The input is converted to lowercase
    ///   before parsing.
    var accessibilityEdicaoDate: String {
        let segments = self.lowercased().split { $0 == "/" }.map(String.init)
        var formatter: (String, String) {
            switch segments.count {
            case 3:
                return ("dd/MMMM/yyyy", "dd 'de' MMMM 'de' yyyy")
            case 2:
                return ("MMMM/yyyy", "MMMM 'de' yyyy")
            default:
                return ("yyyy", "yyyy")
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        dateFormatter.dateFormat = formatter.0

        guard let date = dateFormatter.date(from: self) else {
            return "Erro ao formatar o tempo."
        }

        return date.format(using: formatter.1, locale: dateFormatter.locale)
    }

    /// Returns a localized, accessible time duration string in Portuguese.
    ///
    /// This property converts time strings to a spelled-out format suitable for
    /// VoiceOver and accessibility features. It automatically detects the format
    /// based on the number of colon-separated segments:
    ///
    /// - 3 segments (HH:mm:ss): Hours, minutes, and seconds
    /// - 2 segments (mm:ss): Minutes and seconds
    /// - 1 segment (ss): Seconds only
    ///
    /// ```swift
    /// let duration = "02:30"
    /// print(duration.accessibilityTime)
    /// // "dois minutos, trinta segundos"
    ///
    /// let fullTime = "01:15:30"
    /// print(fullTime.accessibilityTime)
    /// // "uma hora, quinze minutos, trinta segundos"
    /// ```
    ///
    /// - Returns: A spelled-out time duration in Portuguese, or "Erro ao formatar o tempo."
    ///   if parsing fails.
    ///
    /// - Note: Uses pt_BR locale and ``Foundation/DateComponentsFormatter`` with
    ///   spell-out style for natural language output.
    var accessibilityTime: String {
        let segments = self.split { $0 == ":" }.map(String.init)
        var formatter: (String, Set<Calendar.Component>) {
            switch segments.count {
            case 3:
                return ("HH:mm:ss", [.hour, .minute, .second])
            case 2:
                return ("mm:ss", [.minute, .second])
            default:
                return ("ss", [.second])
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = formatter.0

        guard let date = dateFormatter.date(from: self) else {
            return "Erro ao formatar o tempo."
        }
        let components = Calendar.current.dateComponents(formatter.1, from: date)

        return DateComponentsFormatter.localizedString(from: components,
                                                       unitsStyle: .spellOut) ?? "Erro ao formatar o tempo."
    }
}

// MARK: - Base64 -

/// Provides Base64 encoding and decoding utilities.
///
/// This extension adds convenient properties for encoding strings to Base64
/// and decoding Base64-encoded strings.
///
/// ## Topics
///
/// ### Encoding
/// - ``base64Encode``
///
/// ### Decoding
/// - ``base64Decode``
public extension String {
    /// Encodes the string to Base64 format.
    ///
    /// This property converts the string to UTF-8 data and then encodes it
    /// using Base64 encoding, suitable for transmitting binary data as text.
    ///
    /// ```swift
    /// let text = "Hello, World!"
    /// if let encoded = text.base64Encode {
    ///     print(encoded) // "SGVsbG8sIFdvcmxkIQ=="
    /// }
    /// ```
    ///
    /// - Returns: A Base64-encoded string, or `nil` if UTF-8 encoding fails.
    ///
    /// - SeeAlso: ``base64Decode``
    var base64Encode: String? { self.data(using: .utf8)?.base64EncodedString() }

    /// Decodes a Base64-encoded string to its original UTF-8 representation.
    ///
    /// This property decodes a Base64-encoded string back to its original
    /// text representation using UTF-8 encoding.
    ///
    /// ```swift
    /// let encoded = "SGVsbG8sIFdvcmxkIQ=="
    /// if let decoded = encoded.base64Decode {
    ///     print(decoded) // "Hello, World!"
    /// }
    /// ```
    ///
    /// - Returns: The decoded UTF-8 string, or `nil` if the Base64 data is invalid
    ///   or cannot be decoded as UTF-8.
    ///
    /// - SeeAlso: ``base64Encode``
    var base64Decode: String? { String(data: Data(base64Encoded: self) ?? Data(), encoding: .utf8) }
}

// MARK: - Localized -

/// Provides localization utilities for strings.
///
/// This extension adds methods for retrieving localized strings from bundle resources.
///
/// ## Topics
///
/// ### Localization
/// - ``localized(bundle:)``
public extension String {
    /// Returns the localized version of the string from the specified bundle.
    ///
    /// This method looks up the localized value for the string (used as a key)
    /// in the bundle's Localizable.strings file.
    ///
    /// ```swift
    /// let key = "welcome_message"
    /// let localizedText = key.localized()
    /// // Returns the localized value for "welcome_message" from Localizable.strings
    ///
    /// // Using a custom bundle
    /// let customBundle = Bundle(identifier: "com.example.resources")!
    /// let text = "custom_key".localized(bundle: customBundle)
    /// ```
    ///
    /// - Parameter bundle: The bundle containing the localization resources.
    ///   Defaults to ``Foundation/Bundle/main``.
    ///
    /// - Returns: The localized string if found, or the original string if no
    ///   localization exists for the key.
    ///
    /// - Note: This method uses the string itself as the localization key and
    ///   returns the value from the Localizable.strings file.
    func localized(bundle: Bundle = .main) -> String {
        bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}
