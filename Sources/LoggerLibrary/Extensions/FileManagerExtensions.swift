import Foundation

extension FileManager {
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func exists(filename: String?) -> Bool {
        guard let filename else { return false }
        let url = documentsDirectory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }

    func delete(filename: String?) {
        guard let filename else { return }
        let url = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

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

    func content(filename: String?) -> String? {
        guard let filename else { return nil }
        let url = documentsDirectory.appendingPathComponent(filename)
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
