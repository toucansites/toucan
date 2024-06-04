---
slug: building-and-loading-dynamic-libraries-at-runtime-in-swift
title: Building and loading dynamic libraries at runtime in Swift
description: Learn how to create a plugin system using dynamic libraries and the power of Swift, aka. modular frameworks on the server-side.
publication: 2020-05-20 16:20:00
tags: Swift, libraries, frameworks
---

## Why should we make a plugin system?

In the [modules and hooks article](https://theswiftdev.com/modules-and-hooks-in-swift/) I was writing about how modules (plugins) can work together by using various invocation points and hooks. The only problem with that approach is that you can't really turn on or off modules on-the-fly, since we usually build our apps in a static way.

A good plugin system should let us alter the behavior of our code at runtime. Wordpress plugins are extremely successful, because you can add extra functionality to the CMS without recompiling or altering the core. Outside the Apple ecosystem, there is a huge world that could take advantage of this concept. Yes, I am talking about Swift on the server and backend applications.

My idea here is to build an open-source modular CMS that can be fast, safe and extensible through plugins. Fortunately now we have this amazing type-safe programming language that we can use. Swift is fast and reliable, it is the perfect choice for building backend apps on the long term. ✅

In this article I would like to show you a how to build a dynamic plugin system. The whole concept is based on [Lopdo](https://github.com/Lopdo)'s GitHub repositories, he did quite an amazing job implementing it. Thank you very much for showing me how to use `dlopen` and other similar functions. 🙏

## The magic of dynamic linking

Handmade [iOS frameworks](https://theswiftdev.com/how-to-make-a-swift-framework/) are usually bundled with the application itself, you can learn pretty much [everything about a framework](https://theswiftdev.com/deep-dive-into-swift-frameworks/) if you know some command line tools. This time we are only going to focus on static and dynamic linking. By default [Swift package dependencies](https://theswiftdev.com/the-swift-package-manifest-file/) are linked statically into your application, but you can change this if you define a dynamic library product.

First we are going to create a shared plugin interface containing the plugin API as a protocol.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PluginInterface",
    products: [
        .library(name: "PluginInterface", type: .dynamic, targets: ["PluginInterface"]),
    ],
    targets: [
        .target(name: "PluginInterface", dependencies: []),
    ]
)
```

This dynamic `PluginInterface` package can produce a `.dylib` or `.so` file, soon there will be a `.dll` version as well, based on the operating system. All the code bundled into this dynamic library can be shared between other applications. Let's make a simple protocol.

```swift
public protocol PluginInterface {

    func foo() -> String
}
```

Since we are going to load the plugin dynamically we will need something like a builder to construct the desired object. We can use a new abstract class for this purpose.

```swift
open class PluginBuilder {
    
    public init() {}

    open func build() -> PluginInterface {
        fatalError("You have to override this method.")
    }
}
```
That's our dynamic plugin interface library, feel free to push this to a remote repository.

## Building a dynamic plugin
For the sake of simplicity we'll build a module called `PluginA`, this is the manifest file:

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PluginA",
    products: [
        .library(name: "PluginA", type: .dynamic, targets: ["PluginA"]),
    ],
    dependencies: [
        .package(url: "path/to/the/PluginInterface/repository", from: "1.0.0"),
    ],
    targets: [
        .target(name: "PluginA", dependencies: [
            .product(name: "PluginInterface", package: "PluginInterface")
        ]),
    ]
)
```

The plugin implementation will of course implement the `PluginInterface` protocol. You can extend this protocol based on your needs, you can also use other frameworks as dependencies.

```swift
import PluginInterface

struct PluginA: PluginInterface {

    func foo() -> String {
        return "A"
    }
}
```

We have to subclass the `PluginBuilder` class and return our plugin implementation. We are going to use the `@_cdecl` attributed create function to access our plugin builder from the core app. This [Swift attribute](https://theswiftdev.com/everything-about-public-and-private-swift-attributes/) tells the compiler to save our function under the "createPlugin" symbol name.

```swift
import PluginInterface

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(PluginABuilder()).toOpaque()
}

final class PluginABuilder: PluginBuilder {

    override func build() -> PluginInterface {
        PluginA()
    }
}
```

We can build the plugin using the command line, just run `swift build` in the project folder. Now you can find the dylib file under the binary path, feel free to run `swift build --show-bin-path`, this will output the required folder. We will need both `.dylib` files for later use.

## Loading the plugin at runtime

The core application will also use the plugin interface as a dependency.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "CoreApp",
    dependencies: [
        .package(url: "path/to/the/PluginInterface/repository", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CoreApp", dependencies: [
            .product(name: "PluginInterface", package: "PluginInterface")
        ]),
    ]
)
```

This is an executable target, so we can place the loading logic to the `main.swift` file.

```swift
import Foundation
import PluginInterface

typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

func plugin(at path: String) -> PluginInterface {
    let openRes = dlopen(path, RTLD_NOW|RTLD_LOCAL)
    if openRes != nil {
        defer {
            dlclose(openRes)
        }

        let symbolName = "createPlugin"
        let sym = dlsym(openRes, symbolName)

        if sym != nil {
            let f: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
            let pluginPointer = f()
            let builder = Unmanaged<PluginBuilder>.fromOpaque(pluginPointer).takeRetainedValue()
            return builder.build()
        }
        else {
            fatalError("error loading lib: symbol \(symbolName) not found, path: \(path)")
        }
    }
    else {
        if let err = dlerror() {
            fatalError("error opening lib: \(String(format: "%s", err)), path: \(path)")
        }
        else {
            fatalError("error opening lib: unknown error, path: \(path)")
        }
    }
}

let myPlugin = plugin(at: "path/to/my/plugin/libPluginA.dylib")
let a = myPlugin.foo()
print(a)
```

We can use the `dlopen` function to open the dynamic library file, then we are trying to get the createPlugin symbol using the `dlsym` method. If we have a pointer we still need to cast that into a valid `PluginBuilder` object, then we can call the build method and return the plugin interface.

## Running the app

Now if you try to run this application using Xcode you'll get a warning like this:

> WARN: Class \_TtC15PluginInterface13PluginBuilder is implemented in both... One of the two will be used. Which one is undefined.

This is related to an old bug, but fortunately that is already resolved. This time Xcode is the bad guy, since it is trying to link everything as a static dependency. Now if you build the application through the command line (swift build) and place the following files in the same folder:

- CoreApp
- libPluginA.dylib
- libPluginInterface.dylib

You can run the application `./CoreApp` without further issues. The app will print out `A` without the warning message, since the Swift package manager is recognizing that you would like to link the libPluginInterface framework as a dynamic framework, so it won't be embedded into the application binary. Of course you have to set up the right plugin path in the core application.
