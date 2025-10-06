//
//  UISpecialView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 06/10/2025.
//

import SwiftUI
import UIComponentsLibrarySpecial

struct UISpecialView: View {
    var body: some View {
        ScrollView {
            VStack {
                SearchBar(text: .constant(""),
                          placeholder: "Procurar ...",
                          cancel: "Cancelar")

                PDFViewer(url: nil,
                          file: PDFPreview.document,
                          isShowingThumbnail: false)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    UISpecialView()
}
