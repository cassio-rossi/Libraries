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
					  checksum: "08807e3f6e0aadd8defd97f3680de66b9634ff1c52f3becc0889bc62859beb2a"),
    ]
)
