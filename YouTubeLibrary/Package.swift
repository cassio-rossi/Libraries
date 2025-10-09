// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YouTubeLibrary",
	platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "YouTubeLibrary", targets: ["YouTubeLibrary"])
    ],
    dependencies: [
        .package(name: "Libraries", path: "../"),  // Main Libraries package
		.package(name: "UIComponentsLibrarySpecial", path: "../UIComponentsLibrarySpecial"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.29.0"),
		.package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.2")
    ],
	targets: [
		.target(name: "YouTubeLibrary",
				dependencies: [
                    .product(name: "Network", package: "Libraries"),
                    .product(name: "Storage", package: "Libraries"),
                    .product(name: "Utilities", package: "Libraries"),
                    .product(name: "UIComponents", package: "Libraries"),
                    "UIComponentsLibrarySpecial",
                    .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
					.product(name: "Lottie", package: "lottie-ios")
				],
				resources: [.process("Resources")]),
		.testTarget(name: "YouTubeLibraryTests", dependencies: ["YouTubeLibrary"])
	]
)
