// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "toucan",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .executable(name: "toucan-cli", targets: ["toucan-cli"]),
        .library(name: "Toucan", targets: ["Toucan"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/binarybirds/file-manager-kit", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Toucan",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
            ]
        ),

        .executableTarget(
            name: "toucan-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "Toucan"),
            ]
        ),

        .testTarget(
            name: "ToucanTests",
            dependencies: [
                .target(name: "Toucan"),
            ]
        )
    ]
)
