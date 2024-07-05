---
slug: running-and-testing-async-vapor-commands
title: Running and testing async Vapor commands
description: In this article I'll show you how to build asynchronous Vapor commands and how to test them using ConsoleKit.
publication: 2023-02-23 16:20:00
tags: Vapor
---

## How to run async commands in Vapor?

The async / await feature is relatively new in Swift and some framework authors haven't converted everything to take advantage of these new keywords. Currently, this is the situation with the [Command API](https://docs.vapor.codes/advanced/commands/?h=commands) in Vapor 4. You can already define async commands, but there's no way to register them using the Vapor framework. Fortunately, there is a relatively straightforward workaround that you can use if you want to execute commands using an asynchronous context. 🔀

First we're going to define a helper protocol and create an asyncRun function. We are going to extend the original Command protocol and provide a default implementation for the run method.

```swift
import Vapor

public protocol AsyncCommand: Command {
    
    func asyncRun(
        using context: CommandContext,
        signature: Signature
    ) async throws
}

public extension AsyncCommand {

    func run(
        using context: CommandContext,
        signature: Signature
    ) throws {
        let promise = context
            .application
            .eventLoopGroup
            .next()
            .makePromise(of: Void.self)
        
        promise.completeWithTask {
            try await asyncRun(
                using: context,
                signature: signature
            )
        }
        try promise.futureResult.wait()
    }
}
```

This way you should be able to create a new async command and you should implement the asyncRun method if you want to call some asynchronous Swift code.

```swift
import Vapor

final class MyAsyncCommand: AsyncCommand {
    
    static let name = "async"
    
    let help = "This command run asynchronously."

    struct Signature: CommandSignature {}

    func asyncRun(
        using context: CommandContext,
        signature: Signature
    ) async throws {
        context.console.info("This is async.")
    }
}
```

It is possible to register the command using the configure method, you can try this out by running the swift run Run async snippet if you are using the standard Vapor template. 💧

```swift
import Vapor

public func configure(
    _ app: Application
) throws {

    app.commands.use(
        MyAsyncCommand(),
        as: MyAsyncCommand.name
    )

    try routes(app)
}
```

As you can see it's a [pretty neat trick](https://docs.vapor.codes/basics/async/?h=async#working-with-old-and-new-apis), it's also mentioned on [GitHub](https://github.com/vapor/console-kit/issues/171), but hopefully we don't need this workaround for too long and proper async command support will arrive in Vapor 4.x.

## Unit testing Vapor commands

This topic has literally zero documentation, so I thought it would be nice to tell you a bit about how to unit test [scripts created via ConsoleKit](https://theswiftdev.com/how-to-write-swift-scripts-using-the-new-command-api-in-vapor-4/). First of all we need a TestConsole that we can use to collect the output of our commands. This is a shameless ripoff from [ConsoleKit](https://github.com/vapor/console-kit/blob/main/Tests/ConsoleKitTests/Utilities.swift#L97). 😅

```swift
import Vapor

final class TestConsole: Console {

    var testInputQueue: [String]
    var testOutputQueue: [String]
    var userInfo: [AnyHashable : Any]

    init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.userInfo = [:]
    }

    func input(isSecure: Bool) -> String {
        testInputQueue.popLast() ?? ""
    }

    func output(_ text: ConsoleText, newLine: Bool) {
        let line = text.description + (newLine ? "\n" : "")
        testOutputQueue.insert(line, at: 0)
    }

    func report(error: String, newLine: Bool) {
        //
    }

    func clear(_ type: ConsoleClear) {
        //
    }

    var size: (width: Int, height: Int) {
        (0, 0)
    }
}
```

Now inside the test suite, you should create a new application instance using the test environment and configure it for testing purposes. Then you should initiate the command that you'd like to test and run it using the test console. You just have to create a new context and a proper input with the necessary arguments and the `console.run` function will take care of everything else.

```swift
@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testCommand() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let command = MyAsyncCommand()
        let arguments = ["async"]
        
        let console = TestConsole()
        let input = CommandInput(arguments: arguments)
        var context = CommandContext(
            console: console,
            input: input
        )
        context.application = app
        
        try console.run(command, with: context)

        let output = console
            .testOutputQueue
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let expectation = [
            "This is async."
        ]
        XCTAssertEqual(output, expectation)
    }
}
```

The nice thing about this solution is that the ConsoleKit framework will automatically parse the arguments, options and the flags. You can provide these as standalone array elements using the input arguments array (e.g. `["arg1", "--option1", "value1", "--flag1"]`).

It is possible to test command groups, you just have to add the specific command name as the first argument that you'd like to run from the group and you can simply check the output through the test console if you are looking for the actual command results. 💪
