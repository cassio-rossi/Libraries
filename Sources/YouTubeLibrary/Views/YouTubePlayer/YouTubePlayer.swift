#if canImport(WebKit)
import WebKit
#endif

enum YouTubePlayerState: Int, Sendable {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case videoCued = 5
    case unknown = 6

    var description: String {
        switch self {
        case .unstarted: return "unstarted"
        case .ended: return "ended"
        case .playing: return "playing..."
        case .paused: return "paused"
        case .buffering: return "buffering"
        case .videoCued: return "video_cued"
        case .unknown: return "unknown"
        }
    }
}

/// WebKit-based YouTube player with JavaScript API integration.
///
/// Embeds the YouTube IFrame Player API for native video playback control.
#if canImport(WebKit)
public class YouTubePlayer: WKWebView {

    // MARK: - Properties -

    var embedVideoHtml: String {
        return """
  <!DOCTYPE html><html>
  <style>body,html,iframe{margin:0;padding:0;}</style>
  <script>
  var meta = document.createElement('meta');
  meta.setAttribute('name', 'viewport');
  meta.setAttribute('content', 'width=device-width');
  document.getElementsByTagName('head')[0].appendChild(meta);
  var tag = document.createElement('script');
  tag.src = "https://www.youtube.com/iframe_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  var player;
  function onYouTubeIframeAPIReady() {
  player = new YT.Player('player', {
  playerVars: { 'playsinline': 1, 'controls': 1, 'fs': 1, 'enablejsapi': 1, 'hl': '\(language)' },
  height: '100%',
  width: '100%',
  videoId: '\(videoId ?? "")',
  events: { 'onReady': onPlayerReady, 'onStateChange': stateChanged }
  });
  }
  function onPlayerReady(event) { event.target.playVideo(); }
  function stateChanged(event) {
  window.webkit.messageHandlers.stateChanged.postMessage(event.data);
  if (event.data == YT.PlayerState.CUED) {
  player.playVideo();
  }
  if (event.data == YT.PlayerState.PAUSED) {
  window.webkit.messageHandlers.videoPaused.postMessage(JSON.stringify({'videoUrl':player.getVideoUrl(),'currentTime':player.getCurrentTime()}));
  }
  if (event.data == YT.PlayerState.ENDED) {
  window.webkit.messageHandlers.videoPaused.postMessage(JSON.stringify({'videoUrl':player.getVideoUrl(),'currentTime':player.getCurrentTime()}));
  }
  }
  </script>
  <body><div id="player"></div></body></html>
  """
    }

    var autoPlay = false
    var time: Double = 0
    public var videoId: String?
    var language = Locale.preferredLanguageCode

    // MARK: - Methods -

	/// Starts video playback.
    public func play() {
        self.evaluateJavaScript("player.playVideo()")
    }

	/// Seeks to a specific time and starts playback.
	///
	/// - Parameter time: Playback position in seconds.
    public func play(time: Double) {
        if time > 0 {
            self.time = time
            self.evaluateJavaScript("player.seekTo(\(time))")
        }
        play()
    }

	/// Loads and initializes a YouTube video.
	///
	/// - Parameter video: YouTube video identifier.
    public func load(_ video: String) {
        videoId = video
        self.loadHTMLString(self.embedVideoHtml, baseURL: nil)
    }

	/// Cues a video without starting playback.
	///
	/// - Parameters:
	///   - video: YouTube video identifier.
	///   - time: Starting position in seconds.
    public func cue(_ video: String, time: Double = 0) {
        self.evaluateJavaScript("player.cueVideoById('\(video)',\(time));")
    }

    func state(_ state: Int) -> YouTubePlayerState {
        YouTubePlayerState(rawValue: state) ?? .unknown
    }

    func set(language: String) {
        if language.isEmpty { return }
        self.language = language
    }
}
#else
public class YouTubePlayer {
}
#endif

extension Locale {
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).language.languageCode?.identifier else {
            return "en"
        }
        return code
    }

    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({ Locale(identifier: $0).language.languageCode?.identifier })
    }
}
