---
type: post
title: "Beginner's guide to server-side Swift using the Hummingbird framework"
description: "Learn about Swift on the server by creating a simple application using the brand new HTTP server library called: Hummingbird."
publication: 2023-03-08 16:20:00
tags: 
    - hummingbird
    - server
authors:
    - tibor-bodecs
---

## Swift on the Server in 2023

Three years ago I started to [focus on Vapor](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/), the most popular web-framework written in Swift, which served me very well over the years, but now it is time to start a new chapter in my life.

As I learned more and more about how servers work I realized that Vapor has it's own pros and cons. The community changed a lot during the past 3 years, some core members left and new people started to maintain the framework. I also had some struggles with the default template engine (Leaf) and recently I started to turn away from the abstract database layer (Fluent) too. Another pain point for me is the growing number of dependencies, I barely use websockets & multipart-kit, but Vapor has these dependencies by default and you can't get rid of them. 😢

Vapor has some really nice things to offer, and for most of the people it's still going to be a great choice for building backends for frontends (BFFs). For me, Vapor reached its limits and I wanted to use something that feels a bit lighter. Somethings that is modular, something that can be easily extended and fits my exact needs without additional (unused) package dependencies.

This shiny new thing is called [Hummingbird](https://github.com/hummingbird-project/hummingbird) and it looks very promising. It was created by [Adam Fowler](https://x.com/o_aberration) who is a member of the [SSWG](https://www.swift.org/sswg/) and also the main author of the [Soto library](https://github.com/soto-project/soto) (AWS Swift).

Hummingbird has a comprehensive [documentation available online](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/) and a nice [example repository](https://github.com/hummingbird-project/hummingbird-examples) containing various demo apps written using the Hummingbird Swift server framework. I believe that the best part of the the framework is modularity & extensibility. By the way, Hummingbird works without Foundation, but it has extensions for Foundation objects, this is a huge plus for me, but maybe that's just my personal preference nowadays. Hummingbird can be extended easily, you can find some very [useful extensions](https://github.com/hummingbird-project/hummingbird#hummingbird-extensions) under the Hummingbird project page, long story short it works with Fluent and it's relatively easy to get along with it if you have some Vapor knowledge... 🤔

## Getting started with Hummingbird

First of all, there is no toolbox or command line utility to help the kickoff process, but you can always download the examples repository and use one of the projects as a starting point. Alternatively you can set everything up by hand, that's what we're going to do now. 🔨

In order to build a new application using the Hummingbird framework you should create a new directory and initialize a new Swift package using the following commands:

```
mkdir server && cd $_
swift package init --type executable
open Package.swift
```

This will create a new Swift package and open the Package.swift file in Xcode. You can use your own editor if you don't like Xcode, but either way you'll have to add Hummingbird to your package manifest file as a dependency. We're going to setup an App target for the application itself, and a Server target for the main executable, which will use the application and configure it as needed.

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "server",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/hummingbird",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .target(name: "App"),
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .product(
                    name: "Hummingbird",
                    package: "hummingbird"
                ),
                .product(
                    name: "HummingbirdFoundation",
                    package: "hummingbird"
                ),
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-cross-module-optimization"],
                    .when(configuration: .release)
                ),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .product(
                    name: "HummingbirdXCT",
                    package: "hummingbird"
                ),
                .target(name: "App"),
            ]
        ),
    ]
)
```

Please create the necessary file and directory structure, as listed below, before you proceed to the next steps. It is very important to name things as they appear, otherwise SPM won't work and the project won't compile. Anyway, the project structure is kind-of Vapor-like as you can see. 💧

```
.
├── Package.resolved
├── Package.swift
├── README.md
├── Sources
│ ├── App
│ │ └── HBApplication+Configure.swift
│ └── Server
│     └── main.swift
└── Tests
    └── AppTests
        └── AppTests.swift
```

The next step is to create the main entry point for the application. For this purpose Hummingbird uses the [Swift Argument Parser](https://github.com/apple/swift-argument-parser) library. Place the following contents into the main.swift file:

```swift
import ArgumentParser
import Hummingbird
import App

struct HummingbirdCommand: ParsableCommand {

    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() throws {
        let app = HBApplication(
            configuration: .init(
                address: .hostname(hostname, port: port),
                serverName: "Hummingbird"
            )
        )
        try app.configure()
        try app.start()
        app.wait()
    }
}

HummingbirdCommand.main()
```

The HummingbirdCommand has two options, you can setup a custom hostname and port by providing these values as command line options (I'll show it later on), the application itself will setup the address using the input and then it'll start listening on the specified port.

The configure method comes from the App target, this is where you can customize your server instance, register route handlers and stuff like that, just like you would do this in Vapor. The main difference is that Hummingbird uses the HB namespace, which is pretty handy, and the configure method is written as an extension. Let's write it and register a basic route handler. 🧩

```swift
import Hummingbird
import HummingbirdFoundation

public extension HBApplication {

    func configure() throws {

        router.get("/") { _ in
            "Hello, world!"
        }
    }
}
```

That's it. Now you should be able to run your server, you can press the Play button in Xcode that'll start your application or enter one of the following commands into the Terminal application:

```
# just run the server
swift run Server

# custom hostname and port
swift run Server --port 3000
swift run Server --hostname 0.0.0.0 --port 3000

# short version
swift run Server -p 3000
swift run Server -h 0.0.0.0 -p 3000

# set the log level (https://github.com/apple/swift-log#log-levels)
LOG_LEVEL=notice swift run Server -p 3000

# make release build
swift build -c release

# copy release build to the local folder
cp .build/release/Server ./Server

# run the executable
LOG_LEVEL=notice ./Server -p 3000
```

You can set these values in Xcode too, just click on the server scheme and select the Edit Scheme... menu item. Make sure that you're on the Run target, displaying the Arguments tag. Simply provde the Arguments Passed On Launch options to set a custom hostname or port and you can set the log level by adding a new item into the Environment Variables section.

If you'd like to unit test your application, I've got a good news for you. Hummingbird also comes with a nice utility tool called HummingbirdXCT, which you can easily setup & use if you'd like to run some tests against your API. In our project, simply alter the AppTests.swift file.

```swift
import Hummingbird
import HummingbirdXCT
import XCTest
@testable import App

final class AppTests: XCTestCase {
    
    func testHelloWorld() throws {
        let app = HBApplication(testing: .live)
        try app.configure()

        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/", method: .GET) { response in
            XCTAssertEqual(response.status, .ok)

            let expectation = "Hello, world!"
            let res = response.body.map { String(buffer: $0) }
            XCTAssertEqual(res, expectation)
        }
    }
}
```

Instead of creating the application from the main entry point, we can set up a new HBApplication instance, import the App framework and call the configure method on it. the XCT framework comes with a custom XCTStart and XCTStop method, and you can execute HTTP requests using the XCTExecute function. The response is available in a completion block and it's possible to examine the status code and extract the body using a convenient String initializer.

As you can see Hummingbird is quite similar to Vapor, but it's lightweight and you can still add those extra things to your server when it is needed. Hummingbird feels like the next iteration of Vapor. I really don't know if Vapor 5, is going to fix the issues I'm currently having with the framework or not, but I don't really care, because that release won't happen anytime soon.
