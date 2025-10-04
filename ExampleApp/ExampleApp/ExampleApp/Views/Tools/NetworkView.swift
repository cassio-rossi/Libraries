//
//  NetworkView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/10/2025.
//

import NetworkLibrary
import SwiftUI

struct NetworkView: View {
    @State private var ping = ""

    var body: some View {
        List {
            Text("Ping: \(ping)")
        }
        .navigationTitle("Network")
        .task {
            await ping()
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
            let network = NetworkAPI()
            try await network.ping(url: apple)
            ping = "success"
        } catch {
            ping = "failed to ping"
        }
    }
}

#Preview {
    NetworkView()
}
