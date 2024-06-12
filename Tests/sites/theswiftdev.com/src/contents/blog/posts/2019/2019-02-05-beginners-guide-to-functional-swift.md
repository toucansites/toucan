---
slug: beginners-guide-to-functional-swift
title: Beginners guide to functional Swift
description: "The one and only tutorial that you'll ever need to learn higher order functions like: map, flatMap, compactMap, reduce, filter and more."
publication: 2019-02-05 16:20:00
tags: Swift, functional programming
---

## Functional programming explained

First of all let me emphasize one thing:

> Do not be afraid of functional programming!

Even if you are a beginner developer, you'll see that [functional programming](https://en.wikipedia.org/wiki/Functional_programming) is not so hard that you might imagine. If you only learn the basics, it'll save you lots of time & helps you to write way better applications. The main concept of the FP paradigm is to eliminate mutable states and data, by using [functions](https://docs.swift.org/swift-book/LanguageGuide/Functions.html) in a special way. 💫

### First-class functions

If a programming language treats functions as [first-class citizens](https://en.wikipedia.org/wiki/First-class_citizen) (same behavior as we'd expect from a type) we say that it has first class functions.

> This means the language supports passing functions as arguments to other functions, returning them as the values from other functions, and assigning them to variables or storing them in data structures.

In Swift you can use function pointers, [closures](https://medium.com/swift-india/functional-swift-closures-67459b812d0) (anonymous functions), so yes, Swift is pretty much designed to be a real functional language. Quick sample time:

```swift
// an old-school function
func hello() {
    print("Hello!")
}

// it's a block!
let hi: () -> Void = {
    print("Hi!")
}

// this points to a function
let function = hello
// this is a copy of the closure
let block = hi

hello() // simple function call
function() // call through "function pointer"

hi() // simple closure call
block() // closure call through another variable

// closure parameter
func async(completion: () -> Void) {
    // usually we'd do something here first...
    completion()
}

// calling the method with a closure
async(completion: {
    print("Completed.")
})
// trailing closure syntax
async {
    print("Completed.")
}
```

Please note that sometimes I refer to closures as blocks, for the sake of simplicity let's pretend that they're the exact same thing, and don't go too much into the details. 🙄

### Function composition, currying and variadic parameters

[Composing functions](https://en.wikipedia.org/wiki/Function_composition) is basically passing the output of a function to another. This is not so interesting, we do it all the time. On the other hand [currying](https://medium.freecodecamp.org/an-introduction-to-swifts-curried-function-e4b55d10a506) functions is a more exciting topic. Currying is basically converting functions with multiple arguments into functions with one arguments and a returning function.

What is [currying](https://en.wikipedia.org/wiki/Currying) used for? Well, some say it's just a syntactic sugar, others say it's useful, because you can split logic into smaller more specialized chunks. I leave it up to you whether you find currying useful or not, but in my opinion it's a quite interesting technique, and it's worth learning the basics of currying. 🍛

Using a [variadic parameter](https://en.wikipedia.org/wiki/Variadic_function) means accepting zero or more values of a specified type. So this means you can for example input as many integers as you want by using a variadic Int parameter. Creating a variadic argument is pretty simple, you just have to append three dots after your type... let's see these things in action:

```swift
// function composition
func increment(_ x: Int) -> Int {
    return x + 1
}
let x = increment(increment(increment(increment(10))))
print(x)


// function currying
func decrement(_ x: Int) -> (Int) -> Int {
     return { $0 * x }
}
let y = decrement(10)(1)
print(y)


// this is a variadic function that accepts a block as a parameter
func variadic(_ blocks: (() -> Void)...) {
    for block in blocks {
        block()
    }
}

// it means you can pass as many parameters as you want...
variadic({ print("a") }, { print("b") }, { print("c") })

// lol, trailing closure syntax works with variadic block params.
variadic {
    print("d")
}
```

Pretty much that was a quick intro to Swift function capabilities. Of course you can add more parameters (but only one variadic parameter is allowed), use generics and many more, but let's wait just a little bit more, before we dive into the deep water. 🏊‍♂️

### Higher order functions

A function is a [higher order function](https://www.stephanboyer.com/post/115/higher-rank-and-higher-kinded-types) if at least one of the following rule is satisfied:

- takes one or more functions as arguments
- returns a function as its result.

In other words, or maybe even in Swift:

```swift
// a function that takes another function as a parameter
func transform(value: Int, _ transformation: (Int) -> Int) -> Int {
    return transformation(value)
}
let x = transform(value: 10) { value -> Int in
    return value * 2
}
print(x)

// a function that returns another function
func increase(withMultiplication shouldMultiply: Bool) -> (Int, Int) -> Int {
    func add(_ x: Int, _ y: Int) -> Int { return x + y }
    func multiply(_ x: Int, _ y: Int) -> Int { return x * y }
    return shouldMultiply ? multiply : add
}

let y = increase(withMultiplication: true)(10, 10)
print(y)
```

So as you can see it's not like magic, we're just passing around functions. At first sight the syntax can seem quite complicated, but trust me, it's not that hard. If you are having trouble, try to define your own typealiases for the function types, that'll make the code a little bit more readable. `typealias VoidBlock = () -> Void` 👍

### Generic functions

The real problem starts if you're trying to generalize your higher order functions. With [generics](http://adriaanm.github.io/files/higher.pdf) involved, the syntax can look a little bit messy. Generics (aka. [parametric polymorphism](https://en.wikipedia.org/wiki/Parametric_polymorphism)) allows us to abstract away regular types. So for example:

```swift
// this only works for integers
func chooseInt(_ x: Int, or y: Int) -> Int {
    return Bool.random() ? x : y
}

// whoa, this is a generic function
func choose<T>(_ x: T, or y: T) -> T {
    return Bool.random() ? x : y
}

let x = chooseInt(1, or: 2)
print(x) // 1 or 2, but who knows this for sure

let y = choose("heads", or: "tails")
print(y) // maybe heads or maybe tails
```

In the example above we abstracted away the integer type with a generic T type, that can be anything. If we call our generic function with a string as a first parameter, all the remaining T types will be used as strings. Does this make any sense? If yes, then congratulations, now you know what are generic functions. 🎊

### Containers and boxes 📦

Let's start with a generic box. You can put any value into the box (it's just like an ordinary paper box like you'd use in real life), you can always open the box and directly get the value from inside by using the value property.

```swift
struct Box<T> {

    let value: T

    init(_ value: T) {
        self.value = value
    }
}

let x = Box<Int>(360)
print(x.value)
```

Next continue with a little bit more theory, but I promise I'll keep things very short, just because [Russ Bishop](https://x.com/xenadu02) already explained [functors, applicatives and monads in plain English](http://www.russbishop.net/monoids-monads-and-functors). I'll try to do my best in order to make it [even more simple](https://www.mokacoding.com/blog/functor-applicative-monads-in-pictures/). 😉

### Functors

> Functors are containers you can call map on.

Challenge accepted! Let's make a functor from our box type, but what exactly does [map](https://medium.com/@JLHLonline/a-world-beyond-swift-maps-f73397d4504)? Well, it basically transforms a value into another. You can provide your own transformation method, where you'll receive the original value as a parameter and you have to return a "new" value form the same or a different type. Code time!

```swift
extension Box {
    func map<U>(_ transformation: (T) -> U) -> Box<U> {
        return Box<U>(transformation(self.value))
    }
}

let x = Box<Int>(360)
let y = x.map { "\($0) degrees" }
print(y.value)
```

So map is just a generic higher order function! Just a higher order function... 🤔 Just a function passed into another function. Oh, this is only possible, because Swift supports first-class functions! Now you get it! Nothing magical, just functions!

### Monads

> Monads are containers you can call flatMap on.

This one is ridiculously easy. flatMap is a function that transforms a value, then re-wrap it in the original container type. It's like map, but you have to provide the container inside your transformation function. I'll show you the implementation:

```swift
extension Box {
    func flatMap<U>(_ transformation: (T) -> Box<U>) -> Box<U> {
        return transformation(self.value)
    }
}

let x = Box<Int>(360)
let y = x.flatMap { Box<String>("\($0) degrees") }
print(y.value)
```

Are you ready for something more complicated? 😅

### Applicatives

An [applicative](https://kandelvijaya.com/2018/03/25/functorapplicativemonad/#orgff1f53e) lets you put the transformation function inside a container. So you have to unwrap your transformation function first, only after you can apply the function into the wrapped value. That means you have to "unbox" the value as well, before the transformation. Explaining things is a though job, let me try in Swift:

```swift
extension Box {
    func apply<U>(_ transformation: Box<(T) -> U>) -> Box<U> {
        return Box<U>(transformation.value(self.value))
    }
}

let x = Box<Int>(360)

let transformation = Box<((Int) -> String)>({ x -> String in
    return "\(x) degrees"
})

let y = x.apply(transformation)
print(y.value)
```

As you can see it all depends on the container, so if you'd like to extend the Optional enum with an apply function that'd look a little different. Containerization is hard! 🤪

### Quick recap:

- Container = M 
- Functor = map(f: T -> U) -> M 
- Monad = flatMap(f: T -> M) -> M 
- Applicative = apply(f: M U)>) -> M

### Higher kinded types

> The idea of higher-rank types is to make polymorphic functions first-class

Currently this is not implemented in the Swift programming language, and it's [NOT going to be part of the Swift 5 release](https://forums.swift.org/t/questions-about-the-future-of-protocols-with-associated-types/14784/10), but you can [simulate HKT functionality](https://stackoverflow.com/questions/52905485/how-to-declare-protocol-for-hkt-in-swift) in Swift with some tricks. Honestly speaking I really don't want to talk more about [higher kinded types](https://stackoverflow.com/questions/6246719/what-is-a-higher-kinded-type-in-scala) now, because it's a really [hardcore topic](https://typelevel.org/blog/2016/08/21/hkts-moving-forward.html), maybe in the next [functional programming](https://five.agency/functional-programming-in-swift/) tutorial, if you'd like to have more like this. 😉

### Futures

Let's talk a little bit about [futures](http://dist-prog-book.com/chapter/2/futures.html). By definition they are read-only references to a yet-to-be-computed value. Another words: future is a placeholder object for a result that does not exists yet. This can be super useful when it comes to asynchronous programming. Have you ever heard about the [callback hell](https://blog.hellojs.org/asynchronous-javascript-from-callback-hell-to-async-and-await-9b9ceb63c8e8)? 😈

A future is basically a generic result wrapper combined with callbacks and some extra state management. A future is both a functor and a [monad](https://broomburgo.github.io/fun-ios/post/why-monads/), this means that you can usually call both map & flatMap on it, but because of the read-only nature of futures you usually have to make a [promise](https://stackoverflow.com/questions/14541975/whats-the-difference-between-a-future-and-a-promise) in order to create a new future object. You can find a really nice implementation in [SwiftNIO](https://github.com/apple/swift-nio/blob/master/Sources/NIO/EventLoopFuture.swift). 😎

### Promises

> A promise is a writable, single-assignment container, which completes a future.

In a nutshell, you have to make promises, instead of futures, because futures are read-only by design. The promise is the only object that can complete a future (normally only once). We can say that the result of a future will always be set by someone else (private result variable), while the result of a promise (underlying future) will be set by you, since it has a public reject & resolve methods. 🚧

Some promises also implement the future interface, so this means that you can directly call map, flatMap (usually both called as a simple overloaded then method) on a promise. 

Are you Ready for some functional Swift code?

## Functional Programming in Swift 5

It's time to practice what we've learned. In this section I'll go through the most popular functional methods in Swift 5 and show you some of the best practices.

### map

The map function in Swift works on all the [Sequence](https://swiftdoc.org/v4.2/protocol/sequence/) types plus the brand new [Result type in Swift](https://theswiftdev.com/2019/01/28/how-to-use-the-result-type-to-handle-errors-in-swift/) also has a map function, so you can transform values on these types as you want, which is quite nice in some cases. Here are a few examples:

```swift
// array
let numbers = Array(0...100)
numbers.map { $0 * 10 } // 0, 10, 20 ... 1000
numbers.map(String.init) // "0", "1", "2" ... "100"


// dictionary
let params: [String: Any] = [
    "sort": "name",
    "order": "desc",
    "limit": 20,
    "offset": 2,
]

// mapValues is basically map for the dictionary values
let queryItems = params.mapValues { "\($0)" }
                       .map(URLQueryItem.init)


// set
let fruits = Set<String>(arrayLiteral: "apple", "banana", "pear")
fruits.map { $0.capitalized }

// range
(0...100).map(String.init)
```

### flatMap

The flatMap method is also available on most of the types that implements the map functionality. Essentially flatMap does the following thing: it maps and flattens. This means you'll get the flattened array of subarrays. Let me show you how it works:

```swift
// flatMap
let groups = [
    "animals": ["🐔", "🦊", "🐰", "🦁"],
    "fruits": ["🍎", "🍉", "🍓", "🥝"]
]
let emojis = groups.flatMap { $0.value }
// "🐔", "🦊", "🐰", "🦁", "🍎", "🍉", "🍓", "🥝"
```

### compactMap

So what's the deal with [flatMap vs compactMap](https://www.avanderlee.com/swift/compactmap-flatmap-differences-explained/)? In the past flatMap could be used to remove optional elements from arrays, but from Swift 4.1 there is a new function called compactMap which should be used for this purpose. The compiler will give you a warning to [replace flatMap with compactMap](https://useyourloaf.com/blog/replacing-flatmap-with-compactmap/) in most of the cases.

```swift
// compactMap
[1, nil, 3, nil, 5, 6].compactMap { $0 } // 1, 3, 5, 6

let possibleNumbers = ["1", "two", "3", "four", "five", "6"]
possibleNumbers.compactMap { Int($0) } //1, 3, 6
```

### reduce

The reduce method is a powerful tool. It can be used to combine all the elemens from a collection into a single one. For example you can use it to summarize elements, but it's also quite handy for joining elements together with an initial component.

```
let sum = (0...100).reduce(0, +)
print(sum) //5050

let cats = ["🦁", "🐯", "🐱"]
cats.reduce("Cats: ") { sum, cat in "\(sum)\(cat)"} // Cats: 🦁🐯🐱


let basketballScores = [
    "team one": [2,2,3,2,3],
    "team two": [3,2,3,2,2],
]

let points = basketballScores.reduce(0) { sum, element in
    return sum + element.value.reduce(0, +)
}
print(points) // 24 (team one + team two scores together)
```

### filter

You can filter [sequences](https://medium.com/@JLHLonline/superpowered-sequences-a009ccc1ae43) with the [filter](https://medium.com/@abhimuralidharan/higher-order-functions-in-swift-filter-map-reduce-flatmap-1837646a63e8) method, it's pretty obvious! You can define a condition block for each element, and if the condition is true, the given element will be included in the result. It's like looping through elements & picking some. 🤪

```swift
let evenNumbers = (0...100).filter { $0.isMultiple(of: 2) }
let oddNumbers = (0...100).filter { !evenNumbers.contains($0) }

let numbers = [
    "odd": oddNumbers,
    "even": evenNumbers,
]

let luckyThirteen = numbers
.filter { element in
    return element.key == "odd"
}
.mapValues { element in
    return element.filter { $0 == 13 }
}
```

### promises

I love promises, and you should learn them too if you don't know how they work. Otherwise you can still go with the [Dispatch framework](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/), but I prefer promises, because passing variables around is way more easy by using a [promise framework](https://github.com/corekit/promises).

```swift
Promise<String> { fulfill, reject in
    fulfill("Hello")
}
.thenMap { result in
    return result + " World!"
}
.then { result in
    return Promise<String>(value: result)
}
.tap { result in
    print("debug: \(result)")
}
.onSuccess(queue: .main) { result in
    print(result)
}
.onFailure { error in
    print(error.localizedDescription)
}
.always {
    print("done!")
}
```

## What's next?

There is a game for practicing functional methods! It's called [cube composer](https://david-peter.de/cube-composer/), and it is totally awesome and fun! Just play a few rounds, you won't regret it! 🎮
