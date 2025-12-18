#if canImport(WebKit)
#if canImport(UIKit)
import WebKit

/// A cache manager for WKWebView instances.
///
/// `WebViewCache` maintains a pool of WKWebView instances that persist
/// across view recreations, preventing unnecessary page reloads when
/// navigating between views. This provides a TabView-like experience
/// where web content is preserved when switching between different sections.
///
/// Usage:
/// ```swift
/// let webView = WebViewCache.shared.getOrCreateWebView(
///     for: "unique-key",
///     navigationDelegate: delegate
/// )
/// ```
@MainActor
class WebViewCache {
    /// Shared singleton instance.
    static let shared = WebViewCache()

    /// Dictionary storing cached WKWebView instances keyed by unique identifiers.
    private var cachedWebViews: [String: WKWebView] = [:]

    init() {}

    /// Retrieves an existing cached WKWebView or creates a new one if not found.
    ///
    /// - Parameters:
    ///   - cacheKey: Optional unique identifier for this webview instance.
    ///   - navigationDelegate: Optional navigation delegate to set on the webview.
    ///   - uiDelegate: Optional UI delegate to set on the webview.
    /// - Returns: A WKWebView instance, either from cache or newly created.
    func createWebView(for cacheKey: String?,
                              navigationDelegate: WKNavigationDelegate? = nil,
                              uiDelegate: WKUIDelegate? = nil) -> WKWebView {
        if let cacheKey,
            let webView = cachedWebViews[cacheKey] {
            // Update delegates if provided
            webView.navigationDelegate = navigationDelegate
            webView.uiDelegate = uiDelegate
            return webView
        }

        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = navigationDelegate
        webView.uiDelegate = uiDelegate
        webView.configuration.userContentController.removeAllScriptMessageHandlers()

        if let cacheKey {
            cachedWebViews[cacheKey] = webView
        }

        return webView
    }

    /// Clears cached webview(s).
    ///
    /// - Parameter key: Optional key to clear a specific webview. If nil, clears all cached webviews.
    func clearCache(for key: String? = nil) {
        if let key {
            cachedWebViews.removeValue(forKey: key)
        } else {
            cachedWebViews.removeAll()
        }
    }

    /// Checks if a webview with the given key exists in the cache.
    ///
    /// - Parameter key: The unique identifier to check.
    /// - Returns: `true` if a cached webview exists for this key.
    func hasCache(for key: String) -> Bool {
        cachedWebViews[key] != nil
    }
}
#endif
#endif
