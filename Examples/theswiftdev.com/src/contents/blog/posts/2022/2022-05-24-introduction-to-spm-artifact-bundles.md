---
slug: introduction-to-spm-artifact-bundles
title: Introduction to SPM artifact bundles
description: In this tutorial I'm going to show you how to use the new binary target related artifact bundle using the Swift package manager.
publication: 2022-05-24 16:20:00
tags: Swift, SPM
---

## Binary targets and modern Swift packages

Swift 5.6 introduced quite a lot of new features for the Swift Package Manager infrastructure. We were already able to define binary targets, and use [xcframeworks as binary target dependencies](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages) for our apps. They work great if you are targeting Apple platforms, but unfortunately the xcframework format is not compatible with Linux distributions, not to mention the Windows operating system.

This is where artifact bundles can help. If you are developing apps for multiple platforms you can now create an artifact bundle, place all the compatible variants into this new structure and SPM can choose the right one based on your architecture. 💪

Before we actually dive in to our main topic, I'm going to quickly show you how to create an xcframework and ship it as a binary target via SPM.

## XCFrameworks and SPM

Before the introduction of the new format we had to mess around with FAT binaries to support multiple platforms. I have a [deep dive article](https://theswiftdev.com/deep-dive-into-swift-frameworks/) about frameworks and tools that you can use to construct a FAT binary, but I no longer recommend it since [XCFrameworks are here to stay](https://www.rightpoint.com/rplabs/2021/01/why-xcframeworks-matter/). 🔨

In order to build an XCFramework, you have to use Xcode and a process is very simple. You just have to select the Framework type under the iOS tab when you create a new project. Feel free to name it, add your Swift source code and that's it.

You can build this project using the command line for multiple platforms via the following script.

```sh
# build for iOS devices
xcodebuild archive \
  -scheme MySDK \
  -sdk iphoneos \
  -archivePath "build/ios_devices.xcarchive" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO
  
# build for iOS simulators
xcodebuild archive \
  -scheme MySDK \
  -sdk iphonesimulator \
  -archivePath "build/ios_simulators.xcarchive" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

# build for macOS devices
xcodebuild archive \
  -sdk macosx MACOSX_DEPLOYMENT_TARGET=11.0 \
  -arch x86_64 -arch arm64 \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  -scheme "MySDK" \
  -archivePath "build/macos_devices.xcarchive" SKIP_INSTALL=NO

# combine the slices and create the xcframework file
xcodebuild -create-xcframework \
  -framework build/ios_devices.xcarchive/Products/Library/Frameworks/MySDK.framework \
  -framework build/ios_simulators.xcarchive/Products/Library/Frameworks/MySDK.framework \
  -framework build/macos_devices.xcarchive/Products/Library/Frameworks/MySDK.framework \
  -output MySDK.xcframework
```

You can even build versions for Catalyst and other operating systems, if you do a little search you can easily figure out the required parameters and configuration. Long story short, it's very easy to create an xcframework output including all kind of platform slices for specific devices. 😊

Now if you want to use this XCFramework, you can simply drag and drop it to your Xcode project and it should work without further issues (if it contains the necessary slices). Alternatively you can use Swift package manager and create a binary target an hook up your external framework bundle via SPM. This is how a very simple configuration file looks like.

```swift
// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "MySDK",
    products: [
        .library(name: "MySDK", targets: ["MySDK"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .binaryTarget(name: "MySDK", path: "./MySDK.xcframework")
    ]
)
```

In your project you can use the library product as a standard dependency, and the underlying binary target will take care of importing the necessary header files and linking the actual library. The only problem with this approach is that it is macOS (or to be even more precise Apple OS only).

## Say hello to artifact bundles for Swift PM

All right, so XCFrameworks can't be used under Linux, but people like to write command line scripts in Swift and use them for server side projects. In some cases those scripts (or plugins), would like to call external scripts that are not installed on the system by default. This is where artifact bundles can help, because it makes possible to ship multiple versions of the same executable binary file. 🤔

Artifact bundles are not a replacement for xcframeworks, but more like an addition, or improvement as the [proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0305-swiftpm-binary-target-improvements.md) title indicates this, for the Swift package manager plugin architecture. They allow us to ship precompiled binary files for multiple platforms, this way plugin authors don't have to compile those tools from source and the plugin execution time can be heavily reduced.

There is a [great blog post](https://www.polpiella.dev/binary-targets-in-modern-swift-packages) about wrapping the SwiftLint executable in an artifact bundle, so I don't really want to get into the details this time, because it's pretty straightforward. The proposal itself helps a lot to understand the basic setup, also the older [binary dependencies proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0272-swiftpm-binary-dependencies.md) contains some related info nice job Swift team. 👍

I'd like to give an honorable mention to [Karim Alweheshy](https://x.com/k_alweheshy), who is actively working with the new Swift package manager plugin infrastructure, he has an amazing repository on [GitHub](https://github.com/KarimAlweheshy/spm-build-tools) that demos artifact bundles so please take a look if you have time. 🙏

Anyway, I'm going to show you how to wrap an executable into an artifact bundle. Currently there's no way to wrap libraries into artifact bundles, that's going to be added later on.

```sh
# create a simple hello world executable project
mkdir MyApp
cd $_
swift package init --type=executable

# build the project using release config
swift build -c release

# copy the binary
cp $(swift build --show-bin-path -c release)/MyApp ./myapp


# init a new example project
mkdir MyPluginExample
cd $_
swift package init 

mkdir myapp.artifactbundle
cd $_
mkdir myapp-1.0.0-macos
cd $_
mkdir bin
```

Now the file structure is ready, we should create a new info.json file under the artifactbundle directory with the following contents. This will describe your bundle with the available binary variants, you can take a look at the proposals for the available triplets versions.

```json
{
    "schemaVersion": "1.0",
    "artifacts": {
        "myapp": {
            "version": "1.0.0",
            "type": "executable",
            "variants": [
                {
                    "path": "myapp-1.0.0-macos/bin/myapp",
                    "supportedTriples": ["x86_64-apple-macosx", "arm64-apple-macosx"]
                }
            ]
        }
    }
}
```

Copy the myapp binary under the `myapp-1.0.0-macos/bin/myapp` location, and finally we're going to make a very simple command plugin to take advangate of this newly added tool.

```swift
import PackagePlugin
import Foundation

@main
struct MyDistCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let myAppTool = try context.tool(named: "myapp")
        let myAppToolURL = URL(fileURLWithPath: myAppTool.path.string)

        let process = try Process.run(myAppToolURL, arguments: [])
        process.waitUntilExit()
    }
}
```

Be careful with the paths and file names, I used lowercase letters for everything in this example, I recommend to follow this pattern when you create your artifact bundle binaries.

```sh
swift package plugin --list
# ‘hello’ (plugin ‘HelloCommand’ in package ‘MyPluginExample’)
swift package hello
# Hello, world!
```

That's it, now we've got a working artifact bundle with a custom made executable available for macOS. We can use this artifact bundle as a dependency for a plugin and run the tool by using the plugin APIs. I'd really love to be able to cross compile Swift libraries and executable files later on, this could make the development / deployment workflow a bit more easy. Anyway, artifact bundles are a nice little addition, I really like the way you can ship binaries for multiple platforms and I hope that we're going to be able to share libraries as well in a similar fashion. 😊
