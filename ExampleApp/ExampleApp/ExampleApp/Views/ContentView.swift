//
//  ContentView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import AnalyticsLibrary
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var analytics: AnalyticsManager

    private let libraries = [
        Library(type: .logger, image: "bookmark"),
        Library(type: .inApp, image: "sterlingsign"),
        Library(type: .utility, image: "hammer"),
        Library(type: .network, image: "wifi"),
        Library(type: .storage, image: "externaldrive.connected.to.line.below"),
        Library(type: .uiComponents, image: "xmark.triangle.circle.square"),
        Library(type: .uiComponentsSpecial, image: "xmark.triangle.circle.square.fill"),
        Library(type: .youtube, image: "tv")
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
        .trackScreen("Home", analytics: analytics)
        .padding()
        .navigation(path: $path) { (type: Library.LibraryType) in
            switch type {
            case .logger: LoggerView()
            case .inApp: InAppView()
            case .utility: UtilityView()
            case .network: NetworkView()
            case .storage: StorageView()
            case .uiComponents: UIComponentsView()
            case .uiComponentsSpecial: UISpecialView()
            case .youtube: YouTubeView()
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
        case utility = "Utility"
        case network = "Network"
        case storage = "Storage"
        case uiComponents = "UI Components"
        case uiComponentsSpecial = "UI Special"
        case youtube = "Vídeos"
    }

    var id = UUID()
    let type: LibraryType
    let image: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

struct CellView: View {
    @EnvironmentObject var analytics: AnalyticsManager
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
        .trackTap(library.type.rawValue, screen: "Home", analytics: analytics)
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
