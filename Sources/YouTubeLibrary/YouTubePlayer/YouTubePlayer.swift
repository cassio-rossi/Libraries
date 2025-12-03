import UtilityLibrary
#if canImport(WebKit)
import WebKit
#endif

/// Represents the playback state of the YouTube player.
///
/// Maps to YouTube IFrame Player API state values.
enum YouTubePlayerState: Int, Sendable {
	/// Video has not started yet.
    case unstarted = -1
	/// Video has finished playing.
    case ended = 0
	/// Video is currently playing.
    case playing = 1
	/// Video is paused.
    case paused = 2
	/// Video is buffering.
    case buffering = 3
	/// Video has been cued and is ready to play.
    case videoCued = 5
	/// State is unknown or undefined.
    case unknown = 6

	/// Human-readable description of the player state.
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

    private var videoId: String = ""
    private var startTime: Double = 0
    private var language = Locale.preferredLanguageCode

    private var embedVideoHtml: String {
        return """
  <!DOCTYPE html><html>
  <head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;
    background: #000;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  #player {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  #player iframe {
    width: 100% !important;
    height: 100% !important;
    max-width: 100vw;
    max-height: 100vh;
  }
  </style>
  </head>
  <body>
  <div id="player"></div>
  <script>
  var tag = document.createElement('script');
  tag.src = "https://www.youtube.com/iframe_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  var player;
  var pauseTimeout = null;
  function onYouTubeIframeAPIReady() {
    player = new YT.Player('player', {
      playerVars: {
        'playsinline': 1,
        'controls': 1,
        'fs': 0,
        'enablejsapi': 1,
        'autoplay': 1,
        'start': \(Int(startTime)),
        'hl': '\(language)',
        'origin': 'https://\(Bundle.mainBundleIdentifier)',
        'widget_referrer': 'https://\(Bundle.mainBundleIdentifier)'
      },
      width: '100%',
      height: '100%',
      videoId: '\(videoId)',
      events: { 'onReady': onPlayerReady, 'onStateChange': stateChanged }
    });
  }
  function onPlayerReady(event) {
    // event.target.playVideo();
  }
  function stateChanged(event) {
    window.webkit.messageHandlers.stateChanged.postMessage(event.data);
    if (event.data == YT.PlayerState.CUED) {
      player.playVideo();
    }
    if (event.data == YT.PlayerState.PLAYING || event.data == YT.PlayerState.BUFFERING) {
      if (pauseTimeout) {
        clearTimeout(pauseTimeout);
        pauseTimeout = null;
      }
    }
    if (event.data == YT.PlayerState.PAUSED) {
      if (pauseTimeout) clearTimeout(pauseTimeout);
      pauseTimeout = setTimeout(function() {
        window.webkit.messageHandlers.videoPaused.postMessage(JSON.stringify({'videoUrl':player.getVideoUrl(),'currentTime':player.getCurrentTime()}));
        pauseTimeout = null;
      }, 500);
    }
    if (event.data == YT.PlayerState.ENDED) {
      if (pauseTimeout) clearTimeout(pauseTimeout);
      window.webkit.messageHandlers.videoPaused.postMessage(JSON.stringify({'videoUrl':player.getVideoUrl(),'currentTime':player.getCurrentTime()}));
    }
  }
  </script>
  </body></html>
  """
    }

    // MARK: - Methods -

    /// Loads and initializes a YouTube video with start time.
    ///
    /// - Parameters:
    ///   - video: YouTube video identifier.
    ///   - time: Starting playback position in seconds.
    public func load(_ video: String, time: Double = 0, language: String? = nil) {
        videoId = video
        startTime = time
        self.language = language ?? Locale.preferredLanguageCode
        loadHTMLString(embedVideoHtml, baseURL: URL(string: "https://\(Bundle.mainBundleIdentifier)"))
    }

	/// Cues a video without starting playback.
	///
	/// - Parameters:
	///   - video: YouTube video identifier.
	///   - time: Starting position in seconds (default: 0).
    public func cue(_ video: String, time: Double = 0) {
        self.evaluateJavaScript("player.cueVideoById('\(video)',\(time));") { _, _ in }
    }
}
#else
public class YouTubePlayer {
}
#endif

extension Locale {
	/// Returns the user's preferred language code.
	///
	/// Defaults to "en" if no preferred language is available.
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).language.languageCode?.identifier else {
            return "en"
        }
        return code
    }

	/// Returns all user's preferred language codes.
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({ Locale(identifier: $0).language.languageCode?.identifier })
    }
}
