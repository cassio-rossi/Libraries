import Combine
import SwiftUI

/// Actions for controlling YouTube player state.
public enum YouTubePlayerAction: Equatable, Sendable {
    case idle,
         cue(String, Double),
         playing(String),
         paused(String, Double)

    /// Returns the video ID for the current action.
    public var videoId: String? {
        switch self {
        case .cue(let id, _), .playing(let id), .paused(let id, _):
            return id
        case .idle:
            return nil
        }
    }

    /// Returns true if the video is currently playing.
    public var isPlaying: Bool {
        if case .playing = self { return true }
        if case .paused = self { return true }
        return false
    }
}

#if canImport(UIKit)
import FirebaseAnalytics
@preconcurrency import WebKit

/// SwiftUI wrapper for the YouTube player with action-based control.
///
/// Manages player lifecycle and communicates state changes through bindings.
public struct YouTubePlayerView: UIViewRepresentable {
    let api: YouTubeAPI
    @Binding public var action: YouTubePlayerAction

	/// Creates a new YouTube player view.
	///
	/// - Parameters:
	///   - api: YouTube API instance for configuration.
	///   - action: Binding to player action state.
    public init(
        api: YouTubeAPI,
        action: Binding<YouTubePlayerAction>
    ) {
        self.api = api
        _action = action
    }

    public func makeUIView(context: Context) -> YouTubePlayer {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .video
        configuration.userContentController.removeAllScriptMessageHandlers()

        let webView = YouTubePlayer(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.isScrollEnabled = false
        webView.isAccessibilityElement = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        let handler = YouTubePlayerHandler(action: $action)
        var scriptMessageHandlers: [(WKScriptMessageHandler, String)] {
            return [(handler, "videoPaused"),
                    (handler, "stateChanged")]
        }

        for scriptHandler in scriptMessageHandlers {
            webView.configuration.userContentController.add(scriptHandler.0, name: scriptHandler.1)
        }

        webView.load("", language: api.language)

        return webView
    }

    public func updateUIView(_ uiView: YouTubePlayer, context: Context) {
        switch action {
        case let .cue(videoId, time):
            uiView.cue(videoId, time: time)
            Analytics.logEvent("YouTubePlayerView", parameters: [
                "videoId": videoId as NSObject
            ])
        default:
            break
        }
    }

    public func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(webView: self)
    }
}

// MARK: - Coordinator Methods -

public class WebViewCoordinator: NSObject {
    private let webView: YouTubePlayerView

    public init(webView: YouTubePlayerView) {
        self.webView = webView
    }
}

extension WebViewCoordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        preferences: WKWebpagePreferences,
                        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {}
}

// MARK: - Script Message Handler -

class YouTubePlayerHandler: NSObject, ObservableObject, WKScriptMessageHandler {
    @Binding var action: YouTubePlayerAction

    init(action: Binding<YouTubePlayerAction>) {
        _action = action
    }

    func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        struct Body: Decodable {
            let videoUrl: String
            let currentTime: Double

            var videoId: String? {
                guard let url = URLComponents(string: videoUrl) else { return nil }
                return url.queryItems?.first(where: { $0.name == "v" })?.value
            }
        }

        if message.name == "videoPaused" {
            guard let body = message.body as? String,
                  let data = body.data(using: .utf8),
                  let response = try? JSONDecoder().decode(Body.self, from: data) else { return }

            guard let videoId = response.videoId else { return }
            action = .paused(videoId, response.currentTime)
        }

        if message.name == "stateChanged" {
            let state = YouTubePlayerState(rawValue: message.body as? Int ?? 6) ?? .unknown
            if state == .playing, let videoId = action.videoId {
                action = .playing(videoId)
            }
        }
    }
}
#else
public struct YouTubePlayerView {
    public init(api: YouTubeAPI,
                action: Binding<YouTubePlayerAction>) {
    }

    public var body: some View {
        Text("Not supported ...")
    }
}
#endif
