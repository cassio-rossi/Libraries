import Combine
import SwiftUI

/// Actions for controlling YouTube player state.
public enum YouTubePlayerAction: Equatable, Sendable {
    case idle,
         cue(String, Double),
         paused(String, Double)

    public static func == (lhs: YouTubePlayerAction, rhs: YouTubePlayerAction) -> Bool {
        if case .idle = lhs,
           case .idle = rhs {
            return true
        }
        if case let .cue(videoLHS, timeLHS) = lhs,
           case let .cue(videoRHS, timeRHS) = rhs {
            return videoLHS == videoRHS && timeLHS == timeRHS
        }
        if case let .paused(videoLHS, timeLHS) = lhs,
           case let .paused(videoRHS, timeRHS) = rhs {
            return videoLHS == videoRHS && timeLHS == timeRHS
        }
        return false
    }
}

#if canImport(WebKit)
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
    public init(api: YouTubeAPI,
                action: Binding<YouTubePlayerAction>) {
        self.api = api
        _action = action
    }

    public func makeUIView(context: Context) -> YouTubePlayer {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.userContentController.removeAllScriptMessageHandlers()

        let webView = YouTubePlayer(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.isScrollEnabled = false
        webView.isAccessibilityElement = false
        webView.set(language: api.language)

        let handler = YouTubePlayerHandler(action: $action)
        var scriptMessageHandlers: [(WKScriptMessageHandler, String)] {
            return [(handler, "videoPaused"),
                    (handler, "stateChanged")]
        }

        for scriptHandler in scriptMessageHandlers {
            webView.configuration.userContentController.add(scriptHandler.0, name: scriptHandler.1)
        }

        webView.load("")

        return webView
    }

    public func updateUIView(_ uiView: YouTubePlayer, context: Context) {
        switch action {
        case .cue(let videoId, let time):
            uiView.cue(videoId, time: time)
            Analytics.logEvent("Dicas", parameters: [
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
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
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

        if message.name == "stateChanged" &&
            YouTubePlayerState(rawValue: message.body as? Int ?? 6) ?? .unknown == .playing {
        }
    }
}
#else
public struct YouTubePlayerView {
    let api: YouTubeAPI
    @Binding public var action: YouTubePlayerAction

    public init(api: YouTubeAPI,
                action: Binding<YouTubePlayerAction>) {
        self.api = api
        _action = action
    }

    public var body: some View {
        ErrorView(message: "Not supported ...")
    }
}
#endif
