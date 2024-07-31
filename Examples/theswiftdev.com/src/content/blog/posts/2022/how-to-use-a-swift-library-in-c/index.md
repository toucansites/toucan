---
type: post
slug: how-to-use-a-swift-library-in-c
title: How to use a Swift library in C
description: In this tutorial, we're going to build a C app by importing a Swift library and talk a bit about the Swift / C Interoperability in general.
publication: 2022-02-23 16:20:00
tags: Swift, C
authors:
  - tibor-bodecs
---

## How to build a C compatible Swift library?

In order to create a Swift library that's going to work with C, we have to play around with [unsafe memory pointers](https://theswiftdev.com/unsafe-memory-pointers-in-swift/) to create a [C compatible interface](https://developer.apple.com/documentation/swift/swift_standard_library/c_interoperability). Fortunately I was able to find a nice example, which served me as a good starting point, on [the Swift forums](https://forums.swift.org/t/creating-a-c-accessible-shared-library-in-swift/45329/3) created by [Cory Benfield](https://x.com/Lukasaoz), so that's what we're going to use in this case. Thanks you. 🙏

```swift
final class MyType {
    var count: Int = 69
}

@_cdecl("mytype_create")
public func mytype_create() -> OpaquePointer {
    let type = MyType()
    let retained = Unmanaged.passRetained(type).toOpaque()
    return OpaquePointer(retained)
}

@_cdecl("mytype_get_count")
public func mytype_get_count(_ type: OpaquePointer) -> CInt {
    let type = Unmanaged<MyType>.fromOpaque(UnsafeRawPointer(type)).takeUnretainedValue()
    return CInt(type.count)
}

@_cdecl("mytype_destroy")
public func mytype_destroy(_ type: OpaquePointer) {
    _ = Unmanaged<MyType>.fromOpaque(UnsafeRawPointer(type)).takeRetainedValue()
}
```

The good news is that we don't necessary have to create a separate header file for our interfaces, but the Swift compiler can generate it for us if we provide the `-emit-objc-header` flag.

I have an article about [the swiftc command for beginners](https://theswiftdev.com/the-swift-compiler-for-beginners/) and I also wrote some things about [the Swift compiler](https://theswiftdev.com/building-static-and-dynamic-swift-libraries-using-the-swift-compiler/), where I talk about the available flags. This time we're going to use the `-module-name` option to specify our module name, we're going to generate the required files using the `-emit-dependencies` flag, parse the source files as a library (`-parse-as-library`), since we'd like to generate a Swift library provide the necessary target and version information and emit a header file.

```sh
# macOS
swiftc \
        -module-name mytype \
        -emit-dependencies \
        -parse-as-library \
        -c mytype.swift \
        -target arm64-apple-macosx12.0 \
        -swift-version 5 \
        -emit-objc-header \
        -emit-objc-header-path mytype.h

# Linux (without the target option)
swiftc \
    -module-name mytype \
    -emit-dependencies \
    -parse-as-library \
    -c mytype.swift \
    -swift-version 5 \
    -emit-objc-header \
    -emit-objc-header-path mytype.h
```

This should generate a `mytype.h` and a `mytype.o` file plus some additional Swift module related output files. We're going to use these files to [build](https://blog.spencerkohan.com/building-swift-without-a-build-system/) our final executable, but there are a few more additional things I'd like to mention.

Under Linux the header file won't work. It contains a line #include Foundation/Foundation.h and of course there is no such header file for Linux. It is possible to install the [GNUstep package](http://www.gnustep.org/) (e.g. via yum: `sudo yum install gnustep-base gnustep-base-devel gcc-objc`, but for me the [clang](https://clang.llvm.org/) command still complained about the location of the `objc.h` file. Anyway, I just removed the include Foundation statement from the header file and I was good to go. 😅

The second thing I'd like to mention is that if you want to export a class for Swift, that's going to be a bit harder, because classes won't be included in the generated header file. You have two options in this case. The first one is to turn them into Objective-C classes, but this will lead to problems when using Linux, anyway, this is how you can do it:

```swift
import Foundation

@objc public final class MyType: NSObject {
    public var count: Int = 69
}
```

I prefer the second option, when you don't change the Swift file, but you create a separate header file and define your object type as a struct with a custom type (`mytype_struct.h`).

```c
typedef struct mytype mytype_t;
```

We're going to need this type (with the corresponding header file), because the `mytype_create` function returns a pointer that we can use to call the other `mytype_get_count` method. 🤔

Compiling C sources using Swift libraries
So how do we use these exposed Swift objects in C? In the C programming language you just have to import the headers and then voilá you can use everything defined in those headers.

```c
#include <stdio.h>
#include "mytype.h"

int main() {
    mytype_t *item = mytype_create();

    int i = mytype_get_count(item);
 
    printf("Hello, World! %d\n", i);

    return 0;
}
```

We can use clang to compile the main.c file into an object file using the necessary header files.

```sh
# macOS
clang -x objective-c -include mytype.h -include mytype_struct.h -c main.c

# Linux
clang -include mytype.h -include mytype_struct.h -c main.c
```

This command will build a main.o file, which we can use to create the final executable. 💪

## Linking the final executable

This was the hardest part to figure out, but I was able to link the two object files together after a few hours of struggling with the [ld command and other framework tools](https://theswiftdev.com/deep-dive-into-swift-frameworks/) I decided to give it up and let swiftc take care of the job, since it can build and link both C and Swift-based executables.

We're going to need a list of the object files that we're going to link together.

```sh
ls *.o > LinkFileList
```

Then we can call `swiftc` to do the job for us. I suppose it'll invoke the `ld` command under the hood, but I'm not a linker expert, so if you know more about this, feel free to reach out and [provide me more info](https://x.com/tiborbodecs) about the process. I have to read [this book](https://www.amazon.com/Linkers-Kaufmann-Software-Engineering-Programming/dp/1558604960) for sure. 📚

```sh
# macOS
swiftc \
        -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.1.sdk \
        -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks \
        -I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib \
        -L /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib \
        -L /Users/tib/swiftfromc/ \
        -module-name Example \
        -emit-executable \
        -Xlinker -rpath \
        -Xlinker @loader_path @/Users/tib/swiftfromc/LinkFileList \
        -Xlinker -rpath \
        -Xlinker /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
        -Xlinker -rpath \
        -Xlinker /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.5/macosx \
        -target arm64-apple-macosx12.1 \
        -Xlinker -add_ast_path \
        -Xlinker /Users/tib/swiftfromc/mytype.swiftmodule \
        -L /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib

# Linux
swiftc \
    -L /home/ec2-user/swiftfromc \
    -module-name Example \
    -emit-executable \
    -Xlinker -rpath \
    -Xlinker @loader_path @/home/ec2-user/swiftfromc/LinkFileList
```

The command above will produce the final linked executable file that you can run by using the `./Example` snippet and hopefully you'll see the "Hello, World! 69" message. 🙈

If you want to know more about the [rpath linker flag](https://blog.krzyzanowskim.com/2018/12/05/rpath-what/), I highly recommend reading the article by [Marcin Krzyzanowski](https://x.com/krzyzanowskim). If you want to read more about Swift / Objective-C interoperability and using the swiftc command, you should check out [this article](https://rderik.com/blog/understanding-objective-c-and-swift-interoperability/) by [RDerik](https://x.com/rderik). Finally if you want to call C code from Swift and go the other way, you should take a look at [my other blog post](https://theswiftdev.com/how-to-call-c-code-from-swift/).

