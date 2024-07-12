---
slug: swift-visitor-design-pattern
title: Swift visitor design pattern
description: The visitor design pattern in Swift allows us to add new features to an existing group of objects without altering the original code.
publication: 2022-04-06 16:20:00
tags: Swift, iOS, design patterns
---

## A basic visitor example

The [visitor design pattern](https://en.wikipedia.org/wiki/Visitor_pattern) is one of the behavioral patterns, it is used to extend an object with a given functionality without actually modifying it. Sounds cool, right? Actually this pattern is what gives SwiftUI superpowers, let me show you how it works.

```swift
open class View {}

final class FirstView: View {}
final class SecondView: View {}
final class ThirdView: View {}

struct HeightVisitor {
    func visit(_ view: FirstView) -> Float { 16 }
    func visit(_ view: SecondView) -> Float { 32 }
    func visit(_ view: ThirdView) -> Float { 64 }
}

protocol AcceptsHeightVisitor {
    func accept(_ visitor: HeightVisitor) -> Float
}

extension FirstView: AcceptsHeightVisitor {
    func accept(_ visitor: HeightVisitor) -> Float { visitor.visit(self) }
}

extension SecondView: AcceptsHeightVisitor {
    func accept(_ visitor: HeightVisitor) -> Float { visitor.visit(self) }
}

extension ThirdView: AcceptsHeightVisitor {
    func accept(_ visitor: HeightVisitor) -> Float { visitor.visit(self) }
}

let visitor = HeightVisitor()
let view1: AcceptsHeightVisitor = FirstView()
let view2: AcceptsHeightVisitor = SecondView()
let view3: AcceptsHeightVisitor = ThirdView()


print(view1.accept(visitor))
print(view2.accept(visitor))
print(view3.accept(visitor))
```

First we define our custom view classes, this will help to visualize how the pattern works. Next we define the actual HeightVisitor object, which can be used to calculate the height for each view type (FirstView, SecondView, ThirdView). This way we don't have to alter these views, but we can define a protocol AcceptsHeightVisitor, and extend our classes to accept this visitor object and calculate the result using a self pointer. 👈

On the call side we can initiate a new visitor instance and simply define the views using the protocol type, this way it is possible to call the accept visitor method on the views and we can calculate the height for each type without altering the internal structure of these classes.

## A generic visitor

We can also make this pattern more generic by creating a Swift protocol with an associated type.

```swift
open class View {}

final class FirstView: View {}
final class SecondView: View {}
final class ThirdView: View {}

struct HeightVisitor {
    func visit(_ view: FirstView) -> Float { 16 }
    func visit(_ view: SecondView) -> Float { 32 }
    func visit(_ view: ThirdView) -> Float { 64 }
}

protocol Visitor {
    associatedtype R
    func visit<O>(_ object: O) -> R
}

protocol AcceptsVisitor {
    func accept<V: Visitor>(_ visitor: V) -> V.R
}

extension AcceptsVisitor {
    func accept<V: Visitor>(_ visitor: V) -> V.R { visitor.visit(self) }
}

extension FirstView: AcceptsVisitor {}
extension SecondView: AcceptsVisitor {}
extension ThirdView: AcceptsVisitor {}

extension HeightVisitor: Visitor {

    func visit<O>(_ object: O) -> Float {
        if let o = object as? FirstView {
            return visit(o)
        }
        if let o = object as? SecondView {
            return visit(o)
        }
        if let o = object as? ThirdView {
            return visit(o)
        }
        fatalError("Visit method unimplemented for type \(O.self)")
    }
}

let visitor = HeightVisitor()
let view1: AcceptsVisitor = FirstView()
let view2: AcceptsVisitor = SecondView()
let view3: AcceptsVisitor = ThirdView()

print(view1.accept(visitor))
print(view2.accept(visitor))
print(view3.accept(visitor))

// this will crash for sure...
// class FourthView: View {}
// extension FourthView: AcceptsVisitor {}
// FourthView().accept(visitor)
```

You can use the generic Visitor protocol to define the visitor and the AcceptsVisitor protocol to easily extend your objects to accept a generic visitor type. If you choose this approach you still have to implement the generic visit method on the Visitor, cast the object type and call the type specific visit method. This way we moved the visit call logic into the visitor. 🙃

Since the views already conforms to the AcceptsVisitor protocol, we can easily extend them with other visitors. For example we can define a color visitor like this:

```swift
struct ColorVisitor: Visitor {
    func visit(_ view: FirstView) -> String { "red" }
    func visit(_ view: SecondView) -> String { "green" }
    func visit(_ view: ThirdView) -> String { "blue" }
    
    func visit<O>(_ object: O) -> String {
        if let o = object as? FirstView {
            return visit(o)
        }
        if let o = object as? SecondView {
            return visit(o)
        }
        if let o = object as? ThirdView {
            return visit(o)
        }
        fatalError("Visit method unimplemented for type \(O.self)")
    }
}

let visitor = ColorVisitor()
let view1: AcceptsVisitor = FirstView()
let view2: AcceptsVisitor = SecondView()
let view3: AcceptsVisitor = ThirdView()

print(view1.accept(visitor))
print(view2.accept(visitor))
print(view3.accept(visitor))
```

As you can see it's pretty nice that we can achieve this kind of dynamic object extension logic through visitors. If you want to see a practical UIKit example, feel free to take a look at [this article](https://sudonull.com/post/7200-Architectural-pattern-Visitor-Visitor-in-the-universe-of-iOS-and-Swift). Under the hood SwiftUI heavily utilizes the visitor pattern to achieve some [magical TupleView & ViewBuilder related stuff](https://forums.swift.org/t/swiftui-viewbuilder-result-is-a-tupleview-how-is-apple-using-it-and-able-to-avoid-turning-things-into-anyview/28181/4). This pattern is so cool, I highly recommend to learn more about it. 💪
