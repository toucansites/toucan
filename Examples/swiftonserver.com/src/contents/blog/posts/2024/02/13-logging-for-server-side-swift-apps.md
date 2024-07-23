---
slug: logging-for-server-side-swift-apps
title: Logging for server-side Swift apps
description: Discover how to integrate the Logging library into an application, use various log levels, and tailor the unified logging API for backend projects.
publication: 2024-02-13 18:30:00
tags:
  - swift
  - logging
  - observability
authors:
  - tibor-bodecs
---

# Logging for server-side Swift apps

The [swift-log](https://github.com/apple/swift-log) open-source project is developed by Apple. It provides a unified logging solution for server-side Swift applications. The API closely mirrors the functionality of [os_log](https://developer.apple.com/documentation/os/logging), but it also offers cross-platform compatibility. This means that it is possible to use the Logging library on Linux and Windows too. This tutorial aims to provide a simple, but comprehensive overview of the logger API.

## How to use the Logging library

Incorporating Logging into a backend Swift project is straightforward. Swift Package Manager provides an easy way to add the Logging framework as a package dependency using the `Package.swift` file.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "logging-for-server-side-swift-apps-sample",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
        .executable(name: "MyApp", targets: ["MyApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "MyLibrary",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .executableTarget(
            name: "MyApp",
            dependencies: [
                .target(name: "MyLibrary"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
    ]
)

```

This article offers a [sample project](https://github.com/swift-on-server/logging-for-server-side-swift-apps-sample) that you can use as a starting point.

In this tutorial, we are going to create a basic library and an executable target. These simulate a virtual meeting room including participants and their ability to join and leave the room. We're going to use the `MyLibrary` target, which will take advantage of the logging framework.

Inside the `MyApp` target , we'll add more log messages as well. The starter sample project has no logs at all, but relies on the `print` function to display the desired output. We're going to improve the project to provide debug messages for developers through the Logging API.

### The basics

The Logging library defines a public `Logger` struct that developers can instantiate and customize.

The Logger's label serves as an identifier or name for a specific logger instance. It helps distinguish log messages originating from different parts of an application or system. Additionally, the label can be useful for categorizing and organizing log entries, especially in large-scale projects with multiple components or modules. It provides context for where the log messages are coming from, aiding in debugging, monitoring, and analyzing the behavior of the software.

Log levels allow developers to specify the level of detail they want to log, ranging from very specific debugging information to high-level summaries of system activity. This granularity enables developers to tailor logging output according to their specific needs.

Through extra metadata, developers can get even more details about the circumstances surrounding a log event. This contextual information helps developers understand why a log event occurred, making it easier to diagnose issues and trace the flow of execution within a system.

The following snippet demonstrates how to use a basic `Logger` instance:

```swift
// 1.
import Logging

// 2.
var logger: Logger = .init(label: "my-app")

// 3.
logger.logLevel = .trace

// 4.
logger[metadataKey: "foo"] = "bar"

// 5.
logger.info("log-message", metadata: [
    "custom": "example"
])
```

Let's go over the sample code, step-by-step:

1. Import the `Logging` framework
2. Initiate a Logger instance using the label `my-app`, which can be used to identify logs.
3. Set the log level for the logger instance to `.trace`, which provides the most detailed log output.
4. Set custom metadata key-value pair on the logger instance: `foo:bar`
5. Display an `info` message with extra metadata: `custom:example`

The console output of the snippet above, should be something like this:

```
2024-01-24T11:12:28+0100 info my-app : foo=bar custom=example [MyApp] log-message
```

The default Logger output contains these sections:

- The date of the log generation event.
- The log level.
- The custom label of the logger instance.
- All the provided metadata key-value pairs combined together.
- The name of the application, which triggered the log message.

The output format of the logger can be customized and it is also possible to write logs into files.

### Log levels

The SwiftLog library defines 7 standard log levels. All the possible values are defined on the `Logger.Level` enum. The complete list is arranged in order of increasingly higher severity:

- trace
- debug
- info
- notice
- warning
- error
- critical

According to the Log Levels article on [swift.org](https://www.swift.org/server/guides/libraries/log-levels.html), framework authors should mostly use _trace_ and _debug_ to display log messages. Developers should keep their framework logs quiet and, if needed, throw errors that can be caught and logged by end-users.

Application developers can take advantage of the `info` and `notice` levels to differentiate log messages.

The `warning`, `error` and `critical` levels shouldn't be overused. Those are also intended to be used inside apps, but sometimes frameworks also use them to let other developers know about problematic use-cases. (e.g.: bad configuration)

### Log Metadata

Additional information can be attached to log messages, called Metadata. Metadata can include contextual information such as identifiers, keys, names, and any other relevant information.

Providing extra metadata for the log messages can be helpful for debugging, monitoring, and analyzing the behavior of an application.

The Swift Logging library, has built-in metadata support. All the log message functions feature a metadata parameter. A Logger instance can also have associated metadata objects through subscripts. It's also possible to create a custom metadata provider during bootstrapping.

When using structured concurrency in Swift, use a [TaskLocal](https://developer.apple.com/documentation/swift/tasklocal) value to provide contextual data for your log messages. Your Metadata Provider can read these TaskLocal values.

Here's a quick example how to use a task local value with a metadata provider:

```swift
// 1.
enum Request {
    @TaskLocal static var id: String?
}

// 2.
var logger = Logger(
    label: "task-logger",
    metadataProvider: .init(
        {
            guard let requestId = Request.id else {
                return [:]
            }
            return ["id": "\(requestId)"]
        }
    )
)

// 3.
logger[metadataKey: "foo"] = "bar"

// 4.
logger.notice("hi", metadata: [
    "hello": "world",
])

// 5.
Request.$id.withValue("my-req") {
    logger.info("bye", metadata: [
        "abc": "123",
    ])
}
```

1. A static task local `id` property definition on the `Request` enum.
2. Creates the logger with a custom metadata provider using the `Request.id`.
3. Set a metadata key on the logger instance (`foo:bar`).
4. Log a notice (`hi`), featuring additional metadata (`hello:world`).
5. Set the task local value and log an info message (`bye`) with more metadata (`abc:123`).

The snippet's output is going to be something like this:

```swift
2024-02-09T19:26:43+0100 notice task-logger : foo=bar hello=world [MyApp] hi
2024-02-09T19:26:43+0100 info task-logger : abc=123 foo=bar id=my-req [MyApp] bye
```

Log metadata works like a dictionary, it features key-value pairs to store the page.

---

## A practical example

Now that we've covered the basics of the Logging framework, it's time to upgrade the [sample project](https://github.com/swift-on-server/logging-for-server-side-swift-apps-sample).

### Logging in libraries

Start integrating the Logging framework by updating the `Meeting.swift` file as such:

```swift
import Foundation
import Logging

public struct Meeting {

    // 1.
    public init(
        id: UUID,
        logger: Logger = .init(label: "meeting-logger")
    ) {
        self.id = id
        self.participants = .init()
        self.isInProgress = false
        self.logger = logger
        // 2.
        self.logger[metadataKey: "meeting.id"] = "\(id)"

        // 3.
        self.logger.trace("meeting room is ready")
    }
}
```

1. Add a logger parameter to the init method with a default logger instance (`meeting-logger`).
2. Set the current meeting identifier as a metadata value for the `meeting.id` key.
3. Log a trace message to inform others about the status of the meeting room.

A default logger instance as an init parameter helps to avoid interface changes.

The default log level is always set to _info_, meaning _trace_ and _debug_ log messages won't be visible by default.

Integrating swift-log won't significantly affect the performance of the project.

Library consumers can override the logger and provide a custom instance during the instantiation process:

```swift
import MyLibrary
import Logging
import Foundation

@main
struct MyApp {

    static func main() async throws {
        var libLogger = Logger(label: "my-library")
        libLogger.logLevel = .trace

        let bob = Participant(name: "Bob")
        let john = Participant(name: "John")
        let kate = Participant(name: "Kate")
        let mike = Participant(name: "Mike")

        var meeting = Meeting(
            id: .init(),
            logger: libLogger
        )
    }
}
```

This is an extremely powerful debugging feature, since users can filter the console output based on the log levels.

```
2024-01-24T11:31:19+0100 trace my-library : meeting.id=B6176BC5-39A0-4141-B50B-B86141CCE4C8 [MyLibrary] meeting room is ready
```

The next step is to add some useful debug & trace information message to the `add`, `remove`, `start` and `end` functions.

```swift
public mutating func add(_ participant: Participant) {
    // 1.
    logger.debug(
        "trying to add participant",
        metadata: participant.loggerMetadata
    )

    if isInProgress {
        greet(participant)
        // 2.
        logger.trace("meeting is in progress")
    }

    if participants.contains(participant) {
        // 3.
        logger.trace(
            "couldn't add participant, already there",
            metadata: participant.loggerMetadata
        )
        return
    }

    participants.insert(participant)

    // 4.
    logger.debug("participant added", metadata: [
        "participants": "\(participants.count)"
    ])
}
```

1. Log a debug message when the operation begins
2. Use a trace log when the meeting state is already in progress
3. Use a trace log to provide additional feedback if the function returns earlier
4. Log a debug message when the operation is complete as it is expected

Let's apply the exact same pattern for the remove function:

```swift
public mutating func remove(_ participant: Participant) {
    logger.debug(
        "trying to remove participant",
        metadata: participant.loggerMetadata
    )

    if isInProgress {
        bye(participant)
        logger.trace("meeting is in progress")
    }
    guard participants.contains(participant) else {
        logger.trace(
            "can't remove participant, not there",
            metadata: participant.loggerMetadata
        )
        return
    }

    participants.remove(participant)

    logger.debug("participant removed", metadata: [
        "participants": "\(participants.count)"
    ])
}
```

By including the participant identifier and the name, as metadata, developers can identify the referenced objects.

The start function will look very similar:

```swift
public mutating func start() throws {
    logger.debug("trying to start the meeting")

    if isInProgress {
        logger.trace("already in progress")
        return
    }

    guard hasEnoughParticipants else {
        throw Meeting.Issue.notEnoughParticipants
    }

    isInProgress = true

    for participant in participants {
        logger.trace("participating", metadata: participant.loggerMetadata)
        welcome(participant)
    }

    logger.debug("meeting started", metadata: [
        "participants.count": "\(participants.count)",
    ])
}
```

We should also update the end function using the same technique:

```swift
public mutating func end() {
    logger.debug("trying to end the meeting")

    guard isInProgress else {
        logger.trace("meeting is not in progress yet")
        return
    }

    for participant in participants {
        logger.trace(
            "saying goodbye to participant",
            metadata: participant.loggerMetadata
        )
        thankYou(participant)
    }
    participants.removeAll()

    logger.debug("meeting finished")
}
```

The debug log level is used to get a brief overview of the internal behavior of the library functions. In addition, the trace log level's purpose is to enable tracking of the entire workflow, by providing more detailed information.

Try to run the application using different log levels.

Set the log level to `.debug`, using the `libLogger.logLevel` property inside the `MyApp.swift` file to hide trace messages.

### Logging in executables

Using the Swift Logging library in an application is very similar. App developers can take advantage of the _trace_, _debug_, _info_ and _notice_ levels and further distinguish _warnings_, _errors_ and _critical_ issues if something goes wrong.

Let's add some new log messages to the main app target:

```swift
import MyLibrary
import Logging
import Foundation

@main
struct MyApp {

    static func main() {

        // 1.
        var appLogger = Logger(label: "my-app")
        appLogger.logLevel = .trace

        var libLogger = Logger(label: "my-library")
        libLogger.logLevel = .info

        // 2.
        appLogger.info("Start a meeting")
        let bob = Participant(name: "Bob")
        let john = Participant(name: "John")
        let kate = Participant(name: "Kate")
        let mike = Participant(name: "Mike")

        // 3.
        appLogger.notice("Preparing the meeting")
        var meeting = Meeting(
            id: .init(),
            logger: libLogger
        )

        appLogger.notice("Add the participants, except Mike...")

        meeting.add(bob)
        meeting.add(john)
        meeting.add(kate)

        // 4.
        appLogger.warning("Trying to remove Mike from the list, but he is not on the list.")
        meeting.remove(mike)

        appLogger.info("Start the meeting")

        if !meeting.hasEnoughParticipants {
            appLogger.warning("the meeting has not enough participants just yet")
        }

        do {
            try meeting.start()
        }
        catch {
            // 5.
            appLogger.error("\(error)")
        }

        appLogger.notice("Add Mike to the list")
        meeting.add(mike)

        appLogger.notice("Remove Bob to the list")
        meeting.remove(bob)

        appLogger.info("End the meeting")
        meeting.end()

        appLogger.info("Meeting finished")
    }
}
```

1. Instantiate a standalone logger for the application.
2. Log informational messages if necessary, this is the default log level.
3. Use a notice when aiming for a log level higher than info.
4. Warnings can be used to inform users about potential issues or errors.
5. Error log messages can indicate that something has gone wrong.

Try to set different log levels for each Logger instance and run the application.

### Environment-based logs

It's possible to set the log level for the entire application by defining a `LOG_LEVEL` environment variable. This will set the log level for all the logger instances, and may bloat the console with quite a lot of messages.

In an upcoming article, a more detailed explanation will be provided on how to store and define environment variables.

Apple has a solution for this problem, they provide a way to [customize logging behaviors](https://developer.apple.com/documentation/os/logging/customizing_logging_behavior_while_debugging).

Currently, this approach is unavailable for server-side Swift applications featuring the Logging library.

To overcome the issue, we can write a function (`subsystem`) as an extension for the Logger struct:

```swift
import Foundation
import Logging

public extension Logger {

    static func subsystem(
        _ id: String,
        _ level: Logger.Level = .info
    ) -> Logger {
        // 1.
        var logger = Logger(label: id)
        // 2.
        logger.logLevel = level

        let env = ProcessInfo.processInfo.environment
        // 3.
        if let rawLevel = env["LOG_LEVEL"]?.lowercased(),
            let level = Logger.Level(rawValue: rawLevel)
        {
            logger.logLevel = level
        }
        // 4.
        let envKey =
            id
            .appending("-log-level")
            .replacingOccurrences(of: "-", with: "_")
            .uppercased()
        if let rawLevel = env[envKey]?.lowercased(),
            let level = Logger.Level(rawValue: rawLevel)
        {
            logger.logLevel = level
        }
        // 5.
        return logger
    }
}
```

1. Create a logger instance using the id parameter as a label.
2. Set the log level based on the argument, defaults to info.
3. Get the `LOG_LEVEL` env variable if present and update the log level based on that.
4. Get the `<MY_ID>-LOG_LEVEL` env variable if present and set the log level based on that.
5. Return the configured logger instance.

This helper function allows developers to individually set log levels for each subsystem:

```swift
import MyLibrary
import Logging
import Foundation

@main
struct MyApp {

    static func main() {
        // setenv("MY_APP_LOG_LEVEL", "trace", 1)
        let appLogger = Logger.subsystem("my-app", .trace)

        // setenv("MY_LIBRARY_LOG_LEVEL", "trace", 1)
        let libLogger = Logger.subsystem("my-library", .trace)

        // ...
    }
}
```

Define a custom environment variable based on your identifier:

- add the `-log-level` suffix to the identifier
- replace the dash characters with underscores
- capitalize the entire string

e.g.: `my-library` -> `MY_LIBRARY_LOG_LEVEL`

The `setenv` function can be used to define environmental variables from Swift code.

Important: Avoid utilizing the `setenv` function. It is intended solely for demonstration purposes.

Run the project from the command line, using the following command to explicitly set environment variables:

```sh
# single command
MY_APP_LOG_LEVEL=trace MY_LIBRARY_LOG_LEVEL=trace swift run MyApp

# or export env vars
export MY_APP_LOG_LEVEL=trace
export MY_LIBRARY_LOG_LEVEL=trace
swift run MyApp
```

Provide the environmental variables using a single command before the `swift run MyApp` action.

The `export` command can be used to export variables, making them available in the environment of subsequently executed commands.

## Summary

That's how you can integrate the Swift Logging library into a framework or application.

You've learned a lot about logging in this article, including log levels, metadata and custom logging subsystems via environment variables.

If you want to learn a bit more about other logging and debugging solutions, you can also [read this article](https://theswiftdev.com/logging-for-beginners-in-swift/), which contains some useful snippets & examples.
