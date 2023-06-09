// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAICore",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v12), .tvOS(.v11), .watchOS(.v6)],
    products: [
        .library(name: "OpenAICore", targets: ["OpenAICore"]),
    ],
    dependencies: [.package(url: "https://github.com/linhay/STJSON", .upToNextMajor(from: "1.0.1"))],
    targets: [
        .target(name: "OpenAICore",
                dependencies: ["STJSON"],
                resources: [
                    .process("Resources/encoder.json"),
                    .process("Resources/vocab.bpe")
                ])
    ]
)
