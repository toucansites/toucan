---
type: post
slug: how-to-call-c-code-from-swift
title: How to call C code from Swift
description: Interacting with C libraries from the Swift language is really amazing, from this post can learn the most of C interoperability.
publication: 2018-01-15 16:20:00
tags: Swift, C, libraries, frameworks
authors:
  - tibor-bodecs
---

> WARN: From Swift 4 there is native support for [wrapping C libraries in Swift](https://www.hackingwithswift.com/articles/87/how-to-wrap-a-c-library-in-swift) system module packages. This means that you can easily ship your own system modules, you just have to learn [how to use the Swift Package Manager](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/).😅

## Bridging header inside Xcode

Let's fire up Xcode and start a brand new single view app iOS project. Fill out the required fields, and of course choose the Swift language. Next, add a new file and choose the [C file](https://developer.apple.com/documentation/swift/c_interoperability) template.

After you enter the name and check the also create header file box, Xcode will ask you about the Objective-C bridging header file. Just create it. The name of this file is tricky, because it also supports other [C family](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html) languages, like [pure C](https://dzone.com/articles/using-a-c-library-in-swift) or C++, [Objective-C](http://ankit.im/swift/2016/05/21/creating-objc-cpp-packages-with-swift-package-manager/) and plus-plus. 😉

Let's create a public header for the [C code](https://www.sitepoint.com/using-legacy-c-apis-swift/) (`factorial.h`):

```
#ifndef factorial_h
#define factorial_h

#include <stdio.h>

long factorial(int n);

#endif /* factorial_h */
```

This is gona be the implementation of the method (`factorial.c`):

```
#include "factorial.h"

long factorial(int n) {
    if (n == 0 || n == 1) return 1;
    return n * factorial(n-1);
}
```

Inside the bridging header, simply import the C header file:

```
#include "factorial.h"
```

Somewhere inside a Swift file you can use the factorial method:

```
print("Hello \(factorial(5))!")
// it actually prints out "Hello 120!" ;)
```

Compile and run. 🔨 It just works. 🌟 Magic! 🌟

You can do the exact same thing to use Objective-C classes inside your Swift projects. Apple has great docs about this technique, you should read that if you want to know more about [mix and match](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

## Shipping C code with SPM

The real fun begins when you start using the Swift Package Manager to build [C family based sources](https://spin.atomicobject.com/2015/02/23/c-libraries-swift/). From Swift 3.0 you can [build C language targets with SPM](https://github.com/apple/swift-evolution/blob/master/proposals/0038-swiftpm-c-language-targets.md). If you don't know how to use the SPM tool, you should read my [comprehensive tutorial about the Swift Package Manager](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/) first.

The only thing that you'll need to do this is a proper directory structure (plus you'll need the package description file), and the package manager will take care all the rest. Here is everything what you need to build the factorial example with SPM.

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "cfactorial",
    products: [
        .library(name: "cfactorial", targets: ["cfactorial"]),
    ],
    targets: [
        .target(
            name: "cfactorial",
            path: "./Sources/factorial"
        ),
    ]
)
```

The directory structure should be something like this.

```
Sources
    factorial
        include
            factorial.h
        factorial.c
```

You should also change the `#include "factorial.h"` line inside the `factorial.c` file to `#include "include/factorial.h"` because we made a new include directory. This is NOT necessary, but if you don't put your umbrella header into the include directory, you'll need to provide a `modulemap` file, and provide the correct location of your header. If you use the include structure SPM will generate everything for you.

With this technique you can import your `cfactorial` module from any other Swift package and call the factorial method, like we did through Xcode. You just have to add this module as a dependency, oh by the way you can even call this module from another [C project made with SPM](https://medium.com/@Aciid/ship-c-code-with-swift-packages-using-swift-package-manager-44edcc702a45#.ucx9oa9hs)! 💥

```swift
.package(url: "https://gitlab.com/theswiftdev/cfactorial", .branch("master")),
```

Congratulations, you just shipped your first C code with Swift Package Manager. This setup also works with C, C++, Objective-C, Objective-C++ code.

## Wrapping C [system] modules with SPM

If you want to [wrap](http://www.bensnider.com/wrapping-c-code-within-a-single-swift-package.html) a C [system] [library](https://oleb.net/blog/2017/12/importing-c-library-into-swift/) and call it directly from Swift you can crete a brand new wrapper package with the help of the Swift Package Manager. To start you can use the `swift package init --type system-module` command, this will create a generic template project.

These are special packages according to [Apple](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#require-system-libraries), you just have to ship your own `modulemap` and a header file to expose the needed APIs, but first - obviously - you'll need the usual package definition file:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ccurl",
    providers: [
        .brew(["curl"]),
        .apt(["libcurl4-openssl-dev"])
    ]
)
```

Inside the Package.swift file you can set the providers for the library (like brew on macOS or aptitude for Ubuntu / Debian and the others). Here is a good advice for you: `sudo apt-get install pkg-config` under Linux to make things work, because the system will search for package header files with the help of the [pkgConfig](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#pkgconfig) property. For example if you want to use `libxml2` and `pkg-config` is not installed, you won't be able to [compile](http://ankit.im/swift/2016/04/06/compiling-and-interpolating-C-using-swift-package-manager/) / [use](https://stackoverflow.com/questions/36570497/compile-c-code-and-expose-it-to-swift-under-linux) your system module.

Next you'll need a `module.modulemap` file, which is pretty straightforward.

```
module ccurl [system] {
    header "shim.h"
    link "curl"
    export *
}
```

> About the link property see the [Xcode release notes](https://developer.apple.com/library/content/releasenotes/DeveloperTools/RN-Xcode/Chapters/Introduction.html) search for "auto-linking"

Finally add an extra shim.h header file to import all the required APIs. Usually I don't like to import directly the required header files from the `modulemap` file that's why I am using this `shim.h` - name it like you want - you'll see in a second why am I preferring this method, but here is a basic one.

```
#ifndef CLIB_SWIFT_CURL
#define CLIB_SWIFT_CURL

#import <curl/curl.h>;

#endif
```

Let's talk about why I like importing the shim file. If you have platform differences you can use a neat trick with the help of using macros, for example you can import header files from different locations if you check for the `__APPLE__` platform macro.

```
#ifndef CLIB_SWIFT_EXAMPLE
#define CLIB_SWIFT_EXAMPLE

#ifdef __APPLE__
    #include "/usr/local/include/example.h"
#else
    #include "/usr/include/example.h"
#endif

#endif
```

Cool, huh? 🍎 + 🔨 = ❤️
