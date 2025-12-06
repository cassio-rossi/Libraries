//
//  YouTubeView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 08/10/2025.
//

import StorageLibrary
import SwiftUI
import UIComponentsLibrary
import UtilityLibrary
import YouTubeLibrary

struct YouTubeView: View {
    let viewModel = YouTubeViewModel()
    @State private var favorite = false
    @State private var searchText = ""

    var body: some View {
        Videos(
            card: ModernCard(),
            usesDensity: false,
            api: viewModel.youtube,
            scrollPosition: Binding(get: { ScrollPosition() }, set: { _ in }),
            favorite: favorite,
            search: searchText
        )
        .navigationTitle("Vídeos")
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
    lazy var youtube = YouTubeAPI(
        credentials: credentials,
        storage: Database(models: [VideoDB.self], inMemory: false),
        language: "pt-BR"
    )
}

@MainActor
public struct CustomCard: VideoCard {
    public let accessibilityLabels: [CardLabel]?
    public let accessibilityButtons: [CardButton]?

    public init(
        accessibilityLabels: [CardLabel]? = nil,
        accessibilityButtons: [CardButton]? = nil
    ) {
        self.accessibilityLabels = accessibilityLabels
        self.accessibilityButtons = accessibilityButtons
    }

    public func makeBody(data: VideoDB) -> some View {
        CustomVideoCard(data: data)
    }
}

@MainActor
struct CustomVideoCard: View {
    let data: VideoDB

    var body: some View {
        content.cornerRadius(corners: .allCorners)
    }

    var content: some View {
        HStack {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 4) {
                    Text(data.pubDate)
                    Text("•")
                    Text("\(data.views) views")
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
                .padding(.bottom, 4)

                HStack {
                    Text(data.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2, reservesSpace: true)
                    Spacer()
                }
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1)
                .padding(.bottom, 12)
            }
            VStack {
                FavoriteButton(content: data)
                ShareButton(content: data)
            }
        }
        .padding([.leading, .trailing])
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.black.opacity(0.6))
    }
}
