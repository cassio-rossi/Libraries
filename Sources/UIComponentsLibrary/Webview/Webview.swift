#if canImport(UIKit)
import SwiftUI
import WebKit

/// A full-featured web view with navigation controls and customization options.
///
/// `Webview` provides a complete web browsing experience with:
/// - Optional navigation bar with title and close button
/// - Custom back button support
/// - JavaScript injection via user scripts
/// - Cookie management
/// - Message handler support for JavaScript-to-Swift communication
/// - Custom user agent strings
/// - Standalone mode (without navigation controls)
public struct Webview<Content: View>: View {
	/// A binding controlling whether the web view is presented.
    @Binding var isPresenting: Bool

	/// The optional title displayed in the navigation bar.
    let title: String?

	/// The URL string to load.
    let url: String

	/// Whether to display without navigation controls.
    let standAlone: Bool

	/// Optional navigation delegate for handling web navigation events.
    let navigationDelegate: WKNavigationDelegate?

	/// Optional array of JavaScript user scripts to inject.
    let userScripts: [WKUserScript]?

	/// Optional array of HTTP cookies to set.
    let cookies: [HTTPCookie]?

	/// Optional array of script message handlers for JavaScript communication.
    let scriptMessageHandlers: [(WKScriptMessageHandler, String)]?

	/// Optional additional user agent string to append.
    let userAgent: String?

	/// The underlying web view representable.
    let webview: WKWebViewRepresentable?

	/// Additional custom actions displayed in the navigation bar.
    @ViewBuilder private let extraActions: Content

	/// Optional custom back button to replace the default close button.
    @ViewBuilder private let backButton: AnyView?

	/// Creates a web view with extensive customization options.
	///
	/// - Parameters:
	///   - title: Optional title for the navigation bar.
	///   - url: The URL string to load.
	///   - isPresenting: A binding controlling presentation state.
	///   - standAlone: Whether to hide navigation controls. Defaults to `false`.
	///   - navigationDelegate: Optional delegate for navigation events.
	///   - uiDelegate: Optional delegate for UI events.
	///   - userScripts: Optional JavaScript scripts to inject.
	///   - cookies: Optional HTTP cookies to set.
	///   - scriptMessageHandlers: Optional message handlers for JavaScript communication.
	///   - userAgent: Optional additional user agent string.
	///   - extraActions: Optional custom actions in the navigation bar.
	///   - backButton: Optional custom back button view.
    public init(title: String? = nil,
                url: String,
                isPresenting: Binding<Bool>,
                standAlone: Bool = false,
                navigationDelegate: WKNavigationDelegate? = nil,
                uiDelegate: WKUIDelegate? = nil,
                userScripts: [WKUserScript]? = nil,
                cookies: [HTTPCookie]? = nil,
                scriptMessageHandlers: [(WKScriptMessageHandler, String)]? = nil,
                userAgent: String? = nil,
                extraActions: Content = EmptyView(),
                backButton: AnyView? = nil) {

        _isPresenting = isPresenting
        self.standAlone = standAlone

        self.title = title
        self.url = url
        self.navigationDelegate = navigationDelegate
        self.userScripts = userScripts
        self.cookies = cookies
        self.scriptMessageHandlers = scriptMessageHandlers
        self.userAgent = userAgent

        self.extraActions = extraActions
        self.backButton = backButton

        webview = WKWebViewRepresentable(navigationDelegate: navigationDelegate, uiDelegate: uiDelegate)
    }

    public var body: some View {
        VStack {
            if !standAlone {
                ZStack(alignment: .top) {
                    Color(.gray)
                        .opacity(0.4)
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            isPresenting = false
                        }, label: {
                            backButton
                        })

                        if let title = title {
                            Text(title)
                                .foregroundColor(.primary)
                        }
                        Spacer()

                        extraActions

                        if backButton == nil {
                            Button(action: {
                                isPresenting = false
                            }, label: {
                                Image(systemName: "xmark.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.primary)
                            })
                        }
                    }
                    .padding()
                    .frame(height: 60)
                }
                .frame(height: 60)
            }

            webview
                .task {
                    webview?.load(site: url,
                                  userScripts: userScripts,
                                  cookies: cookies,
                                  scriptMessageHandlers: scriptMessageHandlers,
                                  userAgent: userAgent)
                }
        }
    }
}

#Preview("Back") {
    Webview(title: "💥 Aula ao Vivo COMEÇOU - Vem não?",
            url: "https://mailchi.mp/entendendoiphone/desafiodft177-1010674",
            isPresenting: .constant(false),
            backButton: AnyView(Image(systemName: "arrow.left.circle.fill")
                .imageScale(.large)
                .foregroundColor(.primary)
            ))
    .preferredColorScheme(.light)
}

#Preview("Light") {
    Webview(title: "💥 Aula ao Vivo COMEÇOU - Vem não?",
            url: "https://mailchi.mp/entendendoiphone/desafiodft177-1010674",
            isPresenting: .constant(false))
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    Webview(title: "💥 Aula ao Vivo COMEÇOU - Vem não?",
            url: "https://mailchi.mp/entendendoiphone/desafiodft177-1010674",
            isPresenting: .constant(false))
    .preferredColorScheme(.dark)
}
#endif
