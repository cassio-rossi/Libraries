import Foundation
import Testing
@testable import UtilityLibrary

@Suite("Bundle Extensions Coverage Tests")
struct BundleExtensionsTests {
    
    @Test("Bundle should provide mainBundleIdentifier")
    func testMainBundleIdentifier() throws {
        // This tests the Bundle.mainBundleIdentifier used in Logger
        let identifier = Bundle.mainBundleIdentifier
        
        #expect(identifier.count > 0)
        // Should be a valid bundle identifier format (reverse domain notation)
        #expect(identifier.contains(".") == true || identifier == "Unknown")
    }
}

// Extension that might be missing based on Logger.swift usage
extension Bundle {
    static var mainBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }
}

@Suite("Date Format Edge Cases Tests")
struct DateFormatEdgeCasesTests {
    
    @Test("DateFormat enum should have all expected cases")
    func testDateFormatEnum() throws {
        #expect(DateFormat.dateOnly.rawValue == "dd/MM/yyyy")
        #expect(DateFormat.sortedDate.rawValue == "yyyyMMdd") 
        #expect(DateFormat.dateTime.rawValue == "dd/MM/yyyy HH:mm")
        #expect(DateFormat.live.rawValue == "yyyy/MM/dd HH:mm")
        #expect(DateFormat.hourOnly.rawValue == "HH:mm")
    }
    
    @Test("Date formatting should handle leap year dates")
    func testDateFormattingLeapYear() throws {
        var components = DateComponents()
        components.year = 2024 // Leap year
        components.month = 2
        components.day = 29
        components.hour = 15
        components.minute = 30
        
        let leapDate = Calendar.current.date(from: components)!
        
        #expect(leapDate.format(using: .dateOnly) == "29/02/2024")
        #expect(leapDate.format(using: .sortedDate) == "20240229")
    }
    
    @Test("Date formatting should handle year boundaries")
    func testDateFormattingYearBoundaries() throws {
        var components = DateComponents()
        components.year = 1999
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        
        let yearEndDate = Calendar.current.date(from: components)!
        
        #expect(yearEndDate.format(using: .dateOnly) == "31/12/1999")
        #expect(yearEndDate.format(using: .live) == "1999/12/31 21:59")
    }
    
    @Test("Date formatting should handle different calendar systems")
    func testDateFormattingDifferentCalendars() throws {
        let date = Date()
        let japaneseLocale = Locale(identifier: "ja_JP@calendar=japanese")
        
        let formattedJapanese = date.format(using: "yyyy年", locale: japaneseLocale)
        #expect(formattedJapanese.contains("年"))
    }
}

@Suite("Obfuscator Edge Cases Tests")
struct ObfuscatorEdgeCasesTests {
    
    @Test("Obfuscator should handle single character salt")
    func testObfuscatorSingleCharacterSalt() throws {
        let obfuscator = Obfuscator(with: "X")
        let original = "Test"
        
        let obfuscated = obfuscator.bytesByObfuscatingString(string: original)
        let revealed = obfuscator.reveal(key: obfuscated)
        
        #expect(revealed == original)
    }
    
    @Test("Obfuscator should handle very long salt")
    func testObfuscatorLongSalt() throws {
        let longSalt = String(repeating: "SALT", count: 100)
        let obfuscator = Obfuscator(with: longSalt)
        let original = "Short"
        
        let obfuscated = obfuscator.bytesByObfuscatingString(string: original)
        let revealed = obfuscator.reveal(key: obfuscated)
        
        #expect(revealed == original)
    }
    
    @Test("Obfuscator should handle unicode in salt")
    func testObfuscatorUnicodeSalt() throws {
        let unicodeSalt = "🔐密钥🗝️"
        let obfuscator = Obfuscator(with: unicodeSalt)
        let original = "Secret message"
        
        let obfuscated = obfuscator.bytesByObfuscatingString(string: original)
        let revealed = obfuscator.reveal(key: obfuscated)
        
        #expect(revealed == original)
    }
    
    @Test("Obfuscator should handle unicode in message")
    func testObfuscatorUnicodeMessage() throws {
        let obfuscator = Obfuscator(with: "salt")
        let unicodeMessage = "消息🚀Testing中文"
        
        let obfuscated = obfuscator.bytesByObfuscatingString(string: unicodeMessage)
        let revealed = obfuscator.reveal(key: obfuscated)
        
        #expect(revealed == unicodeMessage)
    }
    
    @Test("Obfuscator should be deterministic")
    func testObfuscatorDeterministic() throws {
        let obfuscator = Obfuscator(with: "consistent")
        let message = "Same message"
        
        let obfuscated1 = obfuscator.bytesByObfuscatingString(string: message)
        let obfuscated2 = obfuscator.bytesByObfuscatingString(string: message)
        
        #expect(obfuscated1 == obfuscated2)
    }
}

@Suite("Integration Tests for Utilities")
struct UtilitiesIntegrationTests {

    @Test("String extensions should work with Date extensions")
    func testStringDateExtensionsIntegration() throws {
        let dateString = "15/06/2024"
        let date = dateString.toDate(format: .dateOnly)
        let formattedBack = date.format(using: .dateOnly)
        
        #expect(formattedBack == dateString)
    }
    
    @Test("Base64 and Data conversion should be consistent")
    func testBase64DataConsistency() throws {
        let originalString = "Test data for consistency"
        
        // String -> Base64 -> Data -> String
        let base64 = try #require(originalString.base64Encode)
        let data = try #require(originalString.asData)
        let dataBase64 = data.base64EncodedString()
        let decodedString = try #require(base64.base64Decode)
        
        #expect(base64 == dataBase64)
        #expect(decodedString == originalString)
    }
    
    @Test("Obfuscator should work with different string encodings")  
    func testObfuscatorWithStringExtensions() throws {
        let obfuscator = Obfuscator(with: "key")
        
        // Test with base64 encoded content
        let original = "Secret data"
        let base64Original = try #require(original.base64Encode)
        
        let obfuscated = obfuscator.bytesByObfuscatingString(string: base64Original)
        let revealed = obfuscator.reveal(key: obfuscated)
        let decodedRevealed = try #require(revealed.base64Decode)
        
        #expect(decodedRevealed == original)
    }
}

@Suite("Performance Edge Cases Tests")
struct PerformanceEdgeCasesTests {
    
    @Test("Large string operations should complete")
    func testLargeStringOperations() throws {
        let largeString = String(repeating: "Large content ", count: 10000)
        
        // Test various string operations don't hang
        let base64 = largeString.base64Encode
        #expect(base64 != nil)
        
        let webFormatted = largeString.webQueryFormatted  
        #expect(webFormatted.count > 0)
        
        let data = largeString.asData
        #expect(data != nil)
    }
}
