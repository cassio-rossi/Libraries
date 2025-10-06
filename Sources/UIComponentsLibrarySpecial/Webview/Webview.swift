#if canImport(WebKit)
import SwiftUI
import WebKit

public struct Webview<Content: View>: View {
	@Binding var isPresenting: Bool

	let title: String?
	let url: String
	let standAlone: Bool
	let navigationDelegate: WKNavigationDelegate?
	let userScripts: [WKUserScript]?
	let cookies: [HTTPCookie]?
    let scriptMessageHandlers: [(WKScriptMessageHandler, String)]?
	let userAgent: String?

	let webview: WKWebViewRepresentable?

	@ViewBuilder private let extraActions: Content
    @ViewBuilder private let backButton: AnyView?

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
						.edgesIgnoringSafeArea(.all)

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

			webview?
				.onAppear {
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
