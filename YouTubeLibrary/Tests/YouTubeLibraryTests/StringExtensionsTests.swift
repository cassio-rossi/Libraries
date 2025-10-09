import XCTest
@testable import YouTubeLibrary

class StringExtensionsTests: XCTestCase {

    // MARK: - Youtube related -

    func testDurationFormattedString() {
        let original = "PT4M13S"
        let expected = "04:13"

        XCTAssertEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringWithHour() {
        let original = "PT2H4M13S"
        let expected = "02:04:13"

        XCTAssertEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringNotYoutubeFormatt() {
        let original = "02:04:13"
        let expected = "02:04:13"

        XCTAssertEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringNotYoutubeFormattFailed() {
        let original = "02C04D13"
        let expected = "02:04:13"

        XCTAssertNotEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringNotYoutubeFormattReturnZero() {
        let original = "02C04D13"
        let expected = "00"

        XCTAssertEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringEmpty() {
        let original = ""
        let expected = ""

        XCTAssertNotEqual(original.formattedYTDuration, expected)
    }

    func testDurationFormattedStringEmptyReturnZero() {
        let original = ""
        let expected = "00"

        XCTAssertEqual(original.formattedYTDuration, expected)
    }

    func testBigNumberGreaterMillion() {
        let original = "1000001"
        let expected = "1.0M"

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

    func testBigNumberGreaterMillionFailed() {
        let original = "1.000.001"
        let expected = "1.0M"

        XCTAssertNotEqual(original.formattedYTDuration, expected)
    }

    func testBigNumberGreaterMillionFormatted() {
        let original = "1,000,001.00"
        let expected = "1.0M"

        XCTAssertNotEqual(original.formattedYTDuration, expected)
    }

    func testBigNumberEqualMillion() {
        let original = "1000000"
        let expected = "1000.0K"

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

    func testBigNumberGreaterThousand() {
        let original = "10000"
        let expected = "10.0K"

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

    func testBigNumberEqualThousand() {
        let original = "1000"
        let expected = "1000"

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

    func testBigNumberLessThousand() {
        let original = "999"
        let expected = "999"

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

    func testBigNumberNotNumber() {
        let original = "ABC"
        let expected = ""

        XCTAssertEqual(original.formattedBigNumber, expected)
    }

}
