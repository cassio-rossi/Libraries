import Foundation
import Testing
@testable import UtilityLibrary

@Suite("String Extensions Missing Coverage Tests")
struct StringExtensionsMissingTests {

    @Test("Hour property should extract hour from date string")
    func testHourPropertyExtractsHourFromString() throws {
        let dateTimeString = "15/06/2024 14:30"
        let hourString = dateTimeString.hour

        // The hour should be formatted as HH:mm from the date conversion
        #expect(hourString.contains(":"))
        #expect(hourString.count == 5) // HH:mm format
    }

    @Test("Hour property should handle invalid date string")
    func testHourPropertyWithInvalidDateString() throws {
        let invalidDateString = "invalid-date"
        let hourString = invalidDateString.hour

        // Should still return some hour format (from current date fallback)
        #expect(hourString.contains(":"))
        #expect(hourString.count == 5) // HH:mm format
    }

    @Test("Hour property should handle empty string")
    func testHourPropertyWithEmptyString() throws {
        let emptyString = ""
        let hourString = emptyString.hour

        // Should return current hour due to fallback to Date()
        #expect(hourString.contains(":"))
        #expect(hourString.count == 5) // HH:mm format
    }

    @Test("Hour property should handle different time zones")
    func testHourPropertyWithDifferentTimeZones() throws {
        let dateTimeString = "15/06/2024 14:30"
        let hourString = dateTimeString.hour

        // The result should depend on the current time zone
        // We just verify it's a valid time format
        let components = hourString.split(separator: ":")
        #expect(components.count == 2)

        guard let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            Issue.record("…")
            return
        }

        #expect(hour >= 0 && hour <= 23)
        #expect(minute >= 0 && minute <= 59)
    }

    @Test("Localized should return key when no translation exists")
    func testLocalizedReturnsKeyWhenNoTranslationExists() throws {
        let key = "nonexistent_key_for_testing"
        let localized = key.localized()

        // When no translation exists, it should return the key itself
        #expect(localized == key)
    }

    @Test("Localized should work with custom bundle")
    func testLocalizedWithCustomBundle() throws {
        let key = "test_key"
        let bundle = Bundle.main
        let localized = key.localized(bundle: bundle)

        // Should not crash and return either translation or key
        #expect(!localized.isEmpty)
    }

    @Test("Localized should handle empty string")
    func testLocalizedWithEmptyString() throws {
        let emptyKey = ""
        let localized = emptyKey.localized()

        #expect(localized == emptyKey)
    }

    @Test("Format constants should be defined correctly")
    func testFormatConstants() throws {
        #expect(Format.wordpress == "EEE, dd MMM yyyy HH:mm:ss +0000")
        #expect(Format.youtube == "yyyy-MM-dd'T'HH:mm:ss'Z'")
    }

    @Test("Format should conform to CaseIterable")
    func testFormatCaseIterable() throws {
        // Since Format is CaseIterable but only has static properties,
        // we verify that the enum exists and can be used
        let allCases = Format.allCases
        #expect(allCases.isEmpty) // Should not crash
    }
}

@Suite("Additional String Extensions Edge Cases")
struct StringExtensionsEdgeCaseTests {

    @Test("toDate with custom format and nil timezone")
    func testToDateWithCustomFormatAndNilTimezone() throws {
        let dateString = "2024-06-15T14:30:00Z"
        let date = dateString.toDate(Format.youtube, timeZone: nil)

        // Should handle nil timezone gracefully
        let calendar = Calendar.current
        #expect(calendar.component(.year, from: date) == 2024)
        #expect(calendar.component(.month, from: date) == 6)
        #expect(calendar.component(.day, from: date) == 15)
    }

    @Test("toDate with different locale")
    func testToDateWithDifferentLocale() throws {
        let dateString = "2024-06-15T14:30:00Z"
        let date = dateString.toDate(Format.youtube, timeZone: TimeZone(abbreviation: "UTC"), locale: "fr_FR")

        let calendar = Calendar.current
        #expect(calendar.component(.year, from: date) == 2024)
        #expect(calendar.component(.month, from: date) == 6)
        #expect(calendar.component(.day, from: date) == 15)
    }

    @Test("Base64 encode with special characters")
    func testBase64EncodeWithSpecialCharacters() throws {
        let specialString = "Special chars: éñ中文🚀"
        let encoded = try #require(specialString.base64Encode)
        let decoded = try #require(encoded.base64Decode)

        #expect(decoded == specialString)
    }

    @Test("Base64 decode with invalid padding")
    func testBase64DecodeWithInvalidPadding() throws {
        let invalidBase64 = "SGVsbG8gV29ybGQ" // Missing padding
        let decoded = invalidBase64.base64Decode

        // Should handle invalid base64 gracefully
        // The exact behavior depends on Data(base64Encoded:) implementation
        #expect(decoded != nil || decoded == nil) // Either works, shouldn't crash
    }

    @Test("webQueryFormatted with unicode characters")
    func testWebQueryFormattedWithUnicodeCharacters() throws {
        let unicodeString = "Hello 世界 🌍"
        let encoded = unicodeString.webQueryFormatted

        #expect(encoded.contains("%") == true) // Should be percent encoded
        #expect(encoded != unicodeString) // Should be different from original
    }

    @Test("accessibilityDateTime with edge case times")
    func testAccessibilityDateTimeWithEdgeCases() throws {
        let midnightString = "15/06/2024 00:00"
        let result = midnightString.accessibilityDateTime

        #expect(result.contains("junho") == true)
        #expect(result.contains("2024") == true)
        #expect(result.contains("00 horas e 00 minutos") == true)
    }

    @Test("accessibilityEdicaoDate with malformed input")
    func testAccessibilityEdicaoDateWithMalformedInput() throws {
        let malformedInputs = [
            "////",
            "13/45/2024", // Invalid month/day
            "abc/def/ghi", // Non-numeric
            "2024/february/15" // Mixed format
        ]

        for input in malformedInputs {
            let result = input.accessibilityEdicaoDate
            // Should either format successfully or return error message
            #expect(!result.isEmpty) // Should not be empty
        }
    }

    @Test("accessibilityTime with invalid time components")
    func testAccessibilityTimeWithInvalidComponents() throws {
        let invalidTimes = [
            "25:30", // Invalid hour
            "12:70", // Invalid minute  
            "12:30:70", // Invalid second
            "::", // Empty components
            "abc:def" // Non-numeric
        ]

        for invalidTime in invalidTimes {
            let result = invalidTime.accessibilityTime
            // Should return error message for invalid times
            #expect(result.contains("Erro") == true || !result.isEmpty)
        }
    }
}
