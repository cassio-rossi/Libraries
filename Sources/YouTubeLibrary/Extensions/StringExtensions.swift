import Foundation

extension String {
    /// Converts YouTube's ISO 8601 duration format to a readable time string.
    ///
    /// Transforms formats like "PT4M13S" into "04:13" and "PT1H2M30S" into "01:02:30".
    ///
    /// - Returns: Formatted duration string with zero-padded components.
    public var formattedYTDuration: String {
        // Expected date format: "PT4M13S"
        // PT = fixed
        // 4M = 4 minutes
        // 13S = 13 seconds
        let formattedDuration = self
            .replacingOccurrences(of: "PT", with: "")
            .replacingOccurrences(of: "H", with: ":")
            .replacingOccurrences(of: "M", with: ":")
            .replacingOccurrences(of: "S", with: "")

        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            let value = Int(component) ?? 0
            duration = duration.isEmpty ? duration : duration + ":"
            duration += String(format: "%02d", value)
        }

        return duration
    }

    /// Formats large numbers with K (thousands) or M (millions) suffix.
    ///
    /// Converts numbers like "1500" to "1.5K" and "2500000" to "2.5M".
    ///
    /// - Returns: Abbreviated number string with appropriate suffix.
    public var formattedBigNumber: String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        guard var value = Double(self) else {
            return ""
        }
        var complement = ""
        switch value {
        case let amount where amount > 1_000_000:
            value /= 1_000_000
            complement = "M"
        case let amount where amount > 1_000:
            value /= 1_000
            complement = "K"
        default:
            break
        }
        var formattedString = String(format: "%.1f", value)
        if Double(self) ?? 0 <= 1000 {
            formattedString = String(format: "%.0f", value)
        }
        return "\(formattedString)\(complement)"
    }

    /// Formats an ISO 8601 date string into a localized format.
    ///
    /// - Parameter format: The desired output date format (default: "dd/MM").
    /// - Returns: Formatted date string in BRT timezone.
    public func formattedDate(using format: String = "dd/MM") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: self) ?? Date()

        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
        return dateFormatter.string(from: date)
    }

    /// Converts an ISO 8601 date string to a Date object.
    ///
    /// - Returns: Date object parsed from the string, or current date if parsing fails.
    public func toDate() -> Date {
        // Expected date format: "Tue, 26 Feb 2019 23:00:53 +0000"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: self.replacingOccurrences(of: ".000", with: "")) ?? Date()
    }
}

extension String {
    var accessibilityTime: String {
        let array = self.split { $0 == ":" }.map( String.init )

        if array.count == 3 {
            let hours = array[0]
            let minutes = array[1]
            let seconds = array[2]

            return "\(hours.spokenHours)\(minutes.toSpokenMinutes(elementsQuantity: 3))\(seconds.spokenSeconds)"
        } else if array.count == 2 {
            let minutes = array[0]
            let seconds = array[1]

            return "\(minutes.toSpokenMinutes(elementsQuantity: 2))\(seconds.spokenSeconds)"
        } else {
            let seconds = array[0]

            return "\(seconds.spokenSeconds)"
        }
    }

    private var spokenHours: String {
        if Int(self) == 1 {
            return "Uma hora"
        } else {
            return "\(self) horas"
        }
    }

    private func toSpokenMinutes(elementsQuantity: Int) -> String {
        if Int(self) == 0 {
            return " "
        } else if Int(self) == 1 {
            return elementsQuantity == 2 ? "Um minuto" : ", Um minuto"
        } else {
            return elementsQuantity == 2 ? "\(self) minutos" : ", \(self) minutos"
        }
    }

    private var spokenSeconds: String {
        if Int(self) == 0 {
            return "."
        } else if Int(self) == 1 {
            return " e um segundo."
        } else {
            return " e \(self) segundos."
        }
    }
}

extension String {
	/// Encodes the string for use in URL queries.
	///
	/// - Returns: Percent-encoded string safe for URL parameters.
	var webQueryFormatted: String {
		guard let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
			return ""
		}
		return escapedString
	}

	/// Decodes HTML entities in the string.
	///
	/// Converts HTML encoded characters like "&amp;" to their plain text equivalents.
	///
	/// - Returns: Decoded string with HTML entities resolved.
	var hmlDecoded: String {
		let decoded = try? NSAttributedString(data: Data(utf8), options: [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		], documentAttributes: nil).string

		return decoded ?? self
	}
}
