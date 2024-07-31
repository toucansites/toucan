---
type: post
slug: swift-static-factory-design-pattern
title: Swift static factory design pattern
description: In this article I'll teach you about the static factory design pattern and show some use cases using the Swift programming language.
publication: 2018-05-28 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

## Real world static factory pattern examples

## Named constructors

The first good thing about the static factory pattern is that every static factory method can have a name. Apple uses this pattern in their `UIColor` class implementation to [create](http://www.informit.com/articles/article.aspx?p=1216151) named colors like `.red`, `.yellow`, etc. Please note that the implementation in Swift is not really a method, but a static property, which returns the actual instance.

```swift
public extension TimeInterval {
    public static var second: TimeInterval { return 1 }
    public static var minute: TimeInterval { return 60 }
    public static var hour: TimeInterval { return 3_600 }
    public static var day: TimeInterval { return 86_400 }
    public static var week: TimeInterval { return 604_800 }
}
```

If it's so hard to memorize how many seconds is a day or a week why don't we create a named initializer for it. See? `TimeInterval.week` is much better than `604_800`. 😅

## Cached objects

The next good thing about the static factory pattern is that it can support caching for the sake of better memory usage. This way you can limit the number of objects created if you are initializing it through the static [constructor](https://dzone.com/articles/constructors-or-static-factory-methods) (aka. static [factory method](http://www.bernardosulzbach.com/oo-development/static-factory-vs-constructors/)). 🏭

```swift
class Service {

    var name: String

    // MARK: - cache

    private static var cache: [String:Service] = [:]

    private static func cached(name: String) -> Service {
        if Service.cache[name] == nil {
            Service.cache[name] = Service(named: name)
        }
        return Service.cache[name]!
    }

    // MARK: - static factory

    static var local: Service {
        return Service.cached(name: "local")
    }

    static var remote: Service {
        return Service.cached(name: "remote")
    }

    // MARK: - init

    init(named name: String) {
        self.name = name
    }
}
```

## Local initialization scope

Another good thing about static factory methods that you can limit the initialization of a class to a private scope level. In other words object creation will only be available through the static factory method. You just have to make the `init` method private.

```swift
public final class Service {

    var name: String

    private init(name: String) {
        self.name = name
    }

    public static var local: Service {
        return Service(name: "local")
    }

    public static var remote: Service {
        return Service(name: "remote")
    }
}
```

Note that you can restrict subclassing with the final & static keyword. If you want to allow subclassing you should remove `final` and use the `class` keyword instead of the `static` for the properties, this way subclasses can override factory methods. 🤔

## Statically return anything

Static factory can also return subtypes of a given object, but why don't we take this even one step further? You can also return any kind of type from a static method, I know this seems like a cheat, because I'm not creating an instance of `UIColor` here, but I believe that it's worth to mention this method here, because it's closely related to static factories. This technique can be really useful sometimes. 😛

```swift
extension UIColor {

    private static func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

    static var redImage: UIImage {
        return UIColor.image(with: .red)
    }
}
```
