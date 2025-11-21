import Foundation

extension String {
	var formattedYTDuration: String {
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

	var formattedBigNumber: String {
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

	var webQueryFormatted: String {
		guard let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
			return ""
		}
		return escapedString
	}

	var hmlDecoded: String {
		let decoded = try? NSAttributedString(data: Data(utf8), options: [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		], documentAttributes: nil).string

		return decoded ?? self
	}

    func formattedDate(using format: String = "dd/MM") -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		let date = dateFormatter.date(from: self) ?? Date()

		dateFormatter.dateFormat = format
		dateFormatter.timeZone = TimeZone(abbreviation: "BRT")
		return dateFormatter.string(from: date)
	}

	func toDate() -> Date {
		// Expected date format: "Tue, 26 Feb 2019 23:00:53 +0000"
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		return dateFormatter.date(from: self.replacingOccurrences(of: ".000", with: "")) ?? Date()
	}
}
