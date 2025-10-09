//
//  YouTubeView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 08/10/2025.
//

import SwiftUI
import YouTubeLibrary

struct YouTubeView: View {
    let viewModel = YouTubeViewModel()
    @State private var favorite = false
    @State private var searchText = ""

    var body: some View {
        VideosView(api: viewModel.youtube,
                   favorite: favorite,
                   search: searchText,
                   theme: nil)
        .navigationTitle("Videos")
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    favorite.toggle()
                }, label: {
                    Image(systemName: "star")
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        YouTubeView()
    }
}

class YouTubeViewModel {
    let credentials = YouTubeCredentials(salt: "AppDelegateNSObject",
                                         keys: [
                                            [0, 57, 10, 37, 54, 21, 36, 2, 13, 46, 93, 125, 43, 45, 86, 5, 55, 5, 57, 59, 9, 58, 118, 32, 5, 12, 4, 51, 36, 52, 36, 60, 62, 9, 91, 36, 54, 30, 50]
                                         ],
                                         playlistId: [20, 37, 70, 30, 44, 1, 41, 16, 8, 61, 4, 24, 1, 22, 43, 45, 28, 0, 5, 41, 69, 25, 8, 36],
                                         channelId: [20, 51, 70, 30, 44, 1, 41, 16, 8, 61, 4, 24, 1, 22, 43, 45, 28, 0, 5, 41, 69, 25, 8, 36])

    @MainActor
    lazy var youtube = YouTubeAPI(credentials: credentials,
                                  mock: nil,
                                  containerIdentifier: "iCloud.com.brit.beta.macmagazine",
                                  inMemory: false)
}
