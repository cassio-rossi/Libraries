import Foundation

/// Protocol to specify how to log information to Xcode console and to the Console.app
///
/// ## Usage Example: ##
/// Setup the logger:
/// ```swift
/// class Logger: LoggerProtocol {
/// ...
/// }
/// let logger = Logger(category: "MyAppCategory")
///
/// logger.setup(include: nil,
///              exclude: ["MyAppDelegate", "MyViewController"])
/// ```
/// Using the logger:
/// ```swift
/// logger.info("Message to Display")
/// logger.error("Error Message to Display")
/// logger.debug("Message to Display with \(myVar) variable")
/// ```
public protocol LoggerProtocol {
    /// Turn on or off the logging system
    var isLoggingEnabled: Bool { get set }

    /// Setup the logger system
    ///
    /// - Parameter include: Array of filenames to include on the log
    /// - Parameter exclude: Array of filenames to exclude from the log
    func setup(include: [String]?, exclude: [String]?)

    /// Show an error content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call.
    /// - Parameter method: The method that originated the call.
    /// - Parameter line: The line that originated the call.
    /// - Returns: The content to be logged
    @discardableResult
    func error(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Show a warning content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call.
    /// - Parameter method: The method that originated the call.
    /// - Parameter line: The line that originated the call.
    /// - Returns: The content to be logged
    @discardableResult
    func warning(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Show an info content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call.
    /// - Parameter method: The method that originated the call.
    /// - Parameter line: The line that originated the call.
    /// - Returns: The content to be logged
    @discardableResult
    func info(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?

    /// Show a debug content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call.
    /// - Parameter method: The method that originated the call.
    /// - Parameter line: The line that originated the call.
    /// - Returns: The content to be logged
    @discardableResult
    func debug(_ object: Any, category: String?, filename: String, method: String, line: UInt) -> String?
}

public extension LoggerProtocol {
    /// Setup the logger system
    ///
    /// - Parameter include: Array of filenames to include on the log
    /// - Parameter exclude: Array of filenames to exclude from the log
    func setup(include: [String]? = nil,
               exclude: [String]? = nil) {
        return setup(include: include, exclude: exclude)
    }

    /// Show an error content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
    @discardableResult
    func error(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        return error(object, category: category, filename: filename, method: method, line: line)
    }

    /// Show an info content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
    @discardableResult
    func info(_ object: Any,
              category: String? = nil,
              filename: String = #file,
              method: String = #function,
              line: UInt = #line) -> String? {
        return info(object, category: category, filename: filename, method: method, line: line)
    }

    /// Show a debug content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
    @discardableResult
    func debug(_ object: Any,
               category: String? = nil,
               filename: String = #file,
               method: String = #function,
               line: UInt = #line) -> String? {
        return debug(object, category: category, filename: filename, method: method, line: line)
    }

    /// Show a warning content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
    @discardableResult
    func warning(_ object: Any,
                 category: String? = nil,
                 filename: String = #file,
                 method: String = #function,
                 line: UInt = #line) -> String? {
        return warning(object, category: category, filename: filename, method: method, line: line)
    }
}
