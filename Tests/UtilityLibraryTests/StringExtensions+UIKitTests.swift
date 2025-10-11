#if canImport(UIKit)
import Foundation
import Testing
import UIKit
@testable import UtilityLibrary

@Suite("String Height Tests")
struct StringHeightTests {
    @Test
    func testHeightCalculation() {
        let str = "A\nB\nC"
        let font = UIFont.systemFont(ofSize: 17)
        let width: CGFloat = 200
        let height = str.height(withWidth: width, font: font)
        #expect(height > 0)
    }

    @Test
    func testHtmlDecoded() {
        let html = "<b>bold</b>"
        #expect(html.htmlDecoded.contains("bold"))
        let plain = "plain text"
        #expect(plain.htmlDecoded == plain)
    }

    @Test
    func testDecodeString() {
        let original = "Por padrão, se você não adicionar fotos aos seus contatos manualmente, o iPhone preenche o espaço do avatar [&#8230;]"
        let expected = "Por padrão, se você não adicionar fotos aos seus contatos manualmente, o iPhone preenche o espaço do avatar […]"
        #expect(original.htmlDecoded == expected)
    }

    @Test
    func testDecodeStringFailed() {
        let original = "Por padrão, se você não adicionar fotos aos seus contatos manualmente, o iPhone preenche o espaço do avatar [&#8230;]"
        let expected = "Por padrão, se você não adicionar fotos aos seus contatos manualmente, o iPhone preenche o espaço do avatar [...]"
        #expect(original.htmlDecoded != expected)
    }

    @Test
    func testDecodeStringNoSpecialCharacter() {
        let original = "Por padrão, se você não adicionar fotos aos seus contatos manualmente ..."
        let expected = "Por padrão, se você não adicionar fotos aos seus contatos manualmente ..."
        #expect(original.htmlDecoded == expected)
    }
}
#endif
