//
//  ContentView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import SwiftUI

struct ContentView: View {
    private let libraries = [
        Library(type: .logger, image: "bookmark.circle"),
        Library(type: .inApp, image: "sterlingsign.circle"),
        Library(type: .logger, image: "hammer.circle")
    ]

    @State private var path = NavigationPath()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110.0))],
                      spacing: 8) {
                ForEach(libraries, id: \.id) { library in
                    CellView(path: $path, library: library)
                }
            }
        }
        .padding()
        .navigation(path: $path) { (type: Library.LibraryType) in
            switch type {
            case .logger: LoggerView()
            case .inApp: InAppView()
            }
        }
    }
}

#Preview {
    ContentView()
}

struct Library: Identifiable, Hashable {
    enum LibraryType: String {
        case logger = "Logger"
        case inApp = "InApp"
    }

    var id = UUID()
    let type: LibraryType
    let image: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

struct CellView: View {
    @Binding var path: NavigationPath
    let library: Library

    var body: some View {
        Button(action: { path.append(library.type) },
               label: {
            VStack {
                Image(systemName: library.image)
                    .font(.title)
                    .padding(.bottom, 1)
                Text(library.type.rawValue)
            }
        })
        .frame(minWidth: 110.0, minHeight: 110.0)
        .background(.ultraThinMaterial)
    }
}

private struct Navigation<V>: ViewModifier where V: View {
    @Binding var path: NavigationPath
    let destination: (Library.LibraryType) -> V

    func body(content: Content) -> some View {
        NavigationStack(path: $path) {
            content

                .navigationTitle("Library")
                .navigationDestination(for: Library.LibraryType.self, destination: destination)
        }
    }
}

extension View {
    fileprivate func navigation<V>(path: Binding<NavigationPath>,
                                      @ViewBuilder destination: @escaping (Library.LibraryType) -> V) -> some View where V: View {
        modifier(Navigation(path: path, destination: destination))
    }
}
