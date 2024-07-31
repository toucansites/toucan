---
type: post
slug: ultimate-grand-central-dispatch-tutorial-in-swift
title: Ultimate Grand Central Dispatch tutorial in Swift
description: Learn the principles of multi-threading with the GCD framework in Swift. Queues, tasks, groups everything you'll ever need I promise.
publication: 2018-07-10 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## GCD concurrency tutorial for beginners

The [Grand Central Dispatch](https://developer.apple.com/documentation/dispatch) (GCD, or just Dispatch) framework is based on the underlying thread pool design pattern. This means that there are a fixed number of threads spawned by the system - based on some factors like CPU cores - they're always available waiting for tasks to be executed concurrently. 🚦

Creating threads on the run is an expensive task so [GCD](https://www.raywenderlich.com/148513/grand-central-dispatch-tutorial-swift-3-part-1) organizes tasks into specific queues, and later on the tasks waiting on these queues are going to be executed on a proper and available thread from the pool. This approach leads to great performance and low execution latency. We can say that the [Dispatch](https://www.swiftbysundell.com/posts/a-deep-dive-into-grand-central-dispatch-in-swift) framework is a very fast and efficient concurrency framework designed for modern multi-core hardware and needs.

### Concurrency, multi-tasking, CPU cores, parallelism and threads

A processor can run tasks made by you programmatically, this is usually called coding, developing or programming. The code executed by a [CPU core](https://www.quora.com/What-is-the-difference-between-cores-and-threads-of-a-processor) is a thread. So your app is going to create a process that is made up from threads. 🤓

In the past a processor had one single core, it could only deal with one task at a time. Later on time-slicing was introduced, so CPU's could execute threads concurrently using context switching. As time passed by processors gained more horse power and cores so they were capable of real multi-tasking using parallelism. ⏱

Nowadays a CPU is a very powerful unit, it's capable of executing billions of tasks (cycles) per second. Because of this high availability speed Intel introduced a technology called hyper-threading. They divided CPU clock cycles between (usually two) processes running at the same time, so the number of available threads essentially doubled. 📈

As you can see concurrent execution can be achieved with various techniques, but you don't need to care about that much. It's up to the CPU architecture how it solves [concurrency](https://www.uraimo.com/2017/05/07/all-about-concurrency-in-swift-1-the-present/), and it's the operating system's task how much thread is going to be spawned for the underlying thread pool. The GCD framework will hide all the complexity, but it's always good to understand the basic principles. 👍

## Synchronous and asynchronous execution

Each work item can be executed either synchronously or asynchronously.

Have you ever heard of blocking and non-blocking code? This is the same situation here. With synchronous tasks you'll block the execution queue, but with async tasks your call will instantly return and the queue can continue the execution of the remaining tasks (or work items as Apple calls them). 🚧

### Synchronous execution

When a work item is executed synchronously with the sync method, the program waits until execution finishes before the method call returns.

Your function is most likely synchronous if it has a return value, so `func load() -> String` is going to probably block the thing that runs on until the resources is completely loaded and returned back.

### Asynchronous execution

When a work item is executed asynchronously with the async method, the method call returns immediately.

Completion blocks are a good sing of async methods, for example if you look at this method `func load(completion: (String) -> Void)` you can see that it has no return type, but the result of the function is passed back to the caller later on through a block.

This is a typical use case, if you have to wait for something inside your method like reading the contents of a huge file from the disk, you don't want to block your CPU, just because of the slow IO operation. There can be other tasks that are not IO heavy at all (math operations, etc.) those can be executed while the system is reading your file from the physical hard drive. 💾

With dispatch queues you can execute your code synchronously or asynchronously. With synchronous execution the queue waits for the work, with async execution the code returns immediately without waiting for the task to complete. ⚡️

## Dispatch queues

As I mentioned before, [GCD](https://www.appcoda.com/grand-central-dispatch/) organizes task into queues, these are just like the queues at the shopping mall. On every dispatch queue, tasks will be executed in the same order as you add them to the queue - FIFO: the first task in the line will be executed first - but you should note that the order of completion is not guaranteed. Tasks will be completed according to the code complexity. So if you add two tasks to the queue, a slow one first and a fast one later, the fast one can finish before the slower one. ⌛️

### Serial and concurrent queues

There are two types of dispatch queues. Serial queues can execute one task at a time, these queues can be utilized to synchronize access to a specific resource. Concurrent queues on the other hand can execute one or more tasks parallel in the same time. Serial queue is just like one line in the mall with one cashier, concurrent queue is like one single line that splits for two or more cashiers. 💰

### Main, global and custom queues

The main queue is a serial one, every task on the main queue runs on the main thread.

Global queues are system provided concurrent queues shared through the operating system. There are exactly four of them organized by high, default, low priority plus an IO throttled background queue.

Custom queues can be created by the user. Custom concurrent queues always mapped into one of the global queues by specifying a Quality of Service property (QoS). In most of the cases if you want to run tasks in parallel it is recommended to use one of the global concurrent queues, you should only create custom serial queues.

### System provided queues

- Serial main queue
- Concurrent global queues
- high priority global queue
- default priority global queue
- low priority global queue
- global background queue (IO throttled)

### Custom queues by quality of service

- userInteractive (UI updates) -> serial main queue
- userInitiated (async UI related tasks) -> high priority global queue
- default -> default priority global queue
- utility -> low priority global queue
- background -> global background queue
- unspecified (lowest) -> low priority global queue

Enough from the theory, let's see how to use the Dispatch framework in action! 🎬

## How to use the DispatchQueue class in Swift?

Here is how you can get all the queues from above using the brand new GCD syntax available from Swift 3. Please note that you should always use a global concurrent queue instead of creating your own one, except if you are going to use the concurrent queue for locking with barriers to achieve [thread safety](http://basememara.com/creating-thread-safe-arrays-in-swift/), more on that later. 😳

### How to get a queue?

```swift
import Dispatch

DispatchQueue.main
DispatchQueue.global(qos: .userInitiated)
DispatchQueue.global(qos: .userInteractive)
DispatchQueue.global(qos: .background)
DispatchQueue.global(qos: .default)
DispatchQueue.global(qos: .utility)
DispatchQueue.global(qos: .unspecified)

DispatchQueue(
    label: "com.theswiftdev.queues.serial"
)

DispatchQueue(
    label: "com.theswiftdev.queues.concurrent", 
    attributes: .concurrent
)
```

So executing a task on a background queue and updating the UI on the main queue after the task finished is a pretty easy one using Dispatch queues.

```swift
DispatchQueue.global(qos: .background).async {
    // do your job here

    DispatchQueue.main.async {
        // update ui here
    }
}
```

### Sync and async calls on queues

There is no big difference between sync and async methods on a queue. Sync is just an async call with a semaphore (explained later) that waits for the return value. A sync call will block, on the other hand an async call will immediately return. 🎉

```swift
let q = DispatchQueue.global()

let text = q.sync {
    return "this will block"
}
print(text)

q.async {
    print("this will return instantly")
}
```

Basically if you need a return value use sync, but in every other case just go with async. DEADLOCK WARNING: you should never call sync on the main queue, because it'll cause a deadlock and a crash. You can use this [snippet](https://gist.github.com/sgr-ksmt/4880c5df5aeec9e558622cd6d5b477cb) if you are looking for a safe way to do sync calls on the main queue / thread. 👌

> Don't call sync on a serial queue from the serial queue's thread!

### Delay execution

You can simply delay code execution using the Dispatch framework.

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
    //this code will be executed only after 2 seconds have been passed
}
```

### Perform concurrent loop

Dispatch queue simply allows you to perform iterations concurrently.

```swift
DispatchQueue.concurrentPerform(iterations: 5) { (i) in
    print(i)
}
```

### Debugging

Oh, by the way it's just for debugging purpose, but you can return the name of the current queue by using this little extension. Do not use in production code!!!

```swift
extension DispatchQueue {
    static var currentLabel: String {
        .init(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
//print(DispatchQueue.currentLabel)
```

### Using DispatchWorkItem in Swift

> DispatchWorkItem encapsulates work that can be performed. A work item can be dispatched onto a DispatchQueue and within a DispatchGroup. A DispatchWorkItem can also be set as a DispatchSource event, registration, or cancel handler.

So you just like with operations by using a work item you can cancel a running task. Also work items can notify a queue when their task is completed.

```swift
var workItem: DispatchWorkItem?
workItem = DispatchWorkItem {
    for i in 1..<6 {
        guard let item = workItem, !item.isCancelled else {
            print("cancelled")
            break
        }
        sleep(1)
        print(String(i))
    }
}

workItem?.notify(queue: .main) {
    print("done")
}


DispatchQueue.global().asyncAfter(
    deadline: .now() + .seconds(2)
) {
    workItem?.cancel()
}
DispatchQueue.main.async(execute: workItem!)
// you can use perform to run on the current queue instead of queue.async(execute:)
//workItem?.perform()
```

### Concurrent tasks with DispatchGroups

So you need to perform multiple network calls in order to construct the data required by a view controller? This is where DispatchGroup can help you. All of your long running background task can be executed concurrently, when everything is ready you'll receive a notification. Just be careful you have to use thread-safe data structures, so always modify arrays for example on the same thread! 😅

```swift
func load(delay: UInt32, completion: () -> Void) {
    sleep(delay)
    completion()
}

let group = DispatchGroup()

group.enter()
load(delay: 1) {
    print("1")
    group.leave()
}

group.enter()
load(delay: 2) {
    print("2")
    group.leave()
}

group.enter()
load(delay: 3) {
    print("3")
    group.leave()
}

group.notify(queue: .main) {
    print("done")
}
```

Note that you always have to balance out the enter and leave calls on the group. The dispatch group also allows us to track the completion of different work items, even if they run on different queues.

```swift
let group = DispatchGroup()
let queue = DispatchQueue(
    label: "com.theswiftdev.queues.serial"
)
let workItem = DispatchWorkItem {
    print("start")
    sleep(1)
    print("end")
}

queue.async(group: group) {
    print("group start")
    sleep(2)
    print("group end")
}
DispatchQueue.global().async(
    group: group, 
    execute: workItem
)

// you can block your current queue and wait until the group is ready
// a better way is to use a notification block instead of blocking
//group.wait(timeout: .now() + .seconds(3))
//print("done")

group.notify(queue: .main) {
    print("done")
}
```

One more thing that you can use dispatch groups for: imagine that you're displaying a nicely animated loading indicator while you do some actual work. It might happens that the work is done faster than you'd expect and the indicator animation could not finish. To solve this situation you can add a small delay task so the group will wait until both of the tasks finish. 😎

```swift
let queue = DispatchQueue.global()
let group = DispatchGroup()
let n = 9
for i in 0..<n {
    queue.async(group: group) {
        print("\(i): Running async task...")
        sleep(3)
        print("\(i): Async task completed")
    }
}
group.wait()
print("done")
```

## Semaphores

A [semaphore](https://en.wikipedia.org/wiki/Semaphore_(programming) is simply a variable used to handle resource sharing in a concurrent system. It's a really powerful object, here are a few important examples in Swift.

How to make an async task to synchronous?

The answer is simple, you can use a semaphore (bonus point for timeouts)!

```swift
enum DispatchError: Error {
    case timeout
}

func asyncMethod(completion: (String) -> Void) {
    sleep(2)
    completion("done")
}

func syncMethod() throws -> String {

    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue.global()

    var response: String?
    queue.async {
        asyncMethod { r in
            response = r
            semaphore.signal()
        }
    }
    semaphore.wait(timeout: .now() + 5)
    guard let result = response else {
        throw DispatchError.timeout
    }
    return result
}

let response = try? syncMethod()
print(response)
```

### Lock / single access to a resource

If you want to avoid race condition you are probably going to use [mutual exclusion](https://en.wikipedia.org/wiki/Mutual_exclusion). This could be achieved using a semaphore object, but if your object needs heavy reading capability you should consider a dispatch barrier based solution. 😜

```swift
class LockedNumbers {

    let semaphore = DispatchSemaphore(value: 1)
    var elements: [Int] = []

    func append(_ num: Int) {
        self.semaphore.wait(timeout: DispatchTime.distantFuture)
        print("appended: \(num)")
        self.elements.append(num)
        self.semaphore.signal()
    }

    func removeLast() {
        self.semaphore.wait(timeout: DispatchTime.distantFuture)
        defer {
            self.semaphore.signal()
        }
        guard !self.elements.isEmpty else {
            return
        }
        let num = self.elements.removeLast()
        print("removed: \(num)")
    }
}

let items = LockedNumbers()
items.append(1)
items.append(2)
items.append(5)
items.append(3)
items.removeLast()
items.removeLast()
items.append(3)
print(items.elements)
```

### Wait for multiple tasks to complete

Just like with dispatch groups, you can also use a semaphore object to get notified if multiple tasks are finished. You just have to wait for it...

```swift
let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue.global()
let n = 9
for i in 0..<n {
    queue.async {
        print("run \(i)")
        sleep(3)
        semaphore.signal()
    }
}
print("wait")
for i in 0..<n {
    semaphore.wait()
    print("completed \(i)")
}
print("done")
```

### Batch execution using a semaphore

You can create a thread pool like behavior to simulate limited resources using a dispatch semaphore. So for example if you want to download lots of images from a server you can run a batch of x every time. Quite handy. 🖐

```swift
print("start")
let sem = DispatchSemaphore(value: 5)
for i in 0..<10 {
    DispatchQueue.global().async {
        sem.wait()
        sleep(2)
        print(i)
        sem.signal()
    }
}
print("end")
```

## The DispatchSource object

> A dispatch source is a fundamental data type that coordinates the processing of specific low-level system events.

Signals, descriptors, processes, ports, timers and many more. Everything is handled through the [dispatch source](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html) object. I really don't want to get into the details, it's quite low-level stuff. You can monitor files, ports, signals with dispatch sources. Please just read the official Apple docs. 📄

I'd like to make only one example here using a [dispatch source timer](https://www.cocoawithlove.com/blog/2016/07/30/timer-problems.html).

```swift
let timer = DispatchSource.makeTimerSource()
timer.schedule(deadline: .now(), repeating: .seconds(1))
timer.setEventHandler {
    print("hello")
}
timer.resume()
```

## Thread-safety using the dispatch framework

[Thread safety](https://en.wikipedia.org/wiki/Thread_safety) is an inevitable topic if it comes to multi-threaded code. In the beginning I mentioned that there is a thread pool under the hood of GCD. Every thread has a [run loop](https://izeeshan.wordpress.com/2014/07/22/nsrunloop-understanding/) object associated with it, you can even [run them](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html) by hand. If you create a thread manually a [run loop](https://bou.io/RunRunLoopRun.html) will be added to that thread automatically.

```swift
let t = Thread {
    print(Thread.current.name ?? "")
     let timer = Timer(timeInterval: 1, repeats: true) { t in
         print("tick")
     }
     RunLoop.current.add(timer, forMode: .defaultRunLoopMode)

    RunLoop.current.run()
    RunLoop.current.run(mode: .commonModes, before: Date.distantPast)
}
t.name = "my-thread"
t.start()

//RunLoop.current.run()
```

You should not do this, demo purposes only, always use GCD queues!

### Queue != Thread

A GCD queue is not a thread, if you run multiple async operations on a concurrent queue your code can run on any available thread that fits the needs.

> Thread safety is all about avoiding messed up variable states

Imagine a mutable array in Swift. It can be modified from any thread. That's not good, because eventually the values inside of it are going to be messed up like hell if the array is not thread safe. For example multiple threads are trying to insert values to the array. What happens? If they run in parallel which element is going to be added first? Now this is why you need sometimes to create thread safe resources.

### Serial queues

You can use a serial queue to enforce mutual exclusivity. All the tasks on the queue will run serially (in a FIFO order), only one process runs at a time and tasks have to wait for each other. One big downside of the solution is speed. 🐌

```swift
let q = DispatchQueue(label: "com.theswiftdev.queues.serial")

q.async() {
  // writes
}

q.sync() {
  // reads
}
```

### Concurrent queues using barriers

You can send a barrier task to a queue if you provide an extra flag to the async method. If a task like this arrives to the queue it'll ensure that nothing else will be executed until the barrier task have finished. To sum this up, barrier tasks are sync (points) tasks for concurrent queues. Use async barriers for writes, sync blocks for reads. 😎

```swift
let q = DispatchQueue(label: "com.theswiftdev.queues.concurrent", attributes: .concurrent)

q.async(flags: .barrier) {
  // writes
}

q.sync() {
  // reads
}
```

This method will result in extremely fast reads in a thread safe environment. You can also use serial queues, semaphores, locks it all depends on your current situation, but it's good to know all the available options isn't it? 🤐

## A few anti-patterns

You have to be very careful with [deadlocks](https://en.wikipedia.org/wiki/Deadlock), [race conditions](https://en.wikipedia.org/wiki/Race_condition) and the [readers writers problem](https://en.wikipedia.org/wiki/Readers–writers_problem). Usually calling the sync method on a serial queue will cause you most of the troubles. Another issue is thread safety, but we've already covered that part. 😉

```swift
let queue = DispatchQueue(label: "com.theswiftdev.queues.serial")

queue.sync {
    // do some sync work
    queue.sync {
        // this won't be executed -> deadlock!
    }
}

//What you are trying to do here is to launch the main thread synchronously from a background thread before it exits. This is a logical error.
//https://stackoverflow.com/questions/49258413/dispatchqueue-crashing-with-main-sync-in-swift?rq=1
DispatchQueue.global(qos: .utility).sync {
    // do some background task
    DispatchQueue.main.sync {
        // app will crash
    }
}
```

The Dispatch framework (aka. GCD) is an amazing one, it has such a potential and it really takes some time to master it. The real question is that what path is going to take Apple in order to embrace concurrent programming into a whole new level? [Promises](https://theswiftdev.com/2019/05/28/promises-in-swift-for-beginners/) or async / await, maybe something [entirely new](https://gist.github.com/lattner/31ed37682ef1576b16bca1432ea9f782), let's hope that we'll see something in Swift 6.
