---
slug: getting-started-with-structured-concurrency-in-swift
title: Getting Started with Structured Concurrency in Swift
description: Learn how to apply structured concurrency in your applications, using task groups and other structured concepts.
publication: 2024-03-19 18:30:00
tags:
  - swift
  - structured-concurrency
authors:
  - joannis-orlandos
---

# Structured Concurrency in Swift

Swift 5.5 introduced structured concurrency. The new way to write concurrent code that is more maintainable and easier to reason about. A lot of developers have been adopting concurrency in Swift. But few people understand what '**structured**' means in this context, and how it helps you.

This guide will teach you all you need to know about structured concurrency in Swift. We'll cover the basics of concurrency, and how structured concurrency is different from other concurrency models. By the end of this guide, you'll be able to write any application in Swift using structured concurrency.

## What is Concurrency?

Concurrency is the ability of different parts your code to run out-of-order or in partial order, without affecting the outcome. This allows for parallel execution of the concurrent units, which can improve the overall speed of the execution.

Imagine that you're shopping for groceries with a friend. You both have a list of items to buy, and you decide to split up to save time. You both go to different parts of the store, and pick up the items on your list. You both finish at slightly different times, and meet up at the checkout. Instead of having to go through all the aisles together, you're both able to solve part of the puzzle at the same time. The end result is the same, but you've saved time.

### Pre-Swift 5.5 Concurrency

Concurrency has been a part of Swift for a long time, for example, through the use of `DispatchQueue` and `OperationQueue`. In these models, you can submit work to a queue, and the queue will execute the work in the background. Often times, you'll have to wait for the work to finish, either successfully or with an error.

```swift
DispatchQueue.global().async {
    // Offload some (heavy) work
}
```

In these models, you're responsible for managing the lifecycle of the work. You'll need to ensure that work is properly cancelled when it's no longer needed.

When implementing a function that has callbacks, you're responsible for calling the completion handler when the work is done. This can make it hard to debug and reason about the code, especially when you're working with concurrent units.

Take the following example:

```swift
func fetchImage(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error {
            completion(.failure(error))
            return
        }
        guard let data = data, let image = UIImage(data: data) else {
            completion(.failure(NetworkError.missingImage))
            return
        }
        completion(.success(image))
    }
}
```

In this example, various bugs can arise. For example, in `if let error`, omitting the `return` statement will cause the completion handler to be called twice.

### Race Conditions

When accessing shared state from concurrently running code, it's critical to ensure that the state is accessed in a safe way. If the same value is accessed and modified at the same time, you can run into crashes called 'race conditions'.

Race conditions need to be carefully and correctly solved. When using a mutex/lock to protect shared state, you need to ensure that this lock starts and ends at the right time. And when working with locks in long running calls such as network calls, you need to be careful to avoid performance bottlenecks. Finally, you can cause deadlocks when multiple functions that call each other access the same lock. Take the following example:

```swift
final class ImageCache {
    private var cache: [URL: UIImage] = [:]
    private let lock = NSLock()

    func image(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache[url]
    }

    func loadImage(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        // This is covered by the lock
        if cache.keys.contains(url) {
            return
        }
        fetchImage(at: url) { image in
            guard case .success(let image) = image else { return }
            // This is not covered by the lock
            cache[url] = image
        }
    }
}
```

The above example is non-trivial. It's not always obvious that you need to lock access to `image` twice. There are not one, but four traps here.

1. It's easy to forget to lock access to the cache.
2. One might lock access to the cache, but omit either the check for an existing image - or the assignment of the image.
3. When locking access to the cache, one might forget to unlock the lock. When returning a value, as seen in the `image(for:)` function, the lock should be unlocked after accessing the value, but before returning.
4. Finally, when locking access to the cache, unlocking could be implemented only after the fetching has completed.

These are all common mistakes, and they're hard to debug and reason about. This is where structured concurrency comes in.

Over the years, many patterns and abstractions have emerged to solve these problems. For example, the `Future` and `Promise` pattern is a common way to solve the problem of waiting for a value to be available. These abstractions are not part of the standard library, and are not always easy to work with or reason about. They're also not part of the standard library, leading to a fragmented ecosystem.

## Structured Concurrency

Swift has always been focused on safety and maintainability through _local reasoning_. Common examples are found in the type system, such as the use of value types. Because Array and Dictionary are value types, you can reason about them locally. You don't need to know about other parts of the code, and how those other parts might be modifying a reference to the same array or dictionary. Because value types are copied when passed around, you can reason about them locally.

Similarly, Structured Concurrency is a language feature that is designed to write concurrent code that is more maintainable and easier to reason about. It's designed to solve these problems, and is the recommended to write concurrent code that is maintainable and easy to reason about.

You're probably familiar with structured programming, as it's a paradigm that every Swift developer uses. By making use of a _structured control flow_ through constructs such as if-statements, for-loops and switch-statements, you're able to write code that is easy to reason about and maintain.

Structured Concurrency is the same concept, but applied to concurrent code. Functions in structured concurrency still have a clear entry and exit point. In Swift, this is done through the use of `async` functions and the `await` keyword.

### Async Functions

An `async` function is a function that can pause and resume. Think of it as a function that can be split up into multiple parts.

When you order a pizza, you don't have to wait for the pizza to be made and delivered. You can continue watching your favourite show, while the pizza is delivered to your doorstep. Just like async functions. Should you need to know when the pizza is delivered, you can `await` the delivery.

```swift
func watchTelevision() async throws {
    let store = await PizzaStore.discover()
    let pizza = await store.orderPizza()
    let show = startWatchingTV()
    try await pizza.eat()
    await show.watchUntilDone()
    show.stopWatchingTV()
}
```

Since structured concurrency leverages the structured programming paradigm, handling errors works the same as in synchronous code.

```swift
func watchTelevision() async throws {
    let pizza = await store.orderPizza()
    let show = startWatchingTV()
    do {
        let show = startWatchingTV()
        try await pizza.eat()
        await show.watchUntilDone()
    } catch PizzaError.notHungry {
        // No problem, we'll eat it later
    } catch PizzaError.burnt {
        // Something went wrong, we'll have to stop watching TV
        show.stopWatchingTV()
        await store.complain(about: pizza)
        throw error
    }
    show.stopWatchingTV()
}
```

## Structured Tasks

The `Task` object is not the only way to run concurrent work. The simplest way of running an `async` function in parallel is using the `async let` construct. This is a _structured_ way to start a task and let it run until you need the result:

```swift
func buyBooks(from bankAccount: BankAccount) async throws -> [Book] {
    // Resolve this concurrently
    async let balance = await bankAccount.checkBalance()

    let store = await BookStore.discover()
    var budget = await balance
    var boughtBooks: [Book] = []
    for await book in store.broweBooks() where book.price <= budget {
        let order = try await book.buy()
        let book = await order.delivery()
        budget -= book.price
        boughtBooks.append(book)
    }
    return boughtBooks
}
```

When this `async let` is not `await`ed for, it will continue to run in the background until the end of the function. If the function returns without awaiting the `async let`, the task will be cancelled.

The `async let` pattern is helpful for individual pieces of work that need to run concurrently. But it doesn't help when needing to run multiple pieces of work concurrently in a structured way. For that, there are **task groups**.

### Sequences

Like how a for-loop iterates over a sequence of items, a for-await-in loop iterates over a sequence of async items.

```swift
struct Books: AsyncSequence {
    typealias Element = Book
    ...
}

func browseBooks() -> Books {}

func buyAllBooks() async throws {
    for await book in browseBooks() {
        let order = try await book.buy()
        await order.delivery()
    }
}
```

This is a powerful feature, as it allows you to easily reason about _streams_ of data. On iOS, this can be a stream of keyboard events, StoreKit purchases, notifications or sensor data. For backend developers, this can be a WebSocket, a database query or the incoming connections on a TCP server. If you're interested in that, please check out our tutorial on [writing a SwiftNIO TCP Server](/using-swiftnio-channels).

If you're familiar with the Combine framework, this might sound similar to a `Publisher`. AsyncSequences have many of the same features as Combine's Publishers. Especially with [swift-async-algorithms](https://github.com/apple/swift-async-algorithms), AsyncSequence receive many of the same perks that a Publisher has.

AsyncSequences are part of the standard library, and are designed similarly to the existing `Sequence` protocol. You can create an `AsyncIterator` from them. The iterator has a `mutating func next() async throws -> Element?`.

This allows you to write a longer control flow that expect multiple results, such as the head and body of an HTTP request. You can use a `for-await-in` loop to iterate over the sequence of results, or manually iterate over the sequence using the `next()` method.

Now, a common request; "How can I await the delivery of these books concurrently?"

## Tasks

A task is a concurrent unit of work. In concurrency, many tasks can run in parallel.

The _easiest_ way to create a task is using the **unstructured** `Task` type. It's used to run a piece of code concurrently in the background, similar to `DispatchQueue.global().async {}`. In addition, you can manage it's lifecycle by `cancel()`ing it. Finally, you can also `await` its `value` for it to finish.

```swift
func buyBooks() {
    let store = await BookStore.discover()
    for await book in store.browseBooks() {
        Task {
            let order = try await book.buy()
            await order.delivery()
        }
    }
}
```

This looks great in theory, but the `Task` object is _not_ structured. It's not clear when the task starts, when it ends, and what happens when it's cancelled. You're required to manage the lifecycle of the task yourself, and don't even need to await the result or handle errors. This is inherently unsafe and re-introduces the problems that structured concurrency is designed to solve.

It is very much a part of the structured concurrency model. But think of it as an "escape hatch" when there's no other context or task in which your code can run. In almost every application, you'll have _some_ entrypoint at which you can start with a task. For example, your `@main` annotated entrypoint can be marked as `static func main() async throws` and you can start your application from there.

In SwiftUI apps, concurrent work can be started from within the `.task { }` view modifier. Not only does this allow running `async` work, but it also cancels that task when the view is no longer needed. That way your dependencies can discard heavy work initiated by the view that the user is no longer interested in.

### The Task Hierarchy

Tasks in structured concurrency are part of a hierarchy. This means that a task can create child tasks, and that the child tasks are automatically cancelled when the parent task is cancelled. Both structured and unstructured tasks are part of this hierarchy. Unstructured tasks do not reap all of the same benefits as structured tasks.

Like in structured programming, structured concurrency has a stack. This allows reading a stack trace to understand the flow of the program. This is especially helpful when debugging, or when reading a crash or error report.

When using unstructured tasks, you're not able to see the stack trace outside of the spawned task. This makes it harder to debug, and loses your ability to leverage some Xcode Instruments.

### Task Local Values

Since tasks can run on many different threads, there is (generally) no guarantee that a task will run on the same thread between suspension points. This means that thread-local is not available to store values that are specific to a task in structured concurrency.

A replacement for thread-local storage is task-local storage. This is a way to store values that are specific to a task. By using the `TaskLocal` property wrapper to store values that are specific to a task.

Here's an example of how a `TaskLocal` stores the currently authenticated user in a web server:

```swift
struct UserMiddleware: Middleware {
    @TaskLocal static var currentUser: User?
    let db: Database

    func handleRequest(
        _ request: HTTPRequest,
        next: HTTPResponder
    ) async throws -> HTTPResponse {
        let token = try request.parseJWT()
        let user = try await db.getUser(byId: token.sub)
        return try await HTTPServer.$currentUser.withValue(user) {
            return try await next.respond(to: request)
        }
    }
}
```

Now that the TaskLocal variable is set, it's accessible from any code called within the `withValue` block. For example:

```swift
func respond(to request: HTTPRequest) async throws -> HTTPResponse {
    guard let currentUser = UserMiddleware.currentUser else {
        throw HTTPError.unauthorized
    }
    // ...
}
```

### Task Cancellation

In structured concurrency, tasks are automatically cancelled when their parent task is cancelled. This is a powerful feature, as it allows you to cancel all of a task's dependencies at once. This is especially helpful when you're writing a server.

Let's say you're writing a web server, where your route generates a huge excel file. If the client cancels the request, you'll want to cancel the generation of the excel file. Continuing to generate the file is a waste of resources, and can lead to intentional and unintentional denial of service attacks.

In structured concurrency, you can use the `Task` object to cancel a task. This is a structured way to cancel a task, and it's clear when the task is cancelled. You can also use the `Task` object to check if a task is cancelled, and to handle the cancellation.

```swift
if Task.isCancelled {
    return
}
```

This is a structured way to check if a task is cancelled, and to handle the cancellation. It's clear when the task is cancelled, and you can handle the cancellation in a structured way.

You can also check if a task is cancelled using the `Task.checkCancellation` method. This is a structured way to check if a task is cancelled, and to handle the cancellation. It's clear when the task is cancelled, and you can handle the cancellation in a structured way.

```swift
try Task.checkCancellation()
```

This will throw a `CancellationError` if the task is cancelled. You can catch this error and handle the cancellation in a structured way.

### Blocking and Sleeping Tasks

If you have blocking or heavy work that you want to run concurrently, you'll need to do so outside of the structured concurrency model. This is because blocking or heavy work can cause a performance bottleneck in the global concurrent executor. SwiftNIO has the `NIOThreadPool` that you can use to run blocking work concurrently. For iOS users, it may be wise to use a `DispatchQueue` for these scenarios.

If you do decide to add computationally heavy code in structured concurrency, you can use `await Task.yield()` to yield the current task. This will allow your Task Executor to run other tasks. Doing so can prevent lag spikes, such as UI freezes those that happen on iOS when blocking the main thread.

**Note:** Swift 6 will be able to address these issues, through the addition of custom Task Executors. More on that later.

When finding yourself in a situation where you need to delay a task, you can use the `Task.sleep` method. It's similar to your regular `sleep` function, but rather than blocking the entire thread, it only suspends the task.

```swift
try await Task.sleep(for: .seconds(10))
```

An extra feature of `Task.sleep` is that it can be cancelled. If the task is
cancelled while it's sleeping, the sleep will be interrupted and throw a `CancellationError`.

### Cancellation Handlers

When a task is cancelled, you might want to clean up resources or perform some other action to handle the cancellation. You can use a cancellation handler to do this. A cancellation handler is a piece of code that is run when a task is cancelled.

```swift
func getData() async throws -> HTTPResponse {
    let httpClient = try await HTTPClient.connect(to: "https://api.example.com")
    return try await withTaskCancellationHandler {
        // This will run normally, and does the actual work
        // On cancellation, it will still find that `Task.isCancelled == true`
        // In addition, Task.sleep will throw a CancellationError
        // But if the HTTPClient doens't support cancellation,
        // it will continue to run until it's done
        return try await httpClient.get("/data")
    } onCancel: {
        // If the task is cancelled, this callback will run
        // and clean up the HTTP client
        // This allows users to implement cancellation manunally if needed
        httpClient.shutdown()
    }
}
```

## Task Groups

One can order ten items off your favourite book store. But in the real world, you don't want to `await` for the first book before ordering the next one. For that, we can use a `TaskGroup`:

```swift
func buyBooks() async throws {
    let store = await BookStore.discover()
    try await withThrowingTaskGroup(of: Book.self) { taskGroup in
        for await book in store.browseBooks() {
            taskGroup.addTask {
                try await book.buy()
            }
        }
        // The task group will automatically await all tasks
    }
}
```

This is a structured way to run multiple pieces of work concurrently. It's clear when the tasks start and when they end. You can run many pieces of work in parallel. And you can await all tasks being completed, and get an error if any one of them fails.

The above task group can throw errors, but not all task groups need to throw. If you use `withTaskGroup`, you'll be able to run tasks that don't throw, and you won't need to handle errors.

In the above example, `withThrowingTaskGroup(of: Book.self)` specifies that each task _must_ produce a `Book` result if successful. In some cases, the result of the task is not necessary. In this case however, the results are helpful to collect the books that were bought.

To solve that, use the `reduce` function on the task group. This is a structured way to run multiple pieces of work concurrently, and to reduce the results into a single value.

```swift
func buyBooks() async throws -> [Book] {
    let store = await BookStore.discover()
    return try await withThrowingTaskGroup(of: Book.self) { taskGroup in
        for await book in store.browseBooks() {
            taskGroup.addTask {
                try await book.buy()
            }
        }
        // Completes when all tasks have completed
        return try await taskGroup.reduce(into: []) { books, book in
            books.append(book)
        }
    }
}
```

### Discarding Task Groups

In some cases, you might not be interested in the result of the task group. For example, you might want to run a number of tasks concurrently, but these tasks don't return results. In that case, you can use `withDiscardingTaskGroup` and `withThrowingDiscardingTaskGroup` from iOS 17 and macOS 14. This is a structured way to run multiple pieces of work concurrently, without needing to retain results.

The regular task groups create a collection of results, which you can then iterate over. In some cases, such as a TCP server, this collection of results is not needed and grow indefinitely. In that case, you'll want to use a discarding task group to prevent an ever-growing collection of results. Note that `Void` results are still stored and occupy a small amount of memory!

## Conclusion

Structured concurrency is a powerful feature that was introduced with Swift 5.5. When writing your concurrenct code in a structured way, it's easier to reason about your code and maintain it.

Almost every application that you write will also have some form of shared state. In <a href="/structured-concurrency-and-shared-state-in-swift">the article</a>, we'll cover how Swift's actors, actor isolation and Sendable checking empower you to write race-condition free code.
