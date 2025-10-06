import SwiftUI
import UIComponentsLibrary

public struct PDFViewer: View {
    @ObservedObject private var downloader: Downloader
    @State private var progress = 100.0
    @State private var isShowingThumbnail: Bool = false
    @Binding var isPresenting: Bool

    let theme: Themeable?
    let PDFUIView = PDFViewRepresentable()

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
                    .edgesIgnoringSafeArea(.all)

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

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    let theme: Themeable?

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
