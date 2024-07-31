---
type: post
slug: swift-command-design-pattern
title: Swift command design pattern
description: This time I'm going to show you a behavioral pattern. Here is a little example of the command design patten written in Swift.
publication: 2018-06-13 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

The [command pattern](https://en.wikipedia.org/wiki/Command_pattern) can be handy if you'd like to provide a common interface for different actions that will be executed later in time. Usually it's an object that encapsulates all the information needed to run the underlying action properly.

[Commands](https://medium.com/@NilStack/swift-world-design-patterns-command-cc9c56544bf0) are often used to handle user interface actions, create undo managers, or manage transactions. Let's see a [command pattern](https://medium.com/design-patterns-in-swift/design-patterns-in-swift-command-pattern-b95a1f4bbc45) implementation in Swift by creating a command line argument handler with emojis. 💾

```swift
#!/usr/bin/env swift

import Foundation

protocol Command {
    func execute()
}

class HelpCommand: Command {

    func execute() {
        Help().info()
    }
}

class Help {

    func info() {
        print("""

             🤖 Commander 🤖
                  v1.0

        Available commands:

            👉 help      This command
            👉 ls        List documents

        Bye! 👋

        """)
    }
}

class ListCommand: Command {

    func execute() {
        List().homeDirectoryContents()
    }
}

class List {

    func homeDirectoryContents() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not open documents directory")
            exit(-1)
        }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("\n\t📁 Listing documents directory:\n")
            print(fileURLs.map { "\t\t💾 " + $0.lastPathComponent }.joined(separator: "\n\n") + "\n" )
        }
        catch {
            print(error.localizedDescription)
            exit(-1)
        }

    }
}

class App {

    var commands: [String:Command] = [:]

    init() {
        self.commands["help"] = HelpCommand()
        self.commands["ls"] = ListCommand()
    }

    func run() {
        let arguments = CommandLine.arguments[1...]

        guard let key = arguments.first, self.commands[key] != nil else {
            print("Usage: ./command.swift [\(self.commands.keys.joined(separator: "|"))]")
            exit(-1)
        }

        self.commands[key]!.execute()
    }
}

App().run()
```

If you save this file, can run it by simply typing `./file-name.swift` from a terminal window. The Swift compiler will take care of the rest.

Real world use cases for the [command design](https://tech.okcupid.com/command-patterns-and-uicollectionview/) pattern:

    + various button actions
    + collection / table view selection actions
    + navigating between controllers
    + history management / undo manager
    + transactional behavior
    + progress management
    + wizards

As you can see this pattern can be applied in multiple areas. Apple even made a specific class for this purpose called [NSInvocation](https://developer.apple.com/documentation/foundation/nsinvocation), but unfortunately it's not available in Swift, due to it's dynamic behavior. That's not a big deal, you can always make your own protocol & implementation, in most cases you just need one extra class that wraps the underlying command logic. 😛
