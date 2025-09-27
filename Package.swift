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
				      url: "https://github.com/cassio-rossi/Libraries/releases/download/1.0.1/UtilityLibrary.zip",
					  checksum: "72f7aa715e6aa977be696efa9285a488bc76e923790b39bbc520db244ead313b"),
        .binaryTarget(name: "LoggerLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/1.0.1/LoggerLibrary.zip",
					  checksum: "68b43b5321e6f9337a0c15f160e6ae4213da1fdafc896b69b55ca2514d5de93d"),
        .binaryTarget(name: "InAppLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/1.0.1/InAppLibrary.zip",
					  checksum: "72486e4593a8fe74dbb6669d7170432ff603fa48e343017b3bf3d5efce834079"),
        .binaryTarget(name: "StorageLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/1.0.1/StorageLibrary.zip",
					  checksum: "2ae25f3adb5b49ca291867db1363f60eae4d8ce301fb07234a460e9dfb178b39"),
    ]
)
