---
slug: the-swift-compiler-for-beginners
title: The Swift compiler for beginners
description: Learn how to build executable files using the swiftc command, meet the build pipeline, compilers and linkers under the hood.
publication: 2021-02-10 16:20:00
tags: Swift, compiler
---

## Compiling Swift source files

The most basic scenario is when you want to build and run a single Swift file. Let's create a `main.swift` file somewhere on your disk and print out a simple "Hello world!" text.

```swift
print("Hello world!")
```

We don't even need to import the Foundation framework, Swift has quite a lot built-in language functions and the print function is part of the [Swift standard library](https://swift.org/standard-library/#standard-library-preview-package).

The [standard library](https://developer.apple.com/documentation/swift/swift_standard_library) provides a "base layer" of functionality for writing Swift applications, on the other hand the Foundation framework gives you OS independent extra functions, core utilities (file management, localization, etc.) and more.

So, how do we turn our print function into an executable file that we can run? The [Swift compiler](https://swift.org/swift-compiler/) (`swiftc` command) can compile (translate human readable code into machine code) Swift source files into binary executable files that you can run. 🔨

```sh
# compile the `main.swift` source file into a `main` binary file
swiftc main.swift 

# run the `main` executable, prints "Hello world!"
./main
```

This is the most basic example, you can also specify the name of the output file by using the `-o` parameter. Of course this is an optional parameter, by default the compiler will use the basename of the Swift source that you are trying to build, that's why we were able to run the executable with the `./main` command in the previous example.

```sh
swiftc main.swift -o hello
./hello
```

There are lots of other flags and arguments that you can use to control the compilation process, you can check the available options with the `-h` or `--help` flag.

```sh
swiftc -h
```

Don't worry you don't have to understand any of those, we'll cover some of the compiler flags in this tutorial, others in a more advanced article. 😉

## Swift compiler flags

Sometimes you might want to create custom flags and compile parts of your code if that flag is present. The most common one is the `DEBUG` flag. You can define all kinds of compiler flags through the `-D` argument, here's a quick `main.swift` example file.

```swift
#if(DEBUG)
    print("debug mode")
#endif
print("Hello world!")
```

Now if you run the `swiftc` command it will only print "Hello world!" again, but if we add a new special parameter.

```sh
swiftc main.swift -D DEBUG
./main

# or we can run this as a one-liner
swiftc main.swift -D DEBUG && ./main
```

This time the "debug mode" text will be also printed out. Swift compiler flags can only be present or absent, but you can also use other flags to change source compilation behavior. 🐞

## Mutliple Swift sources

What happens if you have multiple Swift source files and you want to compile them to a single binary? Let me show you an example real quick. Consider the following `point.swift` file:

```swift
struct Point {
    let x: Int
    let y: Int
}
```

Now in the main.swift file, you can actually use this newly defined Point struct. Please note that these files are both located under the same namespace, so you don't have to use the import keyword, you can use the struct right away, it's an internal object.

```swift
#if(DEBUG)
    print("debug mode")
#endif
let p = Point(x: 4, y: 20)

print("Hello world!", p.x, p.y)
```

We can compile multiple sources by simply listing them one after other when using the `swiftc` command, the order of the files doesn't matter, the compiler is smart enough, so it can figure out the object dependencies between the listed sources.

```sh
swiftc point.swift main.swift -o point-app
# prints: Hello world! 4 20
./point-app
```

You can also use the find command to list all the Swift sources in a given directory (even with a maximum search depth), and pass the output to the `swiftc` command. 🔍

```sh
swiftc `find . -name "*.swift" -maxdepth 1` -o app-name

# alternatively
find . -name "*.swift" -maxdepth 1 | xargs swiftc -o app-name
```

The `xargs` command is also handy, if you don't like to evaluate shell commands through the backtick syntax (`\``) you can use it to pass one command output to another as an argument.

## Under the hood of swiftc

I just mentioned that the compiler is smart enough to figure out object dependencies, but how does swiftc actually works? Well, we can see the executed low-level instructions if we compile our source files using the verbose -v flag. Let's do so and examine the output.

```sh
swiftc -D DEBUG point.swift main.swift -o point-app

# swiftc -v -D DEBUG point.swift main.swift -o point-app && ./point-app
# Apple Swift version 5.3.2 (swiftlang-1200.0.45 clang-1200.0.32.28)
# Target: arm64-apple-darwin20.3.0

# /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift \
#   -frontend \
#   -c \
#   -primary-file point.swift main.swift \
#   -target arm64-apple-darwin20.3.0 \
#   -Xllvm -aarch64-use-tbi \
#   -enable-objc-interop \
#   -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/#Developer/SDKs/MacOSX11.1.sdk \
#   -color-diagnostics \
#   -D DEBUG \
#   -target-sdk-version 11.1 \
#   -module-name main \
#   -o /var/folders/7d/m4wk_5195mvgt9sf8j8541n80000gn/T/point-99f33d.o

# /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift \
#   -frontend \
#   -c point.swift \
#   -primary-file main.swift \
#   -target arm64-apple-darwin20.3.0 \
#   -Xllvm -aarch64-use-tbi \
#   -enable-objc-interop \
#   -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk \
#   -color-diagnostics \
#   -D DEBUG \
#   -target-sdk-version 11.1 \
#   -module-name main \
#   -o /var/folders/7d/m4wk_5195mvgt9sf8j8541n80000gn/T/main-e09eef.o

# /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld \
#   /var/folders/7d/m4wk_5195mvgt9sf8j8541n80000gn/T/point-99f33d.o \
#   /var/folders/7d/m4wk_5195mvgt9sf8j8541n80000gn/T/main-e09eef.o \
#   /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/clang/lib/darwin/libclang_rt.osx.a \
#   -syslibroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk \
#   -lobjc \
#   -lSystem \
#   -arch arm64 \
#   -L /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
#   -L /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk/usr/lib/swift \
#   -platform_version macos 11.0.0 11.1.0 \
#   -no_objc_category_merging \
#   -o point-app
```

You might think, this is a mess, I reformatted the output a bit, so we can walk through the steps of the Swift source compilation process.

When you compile a program code with multiple sources, each and every source needs to be converted to machine code (compiler), then those converted files needs to be put together (linker), this way we can get our final executable file. This entire process is called [build pipeline](https://www.bignerdranch.com/blog/manual-swift-understanding-the-swift-objective-c-build-pipeline/) and you should definitely read the linked article if you want to know more about it. 👍

The `swiftc` command calls the "real Swift compiler" (`swift -frontend`) to turn every single swift file into an object file (.o). Every command, function, (class, object etc.) that you write when you create a Swift file needs to be resolved. This is because your machine needs to look up the actual implementation of the components in your codebase. For example when you call the print("Hello world!") line, the print function needs to be resolved to an actual system call, the function itself is located somewhere inside an SDK that is usually shipped with your operating system.

Where exactly? For the compiler, it doesn't matter. The Software Development Kit (SDK) usually contains interfaces (header files or module maps) for specific functionalities. The compiler only needs the interface to build byte code from source files, the compiler doesn't cares about the implementation details. The compiler trusts the interface and builds intermediate object files for a given platform using the flags and other parameters that we don't care about for now. 🙃

This is what happens in the first two section. The swift command turns the point.swift file into a temporary point.o file, then it does the exact same thing with the main.swift file. If you take a closer look, apart from the long paths, it's a pretty simple command with just a few arguments:

```sh
swift \
   -frontend \
   -c point.swift \
   -primary-file main.swift \
   -target arm64-apple-darwin20.3.0 \
   -Xllvm -aarch64-use-tbi \
   -enable-objc-interop \
   -sdk MacOSX11.1.sdk \
   -color-diagnostics \
   -D DEBUG \
   -target-sdk-version 11.1 \
   -module-name main \
   -o main.o
```

As you can see we just tell Swift to turn our primary input file into an intermediate output file. Of course the whole story is way more complicated involving the [LLVM compiler infrastructure](https://llvm.org/), there is a great article about [a brief overview of the Swift compiler](https://medium.com/xcblog/a-brief-overview-of-swift-compiler-7af0bd684718), that you should read if you want more details about the phases and tools, such as the parser, analyzer etc. 🤔

> NOTE: Compilers are complicated, for now it's more than enough if you take away this one simple thing about the Swift compiler: it turns your source files into intermediate object files.

Before we could run our final program code, those temporary object files needs to be combined together into a single executable. This is what linkers can do, they verify object files and resolve underlying dependencies by linking together various dependencies.

Dependencies can be linked together in a static or dynamic way. For now lets just stay that static linking means that we literally copy & paste code into the final binary file, on the other hand dynamic linking means that libraries will be resolved at runtime. I have a pretty detailed article about [Swift frameworks and related command line tools](https://theswiftdev.com/deep-dive-into-swift-frameworks/) that you can use to examine them.

In our case the linker command is `ld` and we feed it with our object files.

```sh
ld \
    point.o \
    main.o \
    libclang_rt.osx.a \
   -syslibroot MacOSX11.1.sdk \
   -lobjc \
   -lSystem \
   -arch arm64 \
   -L /usr/lib/swift/macosx \
   -L /MacOSX11.1.sdk/usr/lib/swift \
   -platform_version macos 11.0.0 11.1.0 \
   -no_objc_category_merging \
   -o point-app
```

I know, there are plenty of unknown flags involved here as well, but in 99% of the cases you don't have to directly interact with these things. This whole article is all about trying to understand the "dark magic" that produces games, apps and all sort of fun things for our computers, phones and other type of gadgets. These core components makes possible to build amazing software. ❤️

> NOTE: Just remember this about the linker (`ld` command): it will use the object files (prepared by the compiler) and it'll create the final product (library or executable) by combining every resource (object files and related libraries) together.

It can be real hard to understand these things at first sight, and you can live without them, build great programs without ever touching the compiler or the linker. Why bother? Well, I'm not saying that you'll become a better developer if you start with the basics, but you can extend your knowledge with something that you use on a daily basis as a computer programmer. 💡
