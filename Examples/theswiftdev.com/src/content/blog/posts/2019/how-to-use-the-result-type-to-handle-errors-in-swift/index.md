---
type: post
title: How to use the result type to handle errors in Swift 5?
description: From this tutorial you can learn how to utilize the do-try-catch syntax with the brand new result type to handle errors in Swift.
publication: 2019-01-28 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Error handling basics in Swift

The way of handling errors changed a lot since the first version of Swift. The first big milestone happened in [Swift 2](https://www.netguru.com/blog/error-handling-swift), where Apple completely revamped [error management](https://appventure.me/2015/06/19/swift-try-catch-asynchronous-closures/). Nowadays you can use the `do`, `try`, `catch`, `throw`, `throws`, `rethrows` keywords instead of dealing with nasty NSError pointers, so this was a warmly welcomed addition for the language. Now in Swift 5 we take another giant leap forward by introducing the [Result type](https://www.hackingwithswift.com/articles/161/how-to-use-result-in-swift) as a built-in generic. First, let me show you all the best practices of error handling in the Swift programming language, next I'll show you some cool stuff by using results to deal with errors. 🚧

### Optionals as error indicators

For simple scenarios you can always use optional [values](https://www.cocoawithlove.com/blog/2016/08/21/result-types-part-one.html), to indicate that something bad happened. Also the `guard` statement is extremely helpful for situations like this.

```swift
let zeroValue = Int("0")! // Int
let nilValue = Int("not a number") // Int?

guard let number = Int("6") else {
    fatalError("Ooops... this should always work, so we crash.")
}
print(number)
```

If you don't really care about the underlying type of the error, this approach is fine, but sometimes things can get more complicated, so you might need some details about the problem. Anyway, you can always stop the execution by calling the `fatalError` method, but if you do so, well... your app will crash. 💥

There are also a couple other ways of stop execution process, but this could be a topic of a standalone post, so here is just a quick cheat sheet of available methods:

```swift
precondition(false, "ouch")
preconditionFailure("ouch")
assert(false, "ouch")
assertionFailure("ouch")
fatalError("ouch")
exit(-1)
```

The key difference between precondition and assertion is that assert will work only in debug builds, but precondition is evaluated always (even in release builds). Both methods will trigger a fatal error if the condition fails aka. is false. ⚠️

### Throwing errors by using the Error protocol

You can define your own error types by simply confirming to the built-in `Error` protocol. Usually most developers use an `enum` in order to define different reasons. You can also have a custom error message if you conform to the `LocalizedError` protocol. Now you're ready to throw custom errors, just use the throw keyword if you'd like to raise an error of your type, but if you do so in a function, you have to mark that function as a throwing function with the throws keywords. 🤮

```swift
enum DivisionError: Error {
    case zeroDivisor
}

extension DivisionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .zeroDivisor:
            return "Division by zero is quite problematic. " +
                   "(https://en.wikipedia.org/wiki/Division_by_zero)"
        }
    }
}

func divide(_ x: Int, by y: Int) throws -> Int {
    guard y != 0 else {
        throw DivisionError.zeroDivisor
    }
    return x / y
}
```

Great, so the divide function above can generate a custom error message. If the divisor is zero it'll throw the zeroDivision error case. Now imagine the following scenario: you are trying to read the contents of a file from the disk. There could be multiple types of errors related to permission or file existence, etc.

> Rethrowing Functions and Methods A function or method can be declared with the rethrows keyword to indicate that it throws an error only if one of it’s function parameters throws an error. These functions and methods are known as rethrowing functions and rethrowing methods. Rethrowing functions and methods must have at least one throwing function parameter.

Ok, so a [throwing](https://stackoverflow.com/questions/43305051/what-are-the-differences-between-throws-and-rethrows-in-swift) function can emit different error types, also it can propagate all the parameter errors, but how do we handle (or should I say: catch) these errors?

### The do-try-catch syntax

You just simply have to try to execute do a throwing function. So don't trust the master, there is definitely room for trying out things! Bad joke, right? 😅

```swift
do {
    let number = try divide(10, by: 0)
    print(number)
}
catch let error as DivisionError {
    print("Division error handler block")
    print(error.localizedDescription)
}
catch {
    print("Generic error handler block")
    print(error.localizedDescription)
}
```

As you can see the syntax is pretty simple, you have a do block, where you can try to execute your throwing functions, if something goes wrong, you can handle the errors in different catch blocks. By default an error property is available inside every catch block, so you don't have to define one yourself by hand. You can however have catch blocks for specific error types by casting them using the `let error as MyType` sytnax right next to the catch keyword. So always try first, don't just do! 🤪

### Differences between try, try? and try!

As we've seen before you can simply try to call a function that throws an error inside a do-catch block. If the function triggers some kind of error, you can put your [error handling](https://andybargh.com/error-handling-in-swift/) logic inside the catch block. That's very simple & straightforward.

Sometimes if you don't really care about the underlying error, you can simply convert your throwing function result into an optional by using try?. With this approach you'll get a nil result if something bad happens, otherwise you'll get back your regular value as it is expected. Here is the example from above by using try?:

```swift
guard let number = try? divide(10, by: 2) else {
    fatalError("This should work!")
}
print(number) // 5
```

Another technique is to prevent error propagation by using try!, but you have to be extremely careful with this approach, because if the execution of the "tried function" fails, your application will simply crash. So use only if you're absolutely sure that the function won't throw an error. ⚠️

```swift
let number = try! divide(10, by: 2) // This will work for sure!
print(number)
```

There are a few places where it's accepted to use force try, but in most of the cases you should go on an alternate path with proper error handlers.

### Swift errors are not exceptions

The Swift compiler always requires you to catch all thrown errors, so a situation of unhandled error will never occur. I'm not talking about empty catch blocks, but unhandled throwing functions, so you can't try without the do-catch companions. This is one key difference when comparing to exceptions. Also when an error is raised, the execution will just exit the current scope. Exceptions will usually unwind the stack, that can lead to memory leaks, but that's not the case with Swift errors. 👍

## Introducing the result type

Swift 5 introduces a long-awaited generic result type. This means that error handling can be even more simple, without adding your own result implementation. Let me show you our previous divide function by using Result.

```swift
func divide(_ x: Int, by y: Int) -> Result<Int, DivisionError> {
    guard y != 0 else {
        return .failure(.zeroDivisor)
    }
    return .success(x / y)
}

let result = divide(10, by: 2)
switch result {
case .success(let number):
    print(number)
case .failure(let error):
    print(error.localizedDescription)
}
```

The result type in Swift is basically a generic enum with a .success and a .failure case. You can pass a generic value if your call succeeds or an Error if it fails.

One major advantage here is that the error given back by result is type safe. Throwing functions can throw any kind of errors, but here you can see from the implementation that a DivisionError is coming back if something bad happens. Another benefit is that you can use exhaustive switch blocks to "iterate through" all the possible error cases, even without a default case. So the compiler can keep you safe, e.g. if you are going to introduce a new error type inside your enum declaration.

So by using the Result type it's clear that we're getting back either result data or a strongly typed error. It's not possible to get both or neither of them, but is this better than using throwing functions? Well, let's get asynchrounous!

```swift
func divide(_ x: Int, by y: Int, completion: ((() throws -> Int) -> Void)) {
    guard y != 0 else {
        completion { throw DivisionError.zeroDivisor }
        return
    }
    completion { return x / y }
}

divide(10, by: 0) { calculate in
    do {
        let number = try calculate()
        print(number)
    }
    catch {
        print(error.localizedDescription)
    }
}
```

Oh, my dear... an inner closure! A completion handler that accepts a throwing function, so we can propagate the error thrown to the outer handler? I'm out! 🤬

Another option is that we eliminate the throwing error completely and use an optional as a result, but in this case we're back to square one. No underlying error type.

```swift
func divide(_ x: Int, by y: Int, completion: (Int?) -> Void) {
    guard y != 0 else {
        return completion(nil)
    }
    completion(x / y)
}

divide(10, by: 0) { result in
    guard let number = result else {
        fatalError("nil")
    }
    print(number)
}
```

Finally we're getting somewhere here, but this time let's add our error as a closure parameter as well. You should note that both parameters need to be optionals.

```swift
func divide(_ x: Int, by y: Int, completion: (Int?, Error?) -> Void) {
    guard y != 0 else {
        return completion(nil, DivisionError.zeroDivisor)
    }
    completion(x / y, nil)
}

divide(10, by: 0) { result, error in
    guard error == nil else {
        fatalError(error!.localizedDescription)
    }
    guard let number = result else {
        fatalError("Empty result.")
    }
    print(number)
}
```
Finally let's introduce result, so we can eliminate optionals from our previous code.

```swift
func divide(_ x: Int, by y: Int, completion: (Result<Int, DivisionError>) -> Void) {
    guard y != 0 else {
        return completion(.failure(.zeroDivisor))
    }
    completion(.success(x / y))
}

divide(10, by: 0) { result in
    switch result {
    case .success(let number):
        print(number)
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

See? Strongly typed errors, without optionals. Handling errors in asynchronous function is way better by using the Result type. If you consider that most of the apps are doing some kind of networking, and the result is usually a JSON response, there you already have to work with optionals (response, data, error) plus you have a throwing JSONDecoder method... can't wait the new APIs! ❤️

## Working with the Result type in Swift 5

We already know that the result type is basically an enum with a generic `.succes(T)` and a `.failure(Error)` cases, but there is more that I'd like to show you here. For example you can create a result type with a throwing function like this:

```swift
let result = Result {
    return try divide(10, by: 2)
}
```

It is also possible to convert back the result value by invoking the get function.

```swift
do {
    let number = try result.get()
    print(number)
}
catch {
    print(error.localizedDescription)
}
```

Also there are `map`, `flatMap` for transforming success values plus you can also use the `mapError` or `flatMapError` methods if you'd like to transform failures. 😎

```swift
// Result<Int, DivisionError>
let result = divide(10, by: 2) 

// Result<Result<Int, DivisionError>, DivisionError>
let mapSuccess = result.map { divide($0, by: 2) } 

// Result<Int, DivisionError>
let flatMapSuccess = result.flatMap { divide($0, by: 2) } 
let mapFailure = result.mapError { 
    NSError(domain: $0.localizedDescription, code: 0, userInfo: nil)
}

let flatMapFailure = result.flatMapError { 
    .failure(NSError(domain: $0.localizedDescription, code: 0, userInfo: nil)) 
}
```

That's it about the Result type in Swift 5. As you can see it's extremely powerful to have a generic implementation built directly into the language. Now that we have result, I just wish for [higher kinded types](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md) or an [async / await](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) implementation. 👍
