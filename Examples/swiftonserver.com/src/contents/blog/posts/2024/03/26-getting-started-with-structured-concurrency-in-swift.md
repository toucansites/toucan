---
slug: structured-concurrency-and-shared-state-in-swift
title: Structured Concurrency and Shared State in Swift
description: Learn how actors and sendable prevent race conditions in your concurrent code.
publication: 2024-03-25 18:30:00
tags:
  - swift
  - structured-concurrency
authors:
  - joannis-orlandos
---

# Sendable and Shared Mutable State

When working with concurrent code, you'll often need to share state between tasks. Using reference types such as a `class` allows you to share state between different threads and tasks. This can lead to race conditions where two tasks are trying to access the same state at the same time.

The Thread Sanitizer in Xcode can help you find race conditions. It's better to avoid them altogether. You can do so by adopting the `Sendable` protocol on your types. This protocol is used to mark types that can be safely sent between tasks.

If the compiler is able to determine that a type is Sendable, the conformance does not require additional work. In other cases, you'll need to provide the conformance yourself.

Sendability is a contract, initiated by the type, that the type is safe to be sent between tasks. Structs and enums are automatically Sendable, if all of their properties are Sendable. Since value types are copied when they are sent between tasks, you can safely send a struct or enum between tasks, and you don't have to worry about race conditions.

### Classes

Classes are not automatically Sendable. Since reference types are explicitly not copied but referenced, you can't safely send a class between tasks. You can mark a class as Sendable if all of its properties are marked `Sendable` and a constant (let).

If you're working with a class that is not a set of constants, you can still mark it as Sendable by using the `@unchecked Sendable` conformance. When you use this conformance, you're telling the compiler that you're sure that the class is Sendable, and that you're taking responsibility of isolating the state. In this case, you can adopt your own isolation such as Locks.

```swift
final class SharedState: @unchecked Sendable {
    private var _state: Int = 0
    let lock = NSLock()
    public var state: Int {
        get {
            lock.withLock { _state }
        }
        set {
            lock.withLock { _state = newValue }
        }
    }
}
```

### Actors and Isolation

Isolation is a way to ensure that only one task can access a piece of state at a time. This is done by using locks, or by using Swift's new `actor` type. When you're using a lock, you're responsible for ensuring that the lock is used correctly. This means that you need to lock the state before accessing it, and unlock it after you're done.

The easier and new way to share state between tasks is using an `actor`. An actor is a reference type, like classes, that is automatically Sendable. Unlike classes, actors do not support inheritance.

Actors achieve Sendable support by only allowing access from the actor's own _isolated_ page. Reading values and calling methods on an actor is forced by the compiler to happen in that isolated page.

When accessing an actor's state or calling its functions, you can prefix your call with `async`, if you're not doing so already. The compiler will enforce that only one thread is accessing the actor's state at a time, and suspend until the actor is available.

You can define an actor like so:

```swift
actor BankAccount {
    var balance: Int = 0

    func deposit(_ amount: Int) {
        balance += amount
    }

    func withdraw(_ amount: Int) {
        balance -= amount
    }
}

let bankAccount = BankAccount()
await bankAccount.deposit(100)
let balance = await bankAccount.balance
print(balance) // 100
```

Just like any type, you can make an `extension` on an actor. Actors can also conform to protocols, assuming that the protocol's signature can be feasibly implemented with isolation. A common obstacle is that you can't easily conform to a protocol that has properties or methods that are not isolated.

An actor's isolation is inherited by its properties and methods. Actor Isolation is compile-time checked to ensures that only one task can access the actor's state at a time. This is achieved through the `unownedExecutor` of an actor. This is a `SerialExecutor` that the Swift runtime submits tasks to, which provides the isolation in this actor. The SerialExecutor may be a single thread, or multiple. But needs to guarantee that only one task is running on this at a time. Akin to `DispatchQueue.main.async { }` in GCD.

```swift
bankAccount.unownedExecutor
```

You can create your own `SerialExecutor` for use with your actors. SwiftNIO's EventLoop already has a `serialExecutor` property that you can use. GCD's DispatchQueue can be adapted easily as well.

Since `unownedExecutor` is not a static member of an actor, an actor's static properties can _not be isolated_ by the actor.

### Nonisolated

You can use the `nonisolated` keyword to mark a function as lacking isolation. This allows you to access these functions without the `await` keyword, and conform to protocols that have non-isolated methods.

```swift
actor BookStore: AsyncSequence {
    typealias AsyncIterator = AsyncStream<Book>.AsyncIterator
    typealias Element = Book

    private var page = 1
    private var hasReachedEnd = false
    private let stream: AsyncStream<Book>
    private let continuation: AsyncStream<Book>.Continuation

    init() {
        (stream, continuation) = AsyncStream<Book>.makeStream(
            bufferingPolicy: .unbounded
        )
    }

    func produce() async throws {
        do {
           while !hasReachedEnd {
               let books = try await fetchBooks(page: page)
               hasReachedEnd = books.isEmpty
               for book in books {
                   continuation.yield(book)
               }
               page += 1
           }
           continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }
    }

    // AsyncSequence required a nonisolated func here
    nonisolated func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
}
```

Starting with Swift 5.10, `nonisolated(unsafe)` can be used to opt-out of actor isolation checking for stored properties. This is useful to expose a property or method to the outside world, but you're sure that it's safe to do so. In this case, you're taking responsibility of isolating the state.

### Async Computed Properties

The alternative way to conform to protocols, is for the _protocol_ to be aware of the actor's isolation. This is done by using `async` computed properties.

```swift
protocol BankAccount {
    var balance: Int { get async }
    func deposit(_ amount: Int) async
    func withdraw(_ amount: Int) async
}

actor MyBankAccount: BankAccount {
    var balance: Int = 0

    func deposit(_ amount: Int) {
        balance += amount
    }

    func withdraw(_ amount: Int) {
        balance -= amount
    }
}
```

Because actor isolation makes these functions and properties `async`, this actor can now to the defined protocol.

Actors are a powerful way to share state between tasks. There's just one catch; Actors are "re-entrant".

When an actor is called from within itself, it's called re-entrant. This is important for many use cases and implementations, but it can lead to an unexpected consequence.

### Actor Re-Entrancy

When isolating state with a lock, Swift guarantees that only one thread can access the state at a time. When a function calls another function on the same thread, you can run into a deadlock. This happens because second function "locks" the state again, but because it's already locked, it waits indefinitely for the first function to unlock it.

Recursive locks are a common solution to that problem. In structured concurrency, you'll want to avoid locks entirely. In addition to the concerns mentioned previously, locks are blocking and can lead to performance bottlenecks even when used correctly.

When an actor is called from within itself, it's called re-entrant. Actors will not deadlock, similarly to recursive lock. This is important for many use cases and implementations, but it can lead to an unexpected consequence.

Because of re-entrancy, multiple tasks can call functions on the same actor at the same time! Actor isolation simply prevents race conditions, but does not provide a 'queue' for access.

Let's take the image cache example as an actor:

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        return cache[url]
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache[url] = image
    }

    func loadImage(for url: URL) async throws {
        if cache.keys.contains(url) {
            return
        }

        let image = try await fetchImage(at: url)
        setImage(image, for: url)
    }
}
```

The above function is an implementation of the image cache. It's a simple actor that allows storing and retrieving images by URL. Since actors are re-entrant, `loadImage` can be ran multiple times concurrently. This can lead to multiple fetches of the same image, and multiple writes to the cache.

Your code can still be correct and crash-free, but can be inefficient.

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]
    private var loadingURLs: Set<URL> = []

    func image(for url: URL) -> UIImage? {
        return cache[url]
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache[url] = image
    }

    func loadImage(for url: URL) async throws {
        if cache.keys.contains(url), !loadingURLs.contains(url) {
            return
        }

        loadingURLs.insert(url)
        defer { loadingURLs.remove(url) }
        let image = try await fetchImage(at: url)
        setImage(image, for: url)
    }
}
```

The above function is an improved implementation of the image cache. By tracking the URLs that are currently being loaded, you can avoid fetching the same image multiple times.

While actors are re-entrant, we can safely access and modify state in sequence _until_ we hit a suspension point.

The `await` keyword is the syntactical equivalent of a _possible_ suspension point. The function doesn't _need_ to suspend, but one should always assume that it _can_ suspend. This is especially important when working with actors.

Inbetween suspension points, this function is the only _currently_ running code on the actor. This means that you can safely access and modify state without worry.

### Capture Groups

Now that you know about Sendable and actors, you might be wondering why only _some_ functions are Sendable.

When passing a callback to a function, it is marked as `@escaping`. This means Swift knows that the function can be stored. It can be called at any point, and possibly even multiple times! The properties that this function need to exist by the time that the escaping closure function is called.

When a callback is accessing properties on `self`, the compiler will emit a retain on `self`. Because implicitly capturing `self` can lead to unintentionally prolonged lifetimes, Swift requires you to explicitly access these properties as such:

```swift
final class NeedsImage {
    var result: Result<Image, Error>?

    func fetch() {
        fetchImage(at: ...) { fetchedImage in
            // Note that we have to *explicitly* add `self.`
            self.result = fetchedImage
        }
    }
}
```

"Escaping" in this context refers to the function escaping the scope in which it was defined. The values that this function accesses are usually implicitly _captured_. If they're a reference type, they emit a retain. Likewise, when this function is no longer stored, it emits a release.

By explicitly creating a capture group, you'll only retain the values needed. See the following example:

```swift
let (stream, continuation) = AsyncThrowingStream<UIImage>.makeStream(
    bufferingPolicy: .unbounded
)

// Hypothetical function that lists images
// Calls the callback once for each image found
findImages { [continuation] image in
    // Captures `continuation`
    continuation.yield(image)
} onCompletion: { [continuation] error in
    // Captures `continuation`
    // Called exactly once when done or failed
    if let error = error {
        continuation.finish(throwing: error)
    } else {
        continuation.finish()
    }
}

for try await image in stream {
    // Show image
}
```

### @Sendable Functions

When marking functions as `@Sendable`, you're telling Swift that the function is safe to be stored and called across actor boundaries and is thread-safe. Swift will enforce that the function is not accessing any state that is not Sendable.

Callback function arguments can be makred `@Sendable` as such:

```swift
func fetchImage(at url: URL, completion: @Sendable @escaping (Result<UIImage, Error>) -> Void) {
    ...
}
```

Finally, regular functions can be marked `@Sendable` as well:

```swift
@Sendable func fetchImage(at url: URL) async throws -> UIImage {
    ...
}
```

## Continuations

So far, we've been using `await` to wait for a value to be available. But not all APIs are designed to work with `async` and `await`. When using APIs that were designed before concurrency, "continuations" can bridge the gap.

A continuation is a way to capture the current state of a task, and to resume the task at a later point.
Let's implement a simple continuation that fetches an image:

```swift
@Sendable func fetchImage(at url: URL) async throws -> UIImage {
    return try await withCheckedThrowingContinuation { continuation in
        fetchImage(at: url) { result in
            switch result {
            case .success(let image):
                continuation.resume(returning: image)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
```

There are two variations of continuations.

A `CheckedContinuation` is a continuation that checks for correct use. Continuations **must** be resumed exactly once. If you don't resume the continuation or if you resume it more than once, your application will crash. This is a safety feature to prevent worse problems from happening.

In contrast, an `UnsafeContinuation` is a continuation that doesn't check for correct use. If you resume the continuation multiple times, or if you don't resume it at all, you'll be sure to run into undefined behaviour - leading to a variety of hard-to-debug problems. However, unsafe continuations can be useful in _extremely_ performance-sensitive code.

Continuations can be throwing or non-throwing, for example:

```swift
await withCheckedContination { continuation in
    // Asynchronous work that does not fail
}
```

Continuations will suspend the task until they're resumed. While continuations are great for bridging the gap between async and non-async code, they're also very useful in other cases when using structured concurrency.

Let's go back to the ImageCache example. In that example, the `loadImage` function fetches an image and stores it in the cache. In this case, it does not return the cached image, making the API very unpractical!

We can restructure the `loadImage` function to use a continuation:

```swift
final class ImageCache {
    private var cache: [URL: UIImage] = [:]
    private var loadingURLs: Set<URL> = []
    private var fetchingURLs: [(URL, CheckedContinuation<UIImage, Error>)] = []
    private func completeFetchingURLs(with result: Result<UIImage, Error>, for url: URL) {
        for (awaitingURL, continuation) in fetchingURLs where awaitingURL == url {
            switch result {
            case .success(let image):
                continuation.resume(returning: image)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
        fetchingURLs.removeAll { $0.0 == url }
    }

    func loadImage(at url: URL) async throws -> UIImage {
        if let image = cache[url] {
            return image
        }

        if loadingURLs.contains(url) {
            return try await withCheckedThrowingContinuation { continuation in
                fetchingURLs.append((url, continuation))
            }
        }

        loadingURLs.insert(url)
        defer { loadingURLs.remove(url) }

        do {
            let image = try await fetchImage(at: url)
            setImage(image, for: url)
            completeFetchingURLs(with: .success(image), for: url)
            return image
        } catch {
            completeFetchingURLs(with: .failure(error), for: url)
            throw error
        }
    }
}
```

**Note:** When creating a continuation, you're starting a new workload that does not (yet) adopt structured concurrency. When this happens, this code is also responsible for ensuring that Task Cancellation is handled propertly. For that, please refer back to `withTaskCancellationHandler` earlier in this article.

## Global Actors

We've seen actors being used to isolate state and to share state between tasks. Global actors are singleton-actors that isolate state outside of their type. This allows global actors to be used to isolate state in a global context, such as static members or static functions.

The most commonly known and used global actor is the `MainActor`. This actor is used to isolate state on the main thread, and is commonly used on iOS to ensure that UI updates and relevant state changes are done on the main thread.

You can use the `@MainActor` attribute to mark a property as being isolated to the main actor:

```swift
@MainActor var view: UIView
```

Functions can also apply the `MainActor` by marking it as shown here:

```swift
// MainActor isolated
@MainActor func updateUI() {
    // Update the UI
    // Accessing `view` is safe, and does not need `await`
    // Because both share the same actor's isolation
    view.backgroundColor = .red
}
```

When applying a global actor, the values and/or functions are isolated to this actor. This means that any isolated state can only be accessed from within the same actor's isolation, and you'll need to `await` getting the actor's state from outside of the actor. In addition, state cannot be _modified_ outside of the actor's isolation.

```swift
// Not a `MainActor` isolated function
func rerenderUI(every duration: Duration) async throws {
    // Within this nonisolated function, `view` may not be modified
    while true {
        // Can get cancelled
        try await Task.sleep(for: duration)

        // `updateUI` is MainActor isolated
        // Since this function is not isolated to @MainActor, we need to `await` the call
        await updateUI()
        // `view` is MainActor isolated, so needs to be `await`ed
        print(await view.backgroundColor)
    }
}
```

When calling an `async` function from an _isolated_ context such as the _MainActor_, isolation is _not_ inherited. Swift will use the global concurrent executor to run this function, instead of the executor specified by the (global) actor.

This frees up the actor to continue processing other tasks, and prevents the actor from being blocked by a long-running task. Freeing up the `MainActor` is helpful, as it ensures that the UI remains responsive. However, this is also the reason why _actor re-entrancy_ happens!

### Creating a Global Actor

Custom global actors can be created through the `@globalActor` attribute:

```swift
@globalActor actor SensorActor {
    static let shared = SensorActor()
}
```

With this addition, you can isolate properties, functions _and types_ to the `SensorActor`:

```swift
struct DeviceRotation {
    var yaw: Double
    var pitch: Double
    var roll: Double
}

@SensorActor final class PhoneMotionSensor: AsyncSequence {
    typealias Element = DeviceRotation
    typealias AsyncIterator = AsyncStream<DeviceRotation>.AsyncIterator

    // Inherts the `SensorActor` isolation
    var initial: DeviceRotation?
    private let continuation: AsyncStream<DeviceRotation>.Continuation

    // Opts out of the `SensorActor` isolation
    nonisolated private let stream: AsyncStream<DeviceRotation>

    init() {
        (stream, continuation) = AsyncStream<DeviceRotation>.makeStream(
            bufferingPolicy: .unbounded
        )
    }

    // Inherts the `SensorActor` isolation
    func startObserving() async {
        let producer = SomeMotionDataProducer()
        for await rotation in producer {
            if initial == nil {
                initial = rotation
            }
            continuation.yield(rotation)
        }
        continuation.finish()
    }

    // Opts out of the `SensorActor` isolation
    nonisolated func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
}
```

## Swift 6

Starting in Swift 6, Structured Concurrency will be improved further. Even though as of writing, Swift 6 is still in development, we can already see some of the improvements that are coming. This section will be regularly updated to reflect Swift 6's changes.

### Task Executors (Swift 6)

Starting from Swift 6, you can specify a "task executor" to run tasks on. This is described in [SE-0417](https://github.com/apple/swift-evolution/blob/main/proposals/0417-task-executor-preference.md). This is especially useful for server-side Swift, where code can run within a [SwiftNIO event loop](/using-swiftnio-fundamentals).

In Server-Side Swift, all I/O is done asynchronously on the EventLoop. By tying business logic to the same EventLoop as the I/O, you can ensure that there is no unnecessary context switching. This can lead to a significant performance improvement.

You can create a task executor by conforming to the `TaskExecutor` type. This is a part of Swift 6, and is used to run tasks on a specific executor.

```swift
final class EventLoopExecutor: TaskExecutor, SerialExecutor {
    @usableFromInline let eventLoop: EventLoop

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }

    func asUnownedTaskExecutor() -> UnownedTaskExecutor {
        UnownedTaskExecutor(ordinary: self)
    }

    @inlinable
    func enqueue(_ job: consuming ExecutorJob) {
        let job = UnownedJob(job)
        eventLoop.execute {
            job.runSynchronously(on: self.asUnownedTaskExecutor())
        }
    }

    @inlinable
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(complexEquality: self)
    }
}
```

Now, when running a task, you can specify the executor to run the task on when you're adding it to a task group:

```swift
let executor = EventLoopExecutor(eventLoop: value.eventLoop)
let unmanaged = Unmanaged.passRetained(executor)
taskGroup.addTask(executorPreference: executor) {
    await handle(value: value, logger: logger)
    unmanaged.release()
}
```

As you may notice, the `EventLoopExecutor` type is _manually_ retained and released. This is becasue the `addTask` method does not retain the executor. If the EventLoopExecutor type is not retained elsewhere, it will be deallocated before the task is done running, causing a crash.

#### Running Heavy Workloads

Previously, we wrote that large workloads should be run outside of structured concurrency. This is necessary, since the _standard_ executor in Swift is designed to run tasks concurrently. In Swift 6, this is executor is the `globalConcurrentExecutor`, which is hidden in previous versions of Swift.

However, heavy workload _can_ be run on a custom executor. Using the pattern shown above, or an executor that is could be provided by SwiftNIO in the future, heavy workloads can run on a custom executor that is designed to handle heavy workloads.
