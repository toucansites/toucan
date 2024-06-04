---
slug: swift-package-manager-tutorial
title: Swift Package Manager tutorial
description: Learn how to use the Swift Package Manager to handle external dependencies, create your library or app on macOS and Linux.
publication: 2017-11-19 16:20:00
tags: Swift, SPM
---

## Swift Package Manager basics

First of all, please check your Swift version on your device before we jump in this tutorial will only work with the latest toolchain, so you'll need Swift 5.2 or newer.

```
Apple Swift version 5.2.2 (swiftlang-1103.0.32.6 clang-1103.0.32.51)
Target: x86_64-apple-darwin19.4.0
```

### Creating apps

All the hard work is done by the `swift package` command. You can enter that into a terminal window and see the available [sub-commands](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md). To generate a new package you should go with the init command, if you don't provide a type flag, by default it'll create a library, but this time we'd like to make an executable application.

```
swift package init --type executable
swift build
swift run my-app
```

The compiler can build your source files with the help of the swift build command. The executable file is going to be placed somewhere under the `.build` directory, if you run the newly created application with the swift run my-app command, you should see the basic `Hello, world!` message.

> Congratulations for your first command line Swift application!

Now you should do some actual coding. Usually your swift source files should be under the Sources directory, however you might want to create some reusable parts for your app. So let's prepare for that scenario by starting a brand new library.

### Making a library

We start with the `init` command, but this time we don't specify the type. We actually could enter `swift package init --type library` but that's way too may words to type. Also because we're making a library, the SPM tool is going to provide us some basic tests, let's run them too with the `swift test` command. 😜

```
swift package init
swift test
# swift test --help
# swift test --filter <test-target>.<test-case>/<test>
```

If you check the file structure now you won't find a `main.swift` file inside the source folder, but instead of this you'll get an example unit test under the `Tests` directory.

Now know the basics. You have an example application and a library, so let's connect them together with the help of the Swift Package Manager Manifest API!

## The Manifest API - Package.swift

Every SPM bundle has a Package.swift manifest file inside of it. In this manifest file you can define all your dependencies, targets and even the exact source files for your project. In this section I'll teach you the basics of the manifest file.

### Tool version

First of all if you want to support the new manifest file format (aka. Swift 4 version), you have to set the swift-tools-version as comment in your manifest file.

```
// swift-tools-version:5.2
```

Now you're ready to work with the brand new manifest API.

### Dependencies

Let's just add our library as a dependency for the main application first by creating a new package dependency inside the Package.swift file. The first argument is a package url string, which can be a local file path or a remote url (usually a github repo link). Note that you should add your dependency to the targets as well. Usually the specific name of a package is defined inside the library manifest file.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "my-app",
    dependencies: [
        .package(url: "../my-lib", .branch("master")),
    ],
    targets: [
        .target(name: "my-app", dependencies: [
            .product(name: "my-lib", package: "my-lib"),
        ]),
    ]
)
```

Now if you run `swift build` you'll fail to build your sources. That's because the SPM only works with git repositories. This means you have to create a repository for your library. Let's move to the directory of the library and run the following commands.

```
git init
git add .
git commit -m 'initial'
```

You should also note that we specified the branch in the package dependencies. You can use version numbers, or even commit hashes too. All the available options are well written inside the [manifest API redesign proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0158-package-manager-manifest-api-redesign.md) document.

Now let's go back to the application directory and update the dependencies with the `swift package update` command. This time it's going to be able to fetch, clone and finally resolve our dependency.

You can build and run, however we've forgot to set the access level of our struct inside our library to public, so nothing is going to be visible from that API.

```
public struct my_lib {
    public var text = "Hello, World!"

    public init() {}
}
```

Let's do some changes and commit them into the library's main branch.

```
git add .
git commit -m 'access level fix'
```

You're ready to use the lib in the app, change the main.swift file like this.

```swift
import my_lib

print(my_lib().text)
```

Update the dependencies again, and let's do a release build this time.

```
swift package update
swift build -c release
swift run -c release
```

With the `-c` or `--configuration` flag you can make a release build.

### Products and targets

By default the SPM works with the following target directories:

Regular targets: package root, Sources, Source, src, srcs. Test targets: Tests, package root, Sources, Source, src, srcs.

This means, that if you create .swift files inside these folders, those sources will be compiled or tested, depending on the file location. Also the generated manifest file contains only one build target (like Xcode targets), but sometimes you want to create multiple apps or libraries from the same bundle. Let's change our Package.swift file a little bit, and see how can we make a brand new target.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "my-app",
    dependencies: [
        .package(url: "../my-lib", .branch("master")),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
    ],
    targets: [
        .target(name: "my-app", dependencies: [
            .product(name: "my-lib", package: "my-lib"),
        ]),
        .target(name: "my-cmd", dependencies: [
            .product(name: "Commander", package: "Commander"),
        ], path: "./Sources/my-cmd", sources: ["main.swift"]),
    ]
)
```

We just created a new dependency from GitHub, and a brand new target which will contain only the `main.swift` file from the `Sources/my-cmd` directory. Now let's create this directory and add the source code for the new app.

```swift
import Foundation
import Commander

let main = command { (name:String) in
    print("Hello, \(name.capitalized)!")
}

main.run()
```

Build the project with swift build and run the newly created app with one extra name parameter. Hopefully you'll see something like this.

```
swift run my-cmd guest
# Hello, Guest!
```

So we just made a brand new executable target, however if you'd like to expose your targets for other packages, you should define them as products as well. If you open the manifest file for the library, you'll see that there is a product defined from the library target. This way the package manager can link the product dependencies based on the given product name.

> NOTE: You can define static or dynamic libraries, however it is recommended to use automatic so the SPM can decide appropriate linkage.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "my-lib-package",
    products: [
        .library(name: "my-lib", targets: ["my-lib"]),
        //.library(name: "my-lib", type: .static, targets: ["my-lib"]),
        //.library(name: "my-lib", type: .dynamic, targets: ["my-lib"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "my-lib", dependencies: []),
        .testTarget(name: "my-libTests", dependencies: ["my-lib"]),
    ]
)
```

### Deployment target, other build flags

Sometimes you'll need to specify a deployment target for your package. Now this is possible with the Swift Package Manager (it was buggy [a log time ago](https://oleb.net/blog/2017/04/swift-3-1-package-manager-deployment-target/)), you just have to provide some extra arguments for the compiler, during the build phase.

```
swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
```

Also if you would like to define build flags, that's possible too.

```
swift build -Xswiftc "-D" -Xswiftc "DEBUG"
```

Now in your source code you can check for the existence of the DEBUG flag.

```swift
#if DEBUG
    print("debug mode")
#endif
```

If you want to know more about the build process, just type `swift build --help` and you'll see your available options for the build command.

This was SPM in a nutshell. Actually we have covered more than just the basics, we deep-dived a little into the Swift Package Manager, now you must be familiar with targets, products and most of the available commands, but there is always more to learn. So if you want to know even more about this amazing tool, you should check the Swift evolution dashboard for more info. 😉
