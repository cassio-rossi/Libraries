import Foundation

/// A protocol defining a structured logging system for iOS, macOS, watchOS, and visionOS applications.
///
/// ``LoggerProtocol`` provides a standardized interface for logging messages with different severity levels.
/// Logs are output to both Xcode's console and macOS Console.app, making debugging and monitoring easier.
///
/// ## Overview
///
/// The protocol defines four log levels:
/// - **Error** (‼️): Critical failures and exceptions
/// - **Warning** (⚠️): Potential issues that aren't failures
/// - **Info** (ℹ️): Important events and state changes
/// - **Debug** (💬): Detailed diagnostic information
///
/// Each log level automatically captures source location information (file, method, line number),
/// making it easy to trace where logs originated.
///
/// ## Usage
///
/// Implement this protocol to create custom loggers, or use the provided ``Logger`` implementation:
///
/// ```swift
/// class MyLogger: LoggerProtocol {
///     var isLoggingEnabled: Bool = true
///
///     func setup(include: [String]?, exclude: [String]?) {
///         // Configure file filtering
///     }
///
///     func error(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String? {
///         // Log error messages
///     }
///
///     // Implement other log level methods...
/// }
/// ```
///
/// Or use the default implementation:
///
/// ```swift
/// let logger = Logger(category: "MyApp")
///
/// // Configure filtering
/// logger.setup(exclude: ["ThirdPartySDK", "AppDelegate"])
///
/// // Log messages
/// logger.info("User logged in")
/// logger.error("Failed to fetch data: \(error)")
/// logger.debug("Current state: \(state)")
/// ```
///
/// ## File Filtering
///
/// Control which source files produce logs:
///
/// ```swift
/// // Only log from specific files
/// logger.setup(include: ["NetworkManager", "DataController"])
///
/// // Exclude specific files from logging
/// logger.setup(exclude: ["ThirdPartySDK", "AnalyticsManager"])
/// ```
///
/// ## Console.app Integration
///
/// All logs appear in macOS Console.app with subsystem and category metadata,
/// making it easy to filter and search logs across your entire app.
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
///
/// - SeeAlso: ``Logger`` for the default implementation
public protocol LoggerProtocol {
    /// Controls whether logging is enabled globally for this logger instance.
    ///
    /// When set to `false`, all log messages are suppressed regardless of log level or file filtering.
    /// This is useful for disabling logging in production builds or specific scenarios.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let logger = Logger(category: "MyApp")
    ///
    /// // Disable logging in production
    /// #if DEBUG
    /// logger.isLoggingEnabled = true
    /// #else
    /// logger.isLoggingEnabled = false
    /// #endif
    /// ```
    ///
    /// - Note: This property affects all log levels (error, warning, info, debug).
    var isLoggingEnabled: Bool { get set }

    /// Configures file-based filtering for log messages.
    ///
    /// Use this method to control which source files can produce logs. You can either
    /// include specific files (allowlist) or exclude specific files (denylist), but not both.
    ///
    /// - Parameters:
    ///   - include: An optional array of filename strings to include. When provided, only logs
    ///     from files whose names contain these strings will be displayed. Pass `nil` to disable
    ///     include filtering (default behavior).
    ///   - exclude: An optional array of filename strings to exclude. Logs from files whose
    ///     names contain these strings will be suppressed. Pass `nil` to disable exclude
    ///     filtering (default behavior).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Only log from networking and database files
    /// logger.setup(include: ["NetworkManager", "Database"])
    ///
    /// // Exclude third-party SDK and delegate files
    /// logger.setup(exclude: ["ThirdPartySDK", "AppDelegate", "SceneDelegate"])
    ///
    /// // Reset to log from all files
    /// logger.setup(include: nil, exclude: nil)
    /// ```
    ///
    /// - Important: The filtering is based on substring matching. For example, "Network" will
    ///   match "NetworkManager.swift", "NetworkService.swift", etc.
    ///
    /// - Note: If both `include` and `exclude` are provided, include takes precedence. Files
    ///   must be in the include list AND not in the exclude list to produce logs.
    func setup(include: [String]?, exclude: [String]?)

    /// Logs an error message to Xcode console and Console.app with the ‼️ indicator.
    ///
    /// Use this method for critical failures, exceptions, and errors that need immediate attention.
    /// The message includes source location information and appears with high visibility in Console.app.
    ///
    /// - Parameters:
    ///   - object: The content to log. Can be any type - will be converted to a string representation.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///     Useful for organizing logs by feature or subsystem in Console.app.
    ///   - filename: The source file where the log originated. Automatically captured via `#file`.
    ///   - method: The method or function where the log originated. Automatically captured via `#function`.
    ///   - line: The line number where the log originated. Automatically captured via `#line`.
    ///
    /// - Returns: The formatted log message that was written, or `nil` if logging is disabled
    ///   or filtered out.
    ///
    /// - Note: You typically don't need to provide `filename`, `method`, or `line` parameters
    ///   as they are automatically captured. The `@discardableResult` attribute allows you to
    ///   ignore the return value if you don't need it.
    @discardableResult
    func error(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Logs a warning message to Xcode console and Console.app with the ⚠️ indicator.
    ///
    /// Use this method for potential issues, deprecated usage, or situations that aren't errors
    /// but warrant attention. Warnings help identify problems before they become failures.
    ///
    /// - Parameters:
    ///   - object: The content to log. Can be any type - will be converted to a string representation.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///     Useful for organizing logs by feature or subsystem in Console.app.
    ///   - filename: The source file where the log originated. Automatically captured via `#file`.
    ///   - method: The method or function where the log originated. Automatically captured via `#function`.
    ///   - line: The line number where the log originated. Automatically captured via `#line`.
    ///
    /// - Returns: The formatted log message that was written, or `nil` if logging is disabled
    ///   or filtered out.
    ///
    /// - Note: You typically don't need to provide `filename`, `method`, or `line` parameters
    ///   as they are automatically captured. The `@discardableResult` attribute allows you to
    ///   ignore the return value if you don't need it.
    @discardableResult
    func warning(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Logs an informational message to Xcode console and Console.app with the ℹ️ indicator.
    ///
    /// Use this method for important events, state changes, and general information about
    /// application flow. Info logs help track the normal operation of your app.
    ///
    /// - Parameters:
    ///   - object: The content to log. Can be any type - will be converted to a string representation.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///     Useful for organizing logs by feature or subsystem in Console.app.
    ///   - filename: The source file where the log originated. Automatically captured via `#file`.
    ///   - method: The method or function where the log originated. Automatically captured via `#function`.
    ///   - line: The line number where the log originated. Automatically captured via `#line`.
    ///
    /// - Returns: The formatted log message that was written, or `nil` if logging is disabled
    ///   or filtered out.
    ///
    /// - Note: You typically don't need to provide `filename`, `method`, or `line` parameters
    ///   as they are automatically captured. The `@discardableResult` attribute allows you to
    ///   ignore the return value if you don't need it.
    @discardableResult
    func info(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Logs a debug message to Xcode console and Console.app with the 💬 indicator.
    ///
    /// Use this method for detailed diagnostic information during development. Debug logs
    /// are typically disabled in production builds to reduce noise and improve performance.
    ///
    /// - Parameters:
    ///   - object: The content to log. Can be any type - will be converted to a string representation.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///     Useful for organizing logs by feature or subsystem in Console.app.
    ///   - filename: The source file where the log originated. Automatically captured via `#file`.
    ///   - method: The method or function where the log originated. Automatically captured via `#function`.
    ///   - line: The line number where the log originated. Automatically captured via `#line`.
    ///
    /// - Returns: The formatted log message that was written, or `nil` if logging is disabled
    ///   or filtered out.
    ///
    /// - Note: You typically don't need to provide `filename`, `method`, or `line` parameters
    ///   as they are automatically captured. The `@discardableResult` attribute allows you to
    ///   ignore the return value if you don't need it.
    @discardableResult
    func debug(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
}

/// Default implementations of ``LoggerProtocol`` methods with automatic source location capture.
///
/// This extension provides convenient overloads of the logging methods that automatically
/// capture source location information using Swift's `#file`, `#function`, and `#line` literals.
/// This allows you to call logging methods without manually providing location parameters.
public extension LoggerProtocol {
    /// Configures file-based filtering with optional parameters.
    ///
    /// This convenience method provides default `nil` values for both parameters,
    /// allowing you to call `setup()` without arguments to reset filtering.
    ///
    /// - Parameters:
    ///   - include: An optional array of filename strings to include. Defaults to `nil`.
    ///   - exclude: An optional array of filename strings to exclude. Defaults to `nil`.
    func setup(include: [String]? = nil,
               exclude: [String]? = nil) {
        return setup(include: include, exclude: exclude)
    }

    /// Logs an error message with automatic source location capture.
    ///
    /// This convenience overload automatically captures the calling file, method, and line number,
    /// so you don't need to provide them manually.
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled.
    @discardableResult
    func error(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        return error(object, category: category, filename: filename, method: method, line: line)
    }

    /// Logs an info message with automatic source location capture.
    ///
    /// This convenience overload automatically captures the calling file, method, and line number,
    /// so you don't need to provide them manually.
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled.
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
    /// This convenience overload automatically captures the calling file, method, and line number,
    /// so you don't need to provide them manually.
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled.
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
    /// This convenience overload automatically captures the calling file, method, and line number,
    /// so you don't need to provide them manually.
    ///
    /// - Parameters:
    ///   - object: The content to log.
    ///   - category: An optional category to temporarily override the logger's default category.
    ///   - filename: The source file (automatically captured via `#file`).
    ///   - method: The calling method (automatically captured via `#function`).
    ///   - line: The line number (automatically captured via `#line`).
    ///
    /// - Returns: The formatted log message, or `nil` if logging is disabled.
    @discardableResult
    func warning(_ object: Any,
                 category: String? = nil,
                 filename: String = #file,
                 method: String = #function,
                 line: UInt = #line) -> String? {
        return warning(object, category: category, filename: filename, method: method, line: line)
    }
}
