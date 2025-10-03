import Foundation

// MARK: - Basic -

public extension String {
    /// Converts the string to UTF-8 encoded Data.
    /// - Returns: A Data representation of the string or nil if encoding fails.
    var asData: Data? { self.data(using: .utf8) }
}

// MARK: - Web related -

public extension String {
    /// Returns a percent-encoded string suitable for use in a URL query.
    /// - Returns: The percent-encoded string or an empty string if encoding fails.
    var webQueryFormatted: String {
        guard let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return ""
        }
        return escapedString
    }
}

// MARK: - Dates -

/// Common date formats for parsing and formatting strings.
public enum Format: CaseIterable {
    static let wordpress = "EEE, dd MMM yyyy HH:mm:ss +0000"
    static let youtube = "yyyy-MM-dd'T'HH:mm:ss'Z'"
}

public extension String {
    /// Extracts the hour component from the string using the given date format.
    /// - Returns: The hour portion of the date string.
    var hour: String { self.toDate(format: DateFormat.hourOnly).hour }

    /// Converts the string to a Date using the provided format, time zone, and locale.
    /// - Parameters:
    ///   - format: The date format string. Defaults to the Wordpress format.
    ///   - timeZone: The time zone to use. Defaults to UTC.
    ///   - locale: The locale identifier to use. Defaults to "en_US".
    /// - Returns: The parsed Date or the current date if parsing fails.
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

    /// Converts the string to a Date using the given DateFormat.
    /// - Parameter format: The format to use. Defaults to `.dateOnly`.
    /// - Returns: The parsed Date or the current date if parsing fails.
    func toDate(format: DateFormat = .dateOnly) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }

    /// Returns a localized, accessible date-time string in extended Portuguese format.
    /// - Returns: A string such as "dd 'de' MMMM 'de' yyyy 'às' HH 'horas e' mm 'minutos'" or an error message.
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

    /// Returns a localized, accessible edition date in Portuguese, based on slash-separated segments.
    /// - Returns: A readable Portuguese string for the date or an error message.
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

    /// Returns a localized, accessible time string in Portuguese.
    /// - Returns: A string with time spelled out or an error message if formatting fails.
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

public extension String {
    /// Encodes the string to Base64.
    /// - Returns: A Base64-encoded string or nil if encoding fails.
    var base64Encode: String? { self.data(using: .utf8)?.base64EncodedString() }
    /// Decodes the Base64 string.
    /// - Returns: A decoded string or nil if decoding fails.
    var base64Decode: String? { String(data: Data(base64Encoded: self) ?? Data(), encoding: .utf8) }
}

// MARK: - Localized -

public extension String {
    func localized(bundle: Bundle = .main) -> String {
        NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
