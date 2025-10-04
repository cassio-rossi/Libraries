import Foundation
import os.log
import UtilityLibrary

// MARK: - Default implementation -

/// Logger is the default implementation for the LoggerProtocol
///
/// ## Usage Example: ##
/// Setup the logger:
/// ```swift
/// let logger = Logger(category: "MyAppCategory")
/// logger.setup(include: nil,
///              exclude: ["MyAppDelegate", "MyViewController"])
/// ````
/// Using the logger:
/// ```swift
/// logger.info("Message to Display")
/// logger.error("Error Message to Display")
/// logger.debug("Message to Display with \(myVar) variable")
/// ````
public final class Logger: LoggerProtocol {

    // MARK: - Definitions -

    enum Event: String {
        case error = "‼️" // error
        case info = "ℹ️" // info
        case debug = "💬" // debug
        case warning = "⚠️" // warning
    }

    public struct Config {
        let truncationLength: Int
        let separator: String
        let filename: String?
    }

    // MARK: - Properties -

    let category: String
    let config: Config

    public var isLoggingEnabled: Bool

    private(set) var include: [String]?
    private(set) var exclusion: [String]?
    private let subsystem: String

    // MARK: - Init methods -

    /// Logger Constructor
    ///
    /// - Parameter category: The category to allow Console.app to filter the content
    /// - Parameter subsystem: Optional subsystem to allow Console.app to filter the content
    public convenience init(category: String,
                            subsystem: String? = nil) {
        self.init(category: category,
                  subsystem: subsystem,
                  config: Config(truncationLength: 1023,
                                 separator: "[...]",
                                 filename: "log.txt"))
    }

    /// Logger Constructor
    ///
    /// - Parameter category: The category to allow Console.app to filter the content
    /// - Parameter subsystem: Optional subsystem to allow Console.app to filter the content
    /// - Parameter config: Configuration for the logger
    public init(category: String,
                subsystem: String? = nil,
                config: Config) {
        self.isLoggingEnabled = true
        self.category = category
        self.subsystem = subsystem ?? Bundle.mainBundleIdentifier
        self.config = config
    }

    /// Setup the logger system
    ///
    /// - Parameter include: Array of filenames to include on the log
    /// - Parameter exclude: Array of filenames to exclude from the log
    public func setup(include: [String]? = nil,
                      exclude: [String]? = nil) {
        self.include = include
        self.exclusion = exclude
    }

    // MARK: - Logging methods -

    /// Check if the logger should log the content based on the filename
    ///
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Returns: A os.Logger if logging is enabled, otherwise nil
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

    /// Returns the full message to be logged into external systems
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter event: The event to be logged: Error, Info, Warn, or Debug
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Returns: The content to be logged
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

    /// Returns chuck ofl messages to be logged on the console
    ///
    /// - Parameter object: The content to be printed
    /// - Returns: An array of strings with the content to be logged
    fileprivate func messageToLog(_ object: Any) -> [String] {
        // The log on the Console App is truncated at 1024 bytes
        String(describing: object).split(by: config.truncationLength - config.separator.count,
                                         separator: config.separator)
    }
}

// MARK: - Individual methods -

extension Logger {

    /// Show an error content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
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

    /// Show an info content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
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

    /// Show a debug content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
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

    /// Show a warning content on Xcode console and Console.app
    ///
    /// - Parameter object: The content to be printed
    /// - Parameter category: Optional Category to temporary override the main Category of the logger
    /// - Parameter filename: The filename that originated the call. Default: #file
    /// - Parameter method: The method that originated the call. Default: #method
    /// - Parameter line: The line that originated the call. Default: #line
    /// - Returns: The content to be logged
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

fileprivate extension Logger {
    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        guard !components.isEmpty, let last = components.last else {
            return ""
        }
        return last
    }
}
