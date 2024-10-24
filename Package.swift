// swift-tools-version: 5.10
import PackageDescription

#if os(macOS)
let deps: [Package.Dependency] = [
    .package(url: "https://github.com/eonil/FSEvents", branch: "master"),
]
let tdeps: [Target.Dependency] = [
    .product(name: "EonilFSEvents", package: "FSEvents"),
]
#else
let deps: [Package.Dependency] = []
let tdeps: [Target.Dependency] = []
#endif

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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/binarybirds/file-manager-kit", from: "0.1.0"),
        .package(url: "https://github.com/binarybirds/shell-kit", from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.2.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.0"),
    ] + deps,
    targets: [
        .executableTarget(
            name: "toucan-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .target(name: "ToucanSDK"),
            ] + tdeps
        ),
        .target(
            name: "ToucanSDK",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ShellKit", package: "shell-kit"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
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
