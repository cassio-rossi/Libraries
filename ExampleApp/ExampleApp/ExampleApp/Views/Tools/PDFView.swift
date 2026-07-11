//
//  PDFView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 10/07/2026.
//

import SwiftUI
import UIComponentsLibrary

struct PDFView: View {
    /// The available PDF sources the viewer can load from.
    private enum Source: String, CaseIterable, Identifiable {
        case local = "Local"
        case remote = "Remote"

        var id: Self { self }
    }

    private static let remoteURL = URL(string: "https://entendendoiphone.com.br/ebook/DC/DomineiCloud2026.pdf")

    @State private var source: Source = .local
    @State private var show = true

    var body: some View {
        PDFViewer(
            url: source == .remote ? Self.remoteURL : nil,
            file: source == .local ? PDFPreview.document : nil,
            isPresenting: $show,
            isShowingThumbnail: false
        )
        .id(source)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Source", selection: $source) {
                    ForEach(Source.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
