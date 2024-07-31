---
type: post
slug: introduction-to-asyncawait-in-swift
title: Introduction to async/await in Swift
description: Beginners guide to the new async/await API's in Swift 5.5. Interacting with sync code, structured concurrency, async let.
publication: 2021-05-25 16:20:00
tags: Swift, Concurrency
authors:
  - tibor-bodecs
---

## The main project

Swift 5.5 contains a lot of new features, most of them is all about "a better concurrency model" for the language. The very first step into this new asynchronous world is a proper [async/await](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md) system.

Of course you can still use regular completion blocks or [the Dispatch framework](https://theswiftdev.com/ultimate-grand-central-dispatch-tutorial-in-swift/) to write async code, but seems like the future of Swift involves a native approach to handle concurrent tasks even better. There is combine as well, but that's only available for Apple platforms, so yeah... 🥲

Let me show you how to convert your old callback & result type based Swift code into a shiny new async/await supported API. First we are going to create our experimental async SPM project.

```swift
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "AsyncSwift",
    products: [
        .executable(name: "AsyncSwift", targets: ["AsyncSwift"])
    ],
    dependencies: [
        // none for now..
    ],
    targets: [
        .executableTarget(name: "AsyncSwift",
                          swiftSettings: [
                            .unsafeFlags([
                                "-parse-as-library",
                                "-Xfrontend", "-disable-availability-checking",
                                "-Xfrontend", "-enable-experimental-concurrency",
                            ])
                          ]
        ),
        .testTarget(name: "AsyncSwiftTests", dependencies: ["AsyncSwift"]),
    ]
)
```

You might have noticed that we're using the latest `swift-tools-version:5.4` and we added a few unsafe flags for this project. This is because we're going to use the new `@main` attribute inside the executable package target, and the concurrency API requires the experimental flag to be present.

Now we should create a main entry point inside our `main.swift` file. Since we're using the [@main attribute](https://github.com/apple/swift-evolution/blob/main/proposals/0281-main-attribute.md) it is possible to create a new struct with a static main method that can be automatically launched when you build & run your project using Xcode or the command line. 🚀

```swift
@main
struct MyProgram {

    static func main() {
        print("Hello, world!")
    }
}
```

Now that we have a clean main entry point, we should add some standard URLSession related functionality that we are going to replace with new async/await calls as we refactor the code.

We're going call our usual sample todo service and validate our HTTP response. To get more specific details of a possible error, we can use a simple `HTTP.Error` object, and of course because the dataTask API returns immediately we have to use the `dispatchMain()` call to wait for the asynchronous HTTP call. Finally we simply switch the [result type](https://theswiftdev.com/how-to-use-the-result-type-to-handle-errors-in-swift/) and exit if needed. ⏳

```swift
import Foundation

enum HTTP {
    enum Error: LocalizedError {
        case invalidResponse
        case badStatusCode
        case missingData
    }
}

struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
    let userId: Int
}

func getTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
    let req = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/todos")!)
    let task = URLSession.shared.dataTask(with: req) { data, response, error in
        guard error == nil else  {
            return completion(.failure(error!))
        }
        guard let response = response as? HTTPURLResponse else {
            return completion(.failure(HTTP.Error.invalidResponse))
        }
        guard 200...299 ~= response.statusCode else {
            return completion(.failure(HTTP.Error.badStatusCode))
        }
        guard let data = data else {
            return completion(.failure(HTTP.Error.missingData))
        }
        do {
            let decoder = JSONDecoder()
            let todos = try decoder.decode([Todo].self, from: data)
            return completion(.success(todos))
        }
        catch {
            return completion(.failure(error))
        }
    }
    task.resume()
}

@main
struct MyProgram {

    static func main() {
        getTodos { result in
            switch result {
            case .success(let todos):
                print(todos.count)
                exit(EXIT_SUCCESS)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
            
        }
        dispatchMain()
    }
}
```

If you remember I already showed you [the Combine version of this URLSession data task](https://theswiftdev.com/urlsession-and-the-combine-framework/) call a while back, but as I mentioned this Combine is not only available for iOS, macOS, tvOS and watchOS.

## Async/await and unsafe continuation

So how do we convert our existing code into an async variant? Well, the good news is that there is a method called `withUnsafeContinuation` that you can use to wrap existing completion block based calls to produce async versions of your functions. The quick and dirty solution is this:

```swift
import Foundation

// ... 

func getTodos() async -> Result<[Todo], Error> {
    await withUnsafeContinuation { c in
        getTodos { result in
            c.resume(returning: result)
        }
    }
}

@main
struct MyProgram {

    static func main() async {
        let result = await getTodos()
        switch result {
        case .success(let todos):
            print(todos.count)
            exit(EXIT_SUCCESS)
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    }
}
```

The [continuations](https://github.com/apple/swift-evolution/blob/main/proposals/0300-continuation.md) proposal was born to provide us the necessary API to interact with synchronous code. The `withUnsafeContinuation` function gives us a block that we can use to resume with the generic async return type, this way it is ridiculously easy to rapidly write an async version of an existing the callback based function. As always, the Swift developer team did a great job here. 👍

One thing you might have noticed, that instead of calling the `dispatchMain()` function we've changed the main function into an async function. Well, the thing is that you can't simply call an async function inside a non-async (synchronous) method. ⚠️

## Interacting with sync code

In order to call an async method inside a sync method, you have to use the new `Task.detached` function and you still have to wait for the async functions to complete using the dispatch APIs.

```swift
import Foundation

// ...

@main
struct MyProgram {

    static func main() {
        Task.detached {
            let result = await getTodos()
            switch result {
            case .success(let todos):
                print(todos.count)
                exit(EXIT_SUCCESS)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        dispatchMain()
    }
}
```

Of course you can call any sync and async method inside an async function, so there are no restrictions there. Let me show you one more example, this time we're going to use the Grand Central Dispatch framework, return a few numbers and add them asynchronously.

## Serial vs concurrent execution

Imagine a common use-case where you'd like to combine (pun intended) the output of some long running async operations. In our example we're going to calculate some numbers asynchronously and we'd like to sum the results afterwards. Let's examine the following code...

```swift
import Foundation

func calculateFirstNumber() async -> Int {
    print("First number is now being calculated...")
    return await withUnsafeContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("First number is now ready.")
            c.resume(returning: 42)
        }
    }
}

func calculateSecondNumber() async -> Int {
    print("Second number is now being calculated...")
    return await withUnsafeContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Second number is now ready.")
            c.resume(returning: 6)
        }
    }
}

func calculateThirdNumber() async -> Int {
    print("Third number is now being calculated...")
    return await withUnsafeContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Third number is now ready.")
            c.resume(returning: 69)
        }
    }
}

@main
struct MyProgram {

    static func main() async {
        let x = await calculateFirstNumber()
        let y = await calculateSecondNumber()
        let z = await calculateThirdNumber()
        print(x + y + z)
    
}

/*
First number is now being calculated...
First number is now ready.
Second number is now being calculated...
Second number is now ready.
Third number is now being calculated...
Third number is now ready.
117
Program ended with exit code: 0
*/
```

As you can see these functions are asynchronous, but they are still executed one after another. It really doesn't matter if you change the main queue into a different concurrent queue, the async task itself is not going to fire until you call it with await. The execution order is always serial. 🤔

## Spawn tasks using async let

It is possible to change this behavior by using the brand new async let syntax. If we move the await keyword just a bit down the line we can fire the async tasks right away via the async let expressions. This new feature is part of [the structured concurrency proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0317-async-let.md).

```swift
// ...

@main
struct MyProgram {

    static func main() async {
        async let x = calculateFirstNumber()
        async let y = calculateSecondNumber()
        async let z = calculateThirdNumber()

        let res = await x + y + z
        print(res)
    }
}
/*
First number is now being calculated...
Second number is now being calculated...
Third number is now being calculated...
Second number is now ready.
First number is now ready.
Third number is now ready.
117
Program ended with exit code: 0
*/
```

Now the execution order is concurrent, the underlying calculation still happens in a serial way on the main queue, but you've got the idea what I'm trying to show you here, right? 😅

Anyway, simply adding the async/await feature into a programming language won't solve the more complex issues that we have to deal with. Fortunately Swift will have great support to async task management and concurrent code execution. I can't wait to write more about these new features. See you next time, there is a lot to cover, I hope you'll find my async Swift tutorials useful. 👋
