import Foundation
@testable import LoggerLibrary
import Testing

@Suite("String Extensions split() Tests")
struct StringExtensionsTests {
    @Test("StringExtensions - Split with default separator")
    func testSplitWithDefaultSeparator() throws {
        let text = "Hello World"
        let chunks = text.split(by: 5)

        #expect(chunks == ["Hello", " Worl", "d"])
    }

    @Test("StringExtensions - Split with custom separator")
    func testSplitWithCustomSeparator() throws {
        let text = "Hello World"
        let chunks = text.split(by: 5, separator: "✄")

        #expect(chunks == ["Hello✄", "✄ Worl✄", "✄d"])
    }

    @Test("StringExtensions - Split empty string")
    func testSplitWithEmptyString() throws {
        let text = ""
        let chunks = text.split(by: 5)

        #expect(chunks == [""])
    }

    @Test("StringExtensions - Split with length larger than string")
    func testSplitWithLengthLargerThanString() throws {
        let text = "Hello"
        let chunks = text.split(by: 10)

        #expect(chunks == ["Hello"])
    }

    @Test("StringExtensions - Split with single character length")
    func testSplitWithSingleCharacterLength() throws {
        let text = "Hello"
        let chunks = text.split(by: 1, separator: "+")

        #expect(chunks == ["H+", "+e+", "+l+", "+l+", "+o"])
    }

    @Test("StringExtensions - Split with special characters")
    func testSplitWithSpecialCharacters() throws {
        let text = "Hello\nWorld\t!"
        let chunks = text.split(by: 5)

        #expect(chunks == ["Hello", "\nWorl", "d\t!"])
    }

    @Test("StringExtensions - Split with unicode characters")
    func testSplitWithUnicodeCharacters() throws {
        let text = "Hello 👋 World 🌎"
        let chunks = text.split(by: 6)

        #expect(chunks == ["Hello ", "👋 Worl", "d 🌎"])
    }

    @Test("StringExtensions - Split with zero length")
    func testSplitWithZeroLength() throws {
        let text = "Hello"
        let chunks = text.split(by: 0)

        #expect(chunks == ["Hello"]) // Or handle as error case
    }

    @Test("StringExtensions - Split with negative length")
    func testSplitWithNegativeLength() throws {
        let text = "Hello"
        let chunks = text.split(by: -5)

        #expect(chunks == ["Hello"]) // Or handle as error case
    }
}
