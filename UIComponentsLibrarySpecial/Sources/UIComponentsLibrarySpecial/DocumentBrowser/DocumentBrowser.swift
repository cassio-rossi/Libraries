import SwiftUI
import UniformTypeIdentifiers

public struct DocumentBrowser {

    @Binding var isPresented: Bool

    let allowedContentTypes: [UTType]
    let allowsMultipleSelection: Bool
    var onCompletion: (Result<[URL], Error>) -> Void

    public init(isPresented: Binding<Bool>,
                allowedContentTypes: [UTType],
                allowsMultipleSelection: Bool,
                onCompletion: @escaping (Result<[URL], Error>) -> Void) {
        _isPresented = isPresented
        self.allowedContentTypes = allowedContentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onCompletion = onCompletion
    }

    func dismissView() {
        isPresented = false
    }
}

// MARK: - UIViewControllerRepresentable -

extension DocumentBrowser: UIViewControllerRepresentable {

    public func makeCoordinator() -> DocumentBrowserCoordinator {
        DocumentBrowserCoordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIDocumentBrowserViewController {
        let controller = UIDocumentBrowserViewController(forOpening: allowedContentTypes)

		controller.allowsPickingMultipleItems = allowsMultipleSelection
		controller.browserUserInterfaceStyle = .white
		controller.allowsDocumentCreation = false

		controller.delegate = context.coordinator

        return controller
    }

    public func updateUIViewController(_ uiViewController: UIDocumentBrowserViewController, context: Context) {}
}

// MARK: - Coordinator -

public class DocumentBrowserCoordinator: NSObject {
    var parent: DocumentBrowser

    public init(parent: DocumentBrowser) {
        self.parent = parent
    }
}

// MARK: - UIDocumentBrowserViewControllerDelegate -

extension DocumentBrowserCoordinator: UIDocumentBrowserViewControllerDelegate {
    public func documentBrowser(_ controller: UIDocumentBrowserViewController,
                                didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(nil, .none)
    }

    public func documentBrowser(_ controller: UIDocumentBrowserViewController,
                                didPickDocumentsAt documentURLs: [URL]) {
        parent.onCompletion(.success(documentURLs))
        parent.dismissView()
    }
}
