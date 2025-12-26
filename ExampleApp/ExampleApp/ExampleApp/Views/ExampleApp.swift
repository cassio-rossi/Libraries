//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Cassio Rossi on 04/06/2025.
//

import AnalyticsLibrary
import FirebaseCore
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@main
struct ExampleApp: App {
#if os(iOS) || os(tvOS) || os(visionOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    let analytics = AnalyticsManager()
    let viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(analytics)
                .modelContainer(viewModel.storage.sharedModelContainer)
                .environment(viewModel)
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
#elseif os(macOS)
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}
#else
// For other platforms (watchOS), configure Firebase in the app init
extension ExampleApp {
    init() {
        analytics = AnalyticsManager()
        FirebaseApp.configure()
    }
}
#endif
