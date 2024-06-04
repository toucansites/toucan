---
slug: swift-object-pool-design-pattern
title: Swift object pool design pattern
description: In this quick tutorial I'll explain & show you how to implement the object pool design pattern using the Swift programming language.
publication: 2018-12-09 16:20:00
tags: Swift, iOS, design patterns
---

## A generic object pool in Swift

The [object pool](https://en.wikipedia.org/wiki/Object_pool_pattern) pattern is a creational design pattern. The main idea behind it is that first you create a set of objects (a pool), then you acquire & release objects from the pool, instead of constantly creating and releasing them. 👍

Why? Performance improvements. For example the [Dispatch framework](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/) uses an [object pool](http://audreyli.me/2015/07/14/a-design-pattern-story-in-swift-chapter-16-object-pool/) pattern to give pre-created queues for the developers, because creating a queue (with an associated thread) is an relatively expensive operation.

Another use case of the [object pool](https://medium.com/@sawomirkowalski/design-patterns-object-pool-e8269fd45e10) pattern is workers. For example you have to download hundreds of images from the web, but you'd like to download only 5 simultaneously you can do it with a pool of 5 worker objects. Probably it's going to be a lot cheaper to allocate a small number of workers (that'll actually do the download task), than create a new one for every single image download request. 🖼

What about the downsides of this pattern? There are some. For example if you have workers in your pool, they might contain states or sensitive user data. You have to be very careful with them aka. reset everything. Also if you are running in a multi-threaded environment you have to make your pool **thread-safe**.

Here is a simple generic thread-safe [object pool](https://github.com/reswifq/pool) class:

```swift
import Foundation

class Pool<T> {

    private let lockQueue = DispatchQueue(label: "pool.lock.queue")
    private let semaphore: DispatchSemaphore
    private var items = [T]()

    init(_ items: [T]) {
        self.semaphore = DispatchSemaphore(value: items.count)
        self.items.reserveCapacity(items.count)
        self.items.append(contentsOf: items)
    }

    func acquire() -> T? {
        if self.semaphore.wait(timeout: .distantFuture) == .success, !self.items.isEmpty {
            return self.lockQueue.sync {
                return self.items.remove(at: 0)
            }
        }
        return nil
    }

    func release(_ item: T) {
        self.lockQueue.sync {
            self.items.append(item)
            self.semaphore.signal()
        }
    }
}


let pool = Pool<String>(["a", "b", "c"])

let a = pool.acquire()
print("\(a ?? "n/a") acquired")
let b = pool.acquire()
print("\(b ?? "n/a") acquired")
let c = pool.acquire()
print("\(c ?? "n/a") acquired")

DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .seconds(2)) {
    if let item = b {
        pool.release(item)
    }
}

print("No more resource in the pool, blocking thread until...")
let x = pool.acquire()
print("\(x ?? "n/a") acquired again")
```

As you can see the implementation is just a few lines. You have the thread safe array of the generic pool items, a dispatch semaphore that'll block if there are no objects available in the pool, and two methods in order to actually use the object pool.

In the sample you can see that if there are no more objects left in the pool, the current queue will be blocked until a resource is being freed & ready to use. So watch out & don't block the main thread accidentally! 😉
