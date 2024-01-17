// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "toucan",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "toucan", targets: ["ToucanCli"]),
        .library(name: "ToucanSDK", targets: ["ToucanSDK"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/hummingbird",
            from: "1.12.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        ),
        .package(
            url: "https://github.com/JohnSundell/Ink",
            from: "0.6.0"
        ),
        .package(
            url: "https://github.com/JohnSundell/Splash",
            from: "0.16.0"
        ),
        .package(
            url: "https://github.com/BinaryBirds/file-manager-kit",
            from: "0.1.0"
        ),
        .package(
            url: "https://github.com/eonil/FSEvents",
            branch: "master"
        ),
    ],
    targets: [
        .target(name: "ToucanSDK", dependencies: [
            .product(
                name: "FileManagerKit",
                package: "file-manager-kit"
            ),
            .product(
                name: "Ink",
                package: "ink"
            ),
            .product(
                name: "Splash",
                package: "splash"
            ),
        ]),

        .executableTarget(name: "ToucanCli",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "Hummingbird",
                    package: "hummingbird"
                ),
                .product(
                    name: "HummingbirdFoundation",
                    package: "hummingbird"
                ),
                .product(
                    name: "EonilFSEvents",
                    package: "FSEvents"
                ),
                .target(name: "ToucanSDK"),
            ]
        ),
        
        .testTarget(name: "ToucanSDKTests",
            dependencies: [
                .target(name: "ToucanSDK"),
            ]
        )
    ]
)
