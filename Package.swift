// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Libraries",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .watchOS(.v11), .visionOS(.v2), .macOS(.v15)],

    products: [
        .library(name: "Utilities", targets: ["UtilityLibrary"]),
        .library(name: "Logger", targets: ["LoggerLibrary"]),
        .library(name: "InApp", targets: ["InAppLibrary"]),
        .library(name: "Storage", targets: ["StorageLibrary"]),
        .library(name: "Network", targets: ["NetworkLibrary"])
    ],

    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.61.0")
    ],

    targets: [
        .target(name: "UtilityLibrary",
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]),
        .testTarget(name: "UtilityLibraryTests",
                    dependencies: ["UtilityLibrary"]),

        .target(name: "LoggerLibrary",
                dependencies: ["UtilityLibrary"],
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]),
        .testTarget(name: "LoggerLibraryTests",
                    dependencies: ["LoggerLibrary"]),

        .target(name: "InAppLibrary",
                dependencies: ["UtilityLibrary", "LoggerLibrary"],
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]),
        .testTarget(name: "InAppLibraryTests",
                    dependencies: ["InAppLibrary"]),

        .target(name: "StorageLibrary",
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]),

        .target(name: "NetworkLibrary",
                dependencies: ["LoggerLibrary"],
                resources: [.process("Resources")],
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")])
    ]
)
