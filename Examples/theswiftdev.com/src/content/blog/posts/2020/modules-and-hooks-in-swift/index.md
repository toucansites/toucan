---
type: post
slug: modules-and-hooks-in-swift
title: Modules and hooks in Swift
description: Learn how to extend your application with new functionalities using a loosely coupled modular plugin system written in Swift.
publication: 2020-04-16 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

## How do modules (plugins) work?

Wouldn't be cool if you could create objects that could work together without knowing about each other? Imagine that you are building a dynamic form. Based on some internal conditions, the fields are going to be composed using the data coming from the enabled modules.

For example you have module A, B, C, where A is providing you Field 1, 2, 3, the B module is taking care of Field 4, 5 and C is the provider of Field 6. Now if you turn off B, you should only be able to see field 1, 2, 3 and 6. If everything is turned on you should see all the fields from 1 to 6.

We can apply this exact same pattern to many things. Just think about one of the biggest plugin ecosystem. Wordpress is using [hooks](https://www.sitepoint.com/wordpress-hook-system/) to extend the core functionalities through them. It's all based on the concept I just mentioned above. This is part of the [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) design pattern. Now the question is how do we implement something similar using Swift? 🤔

## A hook system implementation

First we start with a protocol with a point of invocation. This method will be called by the module manager to invoke the proper hook function by name. We're going to pass around a dictionary of parameters, so our hooks can have arguments. We're using the Any type here as a value, so you can send anything as a parameter under a given key.

```swift
protocol Module {
    func invoke(name: String, params: [String: Any]) -> Any?
}

extension Module {
    func invoke(name: String, params: [String: Any]) -> Any? { nil }
}
```

Now let's implement our modules using a simplified version based on the form example. 🤓

```swift
class A: Module {

    func invoke(name: String, params: [String: Any]) -> Any? {
        switch name {
        case "example_form":
            return self.exampleFormHook()
        default:
            return nil
        }
    }

    private func exampleFormHook() -> [String] {
        ["Field 1", "Field 2", "Field 3"]
    }
}

class B: Module {
    func invoke(name: String, params: [String: Any]) -> Any? {
        switch name {
        case "example_form":
            return self.exampleFormHook()
        default:
            return nil
        }
    }

    private func exampleFormHook() -> [String] {
        ["Field 4", "Field 5"]
    }
}

class C: Module {
    func invoke(name: String, params: [String: Any]) -> Any? {
        switch name {
        case "example_form":
            return self.exampleFormHook()
        default:
            return nil
        }
    }

    private func exampleFormHook() -> [String] {
        ["Field 6"]
    }
}
```

Next we need a module manager that can be initialized with an array of modules. This manager will be responsible for calling the right invocation method on every single module and it'll handle the returned response in a type-safe manner. We're going to implement two invoke method versions right away. One for merging the result and the other to return the first result of a hook.

> You can try to implement a version that can merge `Bool` values using the && operator

Here is our module manager implementation with the two generic methods:

```swift
struct ModuleManager {

    let  modules: [Module]
    
    func invokeAllHooks<T>(_ name: String, type: T.Type, params: [String: Any] = [:]) -> [T] {
        let result = self.modules.map { module in
            module.invoke(name: name, params: params)
        }
        return result.compactMap { $0 as? [T] }.flatMap { $0 }
    }

    func invokeHook<T>(_ name: String, type: T.Type, params: [String: Any] = [:]) -> T? {
        for module in self.modules {
            let result = module.invoke(name: name, params: params)
            if result != nil {
                return result as? T
            }
        }
        return nil
    }
}
```

You can use the the `invokeAllHooks` method to merge together an array of a generic type. This is the one that we can use to gather all he form fields using the underlying hook methods.

```swift
let manager1 = ModuleManager(modules: [A(), B(), C()])
let form1 = manager1.invokeAllHooks("example_form", type: String.self)
print(form1) // 1, 2, 3, 4, 5, 6

let manager2 = ModuleManager(modules: [A(), C()])
let form2 = manager2.invokeAllHooks("example_form", type: String.self)
print(form2) // 1, 2, 3, 6
```

Using the invokeHook method you can achieve a similar behavior like the chain of responsibility design pattern. The [responder chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events) works very similar similar, Apple uses [responders](https://useyourloaf.com/blog/using-the-responder-chain/) on almost every platform to handle UI events. Let me show you how it works by updating module B. 🐝

```swift
class B: Module {
    func invoke(name: String, params: [String: Any]) -> Any? {
        switch name {
        case "example_form":
            return self.exampleFormHook()
        case "example_responder":
            return self.exampleResponderHook()
        default:
            return nil
        }
    }

    private func exampleFormHook() -> [String] {
        ["Field 4", "Field 5"]
    }
    
    private func exampleResponderHook() -> String {
        "Hello, this is module B."
    }
}
```

If we trigger the new `example_responder` hook with the `invokeHook` method on both managers we'll see that the outcome is quite different.

```swift
if let value = manager1.invokeHook("example_responder", type: String.self) {
    print(value) // Hello, this is module B.
}

if let value = manager2.invokeHook("example_responder", type: String.self) {
    print(value) // this won't be called at all...
}
```

In the first case, since we have an implementation in one of our modules for this hook, the return value will be present, so we can print it. In the second case there is no module to handle the event, so the block inside the condition won't be executed. Told ya', it's like a responder chain. 😜

## Conclusion

Using modules or plugins is a powerful approach to decouple some parts of the code. I really love hook functions since they can provide extension points for almost anything in the application.

Mix this with a dynamic module loader and you have a fully-extensible next-gen backend solution on top of Vapor. You can have a compiled core system independently from the modules and later on you can upgrade just some parts of the entire stuff without touching the others. Whops... I just made that happen and I think (just like Swift) it totally rulez. 🤘🏻

I'm working hard both on my upcoming Practical server side Swift book and the open-source blog engine that's powering this site for quite a while now. I used this modular architecture a lot during the creation of my engine. Can't wait to release everything and show it to you. 😉
