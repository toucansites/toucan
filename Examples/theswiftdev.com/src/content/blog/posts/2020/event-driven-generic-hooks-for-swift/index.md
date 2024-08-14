---
type: post
title: Event-driven generic hooks for Swift
description: In this article I am going to show you how to implement a basic event processing system for your modular Swift application.
publication: 2020-11-27 16:20:00
tags: 
    - design-pattern
    - swift
authors:
    - tibor-bodecs
---

## Dependencies, protocols and types

When we write Swift, we can import frameworks and other third party libraries. It's quite natural, just think about Foundation, UIKit or nowadays it's more likely SwiftUI, but there are many other dependencies that we can use. Even when we don't import anything we usually create separate structures or classes to build smaller components instead of one gigantic spaghetti-like file, function or whatever. Consider the following example:

```swift
struct NameProvider {
    func getName() -> String { "John Doe" }
}


struct App {
    let provider = NameProvider()
    
    func run() {
        let name = provider.getName()
        print("Hello \(name)!")
    }
}

let app = App()
app.run()
```

It shows us the basics of the [separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns) principle. The App struct the representation of our main application, which is a simple "Hello World!" app, with a twist. The name is not hardcoded into the App object, but it's coming from a NameProvider struct.

The thing that you should notice is that we've created a static dependency between the App and the NameProvider object here. We don't have to import a framework to create a dependency, these objects are in the same namespace, but still the application will always require the NameProvider type at compilation time. This is not bad, but sometimes it's not what we really want.

How can we solve this? Wait I have an idea, let's create a protocol! 😃

```swift
import Foundation

struct MyNameProvider: NameProvider {
    func getName() -> String { "John Doe" }
}


protocol NameProvider {
    func getName() -> String
}

struct App {
    let provider: NameProvider
    
    func run() {
        let name = provider.getName()
        print("Hello \(name)!")
    }
}

let provider = MyNameProvider()
let app = App(provider: provider)
app.run()
```

Oh no, this just made our entire codebase a bit harder to understand, also didn't really solved anything, because we still can't compile our application without the MyNameProvider dependency. That class must be part of the package no matter how many protocols we create. Of course we could move the NameProvider protocol into a standalone [Swift package](https://theswiftdev.com/swift-package-manager-tutorial/), then we could create another package for the protocol implementation that relies on that one, then use both as a dependency when we build our application, but hey isn't this getting a little bit complicated? 🤔

What did we gain here? First of all we overcomplicated a really simple thing. On the other hand, we eliminated an actual dependency from the App struct itself. That's a great thing, because now we could create a mock name provider and test our application instance with that, we can [inject any kind of Swift object](https://theswiftdev.com/swift-dependency-injection-design-pattern/) into the app that conforms to the NameProvider protocol.

Can we change the provider at runtime? Well, yes, that's also possible we could define the provider as a variable and alter its value later on, but there's one thing that we can't solve with this approach. 

**We can't move out the provider reference from the application itself.** 😳

## Event-driven architecture

The EDA design pattern allows us to create loosely coupled software components and services without forming an actual dependency between the participants. Consider the following alternative:

```swift
struct MyNameProvider {
    func getName(_: HookArguments) -> String { "John Doe" }
}

struct App {

    func run() {
        guard let name: String = hooks.invoke("name-event") else {
            fatalError("Someone must provide a name-event handler.")
        }
        print("Hello \(name)!")
    }
}

let hooks = HookStorage()

let provider = MyNameProvider()
hooks.register("name-event", use: provider.getName)

let app = App()
app.run()
```

Don't try to compile this yet, there are some additional things that we'll need to implement, but first I am going to explain this snippet step-by-step. The MyNameProvider struct getName function signature changed a bit, because in an event-driven world we need a unified function signature to handle all kind of scenarios. Fortunately we don't have to erease the return type to Any thanks to the amazing generic support in Swift. This HookArguments type will be just an alias for a dictionary that has String keys and it can have Any value.

Now inside the App struct we call-out for the hook system and invoke an event with the "name-event" name. The invoke method is a function with a generic return type, it actually returns an optional generic value, hence the guard statement with the explicit String type. Long story short, we call something that can return us a String value, in other words we fire the name event. 🔥

The very last part is the setup, first we need to initialize our hook system that will store all the references for the event handlers. Next we create a provider and register our handler for the given event, finally we make the app and run everything.

I'm not saying that this approach is less complicated than the protocol oriented version, but it's very different for sure. Unfortunately we still have to build our event handler system, so let's get started.

```swift
public typealias HookArguments = [String: Any]

/// a hook function is something that can be invoked with a given arguments
public protocol HookFunction {
    func invoke(_: HookArguments) -> Any
}

/// a hook function signature with a generic return type
public typealias HookFunctionSignature<T> = (HookArguments) -> T
```

As I mentioned this before, the HookArguments is just a typealias for the [String:Any] type, this way we are going to be able to pass around any kind of values under given keys for the hook functions. Next we define a protocol for invoking these functions, and finally we build up a function signature for our hooks, this is going to be used during the registration process. 🤓

```swift
public struct AnonymousHookFunction: HookFunction {

    private let functionBlock: HookFunctionSignature<Any>

    /// anonymous hooks can be initialized using a function block
    public init(_ functionBlock: @escaping HookFunctionSignature<Any>) {
        self.functionBlock = functionBlock
    }

    /// since they are hook functions they can be invoked with a given argument
    public func invoke(_ args: HookArguments) -> Any {
        functionBlock(args)
    }
}
```

The AnonymousHookFunction is a helper that we can use to pass around blocks instead of object pointers when we register a new hook function. It can be quite handy sometimes to write an event handler without creating additional classes or structs. We are going to also need to associate these hook function pointers with an event name and an actual a return type...

```swift
public final class HookFunctionPointer {

    public var name: String
    public var pointer: HookFunction
    public var returnType: Any.Type
    
    public init(name: String, function: HookFunction, returnType: Any.Type) {
        self.name = name
        self.pointer = function
        self.returnType = returnType
    }
}
```

The HookFunctionPointer is used inside the hook storage, that's the core building block for this entire system. The hook storage is the place where all your event handlers live and you can call these events through this storage pointer when you need to trigger an event. 🔫

```swift
public final class HookStorage {
    
    private var pointers: [HookFunctionPointer]

    public init() {
        self.pointers = []
    }

    public func register<ReturnType>(_ name: String, use block: @escaping HookFunctionSignature<ReturnType>) {
        let function = AnonymousHookFunction { args -> Any in
            block(args)
        }
        let pointer = HookFunctionPointer(name: name, function: function, returnType: ReturnType.self)
        pointers.append(pointer)
    }

    /// invokes the first hook function with a given name and the provided arguments
    public func invoke<ReturnType>(_ name: String, args: HookArguments = [:]) -> ReturnType? {
        pointers.first { $0.name == name && $0.returnType == ReturnType.self }?.pointer.invoke(args) as? ReturnType
    }

    /// invokes all the available hook functions with a given name
    public func invokeAll<ReturnType>(_ name: String, args: HookArguments = [:]) -> [ReturnType] {
        pointers.filter { $0.name == name && $0.returnType == ReturnType.self }.compactMap { $0.pointer.invoke(args) as? ReturnType }
    }
}
```

I know, this seems like quite complicated at first sight, but when you start playing around with these methods it'll all make sense. I'm still not sure about the naming conventions, for example the HookStorage is also a global event storage so maybe it'd be better to call it something related to the event term. If you have a better idea, feel free to [tweet me](https://x.com/tiborbodecs).

Oh, I almost forgot that I wanted to show you how to register an anonymous hook function. 😅

```swift
hooks.register("name-event") { _ in "John Doe" }
```

That's it you don't event have to write the return type, the Swift compiler this time is smart enough to figure out the final function signature. This magic only works with one-liners I suppose... ✨

This article was a follow-up on [the modules and hooks in Swift](https://theswiftdev.com/modules-and-hooks-in-swift/), also heavily inspired by the my old Entropy framework, Drupal and the [Wordpress](https://www.sitepoint.com/wordpress-hook-system/) hook systems. The code implementation idea comes from the [Vapor's routing abstraction](https://github.com/vapor/vapor/tree/master/Sources/Vapor/Routing), but it's slightly changed to match my needs.

The event-driven design approach is a very nice architecture and I really hope that we'll see the long term benefit of using this pattern inside [Feather](https://github.com/binarybirds/feather/). I can't wait to tell you more about it... 🪶
