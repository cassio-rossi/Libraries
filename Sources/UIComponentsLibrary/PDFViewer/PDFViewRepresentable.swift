#if canImport(UIKit)
import PDFKit
import SwiftUI

struct PDFViewRepresentable: UIViewRepresentable {
	typealias UIViewType = PDFView
	let pdfView: PDFView

	init() {
		self.pdfView = PDFView()
		setupView(pdfView: pdfView)
	}

	func makeUIView(context: Context) -> PDFView {
		return pdfView
	}

	func updateUIView(_ uiView: PDFView, context: Context) {}
}

extension PDFViewRepresentable {
	func pages() -> CGFloat {
		return CGFloat(pdfView.document?.pageCount ?? 0) * 120.0
	}
}

extension PDFViewRepresentable {
	fileprivate func setupView(pdfView: PDFView) {
		pdfView.autoScales = true
		pdfView.displayDirection = .horizontal
		pdfView.pageShadowsEnabled = true
		pdfView.backgroundColor = UIColor(named: "backgroundColor") ?? .systemBackground
		pdfView.usePageViewController(true, withViewOptions: nil)
	}
}

struct PDFThumbnailViewRepresentable: UIViewRepresentable {
	typealias UIViewType = PDFThumbnailView
	let parent: PDFView?

	func makeUIView(context: Context) -> PDFThumbnailView {
		let thumb = PDFThumbnailView()
		setup(thumbView: thumb)
		thumb.pdfView = parent
		return thumb
	}

	func updateUIView(_ uiView: PDFThumbnailView, context: Context) {}
}

extension PDFThumbnailViewRepresentable {
    @MainActor
	fileprivate func setup(thumbView: PDFThumbnailView) {
		thumbView.thumbnailSize = CGSize(width: 120, height: 180)
		thumbView.layoutMode = .horizontal
	}
}
#endif
