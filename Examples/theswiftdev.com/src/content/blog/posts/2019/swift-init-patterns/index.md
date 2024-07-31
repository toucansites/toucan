---
type: post
slug: swift-init-patterns
title: Swift init patterns
description: The ultimate guide how to init your Swift data types, with the help of designated, convenience, failable intitializers and more.
publication: 2019-08-25 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

## What is initialization?

> [Initialization](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html#//apple_ref/doc/uid/TP40014097-CH18-ID203) is the process of preparing an instance of a class, structure, or enumeration for use.

This process is handled through [initializers](https://www.iphonelife.com/blog/31369/swift-101-demystifying-swifts-initializers), an initializer is just a special kind of function, usually the init keyword is reserved for them - so you don't have to use the func keyword - and usually you don't return any value from an initializer.

## Initializing properties

Classes and structures must set all of their stored properties to an appropriate initial value by the time an instance of that class or structure is created.
First imagine a really simple struct, that has only two properties.

```swift
struct Point {
    let x: Int
    let y: Int
}
```

Now, the rule above says that we have to init all the properties, so let's make that by creating our very first init method.

```swift
struct Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
```

It's just like every other Swift function. Now we're able to create our first point.

```swift
let p1 = Point(x: 1, y: 1)
```

Note that you don't have to initialize implicitly unwrapped optional properties, and optional properties, if they are variables and not constants.

The same logic applies for classes, you can try it by changing the struct keyword to class. However structs are value types, classes are reference types and this difference will provide us some unique capabilities for both types.

## Memberwise initializer (ONLY for structs)

The nice thing about structs is that the compiler will generate a memberwise init for free if you don't provide your own init method. However there are a quite a few catches. The generated method will contain all the properties (optionals too) except constants with default values, and it will have an internal access type, so it's not going to be visible from another modules.

> The default memberwise initializer for a structure type is considered private if any of the structure’s stored properties are private. Likewise, if any of the structure's stored properties are file private, the initializer is file private. Otherwise, the initializer has an access level of internal.

```swift
struct Point {
    let x: Int
    let y: Int
    var key: Int!
    let label: String? = "zero"
}
let p1 = Point(x: 0, y: 0, key: 0) // provided by the memberwise init
```

## Failable initializer

Sometimes things can go wrong, and you don't want to create bad or invalid objects, for example you'd like filter out the origo from the list of valid points.

```swift
struct Point {
    let x: Int
    let y: Int

    init?(x: Int, y: Int) { // ? marks that this could fail
        if x == 0 && y == 0 {
            return nil
        }
        self.x = x
        self.y = y
    }
}
let p1 = Point(x: 0, y: 0) // nil
let p2 = Point(x: 1, y: 1) // valid point
```

Enumerations that deliver from a RawRepresentable protocol can be initialized through rawValues, that's also a failable init pattern:

```swift
enum Color: String {
    case red
    case blue
    case yellow
}

let c1 = Color(rawValue: "orange") // nil, no such case
let c2 = Color(rawValue: "red") // .red
```

You can also use init! instead of init?, that'll create an implicitly unwrapped optinal type of the instance. Note that classes can also have failable initializers.

## Initializing pure Swift classes

You know classes are native types in the Swift programming language. You don't even have to import the Foundation framework in order to create a brand new class. Here is the exact same Point object represented by a pure Swift class:

```swift
class Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
let p1 = Point(x: 1, y: 1)
```

This time we had to provide the init method by ourselves, because classes don't have memberwise initializers. They are reference types, and inheritance logic, so it'd be more complex to generate memberwise init methods for them.

## Default initializer

For Swift classes you will only get an internal default initializer for free if you provide default values for all the stored properties, even for optional ones. In practice it looks something like this:

```swift
class Point {
    let x: Int = 1
    let y: Int = 1
}
let p1 = Point()
```

Or if we follow the previous example:

```swift
class Point {
    let x: Int = 0
    let y: Int = 0
    var key: Int!
    let label: String? = "zero"
}
let p1 = Point()
```

This feels so wrong. Why would a point have a key and a label property? It'd be nice to have a child object which could have the extra properties. It's time to refactor this code with some class inheritance.

## Designated initializer

> Designated initializers are the primary initializers for a class.

In other words, it's not marked with the convenience keyword. A class can also have mutliple designated initializers. So let's continue with our Point class, which is going to be the superclass of our NamedPoint class.

```swift
class Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) { // this is the designated initializer
        self.x = x
        self.y = y
    }
}

class NamedPoint: Point {

    let label: String?

    init(x: Int, y: Int, label: String?) { // designated
        self.label = label

        super.init(x: x, y: y)
    }

    init(point: Point, label: String?) { // also designated
        self.label = label
        super.init(x: point.x, y: point.y) // delegating up
    }
}

let p1 = NamedPoint(x: 1, y: 1, label: "first")
let p2 = NamedPoint(point: Point(x: 1, y: 1), label: "second")
```

A [designated initializer](http://www.codingexplorer.com/designated-initializers-convenience-initializers-swift/) must always call a designated initializer from its immediate superclass, so you have to delegate up the chain. But first we had to initialize all of our properties, by the first rule of initialization. So this means that the Swift language has a two-phase initialization process.

## Two-Phase Initialization

1. Every stored property is assigned an intial value by the class that introduced it.
2. Each class is given the opportunity to customize it's stored properies.

So by these rules, first we had to init the label property, then delegate up and only after then we gave the opportunity to do other things.

## Convenience initializer

They are initializers used to make initialization a bit easier.

So for example in our previous case if we could have an initializers for points where x and y are equal numbers. That'd be pretty handy in some cases.

```swift
class Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    convenience init(z: Int) {
        self.init(x: z, y: z) // we're calling the designated init
    }
}
let p1 = Point(z: 1)
```

A convenience initializer must call another initializer from the same class and ultimately call a designated initializer. Stucts can also have "convenience" initializer like init methods, but you don't have to write out the keyword, actually those init methods are slightly differnet, you can just call out from one to another, that's why it looks like the same.

```swift
struct Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(z: Int) {
        self.init(x: z, y: z)
    }
}

var p1 = Point(z: 1)
```

## Required initializer

If you mark an initializer required in your class, all the direct - you have to mark as required in every level - subclasses of that class have to implement it too.

```swift
class Point {
    let x: Int
    let y: Int

    required init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

class NamedPoint: Point {
    let label: String?

    required init(x: Int, y: Int) {
        self.label = nil

        super.init(x: x, y: y)
    }
}

let p1 = NamedPoint(x: 1, y: 1)
```

## Override initializer

In Swift initializers are not inherited for subclasses by default. If you want to provide the same initializer for a subclass that the parent class already has, you have to use the override keyword.

```swift
class Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

class NamedPoint: Point {
    let label: String?

    override init(x: Int, y: Int) {
        self.label = nil

        super.init(x: x, y: y)
    }
}

let p1 = NamedPoint(x: 1, y: 1)
```

There are two rules of init inheritance, here is the first...

> If your subclass doesn’t define any designated initializers, it automatically inherits all of its superclass designated initializers.

...and the second:

> If your subclass provides an implementation of all of its superclass designated initializers—either by inheriting them as per rule 1, or by providing a custom implementation as part of its definition—then it automatically inherits all of the superclass convenience initializers.

## Deinitialization

> A deinitializer is called immediately before a class instance is deallocated.
> 
So if you want to do some manual cleanup when your class is being terminated, this is the method that you are looking for. You don't have to deal with memory management in most of the cases, because ARC will do it for you.

```swift
class Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    deinit {
        print("Point is clenaed up.")
    }
}

var p1: Point? = Point(x: 1, y: 1)
p1 = nil //deinit is being called
```
