#if canImport(WebKit)
#if canImport(UIKit)
import Observation
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
@Observable
@MainActor
public class WebViewCache {
    /// Shared singleton instance.
    public static let shared = WebViewCache()

    /// Dictionary storing cached WKWebView instances keyed by unique identifiers.
    private var cachedWebViews: [String: WKWebView] = [:]

    private init() {}

    /// Retrieves an existing cached WKWebView or creates a new one if not found.
    ///
    /// - Parameters:
    ///   - key: Optional unique identifier for this webview instance.
    ///   - navigationDelegate: Optional navigation delegate to set on the webview.
    ///   - uiDelegate: Optional UI delegate to set on the webview.
    /// - Returns: A WKWebView instance, either from cache or newly created.
    public func createWebView(for key: String?,
                              navigationDelegate: WKNavigationDelegate? = nil,
                              uiDelegate: WKUIDelegate? = nil) -> WKWebView {
        if let key, let existing = cachedWebViews[key] {
            // Update delegates if provided
            existing.navigationDelegate = navigationDelegate
            existing.uiDelegate = uiDelegate
            return existing
        }

        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = navigationDelegate
        webView.uiDelegate = uiDelegate
        webView.configuration.userContentController.removeAllScriptMessageHandlers()

        if let key {
            cachedWebViews[key] = webView
        }

        return webView
    }

    /// Clears cached webview(s).
    ///
    /// - Parameter key: Optional key to clear a specific webview. If nil, clears all cached webviews.
    public func clearCache(for key: String? = nil) {
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
    public func hasCache(for key: String) -> Bool {
        return cachedWebViews[key] != nil
    }
}
#endif
#endif
