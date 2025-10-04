import Foundation
import Testing
@testable import UtilityLibrary

@Suite("Date Extensions Tests")
struct DateExtensionsTests {
    var date: Date {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 50
        components.timeZone = TimeZone(secondsFromGMT: -3 * 3600) // BRT is UTC-3
        return Calendar.current.date(from: components) ?? Date()
    }

    @Test("Date only format")
    func testDateFormat() throws {
        let value = date.format(using: .dateOnly)
        #expect(value == "10/10/1969")
    }

    @Test("Date only format - incorrect format")
    func testDateFormatFailed() throws {
        let value = date.format(using: .dateOnly)
        #expect(value != "19691010")
    }

    @Test("Date only format - incorrect date")
    func testDateFormatFailedDate() throws {
        let value = date.format(using: .dateOnly)
        #expect(value != "19/10/1969")
    }

    @Test("Sorted date format")
    func testSortFormat() throws {
        let value = date.format(using: .sortedDate)
        #expect(value == "19691010")
    }

    @Test("Sorted date format - incorrect format")
    func testSortFormatFailed() throws {
        let value = date.format(using: .sortedDate)
        #expect(value != "1969/10/10")
    }

    @Test("Date time format")
    func testDateTimeFormat() throws {
        let value = date.format(using: .dateTime)
        #expect(value == "10/10/1969 08:20")
    }

    @Test("Date time format - incorrect time")
    func testDateTimeFormatFailed() throws {
        let value = date.format(using: .dateTime)
        #expect(value != "10/10/1969 04:20")
    }

    @Test("Date time format with different timezone")
    func testDateTimeFormatTimezone() throws {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 50
        components.timeZone = TimeZone(secondsFromGMT: 0) // GMT is UTC-0

        let gmtDate = Calendar.current.date(from: components)
        let value = gmtDate?.format(using: .dateTime)
        #expect(value == "10/10/1969 05:20")
    }

    @Test("Date format using enum formatter")
    func testDateFormatUsingEnumFormatter() throws {
        let value = date.format(using: .sortedDate)
        #expect(value == "19691010")

        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.timeZone = TimeZone(secondsFromGMT: -3 * 3600) // BRT is UTC-3

        let expectedDate = Calendar.current.date(from: components)
        let formattedDate = (value).toDate(format: .sortedDate)

        #expect(expectedDate == formattedDate)
    }

    @Test("Date format with custom locale")
    func testDateFormatWithLocale() throws {
        let frenchLocale = Locale(identifier: "fr_FR")
        let value = date.format(using: "MMMM", locale: frenchLocale)
        #expect(value == "octobre")
    }

    @Test("Date format with custom format string")
    func testDateFormatWithCustomFormat() throws {
        let value = date.format(using: "EEEE, MMM d, yyyy")
        #expect(value == "Friday, Oct 10, 1969")
    }

    @Test("Date format with custom timezone")
    func testDateFormatWithCustomTimezone() throws {
        let estTimezone = TimeZone(secondsFromGMT: -5 * 3600) // EST is UTC-5
        let value = date.format(using: DateFormat.dateTime.rawValue, timezone: estTimezone)
        #expect(value == "10/10/1969 06:20")
    }

    @Test("Date format with all custom parameters")
    func testDateFormatWithAllCustomParameters() throws {
        let japaneseLocale = Locale(identifier: "ja_JP")
        let tokyoTimezone = TimeZone(identifier: "Asia/Tokyo")
        let value = date.format(using: "yyyy年MM月dd日 HH:mm", locale: japaneseLocale, timezone: tokyoTimezone)
        #expect(value == "1969年10月10日 20:20")
    }

    @Test("Date format with default parameters")
    func testDateFormatWithDefaultParameters() throws {
        let value = date.format(using: "dd/MM/yyyy")
        #expect(value == "10/10/1969")
    }

    @Test("Hour computed property returns correct hour for known date")
    func testHourProperty() throws {
        #expect(date.format(using: DateFormat.hourOnly.rawValue,
                           timezone: TimeZone(secondsFromGMT: 1 * 3600)) == "12:20")
    }

    @Test("Hour property reflects local time zone")
    func testHourPropertyWithTimezoneChange() throws {
        var components = DateComponents()
        components.day = 10
        components.month = 10
        components.year = 1969
        components.hour = 8
        components.minute = 20
        components.second = 50
        components.timeZone = TimeZone(secondsFromGMT: 0) // GMT (UTC+0)
        let gmtDate = Calendar.current.date(from: components) ?? Date()

        // Calculate expected hour in current time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        let expectedHour = dateFormatter.string(from: gmtDate)
        #expect(gmtDate.hour == expectedHour)
    }
}
