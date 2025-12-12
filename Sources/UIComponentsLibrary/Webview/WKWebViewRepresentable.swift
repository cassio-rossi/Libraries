#if canImport(WebKit)
#if canImport(UIKit)
import SwiftUI
import WebKit

/// A SwiftUI representable wrapper for WKWebView.
///
/// `WKWebViewRepresentable` bridges WebKit's WKWebView to SwiftUI,
/// providing web content display with support for custom delegates,
/// user scripts, cookies, and message handlers.
public struct WKWebViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = WKWebView

	/// The underlying WKWebView instance.
    let webView: WKWebView

	/// Creates a web view representable with optional delegates.
	///
	/// - Parameters:
	///   - navigationDelegate: Optional delegate for handling navigation events.
	///   - uiDelegate: Optional delegate for handling UI-related events.
    public init(navigationDelegate: WKNavigationDelegate? = nil,
                uiDelegate: WKUIDelegate? = nil) {
        self.webView = WKWebView(frame: .zero)
        self.webView.navigationDelegate = navigationDelegate
        self.webView.uiDelegate = uiDelegate

        self.webView.configuration.userContentController.removeAllScriptMessageHandlers()
    }

	/// Creates the underlying WKWebView.
	///
	/// - Parameter context: The view context.
	/// - Returns: The configured WKWebView.
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }

	/// Updates the web view when SwiftUI state changes.
	///
	/// - Parameters:
	///   - uiView: The WKWebView to update.
	///   - context: The view context.
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}

extension WKWebViewRepresentable {
	/// Loads a website with optional customizations.
	///
	/// Configures user scripts, message handlers, cookies, and user agent
	/// before loading the specified URL.
	///
	/// - Parameters:
	///   - site: The URL string of the website to load.
	///   - userScripts: Optional array of JavaScript user scripts to inject.
	///   - cookies: Optional array of HTTP cookies to set.
	///   - scriptMessageHandlers: Optional array of message handlers for JavaScript communication.
	///   - userAgent: Optional additional user agent string to append.
    public func load(site: String,
                     userScripts: [WKUserScript]? = nil,
                     cookies: [HTTPCookie]? = nil,
                     scriptMessageHandlers: [(WKScriptMessageHandler, String)]? = nil,
                     userAgent: String? = nil) {
        guard let url = URL(string: site) else {
            return
        }
        if let scripts = userScripts {
            addUserScript(scripts)
        }
        if let handlers = scriptMessageHandlers {
            addScriptMessageHandlers(handlers)
        }
        webView.allowsBackForwardNavigationGestures = false
        webView.evaluateJavaScript("navigator.userAgent") { result, _ in
            if let currentUserAgent = result as? String,
               let additionalUserAgent = userAgent {
                webView.customUserAgent = currentUserAgent + additionalUserAgent
            }
            webView.load(URLRequest(url: url))
        }
        load(cookies: cookies) {
            webView.reload()
        }
    }
}

extension WKWebViewRepresentable {
	/// Adds JavaScript user scripts to the web view.
	///
	/// - Parameter scripts: The array of user scripts to add.
    fileprivate func addUserScript(_ scripts: [WKUserScript]) {
        for script in scripts {
            webView.configuration.userContentController.addUserScript(script)
        }
    }

	/// Adds script message handlers for JavaScript-to-Swift communication.
	///
	/// - Parameter handlers: Array of tuples containing message handlers and their names.
    fileprivate func addScriptMessageHandlers(_ handlers: [(WKScriptMessageHandler, String)]) {
        for handler in handlers {
            webView.configuration.userContentController.add(handler.0, name: handler.1)
        }
    }
}

extension WKWebViewRepresentable {
	/// Loads cookies into the web view asynchronously.
	///
	/// Uses a dispatch group to ensure all cookies are set before
	/// invoking the callback.
	///
	/// - Parameters:
	///   - cookies: Optional array of HTTP cookies to set.
	///   - callback: Closure to execute after all cookies are loaded.
    fileprivate func load(cookies: [HTTPCookie]?, _ callback: (() -> Void)?) {
        guard let cookies else {
            callback?()
            return
        }

        // Set cookies syncronuos
        let group = DispatchGroup()
        group.enter()

        var cookiesLeft = cookies.count
        cookies.forEach { cookie in
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                cookiesLeft -= 1
                if cookiesLeft <= 0 {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            callback?()
        }
    }
}
#endif
#endif
