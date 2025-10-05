import Foundation
import os.log
import UtilityLibrary

// MARK: - Default implementation -

/// The default implementation of ``LoggerProtocol`` providing structured logging to console and files.
///
/// ``Logger`` is a production-ready logging system that outputs to both Xcode's console and macOS
/// Console.app. It supports multiple log levels, file filtering, and optional persistent file logging.
///
/// ## Overview
///
/// Logger provides:
/// - Four log levels with emoji indicators (‼️ Error, ⚠️ Warning, ℹ️ Info, 💬 Debug)
/// - Automatic source location tracking (file, method, line)
/// - Category-based organization for Console.app
/// - File-based filtering to control logging scope
/// - Message truncation for long logs
/// - Optional persistent file logging
/// - Integration with Apple's unified logging system (`os.log`)
///
/// ## Basic Usage
///
/// ```swift
/// // Create a logger with a category
/// let logger = Logger(category: "MyApp")
///
/// // Configure filtering (optional)
/// logger.setup(exclude: ["ThirdPartySDK", "AppDelegate"])
///
/// // Log messages at different levels
/// logger.info("User logged in successfully")
/// logger.warning("Low memory detected")
/// logger.error("Failed to fetch data: \(error)")
/// logger.debug("Current state: \(appState)")
/// ```
///
/// ## Advanced Configuration
///
/// ```swift
/// // Custom configuration with truncation and file logging
/// let config = Logger.Config(
///     truncationLength: 2048,
///     separator: "...",
///     filename: "app.log"
/// )
///
/// let logger = Logger(
///     category: "Authentication",
///     subsystem: "com.myapp.auth",
///     config: config
/// )
/// ```
///
/// ## Performance
///
/// Logger is designed for development and debugging. In production builds, consider
/// disabling logging to reduce overhead:
///
/// ```swift
/// #if DEBUG
/// logger.isLoggingEnabled = true
/// #else
/// logger.isLoggingEnabled = false
/// #endif
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
///
/// - SeeAlso: ``LoggerProtocol`` for the protocol definition
public final class Logger: LoggerProtocol {

    // MARK: - Definitions -

    /// Internal log level identifier with associated emoji indicators.
    ///
    /// Each event type has a unique emoji for quick visual identification in console output.
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

    /// Configuration options for the logger.
    ///
    /// Use this struct to customize truncation behavior and file logging.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let config = Logger.Config(
    ///     truncationLength: 2048,
    ///     separator: "...",
    ///     filename: "app.log"
    /// )
    /// ```
    public struct Config {
        /// The maximum length of a log message before truncation occurs.
        ///
        /// Console.app truncates messages at 1024 bytes by default. This setting allows
        /// you to split longer messages into multiple chunks. Default is 1023 characters.
        let truncationLength: Int

        /// The string inserted between truncated message chunks.
        ///
        /// This separator helps identify that a message was split. Default is `"[...]"`.
        let separator: String

        /// The filename for persistent log storage.
        ///
        /// When provided, logs are written to a file in the app's documents directory.
        /// Pass `nil` to disable file logging. Default is `"log.txt"`.
        let filename: String?
    }

    // MARK: - Properties -

    /// The primary category for organizing logs in Console.app.
    ///
    /// This category appears in Console.app's filter sidebar, making it easy to
    /// isolate logs from this logger instance.
    let category: String

    /// The logger's configuration settings.
    ///
    /// Controls truncation, separators, and file logging behavior.
    let config: Config

    /// Controls whether logging is enabled for this instance.
    ///
    /// When `false`, all log methods return `nil` without writing any output.
    public var isLoggingEnabled: Bool

    /// Array of filename patterns to include in logging.
    ///
    /// When set, only logs from files matching these patterns are output.
    /// If `nil`, all files are included (default behavior).
    private(set) var include: [String]?

    /// Array of filename patterns to exclude from logging.
    ///
    /// Logs from files matching these patterns are suppressed.
    /// If `nil`, no files are excluded (default behavior).
    private(set) var exclusion: [String]?

    /// The subsystem identifier for Console.app organization.
    ///
    /// Typically your app's bundle identifier. Used to group related logs in Console.app.
    private let subsystem: String

    // MARK: - Init methods -

    /// Creates a logger with default configuration.
    ///
    /// This convenience initializer creates a logger with standard settings:
    /// - Truncation at 1023 characters
    /// - `"[...]"` separator for truncated messages
    /// - File logging to `"log.txt"` in the documents directory
    ///
    /// - Parameters:
    ///   - category: The category for organizing logs in Console.app. Choose a descriptive
    ///     name like "Networking", "Database", or "Authentication".
    ///   - subsystem: An optional subsystem identifier. Defaults to the app's bundle identifier.
    ///     Use custom values to group related categories (e.g., "com.myapp.backend").
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Simple logger with default config
    /// let logger = Logger(category: "MyApp")
    ///
    /// // Logger with custom subsystem
    /// let authLogger = Logger(category: "Auth", subsystem: "com.myapp.security")
    /// ```
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
    /// Use this initializer when you need fine-grained control over truncation,
    /// separators, or file logging behavior.
    ///
    /// - Parameters:
    ///   - category: The category for organizing logs in Console.app.
    ///   - subsystem: An optional subsystem identifier. Defaults to the app's bundle identifier.
    ///   - config: Custom configuration controlling truncation and file logging.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let config = Logger.Config(
    ///     truncationLength: 2048,
    ///     separator: "...",
    ///     filename: nil  // Disable file logging
    /// )
    ///
    /// let logger = Logger(
    ///     category: "Network",
    ///     subsystem: "com.myapp.api",
    ///     config: config
    /// )
    /// ```
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
    /// This method implements the ``LoggerProtocol/setup(include:exclude:)`` requirement.
    ///
    /// - Parameters:
    ///   - include: Filenames to include in logging. `nil` includes all files.
    ///   - exclude: Filenames to exclude from logging. `nil` excludes no files.
    public func setup(include: [String]? = nil,
                      exclude: [String]? = nil) {
        self.include = include
        self.exclusion = exclude
    }

    // MARK: - Logging methods -

    /// Determines whether a log should be output based on current settings and file filtering.
    ///
    /// This method checks three conditions:
    /// 1. Global logging is enabled (`isLoggingEnabled`)
    /// 2. The file is not in the exclusion list
    /// 3. The file is in the inclusion list (or no inclusion list is set)
    ///
    /// - Parameters:
    ///   - filename: The source file path (typically from `#file`).
    ///   - category: An optional category override.
    ///
    /// - Returns: An `os.Logger` instance if logging should proceed, or `nil` if suppressed.
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

    /// Creates a formatted log message and optionally writes it to a file.
    ///
    /// This method generates a standardized log message with timestamp, emoji indicator,
    /// source location, and content. If file logging is enabled in the config, the message
    /// is appended to the log file.
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - filename: The source file path (from `#file`).
    ///   - line: The line number (from `#line`).
    ///   - method: The method name (from `#function`).
    ///   - event: The log level (error, warning, info, debug).
    ///   - category: An optional category override.
    ///
    /// - Returns: The formatted log message.
    ///
    /// ## Message Format
    ///
    /// ```
    /// [timestamp] [emoji] [filename - method: line] message
    /// ```
    ///
    /// Example:
    /// ```
    /// 20/03/2024 14:30 ℹ️ [ViewController.swift - viewDidLoad(): 42] User logged in
    /// ```
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

    /// Splits a log message into chunks to avoid Console.app truncation.
    ///
    /// Console.app truncates messages at 1024 bytes. This method splits longer messages
    /// into multiple chunks, inserting the configured separator between chunks.
    ///
    /// - Parameter object: The content to log.
    /// - Returns: An array of message chunks, each within the truncation limit.
    fileprivate func messageToLog(_ object: Any) -> [String] {
        // The log on the Console App is truncated at 1024 bytes
        String(describing: object).split(by: config.truncationLength - config.separator.count,
                                         separator: config.separator)
    }
}

// MARK: - LoggerProtocol Implementation

extension Logger {

    /// Logs an error message (‼️) to console and optionally to file.
    ///
    /// This method implements ``LoggerProtocol/error(_:category:filename:method:line:)``.
    /// It outputs the message to Xcode console, Console.app, and the log file (if configured).
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled or filtered.
    ///
    /// ## Example
    ///
    /// ```swift
    /// logger.error("Failed to fetch user data: \(error)")
    /// logger.error("Authentication failed", category: "Security")
    /// ```
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

    /// Logs an informational message (ℹ️) to console and optionally to file.
    ///
    /// This method implements ``LoggerProtocol/info(_:category:filename:method:line:)``.
    /// It outputs the message to Xcode console, Console.app, and the log file (if configured).
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled or filtered.
    ///
    /// ## Example
    ///
    /// ```swift
    /// logger.info("User logged in successfully")
    /// logger.info("Cache cleared", category: "Performance")
    /// ```
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

    /// Logs a debug message (💬) to console and optionally to file.
    ///
    /// This method implements ``LoggerProtocol/debug(_:category:filename:method:line:)``.
    /// It outputs the message to Xcode console, Console.app, and the log file (if configured).
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled or filtered.
    ///
    /// ## Example
    ///
    /// ```swift
    /// logger.debug("Current state: \(viewModel.state)")
    /// logger.debug("API response received", category: "Network")
    /// ```
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

    /// Logs a warning message (⚠️) to console and optionally to file.
    ///
    /// This method implements ``LoggerProtocol/warning(_:category:filename:method:line:)``.
    /// It outputs the message to Xcode console, Console.app, and the log file (if configured).
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled or filtered.
    ///
    /// ## Example
    ///
    /// ```swift
    /// logger.warning("Low memory detected")
    /// logger.warning("Deprecated API usage", category: "Compatibility")
    /// ```
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
    /// Extracts just the filename from a full file path.
    ///
    /// This helper method is used for file filtering and log formatting. It converts
    /// paths like `/path/to/MyFile.swift` into just `MyFile.swift`.
    ///
    /// - Parameter filePath: The full file path from `#file`.
    /// - Returns: Just the filename with extension, or an empty string if extraction fails.
    func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        guard !components.isEmpty, let last = components.last else {
            return ""
        }
        return last
    }
}
