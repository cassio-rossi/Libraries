import SwiftUI

private struct PlayerModifier: ViewModifier {
    let api: YouTubeAPI
    @Binding var action: YouTubePlayerAction

    func body(content: Content) -> some View {
        content
            .background(
                YouTubePlayerView(api: api, action: $action)
                    .opacity(0)
                    .id("youtube-player-stable")
            )
            .onAppear {
                action = .idle
                api.selectedVideo = nil
                api.nextPageToken = nil
            }
            .onDisappear {
                api.searchResult = []
                api.status = .done
            }
            .onChange(of: api.selectedVideo) { _, newValue in
                guard let videoId = newValue?.videoId else {
                    action = .idle
                    return
                }
                action = .cue(videoId, newValue?.current ?? 0)
            }
            .onChange(of: action) { _, action in
                Task {
                    switch action {
                    case .paused(let videoId, let current):
                        await api.update(videoId: videoId, current: current)
                        api.selectedVideo = nil
                        self.action = .idle
                    default: break
                    }
                }
            }
    }
}

extension View {
    public func player(
        api: YouTubeAPI,
        action: Binding<YouTubePlayerAction>
    ) -> some View {
        modifier(
            PlayerModifier(
                api: api,
                action: action
            )
        )
    }
}
