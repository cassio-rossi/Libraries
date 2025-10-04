import Foundation
import Testing
@testable import LoggerLibrary

@Suite("Logger Additional Coverage Tests", .serialized)
class LoggerAdditionalTests {
    
    let logger = Logger(category: "AdditionalTests",
                       subsystem: "AdditionalTestsSubsystem",
                       config: .init(truncationLength: 50,
                                    separator: "...",
                                    filename: "additional_tests.log"))
    
    deinit {
        FileManager.default.delete(filename: logger.config.filename)
    }
    
    @Test("Logger convenience initializer should use default config")
    func testConvenienceInitializer() throws {
        let defaultLogger = Logger(category: "TestCategory", subsystem: "TestSubsystem")
        
        #expect(defaultLogger.category == "TestCategory")
        #expect(defaultLogger.config.truncationLength == 1023)
        #expect(defaultLogger.config.separator == "[...]")
        #expect(defaultLogger.config.filename == "log.txt")
    }
    
    @Test("Logger config should be properly set")
    func testLoggerConfig() throws {
        let customConfig = Logger.Config(truncationLength: 100, separator: "###", filename: "custom.log")
        let customLogger = Logger(category: "ConfigTest", config: customConfig)
        
        #expect(customLogger.config.truncationLength == 100)
        #expect(customLogger.config.separator == "###")
        #expect(customLogger.config.filename == "custom.log")
    }
    
    @Test("Setup with include filter should work correctly")
    func testSetupWithIncludeFilter() throws {
        logger.setup(include: ["AdditionalTests"])
        
        #expect(logger.include == ["AdditionalTests"])
        #expect(logger.exclusion == nil)
        
        let output = logger.info("Test message with include filter")
        #expect(output != nil)
    }
    
    @Test("Setup with exclude filter should work correctly")
    func testSetupWithExcludeFilter() throws {
        logger.setup(exclude: ["SomeOtherFile"])
        
        #expect(logger.exclusion == ["SomeOtherFile"])
        #expect(logger.include == nil)
        
        let output = logger.info("Test message with exclude filter")
        #expect(output != nil)
    }
    
    @Test("Setup with both include and exclude filters")
    func testSetupWithBothFilters() throws {
        logger.setup(include: ["AdditionalTests"], exclude: ["SomeOtherFile"])
        
        #expect(logger.include == ["AdditionalTests"])
        #expect(logger.exclusion == ["SomeOtherFile"])
    }
    
    @Test("Logger should handle long messages with custom truncation")
    func testLoggerWithLongMessage() throws {
        let longMessage = String(repeating: "A", count: 100)
        let output = logger.info(longMessage)
        
        #expect(output != nil)
        #expect(output!.contains(longMessage))
    }
    
    @Test("Logger should handle messages with newlines")
    func testLoggerWithNewlines() throws {
        let messageWithNewlines = "Line 1\nLine 2\nLine 3"
        let output = logger.debug(messageWithNewlines)
        
        #expect(output != nil)
        #expect(output!.contains("Line 1"))
        #expect(output!.contains("Line 2"))
        #expect(output!.contains("Line 3"))
    }
    
    @Test("Logger should handle empty message")
    func testLoggerWithEmptyMessage() throws {
        let output = logger.warning("")
        #expect(output != nil)
    }
    
    @Test("Logger should handle nil-like messages")
    func testLoggerWithNilLikeMessages() throws {
        let nilValue: String? = nil
        let output = logger.error(nilValue as Any)
        #expect(output != nil)
        #expect(output!.contains("nil"))
    }
    
    @Test("Logger should format timestamp correctly")
    func testLoggerTimestampFormat() throws {
        let output = logger.info("Timestamp test")
        
        #expect(output != nil)
        // Should contain a timestamp in the format used by Date().format(using: .dateTime)
        #expect(output!.contains("/"))
        #expect(output!.contains(":"))
    }
    
    @Test("Logger should include file information")
    func testLoggerIncludesFileInformation() throws {
        let output = logger.info("File info test")
        
        #expect(output != nil)
        #expect(output!.contains("LoggerAdditionalTests.swift"))
        #expect(output!.contains("testLoggerIncludesFileInformation"))
    }
    
    @Test("Logger should include correct event emoji")
    func testLoggerEventEmojis() throws {
        let infoOutput = logger.info("Info test")
        let debugOutput = logger.debug("Debug test")  
        let warningOutput = logger.warning("Warning test")
        let errorOutput = logger.error("Error test")
        
        #expect(infoOutput?.contains("ℹ️") == true)
        #expect(debugOutput?.contains("💬") == true)
        #expect(warningOutput?.contains("⚠️") == true)
        #expect(errorOutput?.contains("‼️") == true)
    }
    
    @Test("Logger should handle custom categories temporarily")
    func testLoggerWithCustomCategory() throws {
        let output = logger.info("Custom category test", category: "CustomCategory")
        
        #expect(output != nil)
        #expect(output!.contains("Custom category test"))
    }
    
    @Test("Logger should respect isLoggingEnabled flag")
    func testLoggingEnabledFlag() throws {
        // Enable logging
        logger.isLoggingEnabled = true
        let enabledOutput = logger.info("Enabled test")
        #expect(enabledOutput != nil)
        
        // Disable logging
        logger.isLoggingEnabled = false
        let disabledOutput = logger.info("Disabled test")
        #expect(disabledOutput == nil)
        
        // Re-enable for other tests
        logger.isLoggingEnabled = true
    }
    
    @Test("sourceFileName should extract filename correctly")
    func testSourceFileNameExtraction() throws {
        // This tests the private method indirectly through logging
        let output = logger.info("Source filename test")
        
        #expect(output != nil)
        // Should contain the Swift file name, not the full path
        #expect(output!.contains("LoggerAdditionalTests.swift"))
        #expect(!output!.contains("/Users/") && !output!.contains("/home/")) // Should not contain full path
    }
    
    @Test("Logger should handle complex objects")
    func testLoggerWithComplexObjects() throws {
        struct TestObject {
            let id: Int
            let name: String
            let values: [String]
        }
        
        let complexObject = TestObject(id: 42, name: "TestName", values: ["A", "B", "C"])
        let output = logger.debug(complexObject)
        
        #expect(output != nil)
        #expect(output!.contains("TestObject"))
        #expect(output!.contains("42"))
        #expect(output!.contains("TestName"))
    }
    
    @Test("Logger should handle dictionary objects")
    func testLoggerWithDictionary() throws {
        let dictionary = ["key1": "value1", "key2": "value2", "number": 42] as [String: Any]
        let output = logger.info(dictionary)
        
        #expect(output != nil)
        #expect(output!.contains("key1") || output!.contains("value1"))
    }
    
    @Test("Logger should handle arrays")
    func testLoggerWithArray() throws {
        let array = [1, 2, 3, 4, 5]
        let output = logger.warning(array)
        
        #expect(output != nil)
        #expect(output!.contains("["))
        #expect(output!.contains("1"))
        #expect(output!.contains("5"))
    }
    
    @Test("Logger should create and append to log file correctly")
    func testLoggerFileCreationAndAppending() throws {
        // Ensure file doesn't exist
        FileManager.default.delete(filename: logger.config.filename)
        #expect(!FileManager.default.exists(filename: logger.config.filename))
        
        // Log first message
        logger.info("First message")
        #expect(FileManager.default.exists(filename: logger.config.filename))
        
        // Log second message
        logger.debug("Second message")
        
        // Check file contents
        let fileContents = FileManager.default.content(filename: logger.config.filename)
        #expect(fileContents?.contains("First message") == true)
        #expect(fileContents?.contains("Second message") == true)
        
        // Should be two separate lines
        let lines = fileContents?.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines?.count == 2)
    }
}

@Suite("Logger Edge Cases Tests", .serialized)
struct LoggerEdgeCasesTests {
    
    @Test("Logger should handle extremely long filenames in setup")
    func testLoggerWithLongFilenames() throws {
        let longFilename = String(repeating: "VeryLongFileName", count: 10)
        let logger = Logger(category: "EdgeTest")
        
        logger.setup(include: [longFilename], exclude: ["AnotherLongFileName"])
        
        // Should not crash
        #expect(logger.include?.first?.count ?? 0 > 100)
    }
    
    @Test("Logger should handle empty arrays in setup")
    func testLoggerWithEmptyArraysInSetup() throws {
        let logger = Logger(category: "EdgeTest")
        
        logger.setup(include: [], exclude: [])
        
        #expect(logger.include?.isEmpty == true)
        #expect(logger.exclusion?.isEmpty == true)
    }
    
    @Test("Logger should handle special characters in messages")
    func testLoggerWithSpecialCharacters() throws {
        let logger = Logger(category: "EdgeTest")
        let specialMessage = "Special chars: éñ中文🚀 @#$%^&*()_+-=[]{}|;:,.<>?"
        
        let output = logger.info(specialMessage)
        #expect(output?.contains("éñ中文🚀") == true)
    }
    
    @Test("Logger should handle very short truncation length")
    func testLoggerWithShortTruncationLength() throws {
        let shortConfig = Logger.Config(truncationLength: 10, separator: "...", filename: "short.log")
        let logger = Logger(category: "ShortTest", config: shortConfig)
        
        let longMessage = "This is a very long message that should be truncated"
        let output = logger.info(longMessage)
        
        #expect(output != nil)
        
        // Clean up
        FileManager.default.delete(filename: logger.config.filename)
    }
    
    @Test("Logger should handle zero truncation length")
    func testLoggerWithZeroTruncationLength() throws {
        let zeroConfig = Logger.Config(truncationLength: 0, separator: "...", filename: "zero.log")
        let logger = Logger(category: "ZeroTest", config: zeroConfig)
        
        let message = "Test message"
        let output = logger.debug(message)
        
        #expect(output != nil)
        
        // Clean up
        FileManager.default.delete(filename: logger.config.filename)
    }
}
