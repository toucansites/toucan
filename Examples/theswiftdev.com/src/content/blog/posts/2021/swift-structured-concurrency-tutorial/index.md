---
type: post
title: Swift structured concurrency tutorial
description: Learn how to work with the Task object to perform asynchronous operations in a safe way using the new concurrency APIs in Swift.
publication: 2021-06-30 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Introducing structured concurrency in Swift

In my previous tutorial we've talked about [the new async/await feature in Swift](https://theswiftdev.com/introduction-to-asyncawait-in-swift/), after that I've created a blog post about [thread safe concurrency using actors](https://theswiftdev.com/swift-actors-tutorial-a-beginners-guide-to-thread-safe-concurrency/), now it is time to get started with the other major concurrency feature in Swift, called structured concurrency. 🔀

What is structured concurrency? Well, long story short, it's a new task-based mechanism that allows developers to perform individual task items in concurrently. Normally when you await for some piece of code you create a potential suspension point. If we take our number calculation example from the async/await article, we could write something like this:

```swift
let x = await calculateFirstNumber()
let y = await calculateSecondNumber()
let z = await calculateThirdNumber()
print(x + y + z)
```

I've already mentioned that each line is being executed after the previous line finishes its job. We create three potential suspension points and we await until the CPU has enough capacity to execute & finish each task. This all happens in a serial order, but sometimes this is not the behavior that you want.

If a calculation depends on the result of the previous one, this example is perfect, since you can use x to calculate y, or x & y to calculate z. What if we'd like to run these tasks in parallel and we don't care the individual results, but we need all of them (x,y,z) as fast as we can? 🤔
```swift
async let x = calculateFirstNumber()
async let y = calculateSecondNumber()
async let z = calculateThirdNumber()

let res = await x + y + z
print(res)
```

I already showed you how to do this using the [async let bindings proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0317-async-let.md), which is a kind of a high level abstraction layer on top of the structured concurrency feature. It makes ridiculously easy to run async tasks in parallel. So the big difference here is that we can run all of the calculations at once and we can await for the result "group" that contains both x, y and z.

Again, in the first example the execution order is the following:

- await for x, when it is ready we move forward
- await for y, when it is ready we move forward
- await for z, when it is ready we move forward
- sum the already calculated x, y, z numbers and print the result

We could describe the second example like this

- Create an async task item for calculating x
- Create an async task item for calculating y
- Create an async task item for calculating z
- Group x, y, z task items together, and await sum the results when they are ready
- print the final result

As you can see this time we don't have to wait until a previous task item is ready, but we can execute all of them in parallel, instead of the regular sequential order. We still have 3 potential suspension points, but the execution order is what really matters here. By executing tasks parallel the second version of our code can be way faster, since the CPU can run all the tasks at once (if it has free worker thread / executor). 🧵

At a very basic level, this is what structured concurrency is all about. Of course the async let bindings are hiding most of the underlying implementation details in this case, so let's move a bit down to the rabbit hole and refactor our code using tasks and task groups.

```swift
await withTaskGroup(of: Int.self) { group in
    group.async {
        await calculateFirstNumber()
    }
    group.async {
        await calculateSecondNumber()
    }
    group.async {
        await calculateThirdNumber()
    }

    var sum: Int = 0
    for await res in group {
        sum += res
    }
    print(sum)
}
```

According to the current version of the proposal, we can use [tasks](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md#tasks) as basic units to perform some sort of work. A task can be in one of three states: suspended, running or completed. Task also support cancellation and they can have an associated priority.

Tasks can form a hierarchy by defining [child tasks](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md#child-tasks). Currently we can create task groups and define child items through the group.async function for parallel execution, this child task creation process can be simplified via async let bindings. Children automatically inherit their parent tasks's attributes, such as priority, task-local storage, deadlines and they will be automatically cancelled if the parent is cancelled. Deadline support is coming in a later Swift release, so I won't talk more about them.

A task execution period is called a job, each job is running on an executor. An executor is a service which can accept jobs and arranges them (by priority) for execution on available thread. Executors are currently provided by the system, but later on actors will be able to define custom ones.

That's enough theory, as you can see it is possible to define a task group using the withTaskGroup or the withThrowingTaskGroup methods. The only difference is that the later one is a throwing variant, so you can try to await async functions to complete. ✅

A task group needs a ChildTaskResult type as a first parameter, which has to be a [Sendable](https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md) type. In our case an Int type is a perfect candidate, since we're going to collect the results using the group. You can add async task items to the group that returns with the proper result type.

We can gather individual results from the group by awaiting for the the next element (await group.next()), but since the group conforms to the [AsyncSequence](https://github.com/apple/swift-evolution/blob/main/proposals/0298-asyncsequence.md) protocol we can iterate through the results by awaiting for them using a standard for loop. 🔁

That's how structured concurrency works in a nutshell. The best thing about this whole model is that by using task hierarchies no child task will be ever able to leak and keep running in the background by accident. This a core reason for these APIs that they must always await before the scope ends. (thanks for the suggestions [@ktosopl](https://x.com/ktosopl)). ❤️

Let me show you a few more examples...

## Waiting for dependencies

If you have an async dependency for your task items, you can either calculate the result upfront, before you define your task group or inside a group operation you can call multiple things too.

```swift
import Foundation

func calculateFirstNumber() async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            c.resume(with: .success(42))
        }
    }
}

func calculateSecondNumber() async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            c.resume(with: .success(6))
        }
    }
}

func calculateThirdNumber(_ input: Int) async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            c.resume(with: .success(9 + input))
        }
    }
}

func calculateFourthNumber(_ input: Int) async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            c.resume(with: .success(69 + input))
        }
    }
}

@main
struct MyProgram {
    
    static func main() async {

        let x = await calculateFirstNumber()
        await withTaskGroup(of: Int.self) { group in
            group.async {
                await calculateThirdNumber(x)
            }
            group.async {
                let y = await calculateSecondNumber()
                return await calculateFourthNumber(y)
            }
            

            var result: Int = 0
            for await res in group {
                result += res
            }
            print(result)
        }
    }
}
```

It is worth to mention that if you want to support a proper cancellation logic you should be careful with suspension points. This time I won't get into the cancellation details, but I'll write a dedicated article about the topic at some point in time (I'm still learning this too... 😅).

## Tasks with different result types

If your task items have different return types, you can easily create a new enum with associated values and use it as a common type when defining your task group. You can use the enum and box the underlying values when you return with the async task item functions.

```swift
import Foundation

func calculateNumber() async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            c.resume(with: .success(42))
        }
    }
}

func calculateString() async -> String {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            c.resume(with: .success("The meaning of life is: "))
        }
    }
}

@main
struct MyProgram {
    
    static func main() async {
        
        enum TaskSteps {
            case first(Int)
            case second(String)
        }

        await withTaskGroup(of: TaskSteps.self) { group in
            group.async {
                .first(await calculateNumber())
            }
            group.async {
                .second(await calculateString())
            }

            var result: String = ""
            for await res in group {
                switch res {
                case .first(let value):
                    result = result + String(value)
                case .second(let value):
                    result = value + result
                }
            }
            print(result)
        }
    }
}
```

After the tasks are completed you can switch the sequence elements and perform the final operation on the result based on the wrapped enum value. This little trick will allow you to run all kind of tasks with different return types to run parallel using the new Tasks APIs. 👍

## Unstructured and detached tasks

As you might have noticed this before, it is not possible to call an async API from a sync function. This is where unstructured tasks can help. The most important thing to note here is that the lifetime of an unstructured task is not bound to the creating task. They can outlive the parent, and they inherit priorities, task-local values, deadlines from the parent. Unstructured tasks are being represented by a task handle that you can use to cancel the task.

```swift
import Foundation

func calculateFirstNumber() async -> Int {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            c.resume(with: .success(42))
        }
    }
}

@main
struct MyProgram {
    
    static func main() {
        Task(priority: .background) {
            let handle = Task { () -> Int in
                print(Task.currentPriority == .background)
                return await calculateFirstNumber()
            }
            
            let x = await handle.get()
            print("The meaning of life is:", x)
            exit(EXIT_SUCCESS)
        }
        dispatchMain()
    }
}
```

You can get the current priority of the task using the static currentPriority property and check if it matches the parent task priority (of course it should match it). ☺️

So what's the difference between unstructured tasks and detached tasks? Well, the answer is quite simple: unstructured task will inherit the parent context, on the other hand detached tasks won't inherit anything from their parent context (priorities, task-locals, deadlines).

```swift
@main
struct MyProgram {
    
    static func main() {
        Task(priority: .background) {
            Task.detached {
                /// false -> Task.currentPriority is unspecified
                print(Task.currentPriority == .background)
                let x = await calculateFirstNumber()
                print("The meaning of life is:", x)
                exit(EXIT_SUCCESS)
            }
        }
        dispatchMain()
    }
}
```

You can create a detached task by using the detached method, as you can see the priority of the current task inside the detached task is unspecified, which is definitely not equal with the parent priority. By the way it is also possible to get the current task by using the withUnsafeCurrentTask function. You can use this method too to get the priority or check if the task is cancelled. 🙅‍♂️

```swift
@main
struct MyProgram {
    
    static func main() {
        Task(priority: .background) {
            Task.detached {
                withUnsafeCurrentTask { task in
                    print(task?.isCancelled ?? false)
                    print(task?.priority == .unspecified)
                }
                let x = await calculateFirstNumber()
                print("The meaning of life is:", x)
                exit(EXIT_SUCCESS)
            }
        }
        dispatchMain()
    }
}
```

There is one more big difference between detached and unstructured tasks. If you create an unstructured task from an actor, the task will execute directly on that actor and NOT in parallel, but a detached task will be immediately parallel. This means that an unstructured task can alter internal actor state, but a detached task can not modify the internals of an actor. ⚠️

You can also take advantage of unstructured tasks in task groups to create more complex task structures if the structured hierarchy won't fit your needs.

## Task local values

There is one more thing I'd like to show you, we've mentioned [task local values](https://github.com/apple/swift-evolution/blob/main/proposals/0311-task-locals.md) quite a lot of times, so here's a quick section about them. This feature is basically an improved version of the thread-local storage designed to play nice with the structured concurrency feature in Swift.

Sometimes you'd like to carry on custom contextual data with your tasks and this is where task local values come in. For example you could add debug information to your task objects and use it to find problems more easily. Donny Wals has an in-depth [article about task local values](https://www.donnywals.com/what-are-swift-concurrencys-task-local-values/), if you are interested more about this feature, you should definitely read his post. 💪

So in practice, you can annotate a static property with the @TaskLocal property wrapper, and then you can read this metadata within an another task. From now on you can only mutate this property by using the withValue function on the wrapper itself.

```swift
import Foundation

enum TaskStorage {
    @TaskLocal static var name: String?
}

@main
struct MyProgram {
    
    static func main() async {
        await TaskStorage.$name.withValue("my-task") {
            let t1 = Task {
                print("unstructured:", TaskStorage.name ?? "n/a")
            }
            
            let t2 = Task.detached {
                print("detached:", TaskStorage.name ?? "n/a")
            }
            /// runs in parallel
            _ = await [t1.value, t2.value]
        }
    }
}
```

Tasks will inherit these local values (except detached) and you can alter the value of task local values inside a given task as well, but these changes will be only visible for the current task & child tasks. To sum this up, task local values are always tied to a given task scope.

As you can see structured concurrency in Swift is quite a lot to digest, but once you understand the basics everything comes nicely together with the new async/await features and Tasks you can easily construct jobs for serial or parallel execution. Anyway, I hope you enjoyed this article. 🙏
