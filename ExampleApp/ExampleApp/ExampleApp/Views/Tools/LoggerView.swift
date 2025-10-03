//
//  LoggerView.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import LoggerLibrary
import SwiftUI

struct LoggerView: View {
    let logger = Logger(category: "com.cassiorossi.exampleapp.logger")

    var body: some View {
        List {
            Text(logger.debug("Hello, World!") ?? "")
            Text(logger.info("Hello, World!") ?? "")
            Text(logger.warning("Hello, World!") ?? "")
            Text(logger.error("Hello, World!") ?? "")
        }
        .navigationTitle("Logger")
    }
}

#Preview {
    NavigationStack {
        LoggerView()
    }
}
