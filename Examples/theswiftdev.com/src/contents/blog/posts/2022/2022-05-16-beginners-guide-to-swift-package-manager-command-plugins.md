---
slug: beginners-guide-to-swift-package-manager-command-plugins
title: Beginner's guide to Swift package manager command plugins
description: Learn how to create command plugins for the Swift Package Manager to execute custom actions using SPM and other tools.
publication: 2022-05-16 16:20:00
tags: Swift, SPM
---

## Introduction to Swift Package Manager plugins

First of all I'd like to talk a few words about the new SPM plugin infrastructure, that was introduced in the Swift 5.6 release. The very [first proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0303-swiftpm-extensible-build-tools.md) describes the detailed design of the plugin API with some [plugin examples](https://github.com/apple/swift-evolution/blob/main/proposals/0303-swiftpm-extensible-build-tools.md#example-1-swiftgen), which are quite handy. Honestly speaking I was a bit to lazy to carefully read through the entire documentation, it's quite long, but long story short, you can create the following plugin types with the currently existing APIs:

- Build tools - can be invoked via the SPM targets
    + pre-build - runs before the build starts
    + build - runs during the build
- Commands - can be invoked via the command line
    + source code formatting - modifies the code inside package
    + documentation generation - generate docs for the package
    + custom - user defined intentions

For the sake of simplicity in this tutorial I'm only going to write a bit about the second category, aka. the command plugins. These plugins were a bit more interesting for me, because I wanted to integrate my deployment workflow into SPM, so I started to experiment with the plugin API to see how hard it is to build such a thing. Turns out it's quite easy, but the developer experience it's not that good. 😅

## Building a source code formatting plugin

The very first thing I wanted to integrate with SPM was [SwiftLint](https://github.com/realm/SwiftLint), since I was not able to find a plugin implementation that I could use I started from scratch. As a starting point I was using the [example code](https://github.com/apple/swift-evolution/blob/main/proposals/0332-swiftpm-command-plugins.md#example-2-formatting-source-code) from the [Package Manager Command Plugins proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0332-swiftpm-command-plugins.md).

```
mkdir Example
cd Example
swift package init --type=library
```

I started with a brand new package, using the swift package init command, then I modified the Package.swift file according to the documentation. I've also added [SwiftLint](https://github.com/realm/SwiftLint) as a package dependency so SPM can download & build the and hopefully my custom plugin command can invoke the swiftlint executable when it is needed.

```swift
// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Example", targets: ["Example"]),
        .plugin(name: "MyCommandPlugin", targets: ["MyCommandPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", branch: "master"),
    ],
    targets: [
        .target(name: "Example", dependencies: []),
        .testTarget(name: "ExampleTests", dependencies: ["Example"]),
       
        .plugin(name: "MyCommandPlugin",
                capability: .command(
                    intent: .sourceCodeFormatting(),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command reformats source files")
                    ]
                ),
                dependencies: [
                    .product(name: "swiftlint", package: "SwiftLint"),
                ]),
    ]
)
```

I've created a `Plugins` directory with a `main.swift` file right next to the Sources folder, with the following contents.

```swift
import PackagePlugin
import Foundation

@main
struct MyCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "swiftlint")
        let toolUrl = URL(fileURLWithPath: tool.path.string)
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }

            let process = Process()
            process.executableURL = toolUrl
            process.arguments = [
                "\(target.directory)",
                "--fix",
               // "--in-process-sourcekit" // this line will fix the issues...
            ]

            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Formatted the source code in \(target.directory).")
            }
            else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
}
```

The snippet above should locate the swiftlint tool using the plugins context then it'll iterate through the available package targets, filter out non source-module targets and format only those targets that contains actual Swift source files. The process object should simply invoke the underlying tool, we can wait until the child (swiftlint invocation) process exists and hopefully we're good to go. 🤞

> NOTE: Update: [kalKarmaDev](https://x.com/k_alweheshy) told me that it is possible to pass the `--in-process-sourcekit` argument to SwiftLint, this will fix the underlying issue and the source files are actually fixed.

I wanted to list the available plugins & run my source code linter / formatter using the following shell commands, but unfortunately seems like the swiftlint invocation part failed for some strange reason.

```sh
swift package plugin --list
swift package format-source-code #won't work, needs access to source files
swift package --allow-writing-to-package-directory format-source-code

# error: swift-format invocation failed: NSTaskTerminationReason(rawValue: 2):5
# what the hell happened? 🤔
```

Seems like there's a problem with the exit code of the invoked swiftlint process, so I removed the success check from the plugin source to see if that's causing the issue or not also tried to print out the executable command to debug the underlying problem.

```swift
import PackagePlugin
import Foundation

@main
struct MyCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "swiftlint")
        let toolUrl = URL(fileURLWithPath: tool.path.string)
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }

            let process = Process()
            process.executableURL = toolUrl
            process.arguments = [
                "\(target.directory)",
                "--fix",
            ]

            print(toolUrl.path, process.arguments!.joined(separator: " "))

            try process.run()
            process.waitUntilExit()
        }
    }
}
```

Intentionally made a small "mistake" in the Example.swift source file, so I can see if the swiftlint --fix command will solve this issue or not. 🤔

```swift
public struct Example {
    public private(set) var text = "Hello, World!"

    public init() {
        let xxx :Int = 123
    }
}
```

Turns out, when I run the plugin via the [Process](https://developer.apple.com/documentation/foundation/process) invocation, nothing happens, but when I enter the following code manually into the shell, it just works.

```sh
/Users/tib/Example/.build/arm64-apple-macosx/debug/swiftlint /Users/tib/Example/Tests/Example --fix
/Users/tib/Example/.build/arm64-apple-macosx/debug/swiftlint /Users/tib/Example/Tests/ExampleTests --fix
```

All right, so we definitely have a problem here... I tried to get the standard output message and error message from the running process, seems like swiftlint runs, but something in the SPM infrastructure blocks the code changes in the package. After several hours of debugging I decided to give a shot to [swift-format](https://github.com/apple/swift-format), because that's what the official docs suggest. 🤷‍♂️

```swift
// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Example", targets: ["Example"]),
        .plugin(name: "MyCommandPlugin", targets: ["MyCommandPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", exact: "0.50600.1"),
    ],
    targets: [
        .target(name: "Example", dependencies: []),
        .testTarget(name: "ExampleTests", dependencies: ["Example"]),
       
        .plugin(name: "MyCommandPlugin",
                capability: .command(
                    intent: .sourceCodeFormatting(),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command reformats source files")
                    ]
                ),
                dependencies: [
                    .product(name: "swift-format", package: "swift-format"),
                ]),
    ]
)
```

Changed both the `Package.swift` file and the plugin source code, to make it work with swift-format.

```swift
import PackagePlugin
import Foundation

@main
struct MyCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let swiftFormatTool = try context.tool(named: "swift-format")
        let swiftFormatExec = URL(fileURLWithPath: swiftFormatTool.path.string)
//        let configFile = context.package.directory.appending(".swift-format.json")
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }

            let process = Process()
            process.executableURL = swiftFormatExec
            process.arguments = [
//                "--configuration", "\(configFile)",
                "--in-place",
                "--recursive",
                "\(target.directory)",
            ]
            try process.run()
            process.waitUntilExit()

            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Formatted the source code in \(target.directory).")
            }
            else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
}
```

I tried to run again the exact same package plugin command to format my source files, but this time swift-format was doing the code formatting instead of swiftlint.

```sh
swift package --allow-writing-to-package-directory format-source-code
// ... loading dependencies
Build complete! (6.38s)
Formatted the source code in /Users/tib/Linter/Tests/ExampleTests.
Formatted the source code in /Users/tib/Linter/Sources/Example.
```

Worked like a charm, my Example.swift file was fixed and the : was on the left side... 🎊

```swift
public struct Example {
    public private(set) var text = "Hello, World!"

    public init() {
        let xxx: Int = 123
    }
}
```

Yeah, I've made some progress, but it took me quite a lot of time to debug this issue and I don't like the fact that I have to mess around with processes to invoke other tools... my gut tells me that SwiftLint is not following the standard shell exit status codes and that's causing some issues, maybe it's spawning child processes and that's the problem, I really don't know but I don't wanted to waste more time on this issue, but I wanted to move forward with the other category. 😅

## Integrating the DocC plugin with SPM

As a first step I added some dummy comments to my Example library to be able to see something in the generated documentation, nothing fancy just some one-liners. 📖

```swift
/// This is just an example struct
public struct Example {

    /// this is the hello world text
    public private(set) var text = "Hello, World!"
    
    /// this is the init method
    public init() {
        let xxx: Int = 123
    }
}
```

I discovered that Apple has an [official DocC plugin](https://github.com/apple/swift-docc-plugin), so I added it as a dependency to my project.

```swift
// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Example", targets: ["Example"]),
        .plugin(name: "MyCommandPlugin", targets: ["MyCommandPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", exact: "0.50600.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),

    ],
    targets: [
        .target(name: "Example", dependencies: []),
        .testTarget(name: "ExampleTests", dependencies: ["Example"]),
       
        .plugin(name: "MyCommandPlugin",
                capability: .command(
                    intent: .sourceCodeFormatting(),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command reformats source files")
                    ]
                ),
                dependencies: [
                    .product(name: "swift-format", package: "swift-format"),
                ]),
    ]
)
```

Two new plugin commands were available after I executed the plugin list command.

```sh
swift package plugin --list

# ‘format-source-code’ (plugin ‘MyCommandPlugin’ in package ‘Example’)
# ‘generate-documentation’ (plugin ‘Swift-DocC’ in package ‘SwiftDocCPlugin’)
# ‘preview-documentation’ (plugin ‘Swift-DocC Preview’ in package ‘SwiftDocCPlugin’)
```

Tried to run the first one, and fortunately the doccarchive file was generated. 😊

```sh
swift package generate-documentation
# Generating documentation for 'Example'...
# Build complete! (0.16s)
# Converting documentation...
# Conversion complete! (0.33s)
# Generated DocC archive at '/Users/tib/Linter/.build/plugins/Swift-DocC/outputs/Example.doccarchive'
```

Also tried to preview the documentation, there was a note about the --disable-sandbox flag in the output, so I simply added it to my original command and...

```sh
swift package preview-documentation 
# Note: The Swift-DocC Preview plugin requires passing the '--disable-sandbox' flag
swift package --disable-sandbox preview-documentation
```

Magic. It worked and my documentation was available. Now this is how plugins should work, I loved this experience and I really hope that more and more official plugins are coming soon. 😍

## Building a custom intent command plugin

I wanted to build a small executable target with some bundled resources and see if a plugin can deploy the executable binary with the resources. This could be very useful when I deploy feather apps, I have multiple module bundles there and now I have to manually copy everything... 🙈

```swift
// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Example", targets: ["Example"]),
        .executable(name: "MyExample", targets: ["MyExample"]),
        .plugin(name: "MyCommandPlugin", targets: ["MyCommandPlugin"]),
        .plugin(name: "MyDistCommandPlugin", targets: ["MyDistCommandPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", exact: "0.50600.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),

    ],
    targets: [
        .executableTarget(name: "MyExample",
                          resources: [
                            .copy("Resources"),
                          ], plugins: [
                            
                          ]),
        .target(name: "Example", dependencies: []),
        .testTarget(name: "ExampleTests", dependencies: ["Example"]),
       
        .plugin(name: "MyCommandPlugin",
                capability: .command(
                    intent: .sourceCodeFormatting(),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command reformats source files")
                    ]
                ),
                dependencies: [
                    .product(name: "swift-format", package: "swift-format"),
                ]),
        
        .plugin(name: "MyDistCommandPlugin",
                capability: .command(
                    intent: .custom(verb: "dist", description: "Create dist archive"),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command deploys the executable")
                    ]
                ),
                dependencies: [
                ]),
    ]
)
```

As a first step I created a new executable target called MyExample and a new MyDistCommandPlugin with a custom verb. Inside the Sources/MyExample/Resources folder I've placed a simple test.json file with the following contents.

```json
{
    "success": true
}
```

The main.swift file of the MyExample target looks like this. It just validates that the resource file is available and it simply decodes the contents of it and prints everything to the standard output. 👍

```swift
import Foundation

guard let jsonFile = Bundle.module.url(forResource: "Resources/test", withExtension: "json") else {
    fatalError("Bundle file not found")
}
let jsonData = try Data(contentsOf: jsonFile)

struct Json: Codable {
    let success: Bool
}

let json = try JSONDecoder().decode(Json.self, from: jsonData)

print("Is success?", json.success)
```

Inside the Plugins folder I've created a main.swift file under the MyDistCommandPlugin folder.

```swift
import PackagePlugin
import Foundation

@main
struct MyDistCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        
        // ...
    }
}
```

Now I was able to re-run the swift package plugin --list command and the dist verb appeared in the list of available commands. Now the only question is: how do we get the artifacts out of the build directory? Fortunately the [3rd example](https://github.com/apple/swift-evolution/blob/main/proposals/0332-swiftpm-command-plugins.md#example-3-building-deployment-artifacts) of the commands proposal is quite similar.

```swift
import PackagePlugin
import Foundation

@main
struct MyDistCommandPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let cpTool = try context.tool(named: "cp")
        let cpToolURL = URL(fileURLWithPath: cpTool.path.string)

        let result = try packageManager.build(.product("MyExample"), parameters: .init(configuration: .release, logging: .concise))
        guard result.succeeded else {
            fatalError("couldn't build product")
        }
        guard let executable = result.builtArtifacts.first(where : { $0.kind == .executable }) else {
            fatalError("couldn't find executable")
        }
        
        let process = try Process.run(cpToolURL, arguments: [
            executable.path.string,
            context.package.directory.string,
        ])
        process.waitUntilExit()

        let exeUrl = URL(fileURLWithPath: executable.path.string).deletingLastPathComponent()
        let bundles = try FileManager.default.contentsOfDirectory(atPath: exeUrl.path).filter { $0.hasSuffix(".bundle") }

        for bundle in bundles {
            let process = try Process.run(cpToolURL, arguments: ["-R",
                                                                    exeUrl.appendingPathComponent(bundle).path,
                                                                    context.package.directory.string,
                                                                ])
            process.waitUntilExit()
        }
    }
}
```

So the only problem was that I was not able to get back the bundled resources, so I had to use the URL of the executable file, drop the last path component and read the contents of that directory using the FileManager to get back the .bundle packages inside of that folder.

Unfortunately the builtArtifacts property only returns the executables and libraries. I really hope that we're going to get support for bundles as well in the future so this hacky solution can be avoided for good. Anyway it works just fine, but still it's a hack, so use it carefully. ⚠️

```sh
swift package --allow-writing-to-package-directory dist
./MyExample 
#Is success? true
```

I was able to run my custom dist command without further issues, of course you can use additional arguments to customize your plugin or add more flexibility, the examples in the proposal are pretty much okay, but it's quite unfortunate that there is no official documentation for Swift package manager plugins just yet. 😕

## Conclusion

Learning about command plugins was fun, but in the beginning it was annoying because I expected a bit better developer experience regarding the tool invocation APIs. In summary I can say that this is just the beginning. It's just like the async / await and actors addition to the Swift language. The feature itself is there, it's mostly ready to go, but not many developers are using it on a daily basis. These things will require time and hopefully we're going to see a lot more plugins later on... 💪
