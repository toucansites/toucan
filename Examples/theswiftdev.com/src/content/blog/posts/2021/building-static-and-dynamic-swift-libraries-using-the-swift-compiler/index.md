---
type: post
slug: building-static-and-dynamic-swift-libraries-using-the-swift-compiler
title: Building static and dynamic Swift libraries using the Swift compiler
description: This tutorial is all about emitting various Swift binaries without the Swift package manager, but only using the Swift compiler.
publication: 2021-02-16 16:20:00
tags: Swift, compiler
authors:
  - tibor-bodecs
---

## What the heck is a library?

A [library](https://en.wikipedia.org/wiki/Library_(computing)) is a collection of Swift components that other applications can use.

Imagine that you are creating a simple application to pluralize a string. It works great, you finish the app and you start working on your next one. In your next application, you face the exact same issue, you have to print countable items (e.g 2 bananas). What would you do? 🤔

The first thing that can cross your mind is to copy all the source code from the first application into the second one. Well, this could work of course, but what happens if you discover a bug in the pluralization component? Now you have to fix the issue at two places, since you've just duplicated the entire stuff. There must be a better way... 🧠

Fortunately computer programmers faced the exact same issue, so they invented shared libraries. A shared library is a special kind of binary component that you can use in your main application. This way you can outsource Swift code into a separate file (or bunch of files), throw in some access control to allow other apps to use public methods and call functions from your library and here we go, we just shared our common code between our applications.

Oh wait, there is a bug in the lib, how can I fix it? Well, this is where things get a bit complicated, but don't worry too much, I'll try to explain how it works. So, last time, you know, when we talked [about the Swift compiler and linker](https://theswiftdev.com/the-swift-compiler-for-beginners/), I mentioned, that they can resolve dependencies in your program. When you use a library you can choose between two approaches.

- static linking
- dynamic linking

Static linking means that the source code inside the library will be literally copy-pasted into your application binary. Dynamic linking on the other hand means that your library dependencies will be resolved at runtime. By the way, you have to decide this upfront, since you have to build either a static or a dynamic library. Huhh? Ok, let me try this again... 🙃

The static library approach is more simple. You can easily build a static library using the compiler (you'll see how to make one later on), then you can import this library inside your application source (import MyLibrary). Now when you compile the main app, you have to tell the compiler the location of your static (binary) library, and the publicly accessible objects (headers or module map) that are available to use. This way when your app is composed the symbols from the lib (classes, methods, etc) can be copied to the main executable file). When you run the app, required objects will be there already inside the binary file, so you can run it as it is.

The main difference between a static and a dynamic library is that you don't copy every required symbol to the executable application binary when you use a dylib file, but some of the "undefined" symbols will be resolved at runtime. First you have to build your library as a dynamic dependency using the Swift compiler, this will produce a dynamic (binary) library file and a module map (header files). When you make the final version of your app, the system will put references of the dynamic library to your executable instead of copying the contents of the dylib file. If you want to run your application you have to make sure that the referenced dynamic library is available to use. The operating system will try to load the generated dylib file so the application resolves the symbols based on the reference pointers. 👈

## Should I choose dynamic or static linking?

Well, it depends on the environment. For example the Swift Package Manager prefers to use static linking, but Xcode will try to build SPM packages as dynamic dependencies. You can also explicitly tell SPM to build a static or dynamic library, but in most of the cases you should stick with the automatic value, so the system can build the right module dependency for you.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyLibrary",
    products: [
        /// type: automatic, based on the environment
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
        //.library(name: "MyLibrary", type: .dynamic, targets: ["MyLibrary"]),
        //.library(name: "MyLibrary", type: .static, targets: ["MyLibrary"]),
    ],
    targets: [
        .target(name: "MyLibrary", dependencies: []),
    ]
)
```

By the way if you are confused enough, I have an article for beginners [about Swift packages](https://theswiftdev.com/deep-dive-into-swift-frameworks/), modules, frameworks and the tools that makes this whole dependency management possible. You should definitely take a look, it's a some sort of a deep dive into FAT frameworks, but the first part of the article is full of useful definitions and introductions to various commands.

Back to the original question: static vs dynamic? Do you remember the bug in the library that we have to fix? If you use a static library you have to rebuild all the apps that are depending on it (they must be linked with the fixed library of course) in order to make the issue disappear. 🐛

Since a dynamic library is loaded at runtime and the symbols are not embedded into the application binary, you can simply build a new dylib file and replace the old one to fix the bug. This way all the apps that are referencing to this dependency will have the fix for free. There is no need to recompile everyting, except the faulty code in the framework itself. 💪

It is also worth to mention that the final app size is smaller when you use a dylib.

Ok, but why should I ever use static linking if dylibz are so cool? The truth is that sometimes you want to encapsulate everything into a single binary, instead of installing lots of other dylib files into the system. Also what happens if something deletes a dylib that your app would require to work flawlessly? That'd suck for sure, especially if it is a mission-critical script on a server... 😳

Hopefully, I over-explained things, so we can start building our very first static library.

## Compiling a static Swift library

Do you still have that little Point struct from the previous tutorial? Let's build a static library from that file, but before we do so, we have to explicitly mark it as public, plus we need a public init method in order to be able to create a Point struct from our application. You know, in Swift, [access control](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html) allows us, programmers, to hide specific parts of a library from other developers.

```swift
public struct Point {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
```

Now we're ready to build our static library based on this single point.swift source file. As I mentioned this before, we need a binary file and a module map file that contains the publicly accessible interface for the lib. You can use the -emit-library flat to tell the Swift compiler that we need a binary library file plus using the -emit-module parameter will produce a Swift module info file with all the API and docs needed for other modules. By default the compiler would emit a dylib (on macOS at least), so we have to use the -static flat to explicitly generate a static dependency. 🔨

```sh
swiftc point.swift -emit-module -emit-library -static
```

The command above should produce 4 new files:

- libpoint.a - The binary static library itself
- point.swiftdoc - Documentation for the module (binary format)
- point.swiftmodule - Info about the module, ["Swift header file"](https://forums.swift.org/t/whats-in-the-file-of-swiftmodule-how-to-open-it/1032)
- point.swiftsourceinfo - [Source information file](https://forums.swift.org/t/proposal-emitting-source-information-file-during-compilation/28794)

Move these files inside a lib folder, so it'll be more easy to work with them. That's really it, we've just created a working static library, but how can we use it to link them against our main application? 🤔

First of all, we have to import our newly created module inside the `main.swift` file if we want to use the objects (in our case the Point struct) from it. By the way you can add a custom module name to your library if you use the `-module-name [name]` argument with the previous `swiftc` command.

```swift
import point

let p = Point(x: 4, y: 20)

print("Hello library!", p.x, p.y)
```

So, all of our library files are located in a lib folder, and our default module name is point (based on our single input file). We can use the swiftc command again, to compile the main file, this time we use the -L flag to add a library search path, so the compiler can locate our binary libpoint.a file. We also have to set a search path for imports, the -I property will help us, this way the public API (headers) of the module will be available in our source file. The very last thing that we have to append to the end of the command is the -l[name] flag, this specifies the library name we would like to link against. Be careful, there is no space in between the -l and the name value! ⚠️

```sh
swiftc main.swift -L ./lib/ -I ./lib/ -lpoint

# run the app
./main
# Hello library! 4 20
```

Voilá, we've just separated a file from the main application by using a static dependency. 👏

## Compiling a dynamic Swift library

In theory, we can use the same code and build a dynamic library from the `point.swift` file and compile our main.swift file using that shared framework. We just drop the `-static` flag first.

```
swiftc point.swift -emit-module -emit-library
```

This time the output is slightly different. We've got a `libpoint.dylib` binary instead of the libpoint.a, but all the other files look identical. Extension my vary per operating system:

- macOS - static: `.a`, dynamic: `.dylib`
- Linux - static: `.so`, dynamic: `.dylib`
- Windows - static: `.lib`, dynamic: `.dll`

So we have our dylib file, but the real question is: can we build the main.swift file with it?

```sh
swiftc main.swift -L ./lib/ -I ./lib/ -lpoint

# run the app
./main
# Hello library! 4 20
```

Now rename the libpoint.dylib file into libpoint.foo and run the main app again.

```sh
./main

# dyld: Library not loaded: libpoint.dylib
#   Referenced from: /Users/tib/./main
#   Reason: image not found
# zsh: abort      ./main
```

Whoops, seems like we have a problem. Don't worry, this is the expected output, since we renamed the dynamic library and the application can't find it. When the loader tries to get the referenced symbols from the file it looks up dynamic libraries at a few different places.

- The directory you specified through the `-L` flag (`./lib/`).
- The directory where your executable file is (`./`)
- The `/usr/lib/` or the `/usr/local/lib/` directories

Since the `/usr/lib/` directory is protected by the famous [SIP](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection) "guard", you should ship your dylib files next to your executable binary, or alternatively you can install them under the `/usr/local/lib/` folder. Unfortunately, this lookup strategy can lead to all sort of issues, I really don't want to get into the details this time, but it can lead to compatibility and security issues. 🤫

The good news is that now if you change something in the dylib, and you simply rebuild & replace the file then you run the ./main again (without recompiling), the altered dynamic library will be used. Just try to put a print statement into the init method of the Point struct...

## Summary

Honestly, I'd rather go with a static library in most of the cases because using a static library will guarantee that your application has every necessary dependency embedded into the binary file.

Of course dynamic libraries are great if you are the author of a commonly used framework, such the Swift standard library, Foundation or UIKit. These modules are shipped as shared libraries, because they are huge and almost every single app imports them. Just think about it, if we'd link these three frameworks statically that'd add a lot to the size of our apps, plus it'd be way harder to fix system-wide bugs. This is the reason why these packages are shipped as shared libz, plus Apple can gives us a promise that these components will always be available as part of the operating system. 😅

Anyways, there are some tools that you can use to alter library loader paths, I'll tell you more about this next time. It's going to be a more advanced topic including different languages. I'm going to show you how to build a library using C and how to call it using Swift, without SPM. 🤓
