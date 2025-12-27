import Foundation

/// File operations for logger's documents directory.
///
/// Extends `FileManager` with convenience methods for reading, writing, and managing
/// log files in the application's documents directory.
public extension FileManager {
    /// App's documents directory URL.
    ///
    /// Returns the first URL from the user domain's document directory search path.
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    /// Ensures the documents directory exists, creating it if necessary.
    /// This helps tests run reliably in CI environments where the directory may not be present.
    private func ensureDocumentsDirectoryExists() {
        let url = documentsDirectory
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    /// Checks if file exists in documents directory.
    ///
    /// - Parameter filename: File name to check. Returns `false` if `nil`.
    /// - Returns: `true` if file exists, `false` otherwise.
    func exists(filename: String?) -> Bool {
        guard let filename, !filename.isEmpty else { return false }
        ensureDocumentsDirectoryExists()
        let url = documentsDirectory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Deletes file from documents directory.
    ///
    /// Silently fails if file doesn't exist or deletion fails.
    ///
    /// - Parameter filename: File name to delete. Does nothing if `nil`.
    func delete(filename: String?) {
        guard let filename, !filename.isEmpty else { return }
        ensureDocumentsDirectoryExists()
        let url = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    /// Appends content to file, creating if needed.
    ///
    /// If the file exists, content is appended. If not, a new file is created.
    /// Silently fails if write operation fails.
    ///
    /// - Parameters:
    ///   - content: String content to append or write.
    ///   - filename: File name in documents directory. Does nothing if `nil`.
    func save(_ content: String, filename: String?) {
        guard let filename, !filename.isEmpty else { return }

        ensureDocumentsDirectoryExists()
        let url = documentsDirectory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: url.path),
           let fileHandle = try? FileHandle(forWritingTo: url) {
            let data = Data((content + "\n").utf8)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try? (content + "\n").write(to: url, atomically: false, encoding: .utf8)
        }
    }

    /// Reads file contents from documents directory.
    ///
    /// - Parameter filename: File name to read.
    /// - Returns: File contents as UTF-8 string, or `nil` if file not found or read fails.
    func content(filename: String?) -> String? {
        guard let filename, !filename.isEmpty else { return nil }
        ensureDocumentsDirectoryExists()
        let url = documentsDirectory.appendingPathComponent(filename)
        return try? String(contentsOf: url, encoding: .utf8)
    }
}

