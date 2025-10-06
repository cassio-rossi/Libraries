import SwiftUI
#if canImport(WebKit)
import WebKit

public struct WKWebViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = WKWebView

    let webView: WKWebView

    public init(navigationDelegate: WKNavigationDelegate? = nil,
                uiDelegate: WKUIDelegate? = nil) {
        self.webView = WKWebView(frame: .zero)
        self.webView.navigationDelegate = navigationDelegate
        self.webView.uiDelegate = uiDelegate

        self.webView.configuration.userContentController.removeAllScriptMessageHandlers()
    }

    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}

extension WKWebViewRepresentable {
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
    fileprivate func addUserScript(_ scripts: [WKUserScript]) {
        for script in scripts {
            webView.configuration.userContentController.addUserScript(script)
        }
    }

    fileprivate func addScriptMessageHandlers(_ handlers: [(WKScriptMessageHandler, String)]) {
        for handler in handlers {
            webView.configuration.userContentController.add(handler.0, name: handler.1)
        }
    }
}

extension WKWebViewRepresentable {
    fileprivate func load(cookies: [HTTPCookie]?, _ callback: (() -> Void)?) {
        guard let cookies = cookies else {
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
