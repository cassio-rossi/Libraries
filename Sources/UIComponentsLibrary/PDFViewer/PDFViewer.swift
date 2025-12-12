import SwiftUI

#if canImport(UIKit) && !os(watchOS)
/// A SwiftUI view for displaying PDF documents with download progress and thumbnail navigation.
///
/// `PDFViewer` provides a full-featured PDF viewing experience with:
/// - URL-based or Data-based PDF loading
/// - Download progress indication
/// - Thumbnail navigation
/// - Page navigation support
/// - Themeable appearance
public struct PDFViewer: View {
	/// The downloader responsible for fetching and managing PDF content.
    private var downloader: Downloader

	/// The download progress percentage (0-100).
    @State private var progress = 100.0

	/// Whether the thumbnail navigation view is displayed.
    @State private var isShowingThumbnail: Bool = false

	/// A binding to control whether the viewer is presented.
    @Binding var isPresenting: Bool

	/// The theme configuration for customizing the viewer's appearance.
    let theme: Themeable?

	/// The underlying PDF view representable.
    let PDFUIView = PDFViewRepresentable()

	/// Creates a PDF viewer with the specified configuration.
	///
	/// - Parameters:
	///   - downloader: The downloader to use for fetching PDFs. Defaults to a new instance.
	///   - url: Optional URL to download the PDF from.
	///   - file: Optional PDF data to display directly without downloading.
	///   - page: Optional page number to navigate to initially (1-indexed).
	///   - theme: Optional theme for customizing appearance.
	///   - isPresenting: A binding controlling the presentation state. Defaults to `.constant(true)`.
	///   - isShowingThumbnail: Whether to show thumbnails initially. Defaults to `false`.
    public init(downloader: Downloader = Downloader(),
                url: URL?,
                file: Data? = nil,
                page: String? = nil,
                theme: Themeable? = nil,
                isPresenting: Binding<Bool> = .constant(true),
                isShowingThumbnail: Bool = false) {

        _isPresenting = isPresenting
        self.downloader = downloader
        self.theme = theme
        self.isShowingThumbnail = isShowingThumbnail

        downloader.download(from: url,
                            fallback: file,
                            pdfView: PDFUIView.pdfView,
                            goto: page)
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Color(.gray)
                    .opacity(0.4)
                    .ignoresSafeArea()

                HStack {
                    Button(action: {
                        withAnimation {
                            isShowingThumbnail.toggle()
                        }
                    }, label: {
                        Image(systemName: "square.bottomthird.inset.filled")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    })
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isPresenting = false
                        }
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    })
                }
                .padding()
            }
            .frame(height: 60)

            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    PDFUIView

                    ProgressView(value: downloader.progress,
                                 total: 100.0)
                    .progressViewStyle(CustomCircularProgressViewStyle(theme: theme))
                    .padding()
                }
                if isShowingThumbnail {
                    ScrollView(.horizontal) {
                        PDFThumbnailViewRepresentable(parent: PDFUIView.pdfView)
                            .frame(width: PDFUIView.pages(), height: 240)
                    }
                }
            }
        }
    }
}

struct PDFViewer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PDFViewer(url: nil,
                      file: PDFPreview.document,
                      isShowingThumbnail: false)
            .previewDisplayName("Preview")

            PDFViewer(url: nil,
                      file: PDFPreview.document,
                      isShowingThumbnail: true)
            .previewDisplayName("Thumbnail")
        }
    }
}

/// A custom circular progress view style for PDF download indication.
///
/// Displays download progress as a circular progress indicator with percentage text.
struct CustomCircularProgressViewStyle: ProgressViewStyle {
	/// The theme configuration for customizing colors.
    let theme: Themeable?

	/// Creates the progress view body.
	///
	/// - Parameter configuration: The progress view configuration containing completion percentage.
	/// - Returns: A view displaying circular progress with percentage text.
    func makeBody(configuration: Configuration) -> some View {
        if configuration.fractionCompleted ?? 0.0 > 0.01 &&
            configuration.fractionCompleted ?? 0.0 < 1.0 {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0.0))
                    .stroke(theme?.button.primary.asColor ?? .blue,
                            style: StrokeStyle(lineWidth: 20))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120)

                Text("\(Int((configuration.fractionCompleted ?? 0.0) * 100))%")
                    .fontWeight(.bold)
                    .foregroundColor(theme?.button.primary.asColor ?? .blue)
                    .frame(width: 80)
            }
        }
    }
}
#else
/// A stub PDF viewer for non-UIKit platforms.
///
/// This version is provided for platforms that don't support UIKit.
/// It displays a message indicating PDFs are not supported on the current platform.
public struct PDFViewer: View {
	/// Creates a PDF viewer stub for non-UIKit platforms.
	///
	/// - Parameters:
	///   - url: Ignored on non-UIKit platforms.
	///   - file: Ignored on non-UIKit platforms.
	///   - page: Ignored on non-UIKit platforms.
	///   - theme: Ignored on non-UIKit platforms.
	///   - isPresenting: Ignored on non-UIKit platforms.
	///   - isShowingThumbnail: Ignored on non-UIKit platforms.
    public init(url: URL?,
                file: Data? = nil,
                page: String? = nil,
                theme: Themeable? = nil,
                isPresenting: Binding<Bool> = .constant(true),
                isShowingThumbnail: Bool = false) {}

    public var body: some View {
        Text("Not supported ...")
    }
}
#endif
