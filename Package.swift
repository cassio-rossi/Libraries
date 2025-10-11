// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Libraries",

    products: [
        .library(name: "Library", targets: ["LibraryTarget"]),
        .library(name: "UIComponentsLibrarySpecial", targets: ["UIComponentsLibrarySpecialTarget"]),
        .library(name: "YouTubeLibrary", targets: ["YouTubeLibraryTarget"])
    ],

    dependencies: [
        .package(path: "Library"),
        .package(path: "UIComponentsLibrarySpecial"),
        .package(path: "YouTubeLibrary"),
    ],

    targets: [
        .target(name: "LibraryTarget",
                dependencies: [
                    .product(name: "Library", package: "Library")
                ]),
        .target(name: "UIComponentsLibrarySpecialTarget",
                dependencies: [
                    .product(name: "UIComponentsLibrarySpecial", package: "UIComponentsLibrarySpecial")
                ]),
        .target(name: "YouTubeLibraryTarget",
                dependencies: [
                    .product(name: "YouTubeLibrary", package: "YouTubeLibrary")
                ])
    ]
)
