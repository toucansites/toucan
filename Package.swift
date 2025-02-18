// swift-tools-version: 6.0
import PackageDescription

// GIT_VERSION=1.2.2 swift run toucan-serve --version
var gitVersion: String {
    if let version = Context.environment["GIT_VERSION"] {
        return version
    }
    guard let gitInfo = Context.gitInformation else {
        return "(untracked)"
    }
    let base = gitInfo.currentTag ?? gitInfo.currentCommit
    return gitInfo.hasUncommittedChanges ? "\(base) (modified)" : base
}

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
        .library(name: "ToucanSDK", targets: ["ToucanSDK"]),
        .library(name: "ToucanFileSystem", targets: ["ToucanFileSystem"]),
        .library(name: "ToucanModels", targets: ["ToucanModels"]),
        .library(name: "ToucanSource", targets: ["ToucanSource"]),
        .library(name: "ToucanTesting", targets: ["ToucanTesting"]),
        .library(name: "ToucanCodable", targets: ["ToucanCodable"]),
        .executable(name: "toucan", targets: ["toucan"]),
        .executable(name: "toucan-generate", targets: ["toucan-generate"]),
        .executable(name: "toucan-init", targets: ["toucan-init"]),
        .executable(name: "toucan-serve", targets: ["toucan-serve"]),
        .executable(name: "toucan-watch", targets: ["toucan-watch"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
//        .package(url: "https://github.com/binarybirds/file-manager-kit", from: "0.1.0"),
        .package(url: "https://github.com/binarybirds/file-manager-kit", branch: "tib/features"),
        .package(url: "https://github.com/binarybirds/shell-kit", from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.2.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.0"),
        .package(url: "https://github.com/aus-der-Technik/FileMonitor", from: "1.0.0"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand", from: "1.4.0"),
    ],
    targets: [
        // MARK: - libraries
        .target(
            name: "libgitversion",
            cSettings: [
                .define("GIT_VERSION", to: #""\#(gitVersion)""#),
            ]
        ),
        .target(
            name: "GitVersion",
            dependencies: [
                .target(name: "libgitversion"),
            ]
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
                .target(name: "ToucanFileSystem")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanCodable",
            dependencies: [
                
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanModels",
            dependencies: [
                .target(name: "ToucanCodable"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanFileSystem",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ToucanSource",
            dependencies: [
                .product(name: "Yams", package: "yams"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "FileManagerKit", package: "file-manager-kit"),
                .target(name: "ToucanModels"),
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
        
        // MARK: - executables
        .executableTarget(
            name: "toucan",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ShellKit", package: "shell-kit"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
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
                .product(name: "ShellKit", package: "shell-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-serve",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .target(name: "GitVersion"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "toucan-watch",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ShellKit", package: "shell-kit"),
                .product(name: "FileMonitor", package: "FileMonitor"),
            ],
            swiftSettings: swiftSettings
        ),
        
        // MARK: - tests
        .testTarget(
            name: "ToucanSDKTests",
            dependencies: [
                .target(name: "ToucanSDK"),
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
            name: "ToucanCodableTests",
            dependencies: [
                .target(name: "ToucanCodable"),
            ]
        ),
        .testTarget(
            name: "ToucanSourceTests",
            dependencies: [
                .target(name: "ToucanSource"),
                .target(name: "ToucanTesting"),
            ]
        ),
    ]
)
