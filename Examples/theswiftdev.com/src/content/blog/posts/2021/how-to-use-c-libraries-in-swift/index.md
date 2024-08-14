---
type: post
title: How to use C libraries in Swift?
description: Learn how to use system libraries and call C code from Swift. Interoperability between the Swift language and C for beginners.
publication: 2021-03-05 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Building a custom C library using SPM

You can use the Swift Package Manager to create C family based source files (C, C++, Objective-C and Objective-C++) and ship them as standalone components. If you don't know much about the Swift Package Manager, you should read my comprehensive [tutorial about how SPM works](https://theswiftdev.com/swift-package-manager-tutorial/). 📦

The only thing that you need to setup a library is a standard `Package.swift` manifest file with a slightly altered directory structure to support header files. Let's make a `MyPoint` library.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyPoint",
    products: [
        .library(name: "MyPoint", targets: ["MyPoint"]),
    ],
    targets: [
        .target(name: "MyPoint"),
    ]
)
```

Everything that you put into the header file will be publicly available for other developers to use, the implementation details are going to be located directly under the `Sources/[target]/` directory, but you have to create an additional `include` folder for your headers. Let's make a `MyPoint.h` file under the `Sources/MyPoint/include` path with the following contents.

```c
struct MyPoint {
   int x;
   int y;
};
```

We've just defined the public interface for our library. Now if you try to compile it through the swift build command, it'll complain that the project is missing some source files. We can easily fix this by creating an empty `MyPoint.c` file under the `Sources/MyPoint` directory.

When you import a local header file to use in your implementation code, you can skip the "include" path and simply write #include "MyPoint.h". You could also put all kinds of C family components into this project, this method works with C++, Objective-C and even Objective-C++ files.

> NOTE: You could also place header files next to the implementation source code, but in that case the system won't be able to auto-locate your public (umbrella) header files, so you also have to create a `modulemap` file and provide the correct location of your headers explicitly. If you use the structure with the include directory SPM will generate everything for you automatically.

Congratulations, you just shipped your first C code with Swift Package Manager. 🥳

## Interacting with C libraries using Swift

We're going to create a brand new Swift package to build an executable application based on the previously created C library. In order to use a local package you can simply specify it as with the path argument under the dependencies in your `Package.swift` manifest file.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Sample",
    products: [
        .executable(name: "Sample", targets: ["Sample"]),
    ],
    dependencies: [
        .package(path: "../MyPoint")
    ],
    targets: [
        .target(name: "Sample", dependencies: [
            .product(name: "MyPoint", package: "MyPoint"),
        ]),
    ]
)
```

This time we are going to use the MyPoint library as a local dependency, but of course you can manage and publish your own libraries using a git repository somewhere in the cloud. Next we should create our `Sources/Sample/main.swift` file, import the library and write some code.

```swift
import MyPoint

let p = MyPoint(x: 4, y: 20)
print("Hello, world!", p.x, p.y)
```

If both packages are available locally, make sure you place them next to each other, then everything should work like a charm. You can open the Sample project manifest file using Xcode as well, the IDE can resolve package dependencies automatically for you, but if you prefer the command line, you can use the `swift run` command to compile & run the executable target.

With this technique you can import the MyPoint module from any other Swift package and use the available public components from it. You just have to add this module as a dependency, by the way you can even call this module from another C (C++, ObjC, Objc++) project made with SPM. 😎

## How to use C system libraries from Swift?

There are thousands of available tools that you can install on your operating system (Linux, macOS) with a package manager (apt, brew). For example there is the famous [curl](https://curl.se/) command line tool and library, that can be used for transferring data from or to a server. In other words, you can make HTTP requests with it, just type `curl "https://www.apple.com/"` into a terminal window.

These system components are usually built around libraries. In our case curl comes with [libcurl](https://curl.se/libcurl/), the multiprotocol file transfer library. Sometimes you might want to use these low level components (usually written in C) in your application, but how do we add them as a dependency? 🤔

The answer is simple, we can define a new systemLibrary target in our package manifest file.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Sample",
    products: [
        .executable(name: "Sample", targets: ["Sample"]),
    ],
    dependencies: [
        .package(path: "../MyPoint")
    ],
    targets: [

        .systemLibrary(
            name: "libcurl",
            providers: [
                .apt(["libcurl4-openssl-dev"]),
                .brew(["curl"])
            ]
        ),

        .target(name: "Sample", dependencies: [
            .product(name: "MyPoint", package: "MyPoint"),
            .target(name: "libcurl"),
        ]),
    ]
)
```

Inside the `Package.swift` file you can set the providers for the library (such as brew for macOS or aptitude for many Linux distributions). Unfortunately you still have to manually install these packages, because SPM won't do this for you, think of it as "just a reminder" for now... 😅

This will allow us to create a custom modulemap file with additional headers (regular or umbrella) and linker flags inside our project folder. First, we should add the following modulemap definition to the `Sources/libcurl/module.modulemap` file. Please create the `libcurl` directory, if needed.

```
module libcurl [system] {
    header "libcurl.h"
    link "curl"
    export *
}
```

The concept of [modules are coming from (clang) LLVM](https://clang.llvm.org/docs/Modules.html#introduction), I highly recommend checking the linked article if you want to know more about modulemaps. This way we tell the compiler that we want to build a module based on the curl library, hence we link curl. We also want to provide our custom header file to make some additional stuff available or more convenient. People usually call these header files shims, umbrella headers or bridging headers.

An [umberlla header](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/IncludingFrameworks.html) is the main header file for a framework or library. A [bridging header](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift) allows us to use two languages in the same application. The [shim header](https://oleb.net/blog/2017/12/importing-c-library-into-swift/) works around the limitation that module maps must contain absolute or local paths. They all exposes APIs from a library or language to another, they are very similar, but they are not the same concept. 🙄

In our case we're going to create a `libcurl.h` header file inside the `Sources/libcurl` folder. The module map simply refers to this header file. Here's what we're going to place inside of it.

```c
#include <stdbool.h>
#include <curl/curl.h>

typedef size_t (*curl_func)(void * ptr, size_t size, size_t num, void * ud);

CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
    return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_func(CURL *handle, CURLoption option, curl_func param) {
    return curl_easy_setopt(handle, option, param);
}

CURLcode curl_easy_setopt_pointer(CURL *handle, CURLoption option, void* param) {
    return curl_easy_setopt(handle, option, param);
}
```

This code comes from the archived [SoTS/CCurl](https://github.com/SwiftOnTheServer/CCurl) repository, but if you check the shim file inside the [Kitura/CCurl](https://github.com/Kitura/CCurl) package, you'll find a pretty much similar approach with even more convenient helpers.

The main reason why we need these functions is that variadic functions can't be imported by Swift (yet), so we have to wrap the `curl_easy_setopt` calls, so we'll be able to use it from Swift.

Ok, let me show you how to write a low-level curl call using the `libcurl` & Swift.

```swift
import Foundation
import MyPoint
import libcurl

class Response {
    var data = Data()

    var body: String { String(data: data, encoding: .ascii)! }
}

var response = Response()

let handle = curl_easy_init()
curl_easy_setopt_string(handle, CURLOPT_URL, "http://www.google.com")

let pointerResult = curl_easy_setopt_pointer(handle, CURLOPT_WRITEDATA, &response)
guard pointerResult == CURLE_OK else {
    fatalError("Could not set response pointer")
}
curl_easy_setopt_func(handle, CURLOPT_WRITEFUNCTION) { buffer, size, n, reference in
    let length = size * n
    let data = buffer!.assumingMemoryBound(to: UInt8.self)
    let p = reference?.assumingMemoryBound(to: Response.self).pointee
    p?.data.append(data, count: length)
    return length
}

let ret = curl_easy_perform(handle)
guard ret == CURLE_OK else {
//    let error = curl_easy_strerror(ret)
//    print("error: ", error)
    fatalError("Something went wrong with the request")
}
curl_easy_cleanup(handle)

print(response.body)
```

I know, I know. This looks terrible for the first sight, but unfortunately [C interoperability](https://developer.apple.com/documentation/swift/swift_standard_library/c_interoperability) is all about dealing with pointers, unfamiliar types and memory addresses. Anyway, here's what happens in the code snippet. First we have to define a response object that can hold the data coming from the server as a response. Next we call the system functions from the curl library to create a handle and set the options on it. We simply provide the request URL as a string, we pass the result pointer and a write function that can append the incoming data to the storage when something arrives from the server. Finally we perform the request, check for errors and cleanup the handle.

It is not so bad, but still it looks nothing like you'd expect from Swift. It's just a basic example I hope it'll help you to understand what's going on under the hood and how low level C-like APIs can work in Swift. If you want to practice you should try to take a look at the [Kanna](https://github.com/tid-kijyun/Kanna) library and parse the response using a custom [libxml2](http://www.xmlsoft.org/html/index.html) wrapper (or you can read about a [SQLite3](https://rderik.com/blog/making-a-c-library-available-in-swift-using-the-swift-package/) wrapper). 🤓

The [system library target](https://github.com/apple/swift-evolution/blob/main/proposals/0208-package-manager-system-library-targets.md) feature is a nice way of wrapping C [system] modules with SPM. You can read more about it on the [official Swift forums](https://forums.swift.org/t/system-target-library-how-to-use-them/18196/4). If you are still using the old system library package type format, please migrate, since it's deprecated and it'll be completely removed later on.
