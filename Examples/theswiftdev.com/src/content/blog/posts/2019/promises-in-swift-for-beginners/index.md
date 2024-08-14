---
type: post
title: Promises in Swift for beginners
description: Everything you ever wanted to know about futures and promises. The beginner's guide about asynchronous programming in Swift.
publication: 2019-05-28 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Sync vs async execution

> Writing asynchronous code is one of the hardest part of building an app.

What exactly is the difference between a synchronous and an asynchronous execution? Well, I already explained this in my [Dispatch framework](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/) tutorial, but here is a quick recap. A synchronous function usually blocks the current thread and returns some value later on. An asynchronous function will instantly return and passes the result value into a completion handler. You can use the GCD framework to perform tasks sync on async on a given queue. Let me show you a quick example:

```swift
func aBlockingFunction() -> String {
    sleep(.random(in: 1...3))
    return "Hello world!"
}

func syncMethod() -> String {
    return aBlockingFunction()
}

func asyncMethod(completion block: @escaping ((String) -> Void)) {
    DispatchQueue.global(qos: .background).async {
        block(aBlockingFunction())
    }
}

print(syncMethod())
print("sync method returned")
asyncMethod { value in
    print(value)
}
print("async method returned")

// "Hello world!"
// "sync method returned"
// "async method returned"
// "Hello world!"
```

As you can see the async method runs entirely on a background queue, the function won't block the current thread. This is why the async method can return instantly, so you'll always see the return output before the last hello output. The async method's completion block is stored for later execution, that's the reason why is it possible to call-back and return the string value way after the original function have returned.

What happens if you don't use a different queue? The completion block will be executed on the current queue, so your function will block it. It's going to be somewhat async-like, but in reality you're just moving the return value into a completion block.

```swift
func syncMethod() -> String {
    return "Hello world!"
}

func fakeAsyncMethod(completion block: ((String) -> Void)) {
    block("Hello world!")
}

print(syncMethod())
print("sync method returned")
fakeAsyncMethod { value in
    print(value)
}
print("fake async method returned")
```

I don't really want to focus on completion blocks in this article, that could be a standalone post, but if you are still having trouble with the concurrency model or you don't understand how tasks and threading works, you should read do a little research first.

## Callback hell and the pyramid of doom

What's the [problem](https://pouchdb.com/2015/05/18/we-have-a-problem-with-promises.html) with async code? Or what's the result of writing asynchronous code? The short answer is that you have to use completion blocks (callbacks) in order to handle future results.

The long answer is that managing callbacks sucks. You have to be careful, because in a block you can easily create a retain-cycle, so you have to pass around your variables as weak or unowned references. Also if you have to use multiple async methods, that'll be a pain in the donkey. Sample time! 🐴

```swift
struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!

URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        fatalError("Network error: " + error.localizedDescription)
    }
    guard let response = response as? HTTPURLResponse else {
        fatalError("Not a HTTP response")
    }
    guard response.statusCode <= 200, response.statusCode > 300 else {
        fatalError("Invalid HTTP status code")
    }
    guard let data = data else {
        fatalError("No HTTP data")
    }

    do {
        let todos = try JSONDecoder().decode([Todo].self, from: data)
        print(todos)
    }
    catch {
        fatalError("JSON decoder error: " + error.localizedDescription)
    }
}.resume()
```

The snippet above is a simple async HTTP data request. As you can see there are lots of optional values involved, plus you have to do some JSON decoding if you want to use your own types. This is just one request, but what if you'd need to get some detailed info from the first element? Let's write a helper! #no 🤫

```swift
func request(_ url: URL, completion: @escaping ((Data) -> Void)) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            fatalError("Network error: " + error.localizedDescription)
        }
        guard let response = response as? HTTPURLResponse else {
            fatalError("Not a HTTP response")
        }
        guard response.statusCode <= 200, response.statusCode > 300 else {
            fatalError("Invalid HTTP status code")
        }
        guard let data = data else {
            fatalError("No HTTP data")
        }
        completion(data)
    }.resume()
}

let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
request(url) { data in
    do {
        let todos = try JSONDecoder().decode([Todo].self, from: data)
        guard let first = todos.first else {
            return
        }
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(first.id)")!
        request(url) { data in
            do {
                let todo = try JSONDecoder().decode(Todo.self, from: data)
                print(todo)
            }
            catch {
                fatalError("JSON decoder error: " + error.localizedDescription)
            }
        }
    }
    catch {
        fatalError("JSON decoder error: " + error.localizedDescription)
    }
}
```

See? My problem is that we're slowly moving down the rabbit hole. Now what if we have a 3rd request? Hell no! You have to nest everything one level deeper again, plus you have to pass around the necessary variables eg. a weak or unowned view controller reference because at some point in time you have to update the entire UI based on the outcome. There must be a better way to fix this. 🤔

## Results vs futures vs promises?

The [result type](https://theswiftdev.com/2019/01/28/how-to-use-the-result-type-to-handle-errors-in-swift/) was introduced in Swift 5 and it's extremely good for eliminating the optional factor from the equation. This means you don't have to deal with an optional data, and an optional error type, but your result is either one of them.

Futures are basically representing a value in the future. The underlying value can be for example a result and it should have one of the following states:

- pending - no value yet, waiting for it...
- fulfilled - success, now the result has a value
- rejected - failed with an error

By definition a futures shouldn't be writeable by the end-user. This means that developers should not be able to create, fulfill or reject one. But if that's the case and we follow the rules, how do we make futures?

We promise them. You have to create a promise, which is basically a wrapper around a future that can be written (fulfilled, rejected) or transformed as you want. You don't write futures, you make promises. However some frameworks allows you to get back the future value of a promise, but you shouldn't be able to write that future at all.

Enough theory, are you ready to fall in love with [promises](https://learnappmaking.com/promises-swift-how-to/)? ❤️

## Promises 101 - a beginner's guide

Let's refactor the previous example by using my promise framework!

```swift
extension URLSession {

    enum HTTPError: LocalizedError {
        case invalidResponse
        case invalidStatusCode
        case noData
    }

    func dataTask(url: URL) -> Promise<Data> {
        return Promise<Data> { [unowned self] fulfill, reject in
            self.dataTask(with: url) { data, response, error in
                if let error = error {
                    reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    reject(HTTPError.invalidResponse)
                    return
                }
                guard response.statusCode <= 200, response.statusCode > 300 else {
                    reject(HTTPError.invalidStatusCode)
                    return
                }
                guard let data = data else {
                    reject(HTTPError.noData)
                    return
                }
                fulfill(data)
            }.resume()
        }
    }
}

enum TodoError: LocalizedError {
    case missing
}

let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
URLSession.shared.dataTask(url: url)
.thenMap { data in
    return try JSONDecoder().decode([Todo].self, from: data)
}
.thenMap { todos -> Todo in
    guard let first = todos.first else {
        throw TodoError.missing
    }
    return first
}
.then { first in
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(first.id)")!
    return URLSession.shared.dataTask(url: url)
}
.thenMap { data in
    try JSONDecoder().decode(Todo.self, from: data)
}
.onSuccess { todo in
    print(todo)
}
.onFailure(queue: .main) { error in
    print(error.localizedDescription)
}
```

What just happened here? Well, I made sort of a promisified version of the data task method implemented on the URLSession object as an extension. Of course you can return the HTTP result or just the status code plus the data if you need further info from the network layer. You can use a new response data model or even a tuple. 🤷‍♂️

Anyway, the more interesting part is the bottom half of the source. As you can see I'm calling the brand new dataTask method which returns a `Promise<Data>` object. As I mentioned this before a promise can be transformed. Or should I say: chained?

Chaining promises is the biggest advantage over callbacks. The source code is not looking like a pyramid anymore with crazy indentations and do-try-catch blocks, but more like a chain of actions. In every single step you can transform your previous result value into something else. If you are familiar with some [functional paradigms](https://theswiftdev.com/2019/02/05/beginners-guide-to-functional-swift/), it's going to be really easy to understand the following:

- thenMap is a simple map on a Promise
- then is basically flatMap on a Promise
- onSuccess only gets called if everything was fine in the chain
- onFailure only gets called if some error happened in the chain
- always runs always regardless of the outcome

If you want to get the main queue, you can simply pass it through a queue parameter, like I did it with the onFailure method, but it works for every single element in the chain. These functions above are just the tip of the iceberg. You can also tap into a chain, validate the result, put a timeout on it or recover from a failed promise.

There is also a Promises namespace for other useful methods, like zip, which is capable of zipping together 2, 3 or 4 different kind of promises. Just like the Promises.all method the zip function waits until every promise is being completed, then it gives you the result of all the promises in a single block.

```swift
//executing same promises from the same kind, eg. [Promise<Data>]
Promises.all(promises)
.thenMap { arrayOfResults in
    // e.g. [Data]
}
//zipping together different kind of promises, eg. Proimse<[Todos]>, Promise<Todo>;
Promises.zip(promise1, promise2)
.thenMap { result1, result2 in
    //e.g [Todos], Todo
}
```

It's also worth to mention that there is a first, delay, timeout, race, wait and a retry method under the Promises namespace. Feel free to play around with these as well, sometimes they're extremly useful and powerful too. 💪

## There are only two problems with promises

The first issue is cancellation. You can't simply cancel a running promise. It's doable, but it requires some advanced or some say "hacky" techniques.

The second one is async / await. If you want to know more about it, you should read the [concurrency manifesto](https://gist.github.com/lattner/31ed37682ef1576b16bca1432ea9f782) by Chis Lattner, but since this is a beginner's guide, let's just say that these two keywords can add some syntactic sugar to your code. You won't need the extra (then, thenMap, onSuccess, onFailure) lines anymore, this way you can focus on your code. I really hope that we'll get something like this in Swift 6, so I can throw away my Promise library for good. Oh, by the way, libraries...

## Promise libraries worth to check

My promise implementation is far from perfect, but it's a quite simple one (~450 lines of code) and it serves me really well. This [blog post](http://khanlou.com/2016/08/promises-in-swift/) by [khanlou](https://x.com/khanlou) helped me a lot to understand promises better, you should read it too! 👍

There are lots of promise libraries on github, but if I had to choose from them (instead my own implementation), I'd definitely go with one of the following ones:

- [PromiseKit](https://github.com/mxcl/PromiseKit) - The most popular one
- [Promises](https://github.com/google/promises) by Google - feature rich, quite popular as well
- [Promise](https://github.com/khanlou/promise) by Khanlou - small, but based on on the JavaScript [Promises/A+](https://promisesaplus.com/) spec
- [SwiftNIO](https://github.com/apple/swift-nio) - not an actual promise library, but it has a beautifully written event loop based promise implementation under the hood

Pro tip: don't try to make your own Promise framework, because multi-threading is extremely hard, and you don't want to mess around with threads and locks.

Promises are really addictive. Once you start using them, you can't simply go back and write async code with callbacks anymore. Make a promise today! 😅
