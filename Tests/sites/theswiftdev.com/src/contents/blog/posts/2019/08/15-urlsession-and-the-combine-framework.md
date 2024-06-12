---
slug: urlsession-and-the-combine-framework
title: URLSession and the Combine framework
description: Learn how to make HTTP requests and parse the response using the brand new Combine framework with foundation networking.
publication: 2019-08-15 16:20:00
tags: UIKit, iOS
---

This is going to be a really short, but hopefully very useful tutorial about how I started to utilize the [Combine framework](https://heckj.github.io/swiftui-notes/) to slowly replace my [Promise](https://github.com/corekit/promises) library. 🤫

## API & data structure

First of all we're going to need some kind of API to connect, as usual I'm going to use my favorite JSONPlaceholder service with the following data models:

```swift
enum HTTPError: LocalizedError {
    case statusCode
    case post
}

struct Post: Codable {

    let id: Int
    let title: String
    let body: String
    let userId: Int
}

struct Todo: Codable {

    let id: Int
    let title: String
    let completed: Bool
    let userId: Int
}
```

Nothing special so far, just some basic Codable elements, and a simple error, because hell yeah, we want to show some error if something fails. ❌

## The traditional way

Doing an HTTP request in Swift is pretty easy, you can use the built-in shared [URLSession](https://developer.apple.com/documentation/foundation/urlsession) with a simple data task, and voilá there's your response. Of course you might want to check for valid status code and if everything is fine, you can [parse your response JSON](https://theswiftdev.com/2018/01/29/how-to-parse-json-in-swift-using-codable-protocol/) by using the [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder) object from Foundation.

```swift
//somewhere in viewDidLoad
let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        fatalError("Error: \(error.localizedDescription)")
    }
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        fatalError("Error: invalid HTTP response code")
    }
    guard let data = data else {
        fatalError("Error: missing response data")
    }

    do {
        let decoder = JSONDecoder()
        let posts = try decoder.decode([Post].self, from: data)
        print(posts.map { $0.title })
    }
    catch {
        print("Error: \(error.localizedDescription)")
    }
}
task.resume()
```

Don't forget to resume your data task or the request won't fire at all. 🔥

## Data tasks and the Combine framework

Now as you can see the traditional "block-based" approach is nice, but can we do maybe something better here? You know, like describing the whole thing as a chain, like we used to do this with Promises? Beginning from iOS13 with the help of the amazing [Combine framework](https://developer.apple.com/documentation/combine) you actually can go far beyond! 😃

> My favorite part of Combine is memory management & cancellation.

## Data task with Combine

So the most common example is usually the following one:

```swift
private var cancellable: AnyCancellable?
//...
self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
.map { $0.data }
.decode(type: [Post].self, decoder: JSONDecoder())
.replaceError(with: [])
.eraseToAnyPublisher()
.sink(receiveValue: { posts in
    print(posts.count)
})
//...
self.cancellable?.cancel()
```

I love how the code "explains itself":

- First we make a cancellable storage for your Publisher
- Then we create a brand new data task publisher object
- Map the response, we only care about the data part (ignore errors)
- Decode the content of the data using a JSONDecoder
- If anything goes wrong, just go with an empty array
- Erase the underlying complexity to a simple AnyPublisher
- Use sink to display some info about the final value
- Optional: you can cancel your network request any time

## Error handling

Let's introduce some [error handling](https://medium.com/codequest/error-handling-in-combine-b6150a9fc2a7), because I don't like the idea of hiding errors. It's so much better to present an alert with the actual error message, isn't it? 🤔

```swift
enum HTTPError: LocalizedError {
    case statusCode
}

self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
.tryMap { output in
    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
        throw HTTPError.statusCode
    }
    return output.data
}
.decode(type: [Post].self, decoder: JSONDecoder())
.eraseToAnyPublisher()
.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        break
    case .failure(let error):
        fatalError(error.localizedDescription)
    }
}, receiveValue: { posts in
    print(posts.count)
})
```

In a nutshell, this time we check the response code and if something goes wrong we throw an error. Now because the publisher can result in an error state, sink has another variant, where you can check the outcome of the entire operation so you can do your own error thingy there, like displaying an alert. 🚨

## Assign result to property

Another common pattern is to store the response in an internal variable somewhere in the view controller. You can simply do this by using the assign function.

```swift
class ViewController: UIViewController {

    private var cancellable: AnyCancellable?

    private var posts: [Post] = [] {
        didSet {
            print("posts --> \(self.posts.count)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

        self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
        .map { $0.data }
        .decode(type: [Post].self, decoder: JSONDecoder())
        .replaceError(with: [])
        .eraseToAnyPublisher()
        .assign(to: \.posts, on: self)
    }
}
```

Very easy, you can also use the didSet property observer to get notified about changes.

## Group multiple requests

Sending multiple requests was a painful process in the past. Now we have Compose and this task is just ridiculously easy with Publishers.Zip. You can literally combine multiple requests togeter and wait until both of them are finished. 🤐

```swift
let url1 = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let url2 = URL(string: "https://jsonplaceholder.typicode.com/todos")!

let publisher1 = URLSession.shared.dataTaskPublisher(for: url1)
.map { $0.data }
.decode(type: [Post].self, decoder: JSONDecoder())

let publisher2 = URLSession.shared.dataTaskPublisher(for: url2)
.map { $0.data }
.decode(type: [Todo].self, decoder: JSONDecoder())

self.cancellable = Publishers.Zip(publisher1, publisher2)
.eraseToAnyPublisher()
.catch { _ in
    Just(([], []))
}
.sink(receiveValue: { posts, todos in
    print(posts.count)
    print(todos.count)
})
```
Same pattern as before, we're just zipping together two publishers.

## Request dependency

Sometimes you have to load a resource from a given URL, and then use another one to extend the object with something else. I'm talking about request dependency, which was quite problematic without Combine, but now you can chain two HTTP calls together with just a few lines of Swift code. Let me show you:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let url1 = URL(string: "https://jsonplaceholder.typicode.com/posts")!

    self.cancellable = URLSession.shared.dataTaskPublisher(for: url1)
    .map { $0.data }
    .decode(type: [Post].self, decoder: JSONDecoder())
    .tryMap { posts in
        guard let id = posts.first?.id else {
            throw HTTPError.post
        }
        return id
    }
    .flatMap { id in
        return self.details(for: id)
    }
    .sink(receiveCompletion: { completion in

    }) { post in
        print(post.title)
    }
}

func details(for id: Int) -> AnyPublisher<Post, Error> {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)")!
    return URLSession.shared.dataTaskPublisher(for: url)
        .mapError { $0 as Error }
        .map { $0.data }
        .decode(type: Post.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}
```

The trick here is that you can flatMap a publisher into another.

## Conclusion

Combine is an amazing framework, it can do a lot, but it definitely has some learning curve. Sadly you can only use it if you are targeting iOS13 or above (this means that you have one whole year to learn every single bit of the framework) so think twice before adopting this new technology.

You should also note that currently there is no [upload and download task publisher](https://theswiftdev.com/2020/01/28/how-to-download-files-with-urlsession-using-combine-publishers-and-subscribers/), but you can make your very own solution until Apple officially releases something. Fingers crossed. 🤞

I really love how Apple implemented some concepts of reactive programming, I can't wait for Combine to arrive as an open source package with Linux support as well. ❤️
