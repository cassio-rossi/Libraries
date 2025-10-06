import Foundation
import PDFKit
import SwiftUI
import UtilityLibrary

@MainActor
public class Downloader: NSObject, ObservableObject {
    @Published var progress: Double = 0.0

    var file: String?
    var pdfView: PDFView?

    override public init() {}

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

    public func download(from url: URL?, goto page: String?) {
        guard let url = url else { return }

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

    public func isLocal(url: URL?) -> Bool {
        guard let url = url,
              load(document: url.lastPathComponent) != nil else {
            return false
        }
        return true
    }
}

extension Downloader {
    fileprivate func loadDocument(data: Data, goto page: String? = nil) {
        pdfView?.document = PDFDocument(data: data)
        guard let page = page,
              let pdfPage = pdfView?.document?.page(at: (Int(page) ?? 1) - 1) else { return }

        pdfView?.go(to: pdfPage)
    }
}

extension Downloader {
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    fileprivate func getFilePath(file: String) -> String {
        return "\(file.base64Encode ?? file.replacingOccurrences(of: "/", with: "_")).pdf"
    }

    fileprivate func getFilePath(file: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(getFilePath(file: file))
    }

    fileprivate func save(document: Data?, file: String?) {
        guard let file = file else { return }
        let filename: URL = getFilePath(file: file)
        try? document?.write(to: filename)
    }

    fileprivate func load(document: String?) -> Data? {
        guard let document = document else { return nil }
        let filename: URL = getFilePath(file: document)
        if FileManager.default.fileExists(atPath: filename.relativePath) {
            return loadPdf(from: filename)
        }
        return nil
    }

    fileprivate func loadPdf(from location: URL) -> Data? {
        let reader = try? FileHandle(forReadingFrom: location)
        return reader?.readDataToEndOfFile()
    }
}

extension Downloader: @preconcurrency URLSessionDownloadDelegate {
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

public class PDFPreview {
    static public var document: Data? {
        guard let path = Bundle.module.path(forResource: "Plus-Janeiro21-AdeusAgendadePapel", ofType: "pdf"),
              let content = FileManager.default.contents(atPath: path) else {
            return nil
        }
        return content
    }
}
