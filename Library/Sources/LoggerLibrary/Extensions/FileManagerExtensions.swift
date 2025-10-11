import Foundation

/// File operations for logger's documents directory.
extension FileManager {
    /// App's documents directory URL.
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    /// Checks if file exists in documents directory.
    ///
    /// - Parameter filename: File name to check.
    /// - Returns: `true` if file exists.
    func exists(filename: String?) -> Bool {
        guard let filename else { return false }
        let url = documentsDirectory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Deletes file from documents directory.
    ///
    /// - Parameter filename: File name to delete.
    func delete(filename: String?) {
        guard let filename else { return }
        let url = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    /// Appends content to file, creating if needed.
    ///
    /// - Parameters:
    ///   - content: String content to append or write.
    ///   - filename: File name in documents directory.
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

    /// Reads file contents from documents directory.
    ///
    /// - Parameter filename: File name to read.
    /// - Returns: File contents or `nil` if not found.
    func content(filename: String?) -> String? {
        guard let filename else { return nil }
        let url = documentsDirectory.appendingPathComponent(filename)
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
