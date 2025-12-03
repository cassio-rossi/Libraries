#if canImport(UIKit)
import PDFKit
import SwiftUI

/// A SwiftUI representable wrapper for PDFKit's PDFView.
///
/// `PDFViewRepresentable` bridges UIKit's PDFView to SwiftUI, providing
/// a reusable PDF viewing component with pre-configured settings for
/// optimal display and navigation.
struct PDFViewRepresentable: UIViewRepresentable {
	typealias UIViewType = PDFView

	/// The underlying PDFView instance.
	let pdfView: PDFView

	/// Creates a new PDF view representable with default configuration.
	init() {
		self.pdfView = PDFView()
		setupView(pdfView: pdfView)
	}

	/// Creates the UIKit view that this representable wraps.
	///
	/// - Parameter context: The view context.
	/// - Returns: The configured PDFView.
	func makeUIView(context: Context) -> PDFView {
		return pdfView
	}

	/// Updates the UIKit view when SwiftUI state changes.
	///
	/// - Parameters:
	///   - uiView: The PDFView to update.
	///   - context: The view context.
	func updateUIView(_ uiView: PDFView, context: Context) {}
}

extension PDFViewRepresentable {
	/// Calculates the total width needed to display all page thumbnails.
	///
	/// - Returns: The combined width of all page thumbnails at 120 points per page.
	func pages() -> CGFloat {
		return CGFloat(pdfView.document?.pageCount ?? 0) * 120.0
	}
}

extension PDFViewRepresentable {
	/// Configures the PDF view with optimal display settings.
	///
	/// Sets up auto-scaling, horizontal scrolling, shadows, background color,
	/// and page view controller mode.
	///
	/// - Parameter pdfView: The PDFView to configure.
	fileprivate func setupView(pdfView: PDFView) {
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

extension PDFThumbnailViewRepresentable {
	/// Configures the thumbnail view with size and layout settings.
	///
	/// - Parameter thumbView: The PDFThumbnailView to configure.
    @MainActor
	fileprivate func setup(thumbView: PDFThumbnailView) {
		thumbView.thumbnailSize = CGSize(width: 120, height: 180)
		thumbView.layoutMode = .horizontal
	}
}
#endif
