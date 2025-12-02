//
//  NetworkView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/10/2025.
//

import LoggerLibrary
import NetworkLibrary
import SwiftUI

struct NetworkView: View {
    @State private var ping = ""
    @State private var content = ""

    var body: some View {
        List {
            Text("Ping: \(ping)")
            Text("Response: \(content)")
        }
        .navigationTitle("Network")
        .task {
            await ping()
            await get()
        }
    }
}

extension NetworkView {
    private func ping() async {
        guard let apple = URL(string: "http://www.apple.com") else {
            ping = "wrong URL"
            return
        }
        do {
            let network = NetworkFactory.make()
            try await network.ping(url: apple)
            ping = "success"
        } catch {
            ping = "failed to ping"
        }
    }

    private func get() async {
        guard let apple = URL(string: "http://www.apple.com/response") else {
            content = "wrong URL"
            return
        }
        do {
            let logger = Logger(category: "com.cassiorossi.exampleapp.network")
            let mock = [NetworkMockData(api: "/response",
                                        filename: "mock")]
            let network = NetworkFactory.make(logger: logger, mapper: mock)
            let data = try await network.get(url: apple, headers: nil)
            content = data.asString ?? ""
        } catch {
            content = "failed to get content"
        }
    }
}

#Preview {
    NetworkView()
}
