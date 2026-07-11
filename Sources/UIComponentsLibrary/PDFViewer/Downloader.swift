#if canImport(PDFKit)
import Foundation
import PDFKit
import SwiftUI
import UtilityLibrary

/// A downloader class for fetching and managing PDF documents.
///
/// `Downloader` handles PDF downloads from URLs, caches PDFs locally,
/// and publishes the loaded `PDFDocument` plus download progress so that
/// SwiftUI can render it. It intentionally does **not** hold a reference to a
/// `PDFView`: the mounted `PDFView` is owned by SwiftUI and reads the
/// published `document` through `PDFViewRepresentable`.
///
/// ## Concurrency
/// This type is **not** `@MainActor`-isolated. `URLSession` invokes its delegate
/// callbacks on a background `OperationQueue`, so the class must be free to run
/// off the main actor (a main-actor-isolated delegate would trip Swift 6's
/// actor-executor assertion at runtime). All observable state (`progress`,
/// `document`) is mutated **only** on the main actor via `DispatchQueue.main.async`,
/// which is why the type is marked `@unchecked Sendable`.
@Observable
public final class Downloader: NSObject, @unchecked Sendable {
	/// The download progress as a percentage (0.0 to 100.0).
    var progress: Double = 0.0

	/// The loaded PDF document, or `nil` until a document is available.
	///
	/// Assigned on the main actor. `PDFViewRepresentable` observes this value
	/// and pushes it into the mounted `PDFView` from `updateUIView`.
    var document: PDFDocument?

	/// The filename of the PDF being downloaded or loaded.
    private var file: String?

	/// The URL currently being downloaded, used to guard against re-entrant
	/// downloads of the same resource. `nil` when no network download is in flight.
    private var downloadingURL: URL?

	/// Creates a new downloader instance.
    override public init() {}

	/// Loads a PDF from fallback data, or downloads it from a URL.
	///
	/// If `file` data is provided it is loaded directly. Otherwise the PDF is
	/// downloaded from `url` (using the local cache when available).
	///
	/// - Parameters:
	///   - url: Optional URL to download the PDF from.
	///   - file: Optional PDF data to use as a fallback / direct source.
    public func download(from url: URL?, fallback file: Data?) {
        guard let file else {
            download(from: url)
            return
        }
        DispatchQueue.main.async {
            self.document = PDFDocument(data: file)
        }
    }

	/// Downloads a PDF from a URL.
	///
	/// Checks the local cache first before initiating a network download.
	/// The downloaded PDF is saved locally for future use. A download for a URL
	/// that is already in flight is ignored (re-entrancy guard).
	///
	/// - Parameter url: The URL to download the PDF from.
    public func download(from url: URL?) {
        guard let url else { return }

        // Re-entrancy guard: skip if a load for the same URL is already in flight.
        guard downloadingURL != url else { return }

        let name = url.lastPathComponent
        self.file = name

        guard let data = load(document: name) else {
            downloadingURL = url

            let configuration = URLSessionConfiguration.default
            let operationQueue = OperationQueue()
            let session = URLSession(configuration: configuration,
                                     delegate: self,
                                     delegateQueue: operationQueue)

            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()

            return
        }

        DispatchQueue.main.async {
            self.document = PDFDocument(data: data)
        }
    }

	/// Checks if a PDF is available in the local cache.
	///
	/// - Parameter url: The URL of the PDF to check.
	/// - Returns: `true` if the PDF is cached locally, `false` otherwise.
    public func isLocal(url: URL?) -> Bool {
        guard let url = url,
              load(document: url.lastPathComponent) != nil else {
            return false
        }
        return true
    }
}

private extension Downloader {
	/// Returns the URL for the app's documents directory.
	///
	/// - Returns: The URL of the documents directory.
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

	/// Generates a safe filename for storing PDFs locally.
	///
	/// Encodes the filename using Base64 to avoid filesystem conflicts.
	///
	/// - Parameter file: The original filename.
	/// - Returns: A safe filename with .pdf extension.
    func getFilePath(file: String) -> String {
        return "\(file.base64Encode ?? file.replacingOccurrences(of: "/", with: "_")).pdf"
    }

	/// Generates the full file URL for storing PDFs locally.
	///
	/// - Parameter file: The original filename.
	/// - Returns: The complete file URL in the documents directory.
    func getFilePath(file: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(getFilePath(file: file))
    }

	/// Saves PDF data to the local cache.
	///
	/// - Parameters:
	///   - document: The PDF data to save.
	///   - file: The filename to save under.
    func save(document: Data?, file: String?) {
        guard let file else { return }
        let filename: URL = getFilePath(file: file)
        try? document?.write(to: filename)
    }

	/// Loads a PDF from the local cache.
	///
	/// - Parameter document: The filename of the cached PDF.
	/// - Returns: The PDF data if found in cache, otherwise `nil`.
    func load(document: String?) -> Data? {
        guard let document else { return nil }
        let filename: URL = getFilePath(file: document)
        if FileManager.default.fileExists(atPath: filename.relativePath) {
            return loadPdf(from: filename)
        }
        return nil
    }

	/// Reads PDF data from a file location.
	///
	/// - Parameter location: The file URL to read from.
	/// - Returns: The PDF data if successfully read, otherwise `nil`.
    func loadPdf(from location: URL) -> Data? {
        let reader = try? FileHandle(forReadingFrom: location)
        return reader?.readDataToEndOfFile()
    }
}

extension Downloader: URLSessionDownloadDelegate {
	/// Called periodically to report download progress.
	///
	/// Invoked on the session's background delegate queue; the observable
	/// `progress` is updated on the main actor.
	///
	/// - Parameters:
	///   - session: The URL session.
	///   - downloadTask: The download task.
	///   - bytesWritten: Bytes written since the last call.
	///   - totalBytesWritten: Total bytes written so far.
	///   - totalBytesExpectedToWrite: Expected total bytes for the download.
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {

        let percentDownloaded = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        DispatchQueue.main.async {
            self.progress = percentDownloaded * 100
        }
    }

	/// Called when a download completes successfully.
	///
	/// Saves the downloaded PDF to local cache and publishes the resulting
	/// `PDFDocument` on the main actor. Invoked on the session's background
	/// delegate queue.
	///
	/// - Parameters:
	///   - session: The URL session.
	///   - downloadTask: The download task.
	///   - location: The temporary location of the downloaded file.
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {

        guard let data = loadPdf(from: location) else { return }
        save(document: data, file: file)

        DispatchQueue.main.async {
            self.document = PDFDocument(data: data)
            self.downloadingURL = nil
        }
    }

	/// Called when a task finishes, successfully or with an error.
	///
	/// Clears the in-flight guard so a later attempt for the same URL can retry.
	///
	/// - Parameters:
	///   - session: The URL session.
	///   - task: The task that completed.
	///   - error: The error, if the task failed.
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: (any Error)?) {

        DispatchQueue.main.async {
            self.downloadingURL = nil
        }
    }
}

/// A utility class for providing sample PDF data for previews.
public final class PDFPreview {
	/// Returns sample PDF data from the module's resources.
	///
	/// - Returns: PDF data if the sample file exists, otherwise `nil`.
    static public var document: Data? {
        guard let path = Bundle.module.path(forResource: "Plus-Janeiro21-AdeusAgendadePapel", ofType: "pdf"),
              let content = FileManager.default.contents(atPath: path) else {
            return nil
        }
        return content
    }
}
#endif
