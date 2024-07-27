---
type: post
slug: swift-dependency-injection-design-pattern
title: Swift dependency injection design pattern
description: Want to learn the Dependency Injection pattern using Swift? This tutorial will show you how to write loosely coupled code using DI.
publication: 2018-07-17 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

First of all I really like this little quote by James Shore:

> Dependency injection means giving an object its instance variables. Really. That's it.

In my opinion the whole story is just a little bit more complicated, but if you tear down the problem to the roots, you'll realize that implementing the [DI pattern](http://ilya.puchka.me/dependency-injection-in-swift/) can be as simple as giving an object instance variables. No kidding, it's really a no-brainer, but many developers are over complicating it and using injections at the wrong places. 💉

Learning [DI](https://clean-swift.com/advanced-dependency-injection/) is not about the implementation details, it's all about how are you going to use the pattern. There are four little variations of dependency injection, let's go through them by using real world examples that'll help you to get an idea about when to use dependency injection. Now grab your keyboards! 💻

## Dependency Injection basics

As I mentioned before DI is a fancy term for a simple concept, you don't really need external libraries or frameworks to start using it. Let's imagine that you have two separate objects. Object A wants to use object B. Say hello to your first dependency.

If you hardcode object B into object A that's not going to be good, because from that point A can not be used without B. Now scale this up to a ~100 object level. If you don't do something with this problem you'll have a nice bowl of spaghetti. 🍝

So the main goal is to create independent objects as much as possible or some say loosely coupled code, to improve reusability and testability. Separation of concerns and decoupling are right terms to use here too, because in most of the cases you should literally separate logical functionalities into standalone objects. 🤐

So in theory both objects should do just one specific thing, and the dependency between them is usually realized through a common descriptor (protocol), without hardcoding the exact instances. Using [dependency injection](http://www.jamesshore.com/Blog/Dependency-Injection-Demystified.html) for this purpose will improve your code quality, because dependencies can be replaced without changing the other object's implementation. That's good for mocking, testing, reusing [etc](https://cocoacasts.com/nuts-and-bolts-of-dependency-injection-in-swift). 😎

## How to do DI in Swift?

Swift is an amazing programming language, with excellent support for both protocol and object oriented principles. It also has great functional capabilities, but let's ignore that for now. Dependency injection can be done in [multiple ways](https://www.swiftbysundell.com/posts/different-flavors-of-dependency-injection-in-swift), but in this tutorial I'll focus on just a few basic ones without any external dependency injection. 😂

Well, let's start with a protocol, but that's just because Swift is not exposing the `Encoder` for the public, but we'll need something like that for the demos.

```swift
protocol Encoder {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}
extension JSONEncoder: Encoder { }
extension PropertyListEncoder: Encoder { }
```

Property list and JSON encoders already implement this method we'll only need to extend our objects to comply for our brand new protocol.

## Constructor injection

The most common form of dependency injection is constructor injection or initializer-based injection. The idea is that you pass your dependency through the initializer and store that object inside a (private read-only / immutable) property variable. The main benefit here is that your object will have every dependency - by the time it's being created - in order to work properly. 🔨

```swift
class Post: Encodable {

    var title: String
    var content: String

    private var encoder: Encoder

    private enum CodingKeys: String, CodingKey {
        case title
        case content
    }

    init(title: String, content: String, encoder: Encoder) {
        self.title = title
        self.content = content
        self.encoder = encoder
    }

    func encoded() throws -> Data {
        return try self.encoder.encode(self)
    }
}

let post = Post(title: "Hello DI!", content: "Constructor injection", encoder: JSONEncoder())

if let data = try? post.encoded(), let encoded = String(data: data, encoding: .utf8) {
    print(encoded)
}
```

You can also give a default value for the encoder in the constructor, but you should fear the **bastard injection anti-pattern**! That means if the default value comes from another module, your code will be tightly coupled with that one. So think twice! 🤔

## Property injection

Sometimes initializer injection is hard to do, because your class have to inherit from a system class. This makes the process really hard if you have to work with views or controllers. A good solution for this situation is to use a property-based injection design pattern. Maybe you can't have full control over initialization, but you can always control your properties. The only disadvantage is that you have to check if that property is already presented (being set) or not, before you do anything with it. 🤫

```swift
class Post: Encodable {

    var title: String
    var content: String

    var encoder: Encoder?

    private enum CodingKeys: String, CodingKey {
        case title
        case content
    }

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    func encoded() throws -> Data {
        guard let encoder = self.encoder else {
            fatalError("Encoding is only supported with a valid encoder object.")
        }
        return try encoder.encode(self)
    }
}

let post = Post(title: "Hello DI!", content: "Property injection")
post.encoder = JSONEncoder()

if let data = try? post.encoded(), let encoded = String(data: data, encoding: .utf8) {
    print(encoded)
}
```

There are lots of property injection patterns in iOS frameworks, [delegate patterns](https://theswiftdev.com/2018/06/27/swift-delegate-design-pattern/) are often implemented like this. Also another great benefit is that these properties can be mutable ones, so you can replace them on-the-fly. ✈️

## Method injection

If you need a dependency only once, you don't really need to store it as an object variable. Instead of an initializer argument or an exposed mutable property, you can simply pass around your dependency as a method parameter, this technique is called method injection or some say parameter-based injection. 👍

```swift
class Post: Encodable {

    var title: String
    var content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    func encode(using encoder: Encoder) throws -> Data {
        return try encoder.encode(self)
    }
}

let post = Post(title: "Hello DI!", content: "Method injection")

if let data = try? post.encode(using: JSONEncoder()), let encoded = String(data: data, encoding: .utf8) {
    print(encoded)
}
```

Your dependency can vary each time this method gets called, it's not required to keep a reference from the dependency, so it's just going to be used in a local method scope.

## Ambient context

Our last pattern is quite a dangerous one. It should be used only for universal dependencies that are being shared alongside multiple object instances. Logging, analytics or a caching mechanism is a good example for this. 🚧

```swift
class Post: Encodable {

    var title: String
    var content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    func encoded() throws -> Data {
        return try Post.encoder.encode(self)
    }


    private static var _encoder: Encoder = PropertyListEncoder()

    static func setEncoder(_ encoder: Encoder) {
        self._encoder = encoder
    }

    static var encoder: Encoder {
        return Post._encoder
    }
}

let post = Post(title: "Hello DI!", content: "Ambient context")
Post.setEncoder(JSONEncoder())

if let data = try? post.encoded(), let encoded = String(data: data, encoding: .utf8) {
    print(encoded)
}
```

Ambient context has some disadvantages. It might fits well in case of cross-cutting concerns, but it creates implicit dependencies and represents a global mutable state. It's not highly recommended, you should consider the other dependency injection patterns first, but sometimes it can be a right fit for you.

That's all about dependency injection patterns in a nutshell. If you are looking for more, you should read the following sources, because they're all amazing. Especially the first one by [Ilya Puchka](https://x.com/ilyapuchka), that's highly recommended. 😉
