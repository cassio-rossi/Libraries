import Foundation

// MARK: - Basic -

/// Extension providing basic string conversion utilities.
public extension String {
    /// The string converted to UTF-8 encoded data.
    var asData: Data? { self.data(using: .utf8) }
}

// MARK: - Web related -

/// Extension providing web and URL-related string utilities.
public extension String {
    /// The string percent-encoded for use in URL queries.
    var webQueryFormatted: String {
        guard let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return ""
        }
        return escapedString
    }
}

// MARK: - Dates -

/// Date format strings for parsing dates from external sources.
///
/// Contains commonly used date format patterns for parsing dates from various platforms.
public enum Format: CaseIterable {
    /// WordPress date format: "EEE, dd MMM yyyy HH:mm:ss +0000"
    static let wordpress = "EEE, dd MMM yyyy HH:mm:ss +0000"

    /// YouTube ISO 8601 date format: "yyyy-MM-dd'T'HH:mm:ss'Z'"
    static let youtube = "yyyy-MM-dd'T'HH:mm:ss'Z'"
}

/// Extension providing date and time parsing and formatting utilities.
public extension String {
    /// The hour component when the string represents a time.
    var hour: String { self.toDate(format: DateFormat.hourOnly).hour }

    /// Converts the string to a date.
    ///
    /// - Parameters:
    ///   - format: The date format string. Defaults to WordPress format.
    ///   - timeZone: The time zone for parsing. Defaults to UTC.
    ///   - locale: The locale identifier. Defaults to "en_US".
    /// - Returns: The parsed date, or the current date if parsing fails.
    func toDate(_ format: String? = nil,
                timeZone: TimeZone? = TimeZone(abbreviation: "UTC"),
                locale: String = "en_US") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format ?? Format.wordpress
        return dateFormatter.date(from: self.replacingOccurrences(of: ".000", with: "")) ?? Date()
    }

    /// Converts the string to a date using a predefined format.
    ///
    /// - Parameter format: The ``DateFormat`` to use. Defaults to ``DateFormat/dateOnly``.
    /// - Returns: The parsed date, or the current date if parsing fails.
    func toDate(format: DateFormat = .dateOnly) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }

    /// A localized date-time string for accessibility (Portuguese).
    ///
    /// Converts "dd/MM/yyyy HH:mm" format to spoken Portuguese.
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

    /// A localized date string for accessibility (Portuguese).
    ///
    /// Automatically detects format: dd/MM/yyyy, MM/yyyy, or yyyy.
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

    /// A localized time duration string for accessibility (Portuguese).
    ///
    /// Automatically detects format: HH:mm:ss, mm:ss, or ss.
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

        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "pt_BR")
        let components = calendar.dateComponents(formatter.1, from: date)

        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.calendar = calendar
        componentsFormatter.unitsStyle = .spellOut
        return componentsFormatter.string(from: components) ?? "Erro ao formatar o tempo."
    }
}

// MARK: - Base64 -

/// Extension providing Base64 encoding and decoding utilities.
public extension String {
    /// The string encoded as Base64.
    var base64Encode: String? { self.data(using: .utf8)?.base64EncodedString() }

    /// The Base64-decoded string.
    var base64Decode: String? { String(data: Data(base64Encoded: self) ?? Data(), encoding: .utf8) }

    /// The Base64-decoded Data.
    var asBase64data: Data? { Data(base64Encoded: self) }
}

// MARK: - Localized -

/// Extension providing localization utilities.
public extension String {
    /// Returns the localized version of the string based on Bundle method.
    ///
    /// - Parameter bundle: The bundle containing localization resources. Defaults `.main` bundle.
    /// - Parameter table: The table where localized strings are. Defaults to `Localizable.strings`.
    /// - Returns: The localized string, or the original string if no localization exists.
    func localized(
        bundle: Bundle = .main,
        table: String? = nil
    ) -> String {
        bundle.localizedString(forKey: self, value: nil, table: table)
    }

    /// Returns the localized version of the string based on String method.
    ///
    /// - Parameter bundle: The bundle containing localization resources. Defaults `.main` bundle.
    /// - Parameter table: The table where localized strings are. Defaults to `Localizable.strings`.
    /// - Returns: The localized string, or the original string if no localization exists.
    func localizedString(
        bundle: Bundle = .main,
        table: String? = nil
    ) -> String {
        String(localized: String.LocalizationValue(stringLiteral: self),
               table: table,
               bundle: bundle)
    }

    /// Returns the localized version of the string based on LocalizedStringResource method.
    ///
    /// - Parameter bundle: The bundle containing localization resources. Defaults `.main` bundle.
    /// - Parameter table: The table where localized strings are. Defaults to `Localizable.strings`.
    /// - Returns: The localized string, or the original string if no localization exists.
    func localizedStringFromResource(
        bundle: Bundle = .main,
        table: String? = nil
    ) -> String {
        let resource = LocalizedStringResource(
            String.LocalizationValue(stringLiteral: self),
            table: table,
            bundle: bundle
        )
        return String(localized: resource)
    }
}
