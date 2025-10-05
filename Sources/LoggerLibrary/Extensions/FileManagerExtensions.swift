import Foundation

/// Extensions to `FileManager` for convenient file operations in the logger's documents directory.
///
/// These utilities simplify file-based logging by providing easy access to the app's
/// documents directory and common file operations like checking existence, appending content,
/// and reading files.
extension FileManager {
    /// The app's documents directory URL.
    ///
    /// This is the primary location for user-generated content and persistent storage.
    /// The logger uses this directory for log files when file logging is enabled.
    ///
    /// - Returns: The URL of the documents directory in the user domain mask.
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    /// Checks whether a file exists in the documents directory.
    ///
    /// - Parameter filename: The name of the file to check. Returns `false` if `nil`.
    /// - Returns: `true` if the file exists, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if FileManager.default.exists(filename: "log.txt") {
    ///     print("Log file exists")
    /// }
    /// ```
    func exists(filename: String?) -> Bool {
        guard let filename else { return false }
        let url = documentsDirectory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Deletes a file from the documents directory.
    ///
    /// This method silently fails if the file doesn't exist or deletion fails.
    ///
    /// - Parameter filename: The name of the file to delete. Does nothing if `nil`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FileManager.default.delete(filename: "old_log.txt")
    /// ```
    func delete(filename: String?) {
        guard let filename else { return }
        let url = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    /// Appends content to a file in the documents directory, creating it if needed.
    ///
    /// If the file exists, content is appended to the end. If the file doesn't exist,
    /// it's created with the provided content. This is used by the logger to write
    /// log entries to persistent storage.
    ///
    /// - Parameters:
    ///   - content: The string content to append or write.
    ///   - filename: The name of the file. Does nothing if `nil`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FileManager.default.save("Log entry\n", filename: "app.log")
    /// ```
    ///
    /// - Note: The method silently fails if file operations encounter errors.
    func save(_ content: String, filename: String?) {
        guard let filename else { return }

        let url = documentsDirectory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: url.path),
           let fileHandle = try? FileHandle(forWritingTo: url) {
            let data = Data(content.utf8)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try? "\(content)\n".write(to: url, atomically: true, encoding: .utf8)
        }
    }

    /// Reads the entire contents of a file from the documents directory.
    ///
    /// - Parameter filename: The name of the file to read. Returns `nil` if the parameter is `nil`.
    /// - Returns: The file's contents as a string, or `nil` if the file doesn't exist or can't be read.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let logs = FileManager.default.content(filename: "app.log") {
    ///     print("Log contents:\n\(logs)")
    /// }
    /// ```
    func content(filename: String?) -> String? {
        guard let filename else { return nil }
        let url = documentsDirectory.appendingPathComponent(filename)
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
