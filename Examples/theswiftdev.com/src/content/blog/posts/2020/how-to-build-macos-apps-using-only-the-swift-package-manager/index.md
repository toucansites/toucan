---
type: post
slug: how-to-build-macos-apps-using-only-the-swift-package-manager
title: How to build macOS apps using only the Swift Package Manager?
description: In this article we're going to create a macOS application without ever touching an Xcode project file, but only working with SPM.
publication: 2020-10-26 16:20:00
tags: Swift, macOS
authors:
  - tibor-bodecs
---

## Swift scripts and macOS apps

Swift compiler 101, you can create, build and run a Swift file using the `swiftc` command. Consider the most simple Swift program that we can all imagine in a `main.swift` file:

```swift
print("Hello world!")
```
In Swift if we want to print something, we don't even have to import the Foundation framework, we can simply compile and run this piece of code by running the following:

```sh
swiftc main.swift   # compile main.swift
chmod +x main       # add the executable permission
./main          # run the binary
```

The good news that we can take this one step further by auto-invoking the Swift compiler under the hood with a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)).

```swift
#! /usr/bin/swift

print("Hello world!")
```

Now if you simply run the `./main.swift` file it'll print out the famous "Hello world!" text. 👋

Thanks to the program-loader mechanism and of course the Swift interpreter we can skip an extra step and run our single-source Swift code as easy as a regular shell script. The good news is that we can import all sort of system frameworks that are part of the Swift toolchain. With the help of Foundation we can build quite useful or completely useless command line utilities.

```swift
#!/usr/bin/env swift

import Foundation
import Dispatch

guard CommandLine.arguments.count == 2 else {
    fatalError("Invalid arguments")
}
let urlString =  CommandLine.arguments[1]
guard let url = URL(string: urlString) else {
    fatalError("Invalid URL")   
}

struct Todo: Codable {
    let title: String
    let completed: Bool
}

let task = URLSession.shared.dataTask(with: url) { data, response, error in 
    if let error = error {
        fatalError("Error: \(error.localizedDescription)")
    }
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        fatalError("Error: invalid HTTP response code")
    }
    guard let data = data else {
        fatalError("Error: missing response data")
    }

    do {
        let decoder = JSONDecoder()
        let todos = try decoder.decode([Todo].self, from: data)
        print("List of todos:")
        print(todos.map { " - [" + ($0.completed ? "✅" : "❌") + "] \($0.title)" }.joined(separator: "\n"))
        exit(0)
    }
    catch {
        fatalError("Error: \(error.localizedDescription)")
    }
}
task.resume()
dispatchMain()
```

If you call this example with a URL that can return a list of todos it'll print a nice list of the items.

```sh
./main.swift https://jsonplaceholder.typicode.com/todos
```

Yes, you can say that this script is completely useless, but in my opinion it's an amazing demo app, since it covers how to check command line arguments (`CommandLine.arguments`), it also shows you how to wait (`dispatchMain`) for an async task, such as a HTTP call through the network using the [URLSession API](https://theswiftdev.com/urlsession-and-the-combine-framework/) to finish and exit using the right method when something fails (`fatalError`) or if you reach the end of execution (`exit(0)`). Just a few lines of code, but it contains so much info.

> NOTE: Have you noticed the new shebang? If you have multiple Swift versions installed on your system, you can use the [env shebang](https://unix.stackexchange.com/questions/29608/why-is-it-better-to-use-usr-bin-env-name-instead-of-path-to-name-as-my/29620#29620) to go with the first one that's available in your PATH.

It's not just Foundation, but you can import AppKit or even SwiftUI. Well, not under Linux of course, since those frameworks are only available for macOS plus you will need Xcode installed on your system, since some stuff in Swift the toolchain is still tied to the IDE, but why? 😢

Anyway, back to the topic, here's the boilerplate code for a macOS application Swift script that can be started from the Terminal with one simple `./main.swift` command and nothing more.

```swift
#!/usr/bin/env swift

import AppKit
import SwiftUI

@available(macOS 10.15, *)
struct HelloView: View {
    var body: some View {
        Text("Hello world!")
    }
}

@available(macOS 10.15, *)
class WindowDelegate: NSObject, NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(0)
    }
}


@available(macOS 10.15, *)
class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    let windowDelegate = WindowDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let appMenu = NSMenuItem()
        appMenu.submenu = NSMenu()
        appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        let mainMenu = NSMenu(title: "My Swift Script")
        mainMenu.addItem(appMenu)
        NSApplication.shared.mainMenu = mainMenu
        
        let size = CGSize(width: 480, height: 270)
        window.setContentSize(size)
        window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
        window.delegate = windowDelegate
        window.title = "My Swift Script"

        let view = NSHostingView(rootView: HelloView())
        view.frame = CGRect(origin: .zero, size: size)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.center()
        window.makeKeyAndOrderFront(window)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

Special thanks goes to [karwa](https://github.com/karwa) for the [original gist](https://gist.github.com/karwa/5207e232ac9ec53f0276252ab5e3ee07). Also if you are into Storyboard-less macOS app development, you should definitely take a look at [this article](https://kicsipixel.github.io/2020/nostoryboard/) by [@kicsipixel](https://x.com/kicsipixel). These resources helped me a lot to put together what I needed. I still had to extend the gist with a proper menu setup and the activation policy, but now this version acts like a real-world macOS application that works like a charm. There is only one issue here... the script file is getting crowded. 🙈

## Swift Package Manager and macOS apps

So, if we follow the same logic, that means we can build an executable package that can invoke AppKit related stuff using the Swift Package Manager. Easy as a pie. 🥧

```sh
mkdir MyApp
cd MyApp 
swift package init --type=executable
```

Now we can separate the components into standalone files, we can also remove the availability checking, since we're going to add a platform constraint using our `Package.swift` manifest file. If you don't know much about how the Swift Package Manager works, please read [my SPM tutorial](https://theswiftdev.com/swift-package-manager-tutorial/), or if you are simply curious about the structure of a Package.swift file, you can read my article about the [Swift Package manifest file](https://theswiftdev.com/the-swift-package-manifest-file/). Let's start with the manifest updates.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyApp", dependencies: []),
        .testTarget(name: "MyAppTests", dependencies: ["MyApp"]),
    ]
)
```

Now we can place the HelloView struct into a new HelloView.swift file.

```swift
import SwiftUI

struct HelloView: View {
    var body: some View {
        Text("Hello world!")
    }
}
```

The window delegate can have its own place inside a WindowDelegate.swift file.

```swift
import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(0)
    }
}
```

We can apply the same thing to the AppDelegate class.

```swift
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    let windowDelegate = WindowDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let appMenu = NSMenuItem()
        appMenu.submenu = NSMenu()
        appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        let mainMenu = NSMenu(title: "My Swift Script")
        mainMenu.addItem(appMenu)
        NSApplication.shared.mainMenu = mainMenu
        
        let size = CGSize(width: 480, height: 270)
        window.setContentSize(size)
        window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
        window.delegate = windowDelegate
        window.title = "My Swift Script"

        let view = NSHostingView(rootView: HelloView())
        view.frame = CGRect(origin: .zero, size: size)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.center()
        window.makeKeyAndOrderFront(window)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

Finally we can update the main.swift file and initiate everything that needs to be done.

```swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

The good news is that this approach works, so you can develop, build and run apps locally, but unfortunately you can't submit them to the Mac App Store, since the final application package won't look like a real macOS bundle. The binary is not code signed, plus you'll need a real macOS target in Xcode to submit the application. Then why bother with this approach?

Well, just because it is fun and I can even avoid using Xcode with the help of [SourceKit-LSP](https://github.com/apple/sourcekit-lsp) and some [Editor configuration](https://github.com/apple/sourcekit-lsp/tree/main/Editors). The best part is that SourceKit-LSP is now [part of Xcode](https://vercantez.com/posts/Writing-Swift-in-Sublime/), so you don't have to install anything special, just configure your favorite IDE and start coding.

You can also [bundle resources](https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package), since this feature is available from Swift 5.3, and use them through the `Bundle.module` variable if needed. I already tried this, works pretty well, and it is so much fun to develop apps for the mac without the extra overhead that Xcode comes with. 🥳
