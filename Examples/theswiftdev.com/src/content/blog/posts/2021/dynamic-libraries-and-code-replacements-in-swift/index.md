---
type: post
title: Dynamic libraries and code replacements in Swift
description: How to load a dynamic library and use native method swizzling in Swift? This article is all about the magic behind SwiftUI previews.
publication: 2021-05-20 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Dynamic library packages

I've already published an article about [building static and dynamic libraries using the Swift compiler](https://theswiftdev.com/building-static-and-dynamic-swift-libraries-using-the-swift-compiler/), if you don't know what is a dynamic library or you are simply interested a bit more about how the Swift compiler works, you should definitely take a look at that post first.

This time we're going to focus a bit more on utilizing the Swift Package Manager to create our dynamic library products. The setup is going to be very similar to the one I've created in the [loading dynamic libraries at runtime](https://theswiftdev.com/building-and-loading-dynamic-libraries-at-runtime-in-swift/) article. First we're going to create a shared library using SPM.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TextUI",
    products: [
        .library(name: "TextUI", type: .dynamic, targets: ["TextUI"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "TextUI", swiftSettings: [
            .unsafeFlags(["-emit-module", "-emit-library"])
        ]),
    ]
)
```

The package manifest is quite simple, although there are a few special things that we had to add. The very first thing is that we defined the product type as a dynamic library. This will ensure that the right .dylib (or .so / .dll) binary will be created when you build the target. 🎯

The second thing is that we'd like to emit our Swift module info alongside the library, we can tell this to the compiler through some unsafe flags. Don't be afraid, these are actually not so dangerous to use, these flags will be directly passed to the Swift compiler, but that's it.

Now the source code for our TextUI library is going to be very simple.

```swift
public struct TextUI {

    public static dynamic func build() -> String {
        "Hello, World!"
    }
}
```

It's just a struct with one static function that returns a String value. Pretty simple, except one thing: the dynamic keyword. By adding the dynamic modifier to a function (or method) you tell the compiler that it should use dynamic dispatch to "resolve" the implementation when calling it.

We're going to take advantage of the dynamic dispatch later on, but before we could move onto that part, we have to build our dynamic library and make it available for others to use. 🔨

If you run swift build (or run the project via Xcode) it'll build all the required files and place them under the proper build folder. You can also print the build folder by running the `swift build -c release --show-bin-path` (`-c` release is for release builds, we're going to build the library using the release configuration for obvious reasons... we're releasing them). If you list the contents of the output directory, you should find the following files there:

- TextUI.swiftdoc
- TextUI.swiftmodule
- TextUI.swiftsourceinfo
- libTextUI.dylib
- libTextUI.dylib.dSYM

So, what can we do with this build folder and the output files? We're going to need them under a location where the build tools can access the related files, for the sake of simplicity we're going to put everything into the `/usr/local/lib` folder using a Makefile.

```
PRODUCT_NAME := "TextUI"
DEST_DIR := "/usr/local/lib/"
BUILD_DIR := $(shell swift build -c release --show-bin-path)

install: clean
    @swift build -c release
    @install "$(BUILD_DIR)/lib$(PRODUCT_NAME).dylib" $(DEST_DIR)
    @cp -R "$(BUILD_DIR)/lib$(PRODUCT_NAME).dylib.dSYM" $(DEST_DIR)
    @install "$(BUILD_DIR)/$(PRODUCT_NAME).swiftdoc" $(DEST_DIR)
    @install "$(BUILD_DIR)/$(PRODUCT_NAME).swiftmodule" $(DEST_DIR)
    @install "$(BUILD_DIR)/$(PRODUCT_NAME).swiftsourceinfo" $(DEST_DIR)
    @rm ./lib$(PRODUCT_NAME).dylib
    @rm -r ./lib$(PRODUCT_NAME).dylib.dSYM

uninstall: clean
    
    @rm $(DEST_DIR)lib$(PRODUCT_NAME).dylib
    @rm -r $(DEST_DIR)lib$(PRODUCT_NAME).dylib.dSYM
    @rm $(DEST_DIR)$(PRODUCT_NAME).swiftdoc
    @rm $(DEST_DIR)$(PRODUCT_NAME).swiftmodule
    @rm $(DEST_DIR)$(PRODUCT_NAME).swiftsourceinfo

clean:
    @swift package clean
```

Now if you run `make` or `make install` all the required files will be placed under the right location. Our dynamic library package is now ready to use. The only question is how do we consume this shared binary library using another Swift Package target? 🤔

## Linking against shared libraries

We're going to build a brand new executable application called TextApp using the Swift Package Manager. This package will use our previously created and installed shared dynamic library.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TextApp",
    targets: [
        .target(name: "TextApp", swiftSettings: [
            .unsafeFlags(["-L", "/usr/local/lib/"]),
            .unsafeFlags(["-I", "/usr/local/lib/"]),
            .unsafeFlags(["-lTextUI"]),
        ], linkerSettings: [
            .unsafeFlags(["-L", "/usr/local/lib/"]),
            .unsafeFlags(["-I", "/usr/local/lib/"]),
            .unsafeFlags(["-lTextUI"]),
        ]),
    ]
)
```

The trick is that we can add some flags to the Swift compiler and the linker, so they'll know that we've prepared some special library and header (`modulemap`) files under the `/usr/local/lib/` folder. We'd also like to link the `TextUI` framework with our application, in order to do this we have to pass the name of the module as a flag. I've already explained these flags (`-L`, `-I`, `-l`) in my previous posts so I suppose you're familiar with them, if not please read the linked articles. 🤓

```swift
import TextUI

print(TextUI.build())
```

Our `main.swift` file is pretty straightforward, we just print the result of the build method, the default implementation should return the famous "Hello, World!" text.

Are you ready to replace the build function using native method swizzling in Swift?

## Dynamic method replacement

After publishing my original [plugin system related article](https://theswiftdev.com/building-and-loading-dynamic-libraries-at-runtime-in-swift/), I've got an email from one of my readers. First of all thank you for letting me know about the `@_dynamicReplacement` attribute Corey. 🙏

The thing is that Swift supports dynamic method swizzling out of the box, although it is through a private attribute (starts with an underscore), which means it is not ready for public use yet (yeah... just like `@_exported`, `@_functionBuilder` and the others), but eventually it will be finalized.

You can read the original [dynamic method replacement pitch](https://forums.swift.org/t/dynamic-method-replacement/16619) on the Swift forums, there's also this [great little snippet](https://gist.github.com/alemar11/d2ed3a90dd437267b156f8f33996e8af) that contains a minimal showcase about the `@_dynamicReplacement` attribute.

Long story short, you can use this attribute to override a custom dynamic method with your own implementation (even if it comes from a dynamically loaded library). In our case we've already prepared a dynamic build method, so if we try we can override that the following snippet.

```swift
import TextUI

extension TextUI {

    @_dynamicReplacement(for: build())
    static func _customBuild() -> String {
        "It just works."
    }
}

print(TextUI.build()) // It just works.
```

If you alter the `main.swift` file and run the project you should see that even we're calling the build method, it is going to be dispatched dynamically and our `_customBuild()` method will be called under the hood, hence the new return value.

It works like a charm, but can we make this even more dynamic? Is it possible to build one more dynamic library and load that at runtime, then replace the original build implementation with the dynamically loaded lib code? The answer is yes, let me show you how to do this. 🤩

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TextView",
    products: [
        .library(name: "TextView", type: .dynamic, targets: ["TextView"]),
    ],
    targets: [
        .target(name: "TextView", swiftSettings: [
            .unsafeFlags(["-L", "/usr/local/lib/"]),
            .unsafeFlags(["-I", "/usr/local/lib/"]),
            .unsafeFlags(["-lTextUI"]),
        ], linkerSettings: [
            .unsafeFlags(["-L", "/usr/local/lib/"]),
            .unsafeFlags(["-I", "/usr/local/lib/"]),
            .unsafeFlags(["-lTextUI"]),
        ]),
    ]
)
```

Same SPM pattern, we've just created a dynamic library and we've used the TextUI as a shared library so we can place our TextUI extension into this library instead of the TextApp target.

So far we've created 3 separated Swift packages shared the `TextUI` module between the TextApp and the TextView packages as a pre-built dynamic library (using unsafe build flags). Now we're going to extend the TextUI struct inside our TextView package and build it as a dynamic library.

```swift
import TextUI

extension TextUI {

    @_dynamicReplacement(for: build())
    static func _customBuild() -> String {
        "It just works."
    }
}
```

We can use a similar makefile (to the previous one) or simply run the swift build -c release command and copy the `libTextView.dylib` file from the build directory by hand.

> If you run this code using Linux or Windows, the dynamic library file will be called `libTextView.so` under Linux and `libTextView.dll` on Windows.

So just place this file under your home directory we're going to need the full path to access it using the TextApp's main file. We're going to use the `dlopen` call to load the `dylib`, this will replace our build method, then we close it using `dlclose` (on the supported platforms, more on this later...).

```swift
import Foundation
import TextUI

print(TextUI.build())

let dylibPath = "/Users/tib/libTextView.dylib"
guard let dylibReference = dlopen(dylibPath, RTLD_LAZY) else {
    if let err = dlerror() {
        fatalError(String(format: "dlopen error - %s", err))
    }
    else {
        fatalError("unknown dlopen error")
    }
}
defer {
    dlclose(dylibReference)
}


print(TextUI.build())

// Output:
//
// Hello, World!
// It just works.
```

The great thing about this approach is that you don't have to mess around with additional `dlsym` calls and unsafe C pointers. There is also a nice and detailed [article](https://tech.guardsquare.com/posts/swift-native-method-swizzling/) about Swift and native method swizzling, this focuses a bit more on the emitted replacements code, but I found it a very great read.

Unfortunately there is one more thing that we have to talk about...

## Drawbacks & conclusion

Dynamic method replacement works nice, this approach is behind SwiftUI live previews (or `dlsym` with some pointer magic, but who knows this for sure..). Anyway, everything looks great, until you start involving Swift classes under macOS. What's wrong with classes?

Turns out that the Objective-C runtime gets involved under macOS if you compile a native Swift class. Just compile the following example source and take a look at it using the nm tool.

```
// a.swift
class A {}

// swiftc a.swift -emit-library
// nm liba.dylib|grep -i objc
```

Under macOS the output of `nm` will contain traces of the Objective-C runtime and that is more than enough to cause some troubles during the `dylib` close process. Turns out if your library contains the ObjC runtime you won't be able to actually close the `dylib`, no matter what. ⚠️

> Prior to Mac OS X 10.5, only bundles could be unloaded. Starting in Mac OS X 10.5, dynamic libraries may also be unloaded. There are a couple of cases in which a dynamic library will never be unloaded: 1) the main executable links against it, 2) an API that does not support unloading (e.g. NSAddImage()) was used to load it or some other dynamic library that depends on it, 3) the dynamic library is in dyld's shared cache.

If you take a look at `man 3 dlclose` you can get a few more hints about the reasons, plus you can also check the [source code](https://opensource.apple.com/source/objc4/) of the Objective-C runtime, if you want to see more details.

Anyway I thought this should be mentioned, because it can cause some trouble (only on macOS), but everything works just great under Linux, so if you are planning to use this approach on the server side, then I'd say it'll work just fine. It's not safe, but it should work. 😈

Oh, I almost forget the hot-reload functionality. Well, you can add a directory or file watcher that can [monitor](https://github.com/eonil/FSEvents) your source codes and if something changes you can re-build the TextView dynamic library then load the `dylib` again and call the build method if needed. It's relatively easy after you've tackled the `dylib` part, once you figure out the smaller details, it works like magic. 🥳
