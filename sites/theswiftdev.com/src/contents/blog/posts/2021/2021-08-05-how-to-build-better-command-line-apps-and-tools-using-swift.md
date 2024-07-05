---
slug: how-to-build-better-command-line-apps-and-tools-using-swift
title: How to build better command line apps and tools using Swift?
description: These tips will help you to create amazing CLI tools, utility apps, server side projects or terminal scripts using the Swift language.
publication: 2021-08-05 16:20:00
tags: Swift, command line
---

## Running Swift files as scripts

It is possible to run a Swift file straight from the command line if you add a [hashbang](https://en.wikipedia.org/wiki/Shebang_(Unix)) to the beginning of the file. This way you don't have to manually compile the code using the `swiftc` command. You can simply give the file the executable permission flag and the system will call the Swift [REPL](https://swift.org/lldb/) under the hood, so our app can be evaluated automatically. 🔨

```swift
#!/usr/bin/env swift

print("Hello, world!")
```
For example this `main.swift` file above can be marked as an executable file, and we can simply call it via the `./main.swift` command later on (you just have to use [chmod](https://en.wikipedia.org/wiki/Chmod) only one time).

```sh
chmod +x main.swift 
./main.swift  
# Hello, world!
```

The beauty of this method is that you can rapidly test your Swift command line snippets. You can even place the finished Swift scripts under the `/usr/local/bin/` directory without the swift file extension to make them available "globally" for your operating system user. 💪

## Using command line arguments in Swift

The [CommandLine](https://developer.apple.com/documentation/swift/commandline) enum makes it very easy to fetch the arguments passed to our Swift application or script. You can access every argument using the arguments variable as an array of Strings, but it is also possible to get the raw data using the `argc` and `unsafeArgv` properties.

```swift
#!/usr/bin/env swift

/// the very first element is the current script
let script = CommandLine.arguments[0]
print("Script:", script)

/// you can get the input arguments by dropping the first element
let inputArgs = CommandLine.arguments.dropFirst()
print("Number of arguments:", inputArgs.count)

print("Arguments:")
for arg in inputArgs {
    print("-", arg)
}
```

You should note that the first argument is always the path of the current script, so if you are only looking for the input arguments you can use the `dropFirst()` method to return a subset of the input strings. Usually each argument is separated by a space character.

```sh
./main.swift hello world
# Script: main.swift
# Number of arguments: 2
# Arguments:
# - hello
# - world
```

In Xcode you can add custom arguments under the Edit Scheme... menu item when you click on the current scheme, look for the Arguments tab and use the Arguments Passed On Launch section.

Process info and environment in Swift
Just like we can access command line arguments, it is possible to examine the current process including some hardware information and environment variables.

```swift
#!/usr/bin/env swift
import Foundation

let info = ProcessInfo.processInfo

print("Process info")
print("Process identifier:", info.processIdentifier)
print("System uptime:", info.systemUptime)
print("Globally unique process id string:", info.globallyUniqueString)
print("Process name:", info.processName)

print("Software info")
print("Host name:", info.hostName)
print("OS major version:", info.operatingSystemVersion.majorVersion)
print("OS version string", info.operatingSystemVersionString)

print("Hardware info")
print("Active processor count:", info.activeProcessorCount)
print("Physical memory (bytes)", info.physicalMemory)

/// same as CommandLine.arguments
print("Arguments")
print(ProcessInfo.processInfo.arguments)

print("Environment")
/// print available environment variables
print(info.environment)
```

The environment variables property is a Dictionary where both the keys and the values are available as strings, so you might have to parse them if you are looking for different value types. You can set up environment custom variables in Xcode just like arguments, or you can pass them via the command line before you execute the Swift script using the [export](https://man7.org/linux/man-pages/man1/export.1p.html) command.

## Standard input and output in Swift

You can use the print function to write text to the standard output, but you should note that the [print](https://developer.apple.com/documentation/swift/1541053-print) function has a variadic items definition, so you can pass around multiple arguments and a custom separator & terminator parameter to display more advanced outputs.

There is also a standard error stream, which is part of the [standard streams](https://en.wikipedia.org/wiki/Standard_streams) of course, but what's interesting about it is that you can also write to this channel through the `FileHandle.standardError` property there is quite an elegant solution on a [Stack Overflow](https://stackoverflow.com/questions/24041554/how-can-i-output-to-stderr-with-swift) thread originally created by [Rob Napier](https://x.com/cocoaphony?lang=en), I'm going to include that one here as well. 🙏

Another great feature of the print function is the to parameter, which can accept a custom `TextOutputStream` so you can wrap the `stderr` stream in a custom object or you can also create custom output handlers and separate your print statements e.g. by context if you need.

```swift
#!/usr/bin/env swift
import Foundation

/// print using custom separator & terminator
print("This", "is", "fun", separator: "-", terminator: "!")

/// write to the standard output
"This goes to the standard error output"
    .data(using: .utf8)
    .map(FileHandle.standardError.write)

/// print to the standard output using a custom stream
final class StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}

var outputStream = StandardErrorOutputStream()
print("This is also an error", to: &outputStream)


/// clears the console (@NOTE: won't work in Xcode)
func clear() {
    print("\u{1B}[2J")
    print("\u{1B}[\(1);\(0)H", terminator: "")
}

print("foooooooooooooooooooooo")
clear()
print("Hello, world!")


/// print colorful text using ANSI escape codes
print("\u{1b}[31;1m\u{1b}[40;1m\("Hello, world!")\u{1b}[m")
print("\u{1b}[32;1m\("Hello, world!")\u{1b}[m")

/// reading lines from the standard input
print("Please enter your input:")
guard let input = readLine(strippingNewline: true) else {
    fatalError("Missing input")
}
print(input)
```

The second half of the snippet is full of [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) which I like quite a lot, because it can make our terminal output quite beautiful. The only problem is that they don't work in Xcode at all (come-on Apple, please support this...). You can clear the console or change the background / foreground color of the output by using these codes.

There are quite a lot of libraries on [GitHub](https://www.google.com/search?client=safari&rls=en&q=swift+ansi+escape+github&ie=UTF-8&oe=UTF-8) that you can use to print colorful output, for example [ColorizeSwift](https://github.com/mtynior/ColorizeSwift), [ANSITerminal](https://github.com/pakLebah/ANSITerminal), [ANSIEscapeCode](https://github.com/flintprocessor/ANSIEscapeCode) and many more cool ones.

The very last thing that I'd like to show you is the [readLine](https://developer.apple.com/documentation/swift/1641199-readline) function, which you can use to read a line from the standard input. This comes handy if you need to get user input from the command line.

## Use an argument parser library

If you are looking for a type-safe argument parser written in Swift, you should definitely take a look at the [Swift Argument Parser](https://github.com/apple/swift-argument-parser) library. It is created and maintained by Apple, so it's kind of an official solution for this particular issue, but IMHO it lacks some advanced features.

This is the main reason why I prefer [the Vapor command API](https://theswiftdev.com/how-to-write-swift-scripts-using-the-new-command-api-in-vapor-4/) built on top of the [ConsoleKit](https://github.com/vapor/console-kit) library. Both libraries can parse arguments, options and flags, but ConsoleKit is also capable of displaying progress indicators, it features multiple command groups, secure input, auto-completion, multiple log levels and many more.

```swift
/// HelloCommand.swift
import Foundation
import ConsoleKit

final class HelloCommand: Command {
        
    struct Signature: CommandSignature {

        @Argument(name: "name", help: "The name to say hello")
        var name: String

        @Option(name: "greeting", short: "g", help: "Greeting used")
        var greeting: String?

        @Flag(name: "capitalize", short: "c", help: "Capitalizes the name")
        var capitalize: Bool
    }

    static var name = "hello"
    let help = "This command will say hello to a given name."

    func run(using context: CommandContext, signature: Signature) throws {
        let greeting = signature.greeting ?? "Hello"
        var name = signature.name
        if signature.capitalize {
            name = name.capitalized
        }
        print("\(greeting) \(name)!")
        
        /// progress bar
        let bar = context.console.progressBar(title: "Hello")
        bar.start()
        /// perform some work...
        // bar.fail()
        bar.succeed()
        
        /// input
        let foo = context.console.ask("What?")
        print(foo)
        
        /// secure input
        let baz = context.console.ask("Secure what?", isSecure: true)
        print(baz)
        
        /// choice
        let c = context.console.choose("Make a choice", from: ["foo", "bar", "baz"])
        print(c)

        /// @Tip: look for more options under the context.console property.
    }
}

/// main.swift
import Foundation
import ConsoleKit

let console: Console = Terminal()
var input = CommandInput(arguments: CommandLine.arguments)
var context = CommandContext(console: console, input: input)

var commands = Commands(enableAutocomplete: true)
commands.use(HelloCommand(), as: HelloCommand.name, isDefault: false)

do {
    let group = commands.group(help: "Using ConsoleKit without Vapor.")
    try console.run(group, input: input)
}
catch {
    console.error("\(error)")
    exit(1)
}
```

You can use both solution through the [Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/), the setup process is quite easy, you'll find more tutorials about the Swift Argument Parser and I think that it is harder to find proper docs for ConsoleKit, so yeah... anyway, they're great libraries you won't regret using them. 😉

## Take advantage of the Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is one of the best thing about the Swift programming language. I really love it and I use it almost every day. The fact that [the package manifest file](https://theswiftdev.com/the-swift-package-manifest-file/) is defined using Swift itself makes it easy to use & understand.

```swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "myProject",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit", from: "4.1.0"),
    ],
    targets: [
        .executableTarget(name: "myProject",dependencies: [
            .product(name: "ConsoleKit", package: "console-kit"),
        ]),
        .testTarget(name: "myProjectTests", dependencies: ["myProject"]),
    ]
)
```

The package manager evolved quite a lot during the past few months, if you take a look at the [Swift Evolution dashboard](https://apple.github.io/swift-evolution/#?search=package) you can track these changes, the most recent update was the introduction of custom, user-defined [Package Collections](https://swift.org/blog/package-collections/), but if you are looking for packages you can always take a look at the [Swift Package Index website](https://swiftpackageindex.com/). 👍

