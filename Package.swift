// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Libraries",

    products: [
        .library(name: "Utilities", targets: ["UtilityLibrary"]),
        .library(name: "Logger", targets: ["LoggerLibrary"]),
        .library(name: "InApp", targets: ["InAppLibrary"]),
        .library(name: "Storage", targets: ["StorageLibrary"]),
        .library(name: "Network", targets: ["NetworkLibrary"]),
        .library(name: "UIComponents", targets: ["UIComponentsLibrary"]),
        .library(name: "UIComponentsSpecial", targets: ["UIComponentsLibrarySpecial"]),
        .library(name: "YouTube", targets: ["YouTubeLibrary"])
    ],

    targets: [
        .target(name: "UtilityLibrary",
                path: "./Library/Sources/UtilityLibrary"),
        .target(name: "LoggerLibrary",
                path: "./Library/Sources/LoggerLibrary"),
        .target(name: "InAppLibrary",
                path: "./Library/Sources/InAppLibrary"),
        .target(name: "StorageLibrary",
                path: "./Library/Sources/StorageLibrary"),
        .target(name: "NetworkLibrary",
                path: "./Library/Sources/NetworkLibrary"),
        .target(name: "UIComponentsLibrary",
                path: "./Library/Sources/UIComponentsLibrary"),
        .target(name: "UIComponentsLibrarySpecial",
                path: "./UIComponentsLibrarySpecial/Sources/UIComponentsLibrarySpecial"),
        .target(name: "YouTubeLibrary",
                path: "./YouTubeLibrary/Sources/YouTubeLibrary")
    ]
)
