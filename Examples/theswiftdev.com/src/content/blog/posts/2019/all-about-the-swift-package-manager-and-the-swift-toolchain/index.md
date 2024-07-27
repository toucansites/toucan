---
type: post
slug: all-about-the-swift-package-manager-and-the-swift-toolchain
title: All about the Swift Package Manager and the Swift toolchain
description: Learn everything about the SPM architecture. I'll also teach you how to integrate your binary executable into the Swift toolchain.
publication: 2019-01-14 16:20:00
tags: UIKit, iOS
authors:
  - tibor-bodecs
---

If you don't know too much about the Swift Package Manager, but you are looking for the basics please read my [tutorial about SPM](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/) that explains pretty much everything. The aim of this article is to go deep into the SPM architecture, also before you start reading this I'd recommend to also read my [article about frameworks and tools](https://theswiftdev.com/2018/01/25/deep-dive-into-swift-frameworks/). 📖

Ready? Go! I mean Swift! 😂

## Swift Package Manager

Have you ever wondered about [how does SPM parse it's manifest](http://bhargavg.com/swift/2016/06/11/how-swiftpm-parses-manifest-file.html) file in order to [install](http://log.zyxar.com/blog/2012/03/10/install-name-on-os-x/) your packages? Well, the Package.swift manifest is a strange beast. Let me show you an quick example of a regular package description file:

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "HelloSwift",
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "HelloSwift",
            dependencies: []),
        .testTarget(
            name: "HelloSwiftTests",
            dependencies: ["HelloSwift"]),
    ]
)
```

The first line contains the version information, next we have to import the `PackageDescription` module which contains all the required elements to properly describe a Swift package. If you run for example `swift package update` all your dependencies in this manifest file will be resolved & you can use them inside your own code files. ✅

> But how the heck are they doing this magic? 💫

That question was bugging me for a while, so I did a little research. First I was trying to replicate this behavior without looking at the original implementation of the Swift Package Manager at [GitHub](https://github.com/apple/swift-package-manager). I knew I shouldn't parse the Swift file, because that'd be a horrible thing to do - Swift files are messy - so let's try to import it somehow... 🙃

## Dynamic library loading approach

I searched for the "dynamic swift library" keywords and found an interesting [forum topic on swift.org](https://forums.swift.org/t/communicating-with-dynamically-loaded-swift-library/6769). Yeah, I'm making some progress I thought. WRONG! I was way further from the actual solution than I though, but it was fun, so I was looking into the implementation details of how to open a [compiled](https://modocache.io/getting-started-with-swift-development) `.dylib` file using `dlopen` & `dlsym` from Swift. How does one create a `.dylib` file? Ah, I already know this! 👍

I always wanted to understand this topic better, so I started to read more and more both about static and [dynamic libraries](https://www.bignerdranch.com/blog/it-looks-like-you-are-trying-to-use-a-framework/). Long story short, you can create a dynamic (or static) library with the following product definition:

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "example",
    products: [
        .library(name: "myStaticLib", type: .static, targets: ["myStaticLib"]),
        .library(name: "myDynamicLib", type: .dynamic, targets: ["myDynamicLib"]),
    ],
    targets: [
        .target(
            name: "myStaticLib",
            dependencies: []),
        .target(
            name: "myDynamicLib",
            dependencies: []),
    ]
)
```

The important files are going to be located inside the `.build/debug` folder. The `.swiftmodule` is basically the public header file, this contains all the available API for your library. The `.swiftdoc` file contains the documentation for the compiled [module](https://railsware.com/blog/2014/06/26/creation-of-pure-swift-module/), and depending on the type you'll also get a `.dylib` or a `.a` file. Guess which one is which.

So I could load the `.dylib` file by using `dlopen` & dlsym (some [@\_cdecl](https://theswiftdev.com/2018/03/29/everything-about-public-and-private-swift-attributes/) magic involved to get constant names instead of the "fuzzy" ones), but I was constantly receiving the same [warning](https://bugs.swift.org/browse/SR-6091) over and over again. The dynamic loading worked well, but I wanted to get rid of the warning, so I tried to remove the embedded the lib dependency from my executable target. (Hint: not really possible... afaik. anyone? 🙄)

I was messing around with [rpaths](https://wincent.com/wiki/%40executable_path%2C_%40load_path_and_%40rpath) & the `install_name_tool` for like hours, but even after I succesfully removed my library from the executable, "libSwift\*things" were still embedded into it. So that's the sad state of an unstable ABI, I thought... anyway at least I've learned something very important during the way here:

## Importing Swift code into Swift!

Yes, you heard that. It's possible to import compiled Swift libraries into Swift, but not a lot of people heard about this (I assume). It's not a popular topic amongs iOS / UIKit developers, but SPM does this all the time behind the scenes. 😅

How the heck can we import the pre-built libraries? Well, it's pretty simple.

```sh
// using swiftc with compiler flags

swiftc dynamic_main.swift -I ./.build/debug -lmyDynamicLib -L ./.build/debug
swiftc static_main.swift -I ./.build/debug -lmyStaticLib -L ./.build/debug

// using the Swift Package Manager with compiler flags

swift build -Xswiftc -I -Xswiftc ./.build/debug -Xswiftc -L -Xswiftc ./.build/debug -Xswiftc -lmyStaticLib
swift build -Xswiftc -I -Xswiftc ./.build/debug -Xswiftc -L -Xswiftc ./.build/debug -Xswiftc -lmyDynamicLib
```
You just have to append a few compiler flags. The `-I` stands for the import search path, `-L` is the library search path, `-l` links the given library. Check `swiftc -h` for more details and flags you won't regret it! Voilá now you can distribute closed source Swift packages. At least it was good to know how SPM does the "trick". 🤓

> WARN: Please note that until Swift 5 & ABI stability arrives you can use the precompiled libraries with the same Swift version only! So if you compile a lib with Swift 4.2, your executable also needs to be compiled with 4.2., but this will change pretty soon. 👏

The Swift Package Manager method

After 2 days of research & learning I really wanted to solve this, so I've started to check the source code of SPM. The first thing I've tried was adding the `--verbose` flag after the `swift build` command. Here is the important thing:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc \
--driver-mode=swift \
-L /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm/4_2 \
-lPackageDescription \
-suppress-warnings \
-swift-version 4.2 \
-I /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm/4_2 \
-target x86_64-apple-macosx10.10 \
-sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk \
/Users/tib/example/Package.swift \
-fileno 5
```

Whoa, this spits out a JSON based on my `Package.swift` file!!! 🎉

> How the hell are they doing this?

It turns out, if you change the `-fileno` parameter value to 1 (that's the standard output) you can see the results of this command on the console. Now the trick here is that SPM simply compiles the Package.swift and if there is a `-fileno` flag present in the command line arguments, well it prints out the encoded JSON representation of the Package object after the process exits. That's it, fuckn' easy, but it took 1 more day for me to figure this out... parenting 2 kids & coding is a hard combination. 🤷‍♂️

If you open the `/Applications/Xcode.app/Contents/Developer/` `Toolchains/XcodeDefault.xctoolchain/` `usr/lib/swift/pm/4_2` folder you'll see 3 familiar files there. Exactly. I also looked at the source of the [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Sources/PackageDescription4/Package.swift) file from the SPM repository, and followed the `registerExitHandler` method. After a successful `Package` initialization it simply registers an exit handler if a `-fileno` argument is present encodes itself & dumps the result by using the file handler number. Sweet! 😎

Since I was pretty much in the finish lap, I wanted to figure out one more thing: how did they manage to put the `swift package` command under the `swift` command?

## Swift toolchain

I just entered `swift lol` into my terminal. This is what happened:

```
tib@~: swift lol
error: unable to invoke subcommand:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-lol
(No such file or directory)
```

Got ya! The [toolchain](https://blog.krzyzanowskim.com/2018/10/11/dealing-with-a-swift-toolchain/) is the key to everything:

1. Apple is compiling the PackageDescription library from the Swift Package Manager and puts the `.swiftmodule`, `.swiftdoc`, `.dylib` files into the proper places under Xcode's default toolchain library path.
2. The swift build, run, test subcommands are just another Swift binary executables placed inside the toolchain's binary path. (Named like: swift-package, swift-build, swift-run, swift-test)
3. The swift command tries to invoke the proper subcommand if there is any and it's a valid (Swift) binary. (Tried with a shell script, it failed miserably...)
4. SPM uses the PackageDescription library from the toolchain in order to compile & turn the manifest file into JSON output.
5. The rest is history. 🤐

> NOTE: Swift can resolve subcommands from anywhere "inside" the `PATH` variable. You just have to prefix your [Swift script](https://github.com/mxcl/swift-sh) with `swift-` and you're good to go.

## SwiftCI - a task runner for Swift

I had this idea that it'd be nice to have a [grunt](https://gruntjs.com/) / [gulp](https://gulpjs.com/) like task runner also a continuous integration service on a long term by using this technique I explained above. So I've made a similar extension wired into the heart of the Swift toolchain: [SwiftCI](https://github.com/BinaryBirds/CI). ❤️

You can grab the proof-of-concept implementation of SwiftCI from [GitHub](https://github.com/BinaryBirds/CI). After [installing](https://www.mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html) it you can create your own `CI.swift` files and run your workflows.

```swift
import CI

let buildWorkflow = Workflow(
    name: "default",
    tasks: [
        Task(name: "HelloWorld",
             url: "git@github.com:BinaryBirds/HelloWorld.git",
             version: "1.0.0",
             inputs: [:]),

        Task(name: "OutputGenerator",
             url: "~/ci/Tasks/OutputGenerator",
             version: "1.0.0",
             inputs: [:]),

        Task(name: "SampleTask",
             url: "git@github.com:BinaryBirds/SampleTask.git",
             version: "1.0.1",
             inputs: ["task-input-parameter": "Hello SampleTask!"]),
    ])

let testWorkflow = Workflow(
    name: "linux",
    tasks: [
        Task(name: "SampleTask",
             url: "https://github.com/BinaryBirds/SampleTask.git",
             version: "1.0.0",
             inputs: ["task-input-parameter": "Hello SampleTask!"]),
        ])

let project = Project(name: "Example",
                      url: "git@github.com:BinaryBirds/Example.git",
                      workflows: [buildWorkflow, testWorkflow])
```

The code above is a sample from a `CI.swift` file, you can simply run any workflow with the swift CI run workflow-name command. Everything is 100% written in Swift, even the CI workflow descriptor file. I'm planning to extend my CI namespace with some helpful sub-commands later on. PR's are more than welcomed!

I'm very happy with the result, not just because of the [final product](https://github.com/BinaryBirds/CI) (that's only a proof of concept implementation), but mostly because of the things I've learned during the creation process.
