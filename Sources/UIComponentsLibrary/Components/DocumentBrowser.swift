#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI wrapper for UIDocumentBrowserViewController to browse and pick documents.
public struct DocumentBrowser {

    @Binding var isPresented: Bool

    let allowedContentTypes: [UTType]
    let allowsMultipleSelection: Bool
    var onCompletion: (Result<[URL], Error>) -> Void

    /// Creates a new document browser.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the browser is presented.
    ///   - allowedContentTypes: The UTType array of allowed document types.
    ///   - allowsMultipleSelection: Whether multiple documents can be selected.
    ///   - onCompletion: A closure called with the result of document selection.
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

    /// Creates the coordinator for managing document browser delegate callbacks.
    public func makeCoordinator() -> DocumentBrowserCoordinator {
        DocumentBrowserCoordinator(parent: self)
    }

    /// Creates and configures the UIDocumentBrowserViewController.
    public func makeUIViewController(context: Context) -> UIDocumentBrowserViewController {
        let controller = UIDocumentBrowserViewController(forOpening: allowedContentTypes)

		controller.allowsPickingMultipleItems = allowsMultipleSelection
		controller.browserUserInterfaceStyle = .white
		controller.allowsDocumentCreation = false

		controller.delegate = context.coordinator

        return controller
    }

    /// Updates the UIDocumentBrowserViewController when SwiftUI state changes.
    public func updateUIViewController(_ uiViewController: UIDocumentBrowserViewController, context: Context) {}
}

// MARK: - Coordinator -

/// Coordinator for handling document browser delegate callbacks.
public class DocumentBrowserCoordinator: NSObject {
    var parent: DocumentBrowser

    /// Creates a new document browser coordinator.
    ///
    /// - Parameter parent: The parent DocumentBrowser instance.
    public init(parent: DocumentBrowser) {
        self.parent = parent
    }
}

// MARK: - UIDocumentBrowserViewControllerDelegate -

extension DocumentBrowserCoordinator: UIDocumentBrowserViewControllerDelegate {
    /// Handles document creation requests (currently disabled).
    public func documentBrowser(
		_ controller: UIDocumentBrowserViewController,
		didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
	) {
        importHandler(nil, .none)
    }

    /// Handles document selection by the user.
    public func documentBrowser(_ controller: UIDocumentBrowserViewController,
                                didPickDocumentsAt documentURLs: [URL]) {
        parent.onCompletion(.success(documentURLs))
        parent.dismissView()
    }
}
#endif
