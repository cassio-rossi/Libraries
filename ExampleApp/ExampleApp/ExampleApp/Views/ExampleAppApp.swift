//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import AnalyticsLibrary
import SwiftUI

@main
struct ExampleAppApp: App {
    let analytics = AnalyticsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(analytics)
        }
    }
}
