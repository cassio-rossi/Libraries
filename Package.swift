// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoreLibrary",
	products: [
		.library(name: "LoggerLibrary", targets: ["LoggerLibrary"]),
	],
	targets: [
		.binaryTarget(name: "LoggerLibrary",
					  url: "https://github.com/cassio-rossi/Libraries/releases/download/v1.0.0/LoggerLibrary.zip",
					  checksum: "18fd87bb582efcb34c53e449d9c79dc3f52832926f183856b7ff18553028c6c5"),
	]
)
