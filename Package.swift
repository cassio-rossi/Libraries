// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "Libraries",
    products: [
        .library(name: "UtilityLibrary", targets: ["UtilityLibrary"]),
    ],
    targets: [
        .binaryTarget(name: "UtilityLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/UtilityLibrary.zip",
					  checksum: "cb460fc00e88a4974d729f2af15cd1e3491ba1aa32bc6bda2df405c7dc0ecaa5"),
    ]
)
