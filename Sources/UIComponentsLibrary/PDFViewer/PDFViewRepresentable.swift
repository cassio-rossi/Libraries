#if canImport(PDFKit)
#if canImport(UIKit)
import PDFKit
import SwiftUI

/// A SwiftUI representable wrapper for PDFKit's PDFView.
///
/// `PDFViewRepresentable` bridges UIKit's `PDFView` to SwiftUI. The `PDFView`
/// instance is owned by the parent SwiftUI view (as `@State`) and passed in, so
/// it survives re-renders. The currently loaded `PDFDocument` is pushed into the
/// mounted view from `updateUIView`, keeping SwiftUI the single source of truth
/// for the displayed document.
struct PDFViewRepresentable: UIViewRepresentable {
	typealias UIViewType = PDFView

	/// The underlying, externally-owned `PDFView` instance.
	let pdfView: PDFView

	/// The document to display, or `nil` while loading.
	let document: PDFDocument?

	/// Optional 1-indexed page to navigate to once the document is loaded.
	let page: String?

	/// Creates a representable bound to an externally-owned `PDFView`.
	///
	/// - Parameters:
	///   - pdfView: The `PDFView` to mount (owned by the parent view).
	///   - document: The document to display, or `nil` while loading.
	///   - page: Optional 1-indexed page to navigate to after loading.
	init(pdfView: PDFView, document: PDFDocument?, page: String? = nil) {
		self.pdfView = pdfView
		self.document = document
		self.page = page
	}

	/// Creates the UIKit view that this representable wraps.
	///
	/// - Parameter context: The view context.
	/// - Returns: The configured `PDFView`.
	func makeUIView(context: Context) -> PDFView {
		setupView(pdfView: pdfView)
		return pdfView
	}

	/// Syncs the loaded document into the mounted `PDFView`.
	///
	/// Runs whenever SwiftUI re-evaluates the view (e.g. when `document` changes
	/// as the download completes). Navigation to `page` happens once, right after
	/// the new document is assigned.
	///
	/// - Parameters:
	///   - uiView: The `PDFView` to update.
	///   - context: The view context.
	func updateUIView(_ uiView: PDFView, context: Context) {
		guard uiView.document !== document else { return }
		uiView.document = document

		guard let page,
			  let document,
			  let pdfPage = document.page(at: max(0, (Int(page) ?? 1) - 1)) else { return }
		uiView.go(to: pdfPage)
	}
}

private extension PDFViewRepresentable {
	/// Configures the PDF view with optimal display settings.
	///
	/// Sets up auto-scaling, horizontal scrolling, shadows, background color,
	/// and page view controller mode.
	///
	/// - Parameter pdfView: The `PDFView` to configure.
	func setupView(pdfView: PDFView) {
		pdfView.autoScales = true
		pdfView.displayDirection = .horizontal
		pdfView.pageShadowsEnabled = true
		pdfView.backgroundColor = UIColor(named: "backgroundColor") ?? .systemBackground
		pdfView.usePageViewController(true, withViewOptions: nil)
	}
}

/// A SwiftUI representable wrapper for PDFKit's PDFThumbnailView.
///
/// `PDFThumbnailViewRepresentable` provides a thumbnail navigation bar
/// for PDFs, allowing users to see and navigate between pages visually.
struct PDFThumbnailViewRepresentable: UIViewRepresentable {
	typealias UIViewType = PDFThumbnailView

	/// The parent PDFView that this thumbnail view controls.
	let parent: PDFView?

	/// Creates the UIKit thumbnail view.
	///
	/// - Parameter context: The view context.
	/// - Returns: A configured PDFThumbnailView linked to the parent PDFView.
	func makeUIView(context: Context) -> PDFThumbnailView {
		let thumb = PDFThumbnailView()
		setup(thumbView: thumb)
		thumb.pdfView = parent
		return thumb
	}

	/// Updates the thumbnail view when SwiftUI state changes.
	///
	/// - Parameters:
	///   - uiView: The PDFThumbnailView to update.
	///   - context: The view context.
	func updateUIView(_ uiView: PDFThumbnailView, context: Context) {}
}

private extension PDFThumbnailViewRepresentable {
	/// Configures the thumbnail view with size and layout settings.
	///
	/// - Parameter thumbView: The PDFThumbnailView to configure.
    @MainActor
	func setup(thumbView: PDFThumbnailView) {
		thumbView.thumbnailSize = CGSize(width: 120, height: 180)
		thumbView.layoutMode = .horizontal
	}
}
#endif
#endif
