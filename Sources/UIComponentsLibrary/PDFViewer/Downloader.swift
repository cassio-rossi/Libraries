#if canImport(PDFKit)
import Foundation
import PDFKit
import SwiftUI
import UtilityLibrary

/// A downloader class for fetching and managing PDF documents.
///
/// `Downloader` handles PDF downloads from URLs, caches PDFs locally,
/// and provides progress tracking. It integrates with PDFView to display
/// downloaded content and supports navigation to specific pages.
@MainActor
@Observable
public class Downloader: NSObject {
	/// The download progress as a percentage (0.0 to 100.0).
    var progress: Double = 0.0

	/// The filename of the PDF being downloaded or loaded.
    var file: String?

	/// The PDFView that will display the downloaded PDF.
    var pdfView: PDFView?

	/// Creates a new downloader instance.
    override public init() {}

	/// Downloads or loads a PDF from a URL or fallback data.
	///
	/// This method first checks if fallback data is provided. If so, it loads
	/// the PDF directly from that data. Otherwise, it attempts to download
	/// from the provided URL.
	///
	/// - Parameters:
	///   - url: Optional URL to download the PDF from.
	///   - file: Optional PDF data to use as a fallback.
	///   - pdfView: The PDFView to display the PDF in.
	///   - page: Optional page number to navigate to (1-indexed).
    public func download(from url: URL?,
                         fallback file: Data?,
                         pdfView: PDFView,
                         goto page: String? = nil) {

        guard let data = file else {
            self.pdfView = pdfView
            download(from: url, goto: page)
            return
        }
        DispatchQueue.main.async {
            self.loadDocument(data: data, goto: page)
        }
    }

	/// Downloads a PDF from a URL.
	///
	/// Checks the local cache first before initiating a network download.
	/// The downloaded PDF is saved locally for future use.
	///
	/// - Parameters:
	///   - url: The URL to download the PDF from.
	///   - page: Optional page number to navigate to after loading (1-indexed).
    public func download(from url: URL?, goto page: String?) {
        guard let url else { return }

        self.file = url.lastPathComponent

        guard let data = load(document: file) else {
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
            self.loadDocument(data: data, goto: page)
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
	/// Loads a PDF document from data into the PDF view.
	///
	/// - Parameters:
	///   - data: The PDF data to load.
	///   - page: Optional page number to navigate to (1-indexed).
    func loadDocument(data: Data, goto page: String? = nil) {
        pdfView?.document = PDFDocument(data: data)
        guard let page = page,
              let pdfPage = pdfView?.document?.page(at: (Int(page) ?? 1) - 1) else { return }

        pdfView?.go(to: pdfPage)
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

extension Downloader: @preconcurrency URLSessionDownloadDelegate {
	/// Called periodically to report download progress.
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
	/// Saves the downloaded PDF to local cache and loads it into the PDF view.
	///
	/// - Parameters:
	///   - session: The URL session.
	///   - downloadTask: The download task.
	///   - location: The temporary location of the downloaded file.
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {

        if let data = loadPdf(from: location) {
            save(document: data, file: file)

            DispatchQueue.main.async {
                self.loadDocument(data: data)
            }
        }
    }
}

/// A utility class for providing sample PDF data for previews.
public class PDFPreview {
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
