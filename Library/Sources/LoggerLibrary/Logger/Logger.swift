import Foundation
import os.log
import UtilityLibrary

// MARK: - Default implementation -

/// A structured logging implementation that outputs to console and files.
///
/// ``Logger`` writes to both Xcode console and Console.app with support for multiple log levels,
/// file filtering, and persistent storage.
///
/// ```swift
/// let logger = Logger(category: "MyApp")
/// logger.info("User logged in")
/// logger.error("Failed to fetch: \(error)")
/// ```
///
/// ## Topics
///
/// ### Creating a Logger
/// - ``init(category:subsystem:)``
/// - ``init(category:subsystem:config:)``
///
/// ### Configuration
/// - ``Config``
/// - ``isLoggingEnabled``
/// - ``setup(include:exclude:)``
///
/// ### Logging Methods
/// - ``error(_:category:filename:method:line:)``
/// - ``warning(_:category:filename:method:line:)``
/// - ``info(_:category:filename:method:line:)``
/// - ``debug(_:category:filename:method:line:)``
public final class Logger: LoggerProtocol {

    // MARK: - Definitions -

    /// Log level with emoji indicator for console output.
    enum Event: String {
        /// Critical error (‼️)
        case error = "‼️"
        /// Informational message (ℹ️)
        case info = "ℹ️"
        /// Debug message (💬)
        case debug = "💬"
        /// Warning message (⚠️)
        case warning = "⚠️"
    }

    /// Configuration for message truncation and file logging.
    public struct Config {
        /// Maximum message length before truncation.
        let truncationLength: Int

        /// Separator inserted between truncated message chunks.
        let separator: String

        /// Filename for persistent log storage in documents directory.
        let filename: String?
    }

    // MARK: - Properties -

    /// Category for organizing logs in Console.app.
    let category: String

    /// Configuration controlling truncation and file logging.
    let config: Config

    /// Enables or disables all logging output.
    public var isLoggingEnabled: Bool

    /// Filename patterns to include in logging.
    private(set) var include: [String]?

    /// Filename patterns to exclude from logging.
    private(set) var exclusion: [String]?

    /// Subsystem identifier for Console.app organization.
    private let subsystem: String

    // MARK: - Init methods -

    /// Creates a logger with default configuration.
    ///
    /// - Parameters:
    ///   - category: Category name for Console.app organization.
    ///   - subsystem: Subsystem identifier (defaults to bundle identifier).
    public convenience init(category: String,
                            subsystem: String? = nil) {
        self.init(category: category,
                  subsystem: subsystem,
                  config: Config(truncationLength: 1023,
                                 separator: "[...]",
                                 filename: "log.txt"))
    }

    /// Creates a logger with custom configuration.
    ///
    /// - Parameters:
    ///   - category: Category name for Console.app organization.
    ///   - subsystem: Subsystem identifier (defaults to bundle identifier).
    ///   - config: Configuration for truncation and file logging.
    public init(category: String,
                subsystem: String? = nil,
                config: Config) {
        self.isLoggingEnabled = true
        self.category = category
        self.subsystem = subsystem ?? Bundle.mainBundleIdentifier
        self.config = config
    }

    /// Configures file-based filtering for log output.
    ///
    /// - Parameters:
    ///   - include: Filenames to include in logging.
    ///   - exclude: Filenames to exclude from logging.
    public func setup(include: [String]? = nil,
                      exclude: [String]? = nil) {
        self.include = include
        self.exclusion = exclude
    }

    // MARK: - Logging methods -

    /// Returns a logger instance if filtering allows output from the specified file.
    ///
    /// - Parameters:
    ///   - filename: Source file path from ``#file``.
    ///   - category: Optional category override.
    /// - Returns: Logger instance or `nil` if filtered.
    fileprivate func logger(using filename: String,
                            category: String? = nil) -> os.Logger? {
        // Logger can be disable as a whole or using an array of filename string
        let filename = sourceFileName(filePath: filename)
        let exclude = exclusion?.contains { element in
            return filename.contains(element)
        } ?? false

        let include = include?.contains { element in
            return filename.contains(element)
        } ?? true

        guard isLoggingEnabled && !exclude && include else {
            return nil
        }
        return os.Logger(subsystem: subsystem, category: category ?? self.category)
    }

    /// Formats a log message and writes it to file if configured.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - filename: Source file path from ``#file``.
    ///   - line: Line number from ``#line``.
    ///   - method: Method name from ``#function``.
    ///   - event: Log level.
    ///   - category: Optional category override.
    /// - Returns: Formatted log message.
    @discardableResult
    fileprivate func log(_ object: Any,
                         filename: String = #file,
                         line: UInt = #line,
                         method: String = #function,
                         event: Logger.Event,
                         category: String? = nil) -> String {
        let message = "\(Date().format(using: .dateTime)) \(event.rawValue) [\((filename as NSString).lastPathComponent) - \(method): \(line)] \(object)"
        FileManager.default.save(message, filename: config.filename)
        return message
    }

    /// Splits message into chunks to avoid Console.app truncation.
    ///
    /// - Parameter object: Content to log.
    /// - Returns: Array of message chunks within truncation limit.
    fileprivate func messageToLog(_ object: Any) -> [String] {
        // The log on the Console App is truncated at 1024 bytes
        String(describing: object).split(by: config.truncationLength - config.separator.count,
                                         separator: config.separator)
    }
}

// MARK: - LoggerProtocol Implementation

extension Logger {

    /// Logs an error message with ‼️ indicator.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    public func error(_ object: Any,
                      category: String? = nil,
                      filename: String = #file,
                      method: String = #function,
                      line: UInt = #line) -> String? {
        guard let logger = logger(using: filename, category: category) else { return nil }
        messageToLog(object).forEach {
            logger.error("\($0, privacy: .public)")
        }

        return log(object,
                   filename: filename,
                   line: line,
                   method: method,
                   event: Logger.Event.error,
                   category: category)
    }

    /// Logs an informational message with ℹ️ indicator.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    public func info(_ object: Any,
                     category: String? = nil,
                     filename: String = #file,
                     method: String = #function,
                     line: UInt = #line) -> String? {
        guard let logger = logger(using: filename, category: category) else { return nil }
        messageToLog(object).forEach {
            logger.info("\($0, privacy: .public)")
        }

        return log(object,
                   filename: filename,
                   line: line,
                   method: method,
                   event: Logger.Event.info,
                   category: category)
    }

    /// Logs a debug message with 💬 indicator.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    public func debug(_ object: Any,
                      category: String? = nil,
                      filename: String = #file,
                      method: String = #function,
                      line: UInt = #line) -> String? {
        guard let logger = logger(using: filename, category: category) else { return nil }
        messageToLog(object).forEach {
            logger.debug("\($0, privacy: .public)")
        }

        return log(object,
                   filename: filename,
                   line: line,
                   method: method,
                   event: Logger.Event.debug,
                   category: category)
    }

    /// Logs a warning message with ⚠️ indicator.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    public func warning(_ object: Any,
                        category: String? = nil,
                        filename: String = #file,
                        method: String = #function,
                        line: UInt = #line) -> String? {
        guard let logger = logger(using: filename, category: category) else { return nil }
        messageToLog(object).forEach {
            logger.warning("\($0, privacy: .public)")
        }

        return log(object,
                   filename: filename,
                   line: line,
                   method: method,
                   event: Logger.Event.warning,
                   category: category)
    }
}

// MARK: - Private Helpers

fileprivate extension Logger {
    /// Extracts filename from full file path.
    ///
    /// - Parameter filePath: Full file path from ``#file``.
    /// - Returns: Filename with extension or empty string.
    func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        guard !components.isEmpty, let last = components.last else {
            return ""
        }
        return last
    }
}
