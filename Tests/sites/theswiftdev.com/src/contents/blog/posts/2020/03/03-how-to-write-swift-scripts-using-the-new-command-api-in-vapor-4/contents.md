---
slug: how-to-write-swift-scripts-using-the-new-command-api-in-vapor-4
title: How to write Swift scripts using the new Command API in Vapor 4?
description: Shell scripts are essentials on the server side. Learn how to build Swift scripts for your backend apps using property wrappers.
publication: 2020-03-03 16:20:00
tags: Vapor
---

## Swift Argument Parser vs Vapor Commands

Apple open-sourced a new library that can help you a lot if you want to build scripts that written in Swift. The [Swift Argument Parser](https://github.com/apple/swift-argument-parser) was previously part of the Swift Package Manager tools, but now it is even powerful & has it's own life (I mean repository). 😉

On the other hand Vapor already had a somewhat similar approach to build scripts, but in Vapor 4 the Command API is better than ever. [Property Wrappers](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md) (available from Swift 5.1) are used in both cases to handle arguments, flags & options. Personally I like this approach a lot.

Let me show you a simple hello command:

```swift
// using Argument Parser
import ArgumentParser

struct HelloCommand: ParsableCommand {
    @Argument(help: "The name to say hello")
    var name: String

    func run() throws {
        print("Hello \(self.name)!")
    }
}
HelloCommand.main()
// usage: swift run myProject world
```

Now I'll show you how to implement a similar command [using Vapor](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/):

```swift
// using Vapor
import Vapor

final class HelloCommand: Command {
    
    let help = "This command will say hello to a given name."

    struct Signature: CommandSignature {
        @Argument(name: "name", help: "The name to say hello")
        var name: String
    }

    func run(using context: CommandContext, signature: Signature) throws {
        print("Hello \(signature.name)!")
    }
}

public func configure(_ app: Application) throws {
    app.commands.use(HelloCommand(), as: "hello")
}
// usage: swift run myProject hello world
```

As you can see they almost look like the same.

> NOTE: If you love scripting, you should definitely check [swift-sh](https://github.com/mxcl/swift-sh) and [Brisk](https://github.com/twostraws/Brisk)

The Swift Argument Parser library is a lightweight solution if you are only looking for a simple Swift script. A good example is a tool that manipulates files on the system or something similar. It's just one little dependency, but it removes so much boilerplate from your scripts. It allows you to focus on the script itself, instead of parsing the command line inputs. You can find more detailed examples and a detailed [documentation](https://github.com/apple/swift-argument-parser/tree/master/Documentation) inside the GitHub repository. 🙏

Vapor's Command API is useful if you want to perform more complicated tasks with your scripts. Anything that's part of your Vapor application can be triggered from a command, so you can easily create a backend tool that reads (or writes) records from the database [using Fluent 4](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/). This is the main advantage of using a Vapor command, instead a standalone Swift script.

## Arguments, options, flags

Let's extend the hello command with a new option and a flag. The main difference between an option and a flag is that an option has an associated value, but a flag is just something that you give to the command or not. Both options and flags start with a single `-` or a double dash `--`, usually the single dashed version uses a short name for the same thing. 🤓

> NOTE: Arguments are user provided values read in order (e.g. `./hello joe bob john`).

Now that you know the basic definitions, here is the example:

```swift
final class HelloCommand: Command {
        
    struct Signature: CommandSignature {

        @Argument(name: "name", help: "The name to say hello")
        var name: String

        @Option(name: "greeting", short: "g", help: "Greeting used")
        var greeting: String?

        @Flag(name: "capitalize", short: "c", help: "Capitalizes the name")
        var capitalize: Bool
    }

    let help = "This command will say hello to a given name."

    func run(using context: CommandContext, signature: Signature) throws {
        let greeting = signature.greeting ?? "Hello"
        var name = signature.name
        if signature.capitalize {
            name = name.capitalized
        }
        print("\(greeting) \(name)!")
    }
}
```

Arguments are required by default, options and flags are optionals. You can have a custom name (short and long) for everything, plus you can customize the help message for every component.

```sh
swift run Run hello john
# Hello john!

swift run Run hello john --greeting Hi
# Hi john!

swift run Run hello john --greeting Hi --capitalized
# Hi John!

swift run Run hello john -g Szia -c
# Szia John!
```

You can call the command using multiple styles. Feel free to pick a preferred version. ⭐️

## Subcommands

> When command-line programs grow larger, it can be useful to divide them into a group of smaller programs, providing an interface through subcommands. Utilities such as git and the Swift package manager are able to provide varied interfaces for each of their sub-functions by implementing subcommands such as git branch or swift package init.

Vapor can handle command groups in a really cool way. I'll add an extra static property to name our commands, since I don't like to repeat myself or bloat the code with unnecessary strings:

```swift
final class HelloCommand: Command {
    
    static var name = "hello"
        
    //...
}

struct WelcomeCommandGroup: CommandGroup {
    
    static var name = "welcome"

    let help: String
    let commands: [String: AnyCommand]
    
    var defaultCommand: AnyCommand? {
        self.commands[HelloCommand.name]
    }

    init() {
        self.help = "SEO command group help"

        self.commands = [
            HelloCommand.name: HelloCommand(),
        ]
    }
}

public func configure(_ app: Application) throws {

    app.commands.use(WelcomeCommandGroup(), as: WelcomeCommandGroup.name)
}
```

That's it, we just moved our `hello` command under the `welcome` namespace.

```sh
swift run Run welcome hello john --greeting "Hi" --capitalize
```

If you read the Swift Argument Parser docs, you can achieve the exact same behavior through a custom `CommandConfiguration`. Personally, I prefer Vapor's approach here... 🤷‍♂️

## Waiting for async tasks

Vapor builds on top of [SwiftNIO](https://github.com/apple/swift-nio) including EventLoops, Futures & Promises. Most of the API is asynchronous, but in the CLI world you have to wait for the async operations to finish.

```swift
final class TodoCommand: Command {
    
    static let name = "todo"

    struct Signature: CommandSignature { }
        
    let help = "This command will create a dummy Todo item"

    func run(using context: CommandContext, signature: Signature) throws {
        let app = context.application
        app.logger.notice("Creating todos...")
        
        let todo = Todo(title: "Wait for async tasks...")
        try todo.create(on: app.db).wait()
        
        app.logger.notice("Todo is ready.")
    }
}
```

There is a throwing `wait()` method that you can utilize to "stay in the loop" until everything is done. You can also get a pointer for the application object by using the current context. The app has the database connection, so you can tell Fluent to [create a new model](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/). Also you can use the built-in logger to print info to the console while the user waits. ⏳

## Using ConsoleKit without Vapor

Let's talk about overheads. Vapor comes with this neat commands API, but also bundles lots of other core things. What if I just want the goodies for my Swift scripts? No problem. You can use the underlying ConsoleKit by adding it as a dependency.

```swift
// swift-tools-version:5.2
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
        .target(name: "myProject", dependencies: [
            .product(name: "ConsoleKit", package: "console-kit"),
        ])
    ]
)
```

You still have to do some additional work in your `main.swift` file, but nothing serious:

```swift
import ConsoleKit
import Foundation

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

This way you can get rid of most of the network related core packages (that are included by default if you use Vapor). This approach only fetches [swift-log](https://github.com/apple/swift-log) as a third party dependency. 😍

## Summary

ConsoleKit in Vapor is a great way to write CLI tools and small scripts. The new Swift Argument Parser is a more lightweight solution for the same problem. If your plan is to maintain databases through scripts or you perform lots of networking or asynchronous operations it might be better to go with Vapor, since you can always grow by importing a new component from the ecosystem.
