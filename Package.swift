// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAI",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v12), .tvOS(.v11), .watchOS(.v6)],
    products: [
        .library(name: "OpenAICore", targets: ["OpenAICore"]),
    ],
    targets: [
        .target(name: "OpenAICore",
                resources: [
                    .process("Resources/encoder.json"),
                    .process("Resources/vocab.bpe")
                ])
    ]
)
