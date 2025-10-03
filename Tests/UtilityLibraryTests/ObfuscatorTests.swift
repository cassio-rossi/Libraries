@testable import UtilityLibrary
import XCTest

final class ObfuscatorTests: XCTestCase {
    func testObscure() {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")

        XCTAssertEqual(obfuscated, [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    func testReveal() {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])

        XCTAssertEqual(revealed, "ObfuscatorTests")
    }

    func testObscureSaltIncorrect() {
        let obfuscator = Obfuscator(with: "Salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")

        XCTAssertNotEqual(obfuscated, [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    func testRevealSaltIncorrect() {
        let obfuscator = Obfuscator(with: "Salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])

        XCTAssertNotEqual(revealed, "ObfuscatorTests")
    }

    func testObscureStringIncorrect() {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "obfuscatorTests")

        XCTAssertNotEqual(obfuscated, [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    func testRevealStringIncorrect() {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])

        XCTAssertNotEqual(revealed, "obfuscatorTests")
    }

    func testObscureResultIncorrect() {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")

        XCTAssertNotEqual(obfuscated, [0, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    func testRevealResultIncorrect() {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [0, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])

        XCTAssertNotEqual(revealed, "ObfuscatorTests")
    }

    func testRevealEmptyKey() {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [])

        XCTAssertEqual(revealed, "")
    }

    func testRevealKeyNotString() {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [255])

        XCTAssertEqual(revealed, "")
    }
}
