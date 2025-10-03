import Foundation
import Testing
@testable import UtilityLibrary

@Suite("String Date Tests")
struct StringExtensionsTests {
    @Test("Date conversion with valid date only")
    func testToDateWithValidDateOnly() throws {
        let dateString = "20/03/2024"
        let date = dateString.toDate()

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "BRT")
        formatter.dateFormat = "dd/MM/yyyy"

        #expect(formatter.string(from: date) == dateString)
    }

    @Test("Date conversion with different timezone")
    func testToDateWithDifferentTimeZone() throws {
        let dateString = "20/03/2024"
        let date = dateString.toDate()

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "dd/MM/yyyy"

        #expect(formatter.string(from: date) == dateString)
    }

    @Test("Date conversion with sortedDate format")
    func testToDateWithSortedDate() throws {
        let sortedDateString = "20240320"
        let date = sortedDateString.toDate(format: .sortedDate)

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: -3 * 3600)
        formatter.dateFormat = "yyyyMMdd"

        #expect(formatter.string(from: date) == sortedDateString)
    }

    @Test("Date conversion with dateTime format")
    func testToDateWithDateTime() throws {
        let sortedDateString = "20/03/2024 08:20"
        let date = sortedDateString.toDate(format: .dateTime)

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: -3 * 3600)
        formatter.dateFormat = "dd/MM/yyyy HH:mm"

        #expect(formatter.string(from: date) == sortedDateString)
    }

    @Test("Date conversion with invalid format",
          arguments: ["invalid-date", "45/13/2024", ""])
    func testToDateWithInvalidFormat(_ invalidDate: String) throws {
        // Compare only the date components that matter
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: invalidDate.toDate())
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())

        #expect(dateComponents.year == currentComponents.year)
        #expect(dateComponents.month == currentComponents.month)
        #expect(dateComponents.day == currentComponents.day)
    }

    @Test
    func testToDateWithFormat() {
        let str = "2020-01-01T12:00:00Z"
        let date = str.toDate(Format.youtube)
        let calendar = Calendar(identifier: .gregorian)
        #expect(calendar.component(.year, from: date) == 2020)
        #expect(calendar.component(.hour, from: date) == 12)
    }

    @Test
    func testToDateDefault() {
        let str = "15/06/2024"
        let date = str.toDate(format: .dateOnly)
        let calendar = Calendar.current
        #expect(calendar.component(.year, from: date) == 2024)
    }

    @Test
    func testAccessibilityDateTime() {
        #expect("15/06/2024 14:30".accessibilityDateTime == "15 de junho de 2024 às 14 horas e 30 minutos")
        #expect("15/13/2024 14:30".accessibilityDateTime == "Erro ao formatar a data.")
    }

    @Test
    func testAccessibilityEdicaoDate() {
        #expect("15/junho/2024".accessibilityEdicaoDate == "15 de junho de 2024")
        #expect("junho/2024".accessibilityEdicaoDate == "junho de 2024")
        #expect("2024".accessibilityEdicaoDate == "2024")
        #expect("15/13/2024 14:30".accessibilityEdicaoDate == "Erro ao formatar o tempo.")
    }

    @Test
    func testAccessibilityTime() {
        #expect("01:02:03".accessibilityTime == "one hour, two minutes, three seconds")
        #expect("01:02".accessibilityTime == "one minute, two seconds")
        #expect("01".accessibilityTime == "one second")
        #expect("01:02:65".accessibilityTime == "Erro ao formatar o tempo.")
    }
}

@Suite("String Data Tests")
struct StringExtensionsAsDataTests {
    @Test("asData should return Data for non-empty string")
    func testAsDataWithNonEmptyString() throws {
        let string = "Hello, world!"
        let data = try #require(string.asData, "Expected non-nil Data for a non-empty string")
        #expect(String(data: data, encoding: .utf8) == string)
    }

    @Test("asData should return Data for empty string")
    func testAsDataWithEmptyString() throws {
        let string = ""
        let data = try #require(string.asData, "Expected non-nil Data for a non-empty string")
        #expect(data.isEmpty)
    }

    @Test("asData is always non-nil for valid Swift strings")
    func testAsDataIsNeverNilForValidString() throws {
        let strings = ["abc", "123", "😀", "\u{1F600}"]
        for string in strings {
            #expect(string.asData != nil)
        }
    }
}

@Suite("String Base64 Tests")
struct StringBase64Tests {
    @Test
    func testBase64EncodeDecode() {
        let str = "SwiftTest"
        let encoded = str.base64Encode ?? ""
        #expect(encoded == Data(str.utf8).base64EncodedString())
        #expect(encoded.base64Decode == str)
    }

    @Test
    func testBase64DecodeFailsGracefully() {
        let bad = "**notbase64$$"
        #expect(Bool((bad.base64Decode ?? "").isEmpty))
    }

    @Test
    func testEncode() {
        let original = "2021/Plus-Janeiro21-X-AdeusAgendadePapel.pdf"
        let expected = "MjAyMS9QbHVzLUphbmVpcm8yMS1YLUFkZXVzQWdlbmRhZGVQYXBlbC5wZGY="
        #expect(original.base64Encode == expected)
        #expect(("".base64Encode ?? "").isEmpty)
    }

    @Test
    func testDecode() {
        let expected = "2021/Plus-Janeiro21-X-AdeusAgendadePapel.pdf"
        let original = "MjAyMS9QbHVzLUphbmVpcm8yMS1YLUFkZXVzQWdlbmRhZGVQYXBlbC5wZGY="
        #expect(original.base64Decode == expected)
        #expect(("".base64Decode ?? "").isEmpty)
    }
}

@Suite("String Web Tests")
struct StringWebTests {
    @Test
    func testWebQueryFormatted() {
        let input = "a+b c@!"
        let expected = input.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        #expect(input.webQueryFormatted == expected)
    }

    @Test
    func testUrlEncoded() {
        let invalid = String(utf16CodeUnits: [0xD800], count: 1)
        #expect(Bool(invalid.webQueryFormatted.isEmpty))
    }

    @Test
    func testQueryFormattedString() {
        let original = "http://host.com?q=iPhone 12"
        let expected = "http://host.com?q=iPhone%2012"
        #expect(original.webQueryFormatted == expected)
    }

    @Test
    func testQueryFormattedStringFailed() {
        let original = "http://host.com?q=iPhone 12"
        let expected = "http://host.com?q=iPhone 12"
        #expect(original.webQueryFormatted != expected)
    }

    @Test
    func testQueryFormattedStringSpecialCharacter() {
        let original = "http://host.com?q=iPhone"
        let expected = "http://host.com?q=iPhone"
        #expect(original.webQueryFormatted == expected)
    }
}
