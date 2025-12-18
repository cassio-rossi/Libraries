//
//  WebView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 16/12/2025.
//

import SwiftUI
import UIComponentsLibrary

struct WebView: View {
    @Environment(\.colorScheme) var colorScheme

    private let controller = WebViewController()

    var body: some View {
        Webview(
            url: "https://macmagazine.com.br/live",
            isPresenting: .constant(true),
            standAlone: true,
            navigationDelegate: controller,
            userScripts: nil,
            cookies: makeCookies(using: colorScheme),
            userAgent: "/MacMagazine",
            cacheKey: "macmagazine-live"
        )
        .id(colorScheme)
        .ignoresSafeArea(.container, edges: [.top, .bottom])
    }
}

private extension WebView {
    func makeCookies(using colorScheme: ColorScheme) -> [HTTPCookie] {
        var cookies = [HTTPCookie]()
        if let darkMode = HTTPCookie(properties: [
            .domain: "macmagazine.com.br",
            .path: "/",
            .name: "darkmode",
            .value: colorScheme == .dark ? "true" : "false",
            .secure: "true",
            .expires: NSDate(timeIntervalSinceNow: 60)
        ]) {
            cookies.append(darkMode)
        }
        if let colorSchemaCookie = HTTPCookie(properties: [
            .domain: "macmagazine.com.br",
            .path: "/",
            .name: "_color_schema",
            .value: colorScheme == .dark ? "dark" : "light",
            .secure: "true",
            .expires: NSDate(timeIntervalSinceNow: 60)
        ]) {
            cookies.append(colorSchemaCookie)
        }
        return cookies
    }
}
