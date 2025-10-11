import Testing
@testable import YouTubeLibrary

@Suite("YouTube String Extensions Tests")
struct StringExtensionsTests {

    // MARK: - Youtube related -

    @Test("Duration formatted string - basic format")
    func testDurationFormattedString() {
        let original = "PT4M13S"
        let expected = "04:13"

        #expect(original.formattedYTDuration == expected)
    }

    @Test("Duration formatted string with hour")
    func testDurationFormattedStringWithHour() {
        let original = "PT2H4M13S"
        let expected = "02:04:13"

        #expect(original.formattedYTDuration == expected)
    }

    @Test("Duration formatted string not YouTube format")
    func testDurationFormattedStringNotYoutubeFormatt() {
        let original = "02:04:13"
        let expected = "02:04:13"

        #expect(original.formattedYTDuration == expected)
    }

    @Test("Duration formatted string not YouTube format - should fail")
    func testDurationFormattedStringNotYoutubeFormattFailed() {
        let original = "02C04D13"
        let expected = "02:04:13"

        #expect(original.formattedYTDuration != expected)
    }

    @Test("Duration formatted string not YouTube format - returns zero")
    func testDurationFormattedStringNotYoutubeFormattReturnZero() {
        let original = "02C04D13"
        let expected = "00"

        #expect(original.formattedYTDuration == expected)
    }

    @Test("Duration formatted string empty - should not equal")
    func testDurationFormattedStringEmpty() {
        let original = ""
        let expected = ""

        #expect(original.formattedYTDuration != expected)
    }

    @Test("Duration formatted string empty - returns zero")
    func testDurationFormattedStringEmptyReturnZero() {
        let original = ""
        let expected = "00"

        #expect(original.formattedYTDuration == expected)
    }

    @Test("Big number greater than million")
    func testBigNumberGreaterMillion() {
        let original = "1000001"
        let expected = "1.0M"

        #expect(original.formattedBigNumber == expected)
    }

    @Test("Big number greater than million - should fail")
    func testBigNumberGreaterMillionFailed() {
        let original = "1.000.001"
        let expected = "1.0M"

        #expect(original.formattedYTDuration != expected)
    }

    @Test("Big number greater than million formatted - should fail")
    func testBigNumberGreaterMillionFormatted() {
        let original = "1,000,001.00"
        let expected = "1.0M"

        #expect(original.formattedYTDuration != expected)
    }

    @Test("Big number equal to million")
    func testBigNumberEqualMillion() {
        let original = "1000000"
        let expected = "1000.0K"

        #expect(original.formattedBigNumber == expected)
    }

    @Test("Big number greater than thousand")
    func testBigNumberGreaterThousand() {
        let original = "10000"
        let expected = "10.0K"

        #expect(original.formattedBigNumber == expected)
    }

    @Test("Big number equal to thousand")
    func testBigNumberEqualThousand() {
        let original = "1000"
        let expected = "1000"

        #expect(original.formattedBigNumber == expected)
    }

    @Test("Big number less than thousand")
    func testBigNumberLessThousand() {
        let original = "999"
        let expected = "999"

        #expect(original.formattedBigNumber == expected)
    }

    @Test("Big number not a number")
    func testBigNumberNotNumber() {
        let original = "ABC"
        let expected = ""

        #expect(original.formattedBigNumber == expected)
    }

}
