//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import AnalyticsLibrary
import FirebaseCore
import SwiftUI

@main
struct ExampleAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let analytics = AnalyticsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(analytics)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
