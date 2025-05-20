// swift-tools-version: 6.0
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency=complete")
]

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
        .executable(name: "toucan", targets: ["toucan"]),
        .executable(name: "toucan-init", targets: ["toucan-init"]),
        .executable(name: "toucan-generate", targets: ["toucan-generate"]),
        .executable(name: "toucan-watch", targets: ["toucan-watch"]),
        .executable(name: "toucan-serve", targets: ["toucan-serve"]),

        .library(name: "ToucanCore", targets: ["ToucanCore"]),
        .library(name: "ToucanSerialization", targets: ["ToucanSerialization"]),
        .library(name: "ToucanMarkdown", targets: ["ToucanMarkdown"]),
        .library(name: "ToucanSource", targets: ["ToucanSource"]),
        .library(name: "ToucanSDK", targets: ["ToucanSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/binarybirds/file-manager-kit", from: "0.2.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.9.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.3.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.0"),
        .package(url: "https://github.com/aus-der-Technik/FileMonitor", from: "1.2.0"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand", from: "1.4.0"),
        .package(url: "https://github.com/johnfairh/swift-sass", from: "3.1.0"),
        .package(url: "https://github.com/stackotter/swift-css-parser", from: "0.1.2"),
//        .package(url: "https://github.com/swiftlang/swift-subprocess", branch: "main"),
    ],
    targets: [
        // MARK: - executable targets
        .executableTarget(
            name: "toucan",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
//                .product(name: "Subprocess", package: "swift-subprocess")
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-init",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-generate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "ToucanSDK"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-watch",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileMonitor", package: "FileMonitor"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-serve",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        
        // MARK: - regular targets
        .target(
            name: "ToucanCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSerialization",
            dependencies: [
                .product(name: "Yams", package: "yams"),
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanMarkdown",
            dependencies: [
                // for outline
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                // for markdown to html
                .product(name: "Markdown", package: "swift-markdown"),
                // for transformers
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .target(name: "ToucanCore"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSource",
            dependencies: [
                .target(name: "ToucanCore"),
                .target(name: "ToucanSerialization"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSDK",
            dependencies: [
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "DartSass", package: "swift-sass"),
                .product(name: "SwiftCSSParser", package: "swift-css-parser"),
                .target(name: "ToucanCore"),
                .target(name: "ToucanSerialization"),
                .target(name: "ToucanMarkdown"),
                .target(name: "ToucanSource")
            ],
            swiftSettings: swiftSettings
        ),
        
        // MARK: - test targets

        .testTarget(
            name: "ToucanCoreTests",
            dependencies: [
                .target(name: "ToucanCore"),
            ]
        ),
        .testTarget(
            name: "ToucanSerializationTests",
            dependencies: [
                .target(name: "ToucanSerialization"),
            ]
        ),
        .testTarget(
            name: "ToucanMarkdownTests",
            dependencies: [
                .target(name: "ToucanMarkdown"),
            ]
        ),
        .testTarget(
            name: "ToucanSourceTests",
            dependencies: [
                .target(name: "ToucanSource"),
                .product(name: "FileManagerKitTesting", package: "file-manager-kit")
            ]
        ),
        .testTarget(
            name: "ToucanSDKTests",
            dependencies: [
                .target(name: "ToucanSDK"),
                .product(name: "FileManagerKitTesting", package: "file-manager-kit")
            ]
        ),
    ]
)
