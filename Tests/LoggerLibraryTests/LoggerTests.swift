import Foundation
@testable import LoggerLibrary
import Testing

@Suite("Logger Tests", .serialized)
class LoggerTests {
    enum LoggerError: Error {
        case noOutput
    }

    let logger = Logger(category: "LoggerTests",
                        config: .init(truncationLength: 1023,
                                      separator: "[...]",
                                      filename: "LoggerTests"))

    deinit {
        FileManager.default.delete(filename: logger.config.filename)
    }

    // MARK: - Default Logger Tests

    @Test("Default logger disabled")
    func testDefaultLoggerDisabled() throws {
        logger.isLoggingEnabled = false
        let output = logger.error("This is the Default Logger")
        #expect(output == nil)
    }

    @Test("Default logger excluded")
    func testDefaultLoggerExcluded() throws {
        logger.setup(exclude: ["LoggerTests"])
        let output = logger.error("This is the Default Logger")
        #expect(output == nil)
    }

    @Test("Default logger included")
    func testDefaultLoggerIncluded() throws {
        logger.setup(include: ["LoggerTests"])
        guard let output = logger.info("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("ℹ️"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))
    }

    @Test("Default logger info output")
    func testDefaultLoggerInfo() throws {
        guard let output = logger.info("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("ℹ️"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))
    }

    @Test("Default logger debug output")
    func testDefaultLoggerDebug() throws {
        guard let output = logger.debug("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("💬"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))
    }

    @Test("Default logger warning output")
    func testDefaultLoggerWarn() throws {
        guard let output = logger.warning("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("⚠️"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))
    }

    @Test("Default logger error output")
    func testDefaultLoggerError() throws {
        guard let output = logger.error("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(output.contains("‼️"))
        #expect(output.contains((#file as NSString).lastPathComponent))
        #expect(output.contains(#function))
        #expect(output.contains("This is the Default Logger"))
    }

    @Test("Default logger file exists")
    func testDefaultLoggerFileExists() throws {
        #expect(Bool(FileManager.default.exists(filename: logger.config.filename)) == false)

        guard let output = logger.error("This is the Default Logger") else {
            throw LoggerError.noOutput
        }

        #expect(Bool(FileManager.default.exists(filename: logger.config.filename)) == true)
        #expect(output.contains("‼️"))
    }

    @Test("Default logger file appends")
    func testDefaultLoggerFileAppends() throws {
        var messages: [String] = []

        guard let output = logger.info("This is the Default Logger") else {
            throw LoggerError.noOutput
        }
        messages.append(output)

        #expect(Bool(FileManager.default.exists(filename: logger.config.filename)) == true)

        guard let output2 = logger.debug("This is the Default Logger second message") else {
            throw LoggerError.noOutput
        }
        messages.append(output2)

        #expect(FileManager.default.content(filename: logger.config.filename) == messages.joined(separator: "\n"))
    }
}
