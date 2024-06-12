---
slug: swift-actors-tutorial-a-beginners-guide-to-thread-safe-concurrency
title: Swift actors tutorial - a beginner's guide to thread safe concurrency
description: Learn how to use the brand new actor model to protect your application from unwanted data-races and memory issues.
publication: 2021-06-17 16:20:00
tags: Swift, Concurrency
---

## Thread safety & data races

Before we dive in to Swift actors, let's have a simplified recap of computer theory first.

An instance of a computer program is called [process](https://en.wikipedia.org/wiki/Process_(computing)). A process contains smaller instructions that are going to be executed at some point in time. These instruction tasks can be performed one after another in a serial order or concurrently. The operating system is using [multiple threads](https://en.wikipedia.org/wiki/Multithreading_(computer_architecture)) to execute tasks in parallel, also schedules the order of execution with the help of a [scheduler](https://en.wikipedia.org/wiki/Scheduling_(computing)). 🕣

After a task is being completed on a given [thread](https://en.wikipedia.org/wiki/Thread_(computing)), the CPU can to move forward with the execution flow. If the new task is associated with a different thread, the CPU has to perform a [context switch](https://en.wikipedia.org/wiki/Context_switch). This is quite an expensive operation, because the state of the old thread need to be saved, the new one should be restored before we can perform our actual task.

During this context switching a bunch of other oprations can happen on different threads. Since modern CPU architectures have multiple cores, they can handle multiple threads at the same time. Problems can happen if the same resource is being modified at the same time on multiple threads. Let me show you a quick example that produces an unsafe output. 🙉

```swift
var unsafeNumber: Int = 0
DispatchQueue.concurrentPerform(iterations: 100) { i in
    print(Thread.current)
    unsafeNumber = i
}

print(unsafeNumber)
```

If you run the code above multiple times, it's possible to have a different output each time. This is because the concurrentPerform method runs the block on different threads, some threads have higher priorities than others so the execution order is not guaranteed. You can see this for yourself, by printing the current thread in each block. Some of the number changes happen on the main thread, but others happen on a background thread. 🧵

The main thread is a special one, all the user interface related updates should happen on this one. If you are trying to update a view from a background thread in an iOS application you'll could get an warning / error or even a crash. If you are blocking the main thread with a long running application your entire UI can become unresponsive, that's why it is good to have multiple threads, so you can move your computation-heavy operations into background threads.

It's a very common approach to work with multiple threads, but this can lead to unwanted data races, data corruption or crashes due to memory issues. Unfortunately most of the Swift data types are not thread safe by default, so if you want to achieve thread-safety you usually had to work with serial queues or locks to guarantee the [mutual exclusivity](https://en.wikipedia.org/wiki/Mutual_exclusion) of a given variable.

```swift
var threads: [Int: String] = [:]
DispatchQueue.concurrentPerform(iterations: 100) { i in
    threads[i] = "\(Thread.current)"
}
print(threads)
```

The snippet above will crash for sure, since we're trying to modify the same dictionary from multiple threads. This is called a data-race. You can detect these kind of issues by enabling the Thread Sanitizer under the Scheme > Run > Diagnostics tab in Xcode. 🔨

Now that we know what's a data race, let's fix that by using a regular [Grand Central Dispatch](https://theswiftdev.com/ultimate-grand-central-dispatch-tutorial-in-swift/) based approach. We're going to create a new serial dispatch queue to prevent concurrent writes, this will syncronize all the write operations, but of course it has a hidden cost of switching the context each and every time we update the dictionary.

```swift
var threads: [Int: String] = [:]
let lockQueue = DispatchQueue(label: "my.serial.lock.queue")
DispatchQueue.concurrentPerform(iterations: 100) { i in
    lockQueue.sync {
        threads[i] = "\(Thread.current)"
    }
}
print(threads)
```

This synchronization technique is a quite popular solution, we could create a generic class that hides the internal private storage and the lock queue, so we can have a nice public interface that you can use safely without dealing with the internal protection mechanism. For the sake of simplicity we're not going to introduce generics this time, but I'm going to show you a simple AtomicStorage implementation that uses a serial queue as a lock system. 🔒

```swift
import Foundation
import Dispatch

class AtomicStorage {

    private let lockQueue = DispatchQueue(label: "my.serial.lock.queue")
    private var storage: [Int: String]
    
    init() {
        self.storage = [:]
    }
        
    func get(_ key: Int) -> String? {
        lockQueue.sync {
            storage[key]
        }
    }
    
    func set(_ key: Int, value: String) {
        lockQueue.sync {
            storage[key] = value
        }
    }

    var allValues: [Int: String] {
        lockQueue.sync {
            storage
        }
    }
}

let storage = AtomicStorage()
DispatchQueue.concurrentPerform(iterations: 100) { i in
    storage.set(i, value: "\(Thread.current)")
}
print(storage.allValues)
```

Since both read and write operations are sync, this code can be quite slow since the entire queue has to wait for both the read and write operations. Let's fix this real quick by changing the serial queue to a concurrent one, and marking the write function with a barrier flag. This way users can read much faster (concurrently), but writes will be still synchronized through these barrier points.

```swift
import Foundation
import Dispatch

class AtomicStorage {

    private let lockQueue = DispatchQueue(label: "my.concurrent.lock.queue", attributes: .concurrent)
    private var storage: [Int: String]
    
    init() {
        self.storage = [:]
    }
        
    func get(_ key: Int) -> String? {
        lockQueue.sync {
            storage[key]
        }
    }
    
    func set(_ key: Int, value: String) {
        lockQueue.async(flags: .barrier) { [unowned self] in
            storage[key] = value
        }
    }

    var allValues: [Int: String] {
        lockQueue.sync {
            storage
        }
    }
}

let storage = AtomicStorage()
DispatchQueue.concurrentPerform(iterations: 100) { i in
    storage.set(i, value: "\(Thread.current)")
}
print(storage.allValues)
```

Of course we could speed up the mechanism with dispatch barriers, alternatively we could use an `os_unfair_lock`, `NSLock` or a dispatch semaphore to create similar thread-safe atomic objects.

One important takeaway is that even if we are trying to select the best available option by using sync we'll always block the calling thread too. This means that nothing else can run on the thread that calls synchronized functions from this class until the internal closure completes. Since we're synchronously waiting for the thread to return we can't utilize the CPU for other work. ⏳

We can say that there are quite a lot of problems with this approach:

- Context switches are expensive operations
- Spawning multiple threads can lead to [thread explosions](https://developer.apple.com/videos/play/wwdc2015/718/?time=1509)
- You can (accidentally) block threads and prevent further code execution
- You can create a [deadlock](https://en.wikipedia.org/wiki/Deadlock) if multiple tasks are waiting for each other
- Dealing with (completion) blocks and memory references are error prone
- It's really easy to forget to call the proper synchronization block

That's quite a lot of code just to provide thread-safe atomic access to a property. Despite the fact that we're using a concurrent queue with barriers (locks have problems too), the CPU needs to switch context every time we're calling these functions from a different thread. Due to the synchronous nature we are blocking threads, so this code is not the most efficient.

Fortunately Swift 5.5 offers a safe, modern and overall much better alternative. 🥳

## Introducing Swift actors

Now let's refactor this code using the [new Actor type](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md) introduced in Swift 5.5. Actors can protect internal state through data isolation ensuring that only a single thread will have access to the underlying data structure at a given time. Long story short, everything inside an actor will be thread-safe by default. First I'll show you the code, then we'll talk about it. 😅

```swift
import Foundation

actor AtomicStorage {

    private var storage: [Int: String]
    
    init() {
        self.storage = [:]
    }
        
    func get(_ key: Int) -> String? {
        storage[key]
    }
    
    func set(_ key: Int, value: String) {
        storage[key] = value
    }

    var allValues: [Int: String] {
        storage
    }
}

Task {
    let storage = AtomicStorage()
    await withTaskGroup(of: Void.self) { group in
        for i in 0..<100 {
            group.async {
                await storage.set(i, value: "\(Thread.current)")
            }
        }
    }
    print(await storage.allValues)
}
```

First of all, actors are reference types, just like classes. They can have methods, properties, they can implement protocols, but they don't support inheritance.

> NOTE: Since actors are closely related to the newly introduced [async/await concurrency APIs](https://theswiftdev.com/introduction-to-asyncawait-in-swift/) in Swift you should be familiar with that concept too if you want to understand how they work.

The very first big difference is that we don't need to provide a lock mechanism anymore in order to provide read or write access to our private storage property. This means that we can safely access actor properties within the actor using a synchronous way. Members are isolated by default, so there is a guarantee (by the compiler) that we can only access them using the same context.

What's going on with the new Task API and all the await keywords? 🤔

Well, the Dispatch.concurrentPerform call is part of a parallelism API and Swift 5.5 introduced concurrency instead of parallelism, we have to move away from regular queues and use [structured concurrency](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md) to perform tasks in parallel. Also the concurrentPerform function is not an asynchronous operation, it'll block the caller thread until all the work is done within the block.

Working with async/await means that the CPU can work on a different task when awaits for a given operation. Every await call is a potential [suspension point](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md#suspension-points), where the function can give up the thread and the CPU can perform other tasks until the awaited function resumes & returns with the necessary value. The [new Swift concurrency APIs](https://developer.apple.com/videos/play/wwdc2021/10254/) are built on top a cooperative thread pool, where each CPU core has just the right amount of threads and the suspension & continuation happens "virtually" with the help of the language runtime. This is far more efficient than actual context switching, and also means that when you interact with async functions and await for a function the CPU can work on other tasks instead of blocking the thread on the call side.

So back to the example code, since actors have to protect their internal states, they only allows us to access members asynchronously when you reference from async functions or outside the actor. This is very similar to the case when we had to use the lockQueue.sync to protect our read / write functions, but instead of giving the ability to the system to perform other tasks on the thread, we've entirely blocked it with the sync call. Now with await we can give up the thread and allow others to perform operations using it and when the time comes the function can resume.

Inside the task group we can perform our tasks asynchronously, but since we're accessing the actor function (from an async context / outside the actor) we have to use the await keyword before the set call, even if the function is not marked with the async keyword.

The system knows that we're referencing the actor's property using a different context and we have to perform this operation always isolated to eliminate data races. By converting the function to an async call we give the system a chance to perform the operation on the actor's executor. Later on we'll be able to define [custom executors](https://forums.swift.org/t/support-custom-executors-in-swift-concurrency/44425) for our actors, but this feature is not available yet.

Currently there is a global executor implementation (associated with each actor) that enqueues the tasks and runs them one-by-one, if a task is not running (no contention) it'll be scheduled for execution (based on the priority) otherwise (if the task is already running / under contention) the system will just pick-up the message without blocking.

The funny thing is that this does not necessary means that the exact same thread... 😅

```swift
import Foundation

extension Thread {
    var number: String {
        "\(value(forKeyPath: "private.seqNum")!)"
    }
}

actor AtomicStorage {

    private var storage: [Int: String]
    
    init() {
        print("init actor thread: \(Thread.current.number)")
        self.storage = [:]
    }
        
    func get(_ key: Int) -> String? {
        storage[key]
    }
    
    func set(_ key: Int, value: String) {
        storage[key] = value + ", actor thread: \(Thread.current.number)"
    }

    var allValues: [Int: String] {
        print("allValues actor thread: \(Thread.current.number)")
        return storage
    }
}


Task {
    let storage = AtomicStorage()
    await withTaskGroup(of: Void.self) { group in
        for i in 0..<100 {
            group.async {
                await storage.set(i, value: "caller thread: \(Thread.current.number)")
            }
        }
    }    
    for (k, v) in await storage.allValues {
        print(k, v)
    }
}
```

Multi-threading is hard, anyway same thing applies to the storage.allValues statement. Since we're accessing this member from outside the actor, we have to await until the "synchronization happens", but with the await keyword we can give up the current thread, wait until the actor returns back the underlying storage object using the associated thread, and voilá we can continue just where we left off work. Of course you can create async functions inside actors, when you call these methods you'll always have to use await, no matter if you are calling them from the actor or outside.

There is still a lot to cover, but I don't want to bloat this article with more advanced details. I know I'm just scratching the surface and we could talk about non-isolated functions, actor reentrancy, global actors and many more. I'll definitely create more articles about actors in Swift and cover these topics in the near future, I promise. Swift 5.5 is going to be a great release. 👍

Hopefully this tutorial will help you to start working with actors in Swift. I'm still learning a lot about the new concurrency APIs and nothing is written in stone yet, the core team is still changing names and APIs, there are some proposals on the [Swift evolution dashboard](https://apple.github.io/swift-evolution/) that still needs to be reviewed, but I think the Swift team did an amazing job. Thanks everyone. 🙏

Honestly actors feels like magic and I already love them. 😍
