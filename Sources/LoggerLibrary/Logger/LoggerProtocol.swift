import Foundation

/// A protocol for structured logging with multiple severity levels.
///
/// Provides standardized logging to Xcode console and Console.app with automatic source location tracking.
///
/// ```swift
/// let logger = Logger(category: "MyApp")
/// logger.info("User logged in")
/// logger.error("Failed to fetch: \(error)")
/// ```
///
/// ## Topics
///
/// ### Configuration
/// - ``isLoggingEnabled``
/// - ``setup(include:exclude:)``
///
/// ### Logging Methods
/// - ``error(_:category:filename:method:line:)``
/// - ``warning(_:category:filename:method:line:)``
/// - ``info(_:category:filename:method:line:)``
/// - ``debug(_:category:filename:method:line:)``
public protocol LoggerProtocol {
    /// Enables or disables all logging output.
    var isLoggingEnabled: Bool { get set }

    /// Configures file-based filtering for log messages.
    ///
    /// - Parameters:
    ///   - include: Filenames to include in logging.
    ///   - exclude: Filenames to exclude from logging.
    func setup(include: [String]?, exclude: [String]?)

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
    func error(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

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
    func warning(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

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
    func info(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

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
    func debug(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
}

/// Default implementations with automatic source location capture.
public extension LoggerProtocol {
    /// Configures file-based filtering with optional parameters.
    ///
    /// - Parameters:
    ///   - include: Filenames to include in logging.
    ///   - exclude: Filenames to exclude from logging.
    func setup(include: [String]? = nil,
               exclude: [String]? = nil) {
        return setup(include: include, exclude: exclude)
    }

    /// Logs an error message with automatic source location capture.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    func error(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        return error(object, category: category, filename: filename, method: method, line: line)
    }

    /// Logs an informational message with automatic source location capture.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    func info(_ object: Any,
              category: String? = nil,
              filename: String = #file,
              method: String = #function,
              line: UInt = #line) -> String? {
        return info(object, category: category, filename: filename, method: method, line: line)
    }

    /// Logs a debug message with automatic source location capture.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    func debug(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        return debug(object, category: category, filename: filename, method: method, line: line)
    }

    /// Logs a warning message with automatic source location capture.
    ///
    /// - Parameters:
    ///   - object: Content to log.
    ///   - category: Optional category override.
    ///   - filename: Source file (auto-captured).
    ///   - method: Calling method (auto-captured).
    ///   - line: Line number (auto-captured).
    /// - Returns: Formatted message or `nil` if filtered.
    @discardableResult
    func warning(_ object: Any,
                 category: String? = nil,
                 filename: String = #file,
                 method: String = #function,
                 line: UInt = #line) -> String? {
        return warning(object, category: category, filename: filename, method: method, line: line)
    }
}
