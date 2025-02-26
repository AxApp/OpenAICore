// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "OpenAICore",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v12), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "OpenAICore", targets: ["OpenAICore"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.3.0"),
        .package(url: "https://github.com/linhay/STJSON", from: "1.3.1"),
        .package(url: "https://github.com/linhay/Tiktoken", from: "0.0.5"),
    ],
    targets: [
        .macro(
            name: "OpenAICoreMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "OpenAICore",
                dependencies: [
                    "OpenAICoreMacros",
                    "STJSON",
                    .product(name: "Crypto", package: "swift-crypto"),
                    .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
                    .product(name: "HTTPTypes", package: "swift-http-types"),
                    .product(name: "Tiktoken", package: "Tiktoken")
                ]),
        .testTarget(name: "OpenAICoreTests", dependencies: [
            .target(name: "OpenAICore"),
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ])
    ]
)
