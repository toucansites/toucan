---
type: post
slug: logging-for-beginners-in-swift
title: Logging for beginners in Swift
description: Learn how to print variables to the debug console using different functions such as print, dump, NSLog and the unified os.log API.
publication: 2020-09-30 16:20:00
tags: Swift, loggging
authors:
  - tibor-bodecs
---

## Basic output in Swift using print

The very first method I'd like to show you is the [print function](https://developer.apple.com/documentation/swift/1541053-print). It can write the textual representation of the given items to the standard output. In other words we can simply say that it can print text to the screen. Most of the [hello word programs](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) utilize this method to display the famous "Hello world!" message. In Swift, print is quite a powerful method, since you can pass around multiple items for printing out plus you can specify a separator string and a terminator parameter. 🤔

```swift
print("Hello World!")
// output: Hello World!\n
```
The snippet above will display the `Hello World!` text followed by a newline character (`\n`), this is because the default terminator is always a newline. You can override this behavior by providing your own terminator string.

```swift
print("Hello World!", terminator: "")
// output: Hello World!
```

If you run this example using Xcode you should see that the "Program ended with exit code: 0" text will appear in a newline in the first case, but in the second scenario it'll be printed out right after the "Hello World!" sentence. If you run the program using a Terminal application, a `%` character be present instead of the new line in the second case. 💡

What about printing out multiple variables? It is possible to give multiple items to the print function, they can be literally anything, print can handle strings, integers and all kinds of other variables. Print under the hood will convert the variable into a proper string representation, so you don't have to mess around with type casting all the time, but simply print out anything.

```swift
print(1, 2, 3, 4, 5)
// output: 1 2 3 4 5\n

print(1, "two", 3.14, true)
// output: 1 two 3.14 true\n
```

You can also customize the separator character through an argument. So if you need a coma character (followed by a space) in between the elements, you can write something like this:

```swift
print("a", "b", "c", separator: ", ")
// output: a, b, c\n
```

Well, in [my previous article](https://theswiftdev.com/how-to-define-strings-use-escaping-sequences-and-interpolations/) you have seen how to construct various strings using literals and interpolation, you can use all those variables to print out stuff to the console.

```swift
print("""
            __
           / _)
    .-^^^-/ /
 __/       /
<__.|_|-|_|
""")
```

For example, here's a cute multi-line ascii art dinosaur. 🦕

## Debugging and print

Sometimes it would be cool to know just a little bit of extra info about the printed variable, this is when `debugPrint` can help you. The main difference between [print and debugPrint](https://stackoverflow.com/questions/41826683/print-vs-debugprint-in-swift) is that while print simply converts everything to string, debug print will give you a brief debug info about the given items. The debugPrint method will print out numbers just like print does, it'll add double quotes around strings, and it'll print some extra info about most of the other "complex" types.

```swift
print(1) // 1
debugPrint(1) // 1

print("foo") // foo
debugPrint("foo") // "foo"

print(1...5) // 1...5
debugPrint(1...5) // ClosedRange(1...5)
```

Honestly I've almost never used this method, and I always preferred print if I had to print out something to the console, but it's always good to know that there is such an option available built-in to the standard library, however there is a method that can give you way more info... 🧐

## Debugging using dump

The [dump method](https://developer.apple.com/documentation/swift/1539127-dump) can print out the given object's content using its mirror to the standard output. Long story short, this function will show you a more detailed view about the property. For scalar values the dump method will produce almost the same output as debug-print, except the dump line always starts with a dash character, but for more complex types it'll output the underlying structure of the object. Don't worry, you don't need to understand the output of this method, just remember that it can show you helpful info during debugging. 🐞

```swift
dump(1)
dump(3.14)
dump("foo")
dump(1...5)
/*
 - 1
 - 3.14
 - "foo"
 ▿ ClosedRange(1...5)
   - lowerBound: 1
   - upperBound: 5
 */
```
The `ClosedRange` struct is a built-in type with a `lowerBound` and an `upperBound` property. While the print function only returned the defined range (1...5), the debugPrint method also revealed the type of the object, dump takes this one step further by showing us the exact lower and upper bound properties of the value. This can be extremely helpful when you have a complex type with lots of underlying properties that you want to quickly inspect for some reason. 🔍

> NOTE: By the way, [debugging](https://en.wikipedia.org/wiki/Debugging) is the act of finding (and resolving) bugs. Bugs are problems in your program code that prevent normal operation. Developers can use [debugger tools](https://en.wikipedia.org/wiki/Debugger) to run and inspect code step by step, line by line or per instruction, but most of them are simply putting print statements into the code to see the current state or result of a given function. 🤷‍♂️

Dump has a few more function arguments that you can configure:

```swift
dump("test", name: "my-variable", indent: 4, maxDepth: 5, maxItems: 5)
// output:     - my-variable: "test"
```
You can give a name to each dumped variable, add some extra indentation before the dash character, specify the maximum depth for descendents and the maximum number of elements for which to write the full contents. Feel free to play with these parameters for a while. 😉

As you can see dump is quite a powerful method, but still there are other functions for logging purposes, let me show you one that is coming from the Objective-C times.

## NSLog - the legacy logger function

If you have ever worked with Objective-C you should be familiar with the NS prefixes. The [NSLog](https://developer.apple.com/documentation/foundation/1395275-nslog) function can log an error message to the Apple System Log facility console. It's not part of the [Swift standard library](https://developer.apple.com/documentation/swift/swift_standard_library), but you have to import the [Foundation framework](https://developer.apple.com/documentation/foundation) in order to use NSLog.

```swift
import Foundation

NSLog("I'm a dinosaur.")

// output: [date][time][program-name][process-id][thread-id][message]
```

You should know that NSLog will print the current date & time first, then it'll display the name of the running program with the process and thread identifiers and only then it'll print your message.

Just to be clear, NSLog is coming from the Objective-C era, it is not a recommended logging solution anymore. It is also very slow and that can cause some issues if you need precisely timed outputs. That's why I [do NOT recommend using NSLog](https://stackoverflow.com/questions/25951195/swift-print-vs-println-vs-nslog) at all, but you also have to know that until a few years ago there was no better built-in alternative for it, I'm not judging, just saying... 😅

## Unified Logging and Activity Tracing

If you want to send log messages on an Apple device to the [unified logging system](https://developer.apple.com/documentation/os/logging), you can use the [OSLog framework](https://developer.apple.com/documentation/oslog). This new tool was introduced at [WWDC 2016](https://developer.apple.com/videos/play/wwdc2016/721/) and recently got some nice API refinements & updates. You should definitely check the [OSLog and Unified Logging recommended by Apple](https://www.avanderlee.com/workflow/oslog-unified-logging/) article if you want to learn more about this topic it's a great write up.

My only concern about this logging API is that it is not that universal. It works great on Apple platforms, but since Swift is an universal language if you want to add Linux or even Windows support, this solution won't work for you...

## SwiftLog - A Logging API package for Swift

This [open source package](https://github.com/apple/swift-log) can be easily integrated into your Swift projects via the [Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/). You just have to set it up as a dependency in the `Package.swift` manifest file or you can hook it using Xcode under the File > Swift Packages menu as an SPM dependency.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "myProject",
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "myProject", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ])
    ]
)
```

The usage is really straightforward. First you have to import the Logging framework, then you create a logger and you use that logger instance to print out various log messages.

```swift
import Logging

let logger = Logger(label: "app-identifier")

logger.info("Hello World!")
```

The following log levels are supported:

- trace
- debug
- info
- notice
- warning
- error
- critical

You can also attach additional logging metadata to the logger, you should check the [readme](https://github.com/apple/swift-log) for more info about this option. SwiftLog is used in many real-world projects, such as [Vapor 4](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/) (a server side Swift framework), this also means that it works great on Linux operating systems. 🐧

## Conclusion

If it comes to logging, there are several good options to choose from. It only depends on your needs which one is the best, but in general we can say that it is time to leave behind NSLog, and time to use the new OSLog framework. If you are using Swift on non-Apple platform you should consider using the SwiftLog library, which is also provided by Apple.

Alternatively if you are just scratching the surface and you don't need that many options or log levels you can simply stick with print and dump statements. It's perfectly fine to debug using these simple techniques in the beginning. Mastering something takes time and debuggers can be quite frightening at first sight. Use print as much as you need, but always try to improve your tools & knowledge over time, I hope this article gives you a better view of the available logging tools. 🤓
