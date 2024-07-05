// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "toucan",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .executable(name: "toucan-cli", targets: ["toucan-cli"]),
        .library(name: "ToucanSDK", targets: ["ToucanSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/binarybirds/file-manager-kit", from: "0.1.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0-beta.1"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0-rc.1"),
        .package(url: "https://github.com/eonil/FSEvents", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "toucan-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "EonilFSEvents", package: "FSEvents"),
                .target(name: "ToucanSDK"),
            ]
        ),
        .target(
            name: "ToucanSDK",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "Yams", package: "yams"),
            ]
        ),
        .testTarget(
            name: "ToucanSDKTests",
            dependencies: [
                .target(name: "ToucanSDK"),
            ]
        )
    ]
)
