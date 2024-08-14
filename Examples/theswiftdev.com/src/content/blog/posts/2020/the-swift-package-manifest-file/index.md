---
type: post
title: The Swift package manifest file
description: This article is a complete Swift Package Manager cheatsheet for the package manifest file, using the latest Swift 5.2 tools version.
publication: 2020-04-24 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

> NOTE: If you want to learn [how to use the Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/) you should read my other article, because that is more like an introduction for those who have never worked with SPM yet.

## Package types

There are multiple package types that you can create with the `swift package init` command. You can specify the `--type` flag with the following values: empty, library, executable, system-module, manifest. You can also define a custom package name through the `--name` flag.

- The empty package will create the default file structure without the sample code files.
- The library type will create a reusable library product template.
- The executable type will create a Swift application with an executable product definition in the package and a `main.swift` file as a starting point.
- The system-module type will create a wrapper around a system provided package, such as libxml, we'll talk about this later on.
- The manifest type will only create a `Package.swift` file without anything else.

## The Package manifest file

Every single SPM project has this special file inside of it called `Package.swift`. I already wrote a post about [how the package manager and the Swift toolchain works](https://theswiftdev.com/all-about-the-swift-package-manager-and-the-swift-toolchain/) behind the scenes, this time we're going to focus only on the manifest file itself. Let's get started. 📦

Every single Package.swift file begins with a special comment line where you have to define the version of the used Swift tools. The latest version is quite different from the older ones.

```swift
// swift-tools-version:5.2
```

Next you have to import the PackageDescription framework in order to define your Swift package. This framework contains the package manifest structure as Swift objects.

```swift
import PackageDescription
```

That's it now you are ready to describe the package itself. Oh by the way you can change the version of the used tools, you can read more about this in the Package Manager [usage](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md) docs.

## Package

A package is just a bunch of Swift (or other) files. The manifest file is the description of what and how to build from those sources. Every single package should have a name, but this is not enough to actually generate something from it. You can only have exactly one package definition inside the file. This is the shortest and most useless one that you can create. 🙈

```swift
let package = Package(name: "myPackage")
```

The package name is going to be used when you are importing packages as dependencies, so name your pacages carefully. If you choose a reserved name by a system framework there can be issues with linking. If there's a conflict you have to use static linking instead of dynamic. If you generate a project via the `swift package generate-xcodeproj` command that project will try to link everything dynamically, but if you open the `Package.swift` file using Xcode 11, the dependencies will be linked statically if this was not set explicitly in the product definition section.

## Platform

A platform is basically an operating system with a given version that you can support.

```swift
let package = Package(
    name: "myPackage",
    platforms: [
        .iOS(.v13),         //.v8 - .v13
        .macOS(.v10_15),    //.v10_10 - .v10_15
        .tvOS(.v13),        //.v9 - .v13
        .watchOS(.v6),      //.v2 - .v6
    ]
)
```

When you add a platform you are putting a constraint on it via the required version. Every single dependency should match the requirement of the main package platforms. Long story short if you need to add support for Apple platforms, you should specify a platform flag with a supported version, otherwise SPM will use the oldest deployment target based on the installed SDK, except for macOS, that's going to be v10_10. Every package has Linux support by default, you can't add such restrictions yet, but maybe this will change in the near future, also Windows is coming.

## Product
A package can have one or more final products (build artifacts). Currently there are two types of build products: executables and libraries. The executable is a binary that can be executed, for example this can be a command line application. A library is something that others can use, it is basically the public API product representation on your targets.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(name: "myPackage", products: [
    .library(name: "myPackageLib", targets: ["myPackageLib"]),
    .library(name: "myPackageStaticLib", type: .static, targets: ["myPackageLib"]),
    .library(name: "myPackageDynLib", type: .dynamic, targets: ["myPackageLib"]),
    .executable(name: "myPackageCli", targets: ["myPackage"])
], targets: [
    .target(name: "myPackageLib"),
    .target(name: "myPackageCli"),
])
```

If the library type is unspecified, the Package Manager will automatically choose it based on the client's preference. As I mentioned this earlier generated Xcode projects prefer dynamic linking, but if you simply open the manifest file the app will be statically linked.

## Dependency

Packages can rely on other packages. You can define your dependencies by specifying a local path or a repository URL with a given version tag. Adding a dependency into this section is not enough to use it in your targets. You also have to add the product provided by the package at the target level.

```swift
let package = Package(
    name: "myPackage",
    dependencies: [
        .package(path: "/local/path/to/myOtherPackage"),
        .package(url: "<git-repository-url>", from: "1.0.0"),
        .package(url: "<git-repository-url>", .branch("dev")),
        .package(url: "<git-repository-url>", .exact("1.3.2")),
        .package(url: "<git-repository-url>", .revision("<hash>")),
        .package(url: "<git-repository-url>", .upToNextMajor(from: "1.0.0")),
        .package(url: "<git-repository-url>", .upToNextMinor(from: "1.0.0")),
        .package(url: "<git-repository-url>", "1.0.0"..<"1.3.0"),
    ]
)
```
The URL can be a GitHub URL, fortunately you can add private repositories as well by using an ssh key based authentication. Just use the `git@github.com:BinaryBirds/viper-kit.git` URL format, instead of the HTTP based, if you want to add private packages. 🤫

## Target

A target is something that you can build, in other words it's a build target that can result in a library or an executable. You should have at least one target in your project file otherwise you can't build anything. A target should always have a name, every other settings is optional.

## Settings

There are many settings that you can use to configure your [target](https://developer.apple.com/documentation/swift_packages/target). Targets can depend on other targets or products defined in external packages. A target can have a custom location, you can specify this by setting the path attribute. Also you can exclude source files from the target or explicitly define the sources you want to use. Targets can have their own public headers path and you can provide build settings both for the C, C++ and the Swift language, and compiler flags.

```swift
.target(name: "myPackage",
        dependencies: [
            .target(name: "other"),
            .product(name: "package", package: "package-kit")
        ],
        path: "./Sources/myPackage",
        exclude: ["foo.swift"],
        sources: ["main.swift"],
        publicHeadersPath: "./Sources/myPackage/headers",
        cSettings: [
            .define("DEBUG"),
            .define("DEBUG", .when(platforms: [.iOS, .macOS, .tvOS, .watchOS], configuration: .debug)),
            .define("DEBUG", to: "yes-please", .when(platforms: [.iOS], configuration: .debug)),
            .headerSearchPath(""),
            .headerSearchPath("", .when(platforms: [.android, .linux, .windows], configuration: .release)),
            .unsafeFlags(["-D EXAMPLE"]),
            .unsafeFlags(["-D EXAMPLE"], .when(platforms: [.iOS], configuration: .debug)),
        ],
        cxxSettings: [
            // same as cSettings
        ],
        swiftSettings: [
            .define("DEBUG"),
            .define("DEBUG", .when(platforms: [.iOS, .macOS, .tvOS, .watchOS], configuration: .debug)),
            .unsafeFlags(["-D EXAMPLE"]),
            .unsafeFlags(["-D EXAMPLE"], .when(platforms: [.iOS], configuration: .debug)),
        ],
        linkerSettings: [
            .linkedFramework("framework"),
            .linkedLibrary("framework", .when(platforms: [.iOS], configuration: .debug)),
            .linkedLibrary("library"),
            .linkedLibrary("library", .when(platforms: [.macOS], configuration: .release)),
            .unsafeFlags(["-L example"]),
            .unsafeFlags(["-L example"], .when(platforms: [.linux], configuration: .release)),
        ]),
```

As you can see you can define preprocessor macros for every single language. You can use the safe cases for basic stuff, but there is an unsafeFlags case for the reckless ones. The nice thing is that you can support a platform condition filter including build configuration to every single settings as the last param.

Available platforms are: 

- `.iOS`
- `.macOS`
- `.watchOS`
- `.tvOS`
- `.android`
- `.linux`
- `.windows `

The build configuration can be `.debug` or `.release`

## Test targets

Test targets are used to define test suites. They can be used to [unit test](https://theswiftdev.com/the-ultimate-guide-to-unit-and-ui-testing-for-beginners-in-swift/) other targets using the [XCTest](https://github.com/apple/swift-corelibs-xctest) framework. They look like exactly the same as regular targets.

```swift
.testTarget(name: String,
    dependencies: [Target.Dependency],
    path: String?,
    exclude: [String],
    sources: [String]?,
    cSettings: [CSetting]?,
    cxxSettings: [CXXSetting]?,
    swiftSettings: [SwiftSetting]?,
    linkerSettings: [LinkerSetting]?)
```

I think the only difference between a target and a test target is that you can run a test target using the `swift test` command, but from a structural point of view, they are basically the same.

## Package configs and system libraries

You can wrap an existing system library using Swift, the beauty of this is that you can use packages written in C, CPP or other languages. I'll show you a quick example through the amazing [Kanna(鉋) - XML/HTML parser repository](https://github.com/tid-kijyun/Kanna). I'm using this tool a lot, thanks for making it [Atsushi Kiwaki](https://github.com/tid-kijyun). 🙏

```swift
// https://github.com/tid-kijyun/Kanna/tree/master/Modules
#if swift(>=5.2) && !os(Linux)
let pkgConfig: String? = nil
#else
let pkgConfig = "libxml-2.0"
#endif

#if swift(>=5.2)
let providers: [SystemPackageProvider] = [
    .apt(["libxml2-dev"])
]
#else
let providers: [SystemPackageProvider] = [
    .apt(["libxml2-dev"]),
    .brew(["libxml2"])
]
#endif

let package = Package(name: "Kanna",
pkgConfig: "",
providers: [
  .apt(["libsqlite-dev"]),
  .brew(["sqlite3"])
],
products: [
  .library(name: "Kanna", targets: ["Kanna"])
],
targets: [
.target(name: "myPackage"),
.systemLibrary(name: "libxml2",
               path: "Modules",
               pkgConfig: pkgConfig,
               providers: providers)
])
```

There is a module definition file at the Modules directory. You'll need a `module.modulemap` file to export a given library, you can read more about [Modules](https://clang.llvm.org/docs/Modules.html) on the LLVM website.

```
module libxml2 [system] {
    link "xml2"
    umbrella header "libxml2-kanna.h"
    export *
    module * { export * }
}
```
You can define your own umbrella header and tell the system what to import.

```
#import <libxml2/libxml/HTMLtree.h>
#import <libxml2/libxml/xpath.h>
#import <libxml2/libxml/xpathInternals.h>
```

I barely use system libraries, but this is a good reference point. Anyways, if you need to wrap a system library I assume that you'll have the required knowledge to make it happen. 😅

## Language settings

You can also specify the list of Swift verisons that the package is compatible with. If you are creating a package that contains C or C++ code you can tell the compiler to use a specific language standard during the build process.

```swift
//supported Swift versions
swiftLanguageVersions: [.v4, .v4_2, .v5, .version("5.1")],

//.c89, .c90, .iso9899_1990, .iso9899_199409, .gnu89, .gnu90, .c99, .iso9899_1999, .gnu99, .c11, .iso9899_2011, .gnu11
cLanguageStandard: .c11,

//.cxx98, .cxx03, .gnucxx98, .gnucxx03, .cxx11, .gnucxx11, .cxx14, .gnucxx14, .cxx1z, .gnucxx1z
cxxLanguageStandard: .gnucxx11)
```

You can see all the currently available options in the comments. I don't know how many of you use these directives, but personally I never had to work with them. I'm not writing too much code from the C language family nowadays, but it's still good that SPM has this option built-in. 👍

## Summary

The Swift Package Manager is not the perfect tool just yet, but it's on a good track to become the de facto standard by slowly replacing CocoaPods and Carthage. There are still some missing features that are essentials for most of the developers. Don't worry, SPM will improve a lot in the near future. For example the binary dependency and resource support is coming alongside Swift 5.3. You can track the [package evolution process](https://apple.github.io/swift-evolution/#?search=package) on the official Swift Evolution dashboard.

You can read more about the [Package Manager](https://swift.org/package-manager/) on the official Swift website, but it's quite obsolate. The [documentation](https://developer.apple.com/documentation/swift_packages) on Apple's website is also very old, but still useful. There is a good read me file on GitHub about the [usage of the Swift Package Manager](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md), but nothing is updated frequently. 😢
