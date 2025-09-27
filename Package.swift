// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "Libraries",
    products: [
        .library(name: "UtilityLibrary", targets: ["UtilityLibrary"]),
        .library(name: "LoggerLibrary", targets: ["LoggerLibrary"]),
        .library(name: "InAppLibrary", targets: ["InAppLibrary"]),
        .library(name: "StorageLibrary", targets: ["StorageLibrary"]),
    ],
    targets: [
        .binaryTarget(name: "UtilityLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/UtilityLibrary.zip",
					  checksum: "067d8ab53085859e307512e23371245988454db68c05f85f28b5e3529215a63b"),
        .binaryTarget(name: "LoggerLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/LoggerLibrary.zip",
					  checksum: "bc0b23c250ae1ac005fed66e9423f848c45932a4b03a82823d54882cd5ab3c3c"),
        .binaryTarget(name: "InAppLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/InAppLibrary.zip",
					  checksum: "13c408e8f1c59435ca01140110fde0b9b5ad2bb090b5a982028f831193b3be08"),
        .binaryTarget(name: "StorageLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/StorageLibrary.zip",
					  checksum: "4bf33a66d2cb2365f10f66a41bb6448eaad10039410549d000df692fc5221c20"),
    ]
)
