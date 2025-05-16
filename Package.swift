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
        .executable(name: "toucan-generate", targets: ["toucan-generate"]),
        .executable(name: "toucan-init", targets: ["toucan-init"]),
        .executable(name: "toucan-serve", targets: ["toucan-serve"]),
        .executable(name: "toucan-watch", targets: ["toucan-watch"]),
        
        .library(name: "ToucanSDK", targets: ["ToucanSDK"]),
        .library(name: "ToucanFileSystem", targets: ["ToucanFileSystem"]),
        .library(name: "ToucanModels", targets: ["ToucanModels"]),
        .library(name: "ToucanSerialization", targets: ["ToucanSerialization"]),
        .library(name: "ToucanSource", targets: ["ToucanSource"]),
        .library(name: "ToucanContent", targets: ["ToucanContent"]),
        .library(name: "ToucanTesting", targets: ["ToucanTesting"]),
        .library(name: "ToucanInfo", targets: ["ToucanInfo"]),
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
                .target(name: "ToucanInfo"),
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
            name: "toucan-init",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .target(name: "ToucanInfo"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-serve",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .target(name: "ToucanInfo"),
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
                .target(name: "ToucanInfo"),
            ],
            swiftSettings: swiftSettings
        ),
        // MARK: - regular targets
        .target(
            name: "ToucanInfo",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanModels",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanContent",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                // for outline
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                // for markdown to html
                .product(name: "Markdown", package: "swift-markdown"),
                // for transformers
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanFileSystem",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .target(name: "ToucanModels"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSerialization",
            dependencies: [
                .product(name: "Yams", package: "yams"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSource",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "DartSass", package: "swift-sass"),
                .product(name: "SwiftCSSParser", package: "swift-css-parser"),
                .target(name: "ToucanModels"),
                .target(name: "ToucanSerialization"),
                .target(name: "ToucanContent"),
                .target(name: "ToucanInfo"),
            ],
            swiftSettings: swiftSettings
        ),
        
        .target(
            name: "ToucanSDK",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Yams", package: "yams"),
                .target(name: "ToucanFileSystem"),
                .target(name: "ToucanSource"),
                .target(name: "ToucanTesting"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanTesting",
            dependencies: [
                .target(name: "ToucanModels"),
                .target(name: "ToucanSource"),
            ],
            swiftSettings: swiftSettings
        ),
        
        // MARK: - test targets
        .testTarget(
            name: "ToucanSDKTests",
            dependencies: [
                .target(name: "ToucanSDK"),
                .product(name: "FileManagerKitTesting", package: "file-manager-kit")
            ]
        ),
        .testTarget(
            name: "ToucanFileSystemTests",
            dependencies: [
                .target(name: "ToucanFileSystem"),
                .product(name: "FileManagerKitTesting", package: "file-manager-kit")
            ]
        ),
        .testTarget(
            name: "ToucanModelsTests",
            dependencies: [
                .target(name: "ToucanModels"),
            ]
        ),
        .testTarget(
            name: "ToucanSerializationTests",
            dependencies: [
                .target(name: "ToucanModels"),
                .target(name: "ToucanSerialization"),
            ]
        ),
        .testTarget(
            name: "ToucanSourceTests",
            dependencies: [
                .target(name: "ToucanSource"),
                .target(name: "ToucanTesting"),
            ]
        ),
        .testTarget(
            name: "ToucanContentTests",
            dependencies: [
                .target(name: "ToucanContent"),
                .target(name: "ToucanTesting"),
            ]
        ),
    ]
)
