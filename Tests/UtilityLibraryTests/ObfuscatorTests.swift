import Testing
@testable import UtilityLibrary

@Suite("Dictionary tests")
struct ObfuscatorTests {
    @Test("ObfuscatorTests - obscure")
    func testObscure() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")
        #expect(obfuscated == [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    @Test("ObfuscatorTests - reveal")
    func testReveal() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
        #expect(revealed == "ObfuscatorTests")
    }

    @Test("ObfuscatorTests - incorrect obscure salt")
    func testObscureSaltIncorrect() async throws {
        let obfuscator = Obfuscator(with: "Salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")
        #expect(obfuscated != [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    @Test("ObfuscatorTests - incorrect reveal salt")
    func testRevealSaltIncorrect() async throws {
        let obfuscator = Obfuscator(with: "Salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
        #expect(revealed != "ObfuscatorTests")
    }

    @Test("ObfuscatorTests - incorrect obscure string")
    func testObscureStringIncorrect() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "obfuscatorTests")
        #expect(obfuscated != [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    @Test("ObfuscatorTests - incorrect reveal string")
    func testRevealStringIncorrect() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [60, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
        #expect(revealed != "obfuscatorTests")
    }

    @Test("ObfuscatorTests - incorrect obscure result")
    func testObscureResultIncorrect() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let obfuscated = obfuscator.bytesByObfuscatingString(string: "ObfuscatorTests")
        #expect(obfuscated != [0, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
    }

    @Test("ObfuscatorTests - incorrect reveal result")
    func testRevealResultIncorrect() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [0, 3, 10, 1, 0, 2, 13, 0, 28, 19, 56, 17, 0, 21, 31])
        #expect(revealed != "ObfuscatorTests")
    }

    @Test("ObfuscatorTests - empty")
    func testRevealEmptyKey() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [])
        #expect(Bool(revealed.isEmpty))
    }

    @Test("ObfuscatorTests - no key")
    func testRevealKeyNotString() async throws {
        let obfuscator = Obfuscator(with: "salt")
        let revealed = obfuscator.reveal(key: [255])
        #expect(Bool(revealed.isEmpty))
    }
}
