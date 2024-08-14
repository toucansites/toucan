---
type: post
title: Comparing factory design patterns
description: Learn what's the difference between static factory, simple factory, factory method and abstract factory using the Swift language.
publication: 2018-06-05 16:20:00
tags: 
    - design patterns
authors:
  - tibor-bodecs
---

I thought that I'd be nice to have a summarized comparison between all the factory patterns, so here it is everything that you should know about them. Constructing them is relatively straightforward, in this example I'm going to use some `UIColor` magic written in the Swift programming language to show you the basics. 🧙‍♂️

## Static factory

- no separate factory class
- named static method to initialize objects
- can have cache & can return subtypes

```swift
extension UIColor {
    static var primary: UIColor { return .black }
    static var secondary: UIColor { return .white }
}

let primary = UIColor.primary
let secondary = UIColor.secondary
```

## Simple factory

- one factory class
- switch case objects inside of it
- encapsulates varying code
- if list is too big use factory method instead

```swift
class ColorFactory {
    enum Style {
        case primary
        case secondary
    }

    func create(_ style: Style) {
        switch style
        case .primary:
            return .black
        case .secondary:
            return .white
    }
}
let factory = ColorFactory()
let primary = factory.create(.primary)
let secondary = factory.create(.secondary)
```

## Factory method

- multiple (decoupled) factory classes
- per-instance factory method
- create a simple protocol for factory

```swift
protocol ColorFactory {
    func create() -> UIColor
}

class PrimaryColorFactory: ColorFactory {
    func create() -> UIColor {
        return .black
    }
}

class SecondaryColorFactory: ColorFactory {
    func create() -> UIColor {
        return .white
    }
}

let primaryColorFactory = PrimaryColorFactory()
let secondaryColorFactory = SecondaryColorFactory()
let primary = primaryColorFactory.create()
let secondary = secondaryColorFactory.create()
```

## Abstract factory

- combines simple factory with factory method
- has a global effect on the whole app

```swift
// exact same factory method pattern from above
protocol ColorFactory {
    func create() -> UIColor
}

class PrimaryColorFactory: ColorFactory {
    func create() -> UIColor {
        return .black
    }
}

class SecondaryColorFactory: ColorFactory {
    func create() -> UIColor {
        return .white
    }
}

// simple factory pattern from above using the factory methods
class AppColorFactory: ColorFactory {

    enum Theme {
        case dark
        case light
    }

    func create(_ theme: Theme) -> UIColor {
        switch theme {
        case .dark:
            return PrimaryColorFactory().create()
        case .light:
            return SecondaryColorFactory().create()
        }
    }
}

let factory = AppColorFactory()
let primaryColor = factory.create(.dark)
let secondaryColor = factory.create(.light)
```

So these are all the factory patterns using practical real world examples written in Swift. I hope my series of articles will help you to gain a better understanding. 👍
