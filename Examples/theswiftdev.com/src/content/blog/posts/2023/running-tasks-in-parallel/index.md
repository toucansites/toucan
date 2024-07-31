---
type: post
slug: running-tasks-in-parallel
title: Running tasks in parallel
description: Learn how to run tasks in parallel using the old-school tools and frameworks plus the new structured concurrency API in Swift.
publication: 2023-02-09 16:20:00
tags: Swift, Concurrency
authors:
  - tibor-bodecs
---

Being able to run tasks in parallel is nice, it can speed up things for sure when you can utilize multiple CPU cores, but how can we actually implement these kind of operations in Swift? 🤔

There are multiple ways of running parallel operations, I had a longer article about the [Grand Central Dispatch](https://theswiftdev.com/ultimate-grand-central-dispatch-tutorial-in-swift/) (GCD) framework, there I explained the differences between parallelism and concurrency. I also demonstrated how to set up serial and concurrent dispatch queues, but this time I'd like to focus a bit more on tasks, workers and jobs.

Imagine that you have a picture which is 50000 pixel wide and 20000 pixel long, that's exactly one billion pixels. How would you alter the color of each pixel? Well, we could do this by iterating through each pixel and let one core do the job, or we could run tasks in parallel.

The Dispatch framework offers multiple ways to solve this issue. The first solution is to use the [concurrentPerform](https://developer.apple.com/documentation/dispatch/dispatchqueue/2016088-concurrentperform) function and specify some number of workers. For the sake of simplicity, I'm going to add up the numbers from zero to 1 billion using 8 workers. 💪

```swift
import Dispatch

let workers: Int = 8
let numbers: [Int] = Array(repeating: 1, count: 1_000_000_000)

var sum = 0
DispatchQueue.concurrentPerform(iterations: workers) { index in
    let start = index * numbers.count / workers
    let end = (index + 1) * numbers.count / workers
    print("Worker #\(index), items: \(numbers[start..<end].count)")

    sum += numbers[start..<end].reduce(0, +)
}

print("Sum: \(sum)")
```

Cool, but still each worker has to work on quite a lot of numbers, maybe we shouldn't start all the workers at once, but use a pool and run only a subset of them at a time. This is quite an easy task with [operation queues](https://developer.apple.com/documentation/foundation/operationqueue), let me show you a basic example. 😎

```swift
import Foundation

let workers: Int = 8
let numbers: [Int] = Array(repeating: 1, count: 1_000_000_000)

let operationQueue = OperationQueue()
operationQueue.maxConcurrentOperationCount = 4

var sum = 0
for index in 0..<workers {
    let operation = BlockOperation {
        let start = index * numbers.count / workers
        let end = (index + 1) * numbers.count / workers
        print("Worker #\(index), items: \(numbers[start..<end].count)")
        
        sum += numbers[start..<end].reduce(0, +)
    }
    operationQueue.addOperation(operation)
}

operationQueue.waitUntilAllOperationsAreFinished()

print("Sum: \(sum)")
```

Both of the examples are above are more ore less good to go (if we look through at possible data race & synchronization), but they depend on additional frameworks. In other words they are non-native Swift solutions. What if we could do something better using [structured concurrency](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md)?

```swift
let workers: Int = 8
let numbers: [Int] = Array(repeating: 1, count: 1_000_000_000)

let sum = await withTaskGroup(of: Int.self) { group in
    for i in 0..<workers {
        group.addTask {
            let start = i * numbers.count / workers
            let end = (i + 1) * numbers.count / workers
            return numbers[start..<end].reduce(0, +)
        }
    }

    var summary = 0
    for await result in group {
        summary += result
    }
    return summary
}

print("Sum: \(sum)")
```

By using [task groups](https://developer.apple.com/documentation/swift/taskgroup) you can easily setup the workers and run them in parallel by adding a task to the group. Then you can wait for the partial sum results to arrive and sum everything up using a thread-safe solution. This approach is great, but is it possible to limit the maximum number of concurrent operations, just like we did with operation queues? 🤷‍♂️

```swift
func parallelTasks<T>(
    iterations: Int,
    concurrency: Int,
    block: @escaping ((Int) async throws -> T)
) async throws -> [T] {
    try await withThrowingTaskGroup(of: T.self) { group in
        var result: [T] = []

        for i in 0..<iterations {
            if i >= concurrency {
                if let res = try await group.next() {
                    result.append(res)
                }
            }
            group.addTask {
                try await block(i)
            }
        }

        for try await res in group {
            result.append(res)
        }
        return result
    }
}


let workers: Int = 8
let numbers: [Int] = Array(repeating: 1, count: 1_000_000_000)

let res = try await parallelTasks(
    iterations: workers,
    concurrency: 4
) { i in
    print(i)
    let start = i * numbers.count / workers
    let end = (i + 1) * numbers.count / workers
    return numbers[start..<end].reduce(0, +)
}

print("Sum: \(res.reduce(0, +))")
```

It is possible, I made a little helper function similar to the `concurrentPerform` method, this way you can execute a number of tasks and limit the level of concurrency. The main idea is to run a number of iterations and when the index reaches the maximum number of concurrent items you wait until a work item finishes and then you add a new task to the group. Before you finish the task you also have to await all the remaining results and append those results to the grouped result array. 😊

That's it for now, I hope this little article will help you to manage concurrent operations a bit better.
