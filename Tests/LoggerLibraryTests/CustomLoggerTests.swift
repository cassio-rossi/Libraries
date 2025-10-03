import Foundation
@testable import LoggerLibrary
import Testing

// MARK: - Inherited Logger Definition -

final class InheritedLogger: LoggerProtocol {
    var isLoggingEnabled = true
    let logger: Logger
    var config: Logger.Config { logger.config }

    init(category: String) {
        logger = Logger(category: category,
                        config: .init(truncationLength: 1023,
                                      separator: "[...]",
                                      filename: nil))
    }

    func setup(include: [String]?, exclude: [String]?) {
        logger.setup(include: include, exclude: exclude)
    }

    @discardableResult
    func error(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? { nil }

    @discardableResult
    func info(_ object: Any,
              category: String? = nil,
              filename: String = #file,
              method: String = #function,
              line: UInt = #line) -> String? { nil }

    @discardableResult
    func warning(_ object: Any,
                 category: String? = nil,
                 filename: String = #file,
                 method: String = #function,
                 line: UInt = #line) -> String? {
        let message = "=== CUSTOM_LOGGER -> \(object)"
        debugPrint(message)
        return message
    }

    @discardableResult
    func debug(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        logger.debug(object, category: category, filename: filename, method: method, line: line)
    }
}

// MARK: - Inherited Logger Tests -

@Suite("Inherited Logger Tests")
class InheritedLoggerTests {
    enum LoggerError: Error {
        case noOutput
    }

    let logger = InheritedLogger(category: "InheritedLogger")
    let bigString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

    deinit {
        FileManager.default.delete(filename: logger.config.filename)
    }

    @Test("Custom logger info output")
    func testCustomLoggerInfo() throws {
        let output = logger.info("This is the Custom Logger")
        #expect(output == nil)
    }

    @Test("Custom logger error output")
    func testCustomLoggerError() throws {
        let output = logger.error("This is the Custom Logger")
        #expect(output == nil)
    }

    @Test("Custom logger debug output")
    func testCustomLoggerDebug() throws {
        #expect(Bool(FileManager.default.exists(filename: logger.config.filename)) == false)

        guard let output = logger.debug("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("💬"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))

        #expect(Bool(FileManager.default.exists(filename: logger.config.filename)) == false)
    }

    @Test("Custom logger warning output")
    func testCustomLoggerWarning() throws {
        guard let output = logger.warning("This is the Custom Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output == "=== CUSTOM_LOGGER -> This is the Custom Logger")
    }
}

// MARK: - Custom Logger -

final class MyLogger: LoggerProtocol {
    var isLoggingEnabled = true

    func setup(include: [String]?, exclude: [String]?) {}

    func error(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        "[ERROR]: \(object)"
    }

    func info(_ object: Any,
              category: String? = nil,
              filename: String = #file,
              method: String = #function,
              line: UInt = #line) -> String? {
        "[INFO]: \(object)"
    }

    func warning(_ object: Any,
                 category: String? = nil,
                 filename: String = #file,
                 method: String = #function,
                 line: UInt = #line) -> String? {
        "[WARN]: \(object)"
    }

    func debug(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        "[DEBUG]: \(object)"
    }
}

// MARK: - Custom Logger Tests -

@Suite("Custom Logger Tests")
struct CustomLoggerTests {

    @Test("Custom logger info output")
    func testCustomLoggerInfo() throws {
        let logger = MyLogger()
        let output = logger.info("This is the Custom Logger")

        #expect(output == "[INFO]: This is the Custom Logger")
    }

    @Test("Custom logger debug output")
    func testCustomLoggerDebug() throws {
        let logger = MyLogger()
        let output = logger.debug("This is the Custom Logger")

        #expect(output == "[DEBUG]: This is the Custom Logger")
    }

    @Test("Custom logger warning output")
    func testCustomLoggerWarn() throws {
        let logger = MyLogger()
        let output = logger.warning("This is the Custom Logger")

        #expect(output == "[WARN]: This is the Custom Logger")
    }

    @Test("Custom logger error output")
    func testCustomLoggerError() throws {
        let logger = MyLogger()
        let output = logger.error("This is the Custom Logger")

        #expect(output == "[ERROR]: This is the Custom Logger")
    }
}
