---
slug: beginners-guide-to-modern-generic-programming-in-swift
title: Beginner's guide to modern generic programming in Swift
description: Learn the very basics about protocols, existentials, opaque types and how they are related to generic programming in Swift.
publication: 2022-06-28 16:20:00
tags: Swift, generics
---

## Protocols (with associated types)

According to the Swift language guide a [protocol](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html) can define a blueprint of methods, properties and other requirements. It's pretty easy to pre-define properties and methods using a protocol, the syntax is pretty straightforward, the problem starts to occur when we start to work with associated types. The very first question that we have to answer is this: what are associated types exactly?

An [associated type](https://www.avanderlee.com/swift/associated-types-protocols/) is a generic placeholder for a specific type. We don't know that type until the protocol is being adopted and the exact type is specified by the implementation.

```swift
protocol MyProtocol {
    associatedtype MyType
    
    var myVar: MyType { get }
    
    func test()
}

extension MyProtocol {
    
    func test() {
        print("is this a test?")
    }
}
struct MyIntStruct: MyProtocol {
    typealias MyType = Int
    
    var myVar: Int { 42 }
}

struct MyStringStruct: MyProtocol {
    let myVar = "Hello, World!"
}

let foo = MyIntStruct()
print(foo.myVar)
foo.test()

let bar = MyStringStruct()
print(bar.myVar)
bar.test()
```

As you can see, associated MyType placeholder can have different types, when we implement the protocol. In the first case (MyIntStruct) we have explicitly told the compiler - by using a typealias - to use an Int type, and in the second case (`MyStringStruct`) the Swift compiler is smart enough to figure out the type of the myVar based on the provided String value.

Of course we can explicitly write `let myVar: String = "Hello, World!"` or use a computed property or a regular variable, it really doesn't matter. The key takeaway is that we've defined the type of the MyType placeholder when we implemented the protocol using the two struct. 🔑

You can use an associated type to serve as a generic placeholder object so you don't have to duplicate code if you need support for multiple different types.

## Existentials (any)

Great, our generic protocol has a default test method implementation that we can use on both objects, now here's the thing, I don't really care about the type that's going to implement my protocol, I just want to call this test function and use the protocol as a type, can I do that? Well, if you are using Swift 5.6+ the answer is yes, otherwise...

```swift
// 
// ERROR:
//
// Protocol 'MyProtocol' can only be used as a generic constraint 
// because it has Self or associated type requirements
//
let myObject: MyProtocol 

// even better example, an array of different types using the same protocol
let items: [MyProtocol]
```

I bet that you've seen this famous error message before. What the hell is happening here?

The answer is quite simple, the compiler can't figure out the underlying associated type of the protocol implementations, since they can be different types (or should I say: dynamic at runtime 🤔), anyway, it's not determined at compile time.

The latest version of the Swift programming language solves this issue by introducing [a new any keyword](https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md), which is a type-erasing helper that will box the final type into a wrapper object that can be used as an existential type. Sounds complicated? Well it is. 😅

```swift
// ...

let myObject: any MyProtocol 

let items: [any MyProtocol] = [MyIntStruct(), MyStringStruct()]

for item in items {
    item.test()
}
```

By using the any keyword the system can create an invisible box type that points to the actual implementation, the box has the same type and we can call the shared interface functions on it.

- any HiddenMyProtocolBox: MyProtocol --- pointer ---> MyIntStruct
- any HiddenMyProtocolBox: MyProtocol --- pointer ---> MyStringStruct

This approach allows us to put different protocol implementations with Self associated type requirements into an array and call the test method on both of the objects.

If you really want to understand how these things work, I highly recommend to watch the [Embrace Swift Generics](https://developer.apple.com/videos/play/wwdc2022/110352/) WWDC22 session video. The entire video is a gem. 💎

There is one more session called [Design protocol interfaces in Swift](https://developer.apple.com/videos/play/wwdc2022/110353/) that you should definitely watch if you want to learn more about generics.

From Swift 5.7 the any keyword is mandatory when creating an existential type, this is a breaking change, but it is for the greater good. I really like how Apple tackled this issue and both the any and some keywords are really helpful, however [understanding the differences](https://swiftsenpai.com/swift/understanding-some-and-any/) can be hard. 🤓

## Opaque types (some)

An [opaque type](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html) can hide the type information of a value. By default, the compiler can infer the underlying type, but in case of a protocol with an associated type the generic type info can't be resolved, and this is where the some keyword and the opaque type can help.

The some keyword was introduced in Swift 5.1 and you must be familiar with it if you've used SwiftUI before. First it was a return type feature only, but with Swift 5.7 you can now use the some keyword in function parameters as well.

```swift
import SwiftUI

struct ContentView: View {

    // the compiler knows that the body is always a Text type
    var body: some View {
        Text("Hello, World!")
    }
}
```

By using the some keyword you can tell the compiler that you are going to work on a specific concrete type rather than the protocol, this way the compiler can perform additional optimizations and see the actual return type. This means that you won't be able to assign a different type to a variable with a some 'restriction'. 🧐

```swift
var foo: some MyProtocol = MyIntStruct()

// ERROR: Cannot assign value of type 'MyStringStruct' to type 'some MyProtocol'
foo = MyStringStruct()
```

Opaque types can be used to [hide the actual type information](https://www.avanderlee.com/swift/some-opaque-types/), you can find more great code examples using the linked article, but since my post focuses on the generics, I'd like to show you one specific thing related to this topic.

```swift
func example<T: MyProtocol>(_ value: T) {}

func example<T>(_ value: T) where T: MyProtocol {}

func example(_ value: some MyProtocol) {}
```

Believe or not, but the 3 functions above are [identical](https://stackoverflow.com/questions/46810009/whats-the-difference-between-using-or-not-using-the-where-clause-with-generic). The first one is a generic function where the T placeholder type conforms to the MyProtocol protocol. The second one describes the exact same thing, but we're using the where claues and this allows us to place further restrictions on the associated types if needed. e.g. `where T: MyProtocol, T.MyType == Int`. The third one uses the some keyword to hide the type allowing us to use anything as a function parameter that conforms to the protocol. This is a new feature in Swift 5.7 and it makes the generic syntax more simple. 🥳

If you want to read more about the differences between the some and any keyword, you can read [this article](https://www.donnywals.com/whats-the-difference-between-any-and-some-in-swift-5-7/) by Donny Wals, it's really helpful.

## Primary associated types (Protocol\<T\>)

To constraint opaque result types you can use the where clause, or alternatively we can 'tag' the protocol with one or more [primary associated types](https://github.com/apple/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md). This will allow us to make further constraints on the primary associated type when using some.

```swift
protocol MyProtocol<MyType> {
    associatedtype MyType
    
    var myVar: MyType { get }
    
    func test()
}

//...

func example(_ value: some MyProtocol<Int>) {
    print("asdf")
}
```

If you want to learn more about primary associated types, you should read [Donny's article](https://www.donnywals.com/what-are-primary-associated-types-in-swift-5-7/) too. 💡

## Generics (\<T\>)

So far we haven't really talked about the standard generic features of Swift, but we were mostly focusing on protocols, associated types, existentials and opaque types. Fortunately you write [generic code in Swift](https://docs.swift.org/swift-book/LanguageGuide/Generics.html) without the need to involve all of these stuff.

```swift
struct Bag<T> {
    var items: [T]
}

let bagOfInt = Bag<Int>(items: [4, 2, 0])
print(bagOfInt.items)

let bagOfString = Bag<String>(items: ["a", "b", "c"])
print(bagOfString.items)
```

This bag type has a placeholder type called T, which can hold any kind of the same type, when we initialize the bag we explicitly tell which type are we going to use. In this example we've created a generic type using a struct, but you can also use an enum, a class or even an actor, plus it is also possible to write even more simple generic functions. 🧐

```swift
func myPrint<T>(_ value: T) {
    print(value)
}

myPrint("hello")
myPrint(69)
```

If you want to learn more about generics you should read [this article](https://www.hackingwithswift.com/plus/intermediate-swift/understanding-generics-part-1) by Paul Hudson, it's a nice introduction to generic programming in Swift. Since this article is more about providing an introduction I don't want to get into the more advanced stuff. Generics can be really difficult to understand, especially if we involve protocols and the new keywords.

I hope this article will help you to understand these things just a bit better.
