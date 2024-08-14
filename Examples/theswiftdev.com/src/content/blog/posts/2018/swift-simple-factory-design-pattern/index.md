---
type: post
title: Swift simple factory design pattern
description: This time let's talk about the simple factory design pattern to encapsulate object creation in a really simple way using Swift.
publication: 2018-05-29 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

## Simple factory implementation using switch-case

The goal of this pattern is to encapsulate something that can often vary. Imagine a color palette for an application. You might have to change the colors according to the latest habit of the designer on a daily basis. I'd be really inconvenient if you had to search & replace every single instance of the color code by hand. So let's make a [simple factory](http://pengguo.xyz/tutorial/2017/03/07/Swift-World-Design-Patterns-Simple-Factory.html) in Swift that can return colors based on a given style. 🎩

```swift
class ColorFactory {

    enum Style {
        case text
        case background
    }

    func create(_ style: Style) -> UIColor {
        switch style {
        case .text:
            return .black
        case .background:
            return .white
        }
    }
}


let factory = ColorFactory()
let textColor = factory.create(.text)
let backgroundColor = factory.create(.background)
```

This can be really useful, especially if it comes to a complicated object initialization process. You can also define a protocol and return various instance types that implement the required interface using a switch case block. 🚦

```swift
protocol Environment {
    var identifier: String { get }
}

class DevEnvironment: Environment {
    var identifier: String { return "dev" }
}

class LiveEnvironment: Environment {
    var identifier: String { return "live" }
}

class EnvironmentFactory {

    enum EnvType {
        case dev
        case live
    }

    func create(_ type: EnvType) -> Environment {
        switch type {
        case .dev:
            return DevEnvironment()
        case .live:
            return LiveEnvironment()
        }
    }
}

let factory = EnvironmentFactory()
let dev = factory.create(.dev)
print(dev.identifier)
```

So, a few things to remember about the [simple factory](https://code.tutsplus.com/tutorials/design-patterns-the-simple-factory-pattern--cms-22345) design pattern:

    + it helps loose coupling by separating init & usage logic 🤔
    + it's just a wrapper to encapsulate things that can change often 🤷‍♂️
    + simple factory can be implemented in Swift using an enum and a switch-case
    + use a protocol if you are planning to return different objects (POP 🎉)
    + keep it simple 🏭

[This pattern](http://www.sihui.io/design-pattern-factory/) separates the creation from the actual usage and moves the responsibility to a specific role, so if something changes you only have to modify the factory. You can leave all your tests and everything else completely untouched. Powerful and simple! 💪


