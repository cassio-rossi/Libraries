// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "UIComponentsLibrarySpecial",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],

    products: [
        .library(name: "UIComponentsLibrarySpecial", targets: ["UIComponentsLibrarySpecial"])
    ],

    dependencies: [
        .package(name: "Libraries", path: "../"),  // Main Libraries package
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.61.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.2")
    ],

    targets: [
        .target(name: "UIComponentsLibrarySpecial",
                dependencies: [
                    .product(name: "Utilities", package: "Libraries"),
                    .product(name: "UIComponents", package: "Libraries"),
                    "Kingfisher",
                    .product(name: "Lottie", package: "lottie-ios")
                ],
                resources: [.process("Resources")],
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")])
    ]
)
