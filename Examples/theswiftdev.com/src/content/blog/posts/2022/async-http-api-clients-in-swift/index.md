---
type: post
slug: async-http-api-clients-in-swift
title: Async HTTP API clients in Swift
description: Learn how to communicate with API endpoints using the brand new SwiftHttp library, including async / await support.
publication: 2022-03-18 16:20:00
tags: Swift, networking, HTTP
authors:
  - tibor-bodecs
---

## Introducing SwiftHttp

An awesome [Swift HTTP library](https://github.com/binarybirds/swift-http/) to rapidly create communication layers with API endpoints. The library tries to separate the client request logic from the request building and response handling. That's the main reason why it has a HttpClient protocol which can be used to perform data, download and upload tasks. You can implement your own HttpClient, but SwiftHttp comes with a built-in UrlSessionHttpClient based on [Foundation networking](https://developer.apple.com/documentation/foundation/urlsession).

So the client is responsible for executing the requests, but we still have to describe the request itself somehow. This is where the HttpRawRequest object comes into play. You can easily create a base HttpUrl and perform a request using the HttpRawRequest object. When working with a raw request you can specify additional header fields and a raw body data object too. 💪

```swift
let url = HttpUrl(scheme: "https",
                  host: "jsonplaceholder.typicode.com",
                  port: 80,
                  path: ["todos"],
                  resource: nil,
                  query: [:],
                  fragment: nil)

let req = HttpRawRequest(url: url, method: .get, headers: [:], body: nil)

/// execute the request using the client
let client = UrlSessionHttpClient(session: .shared, log: true)
let response = try await client.dataTask(req)

/// use the response data
let todos = try JSONDecoder().decode([Todo].self, from: response.data)
// response.statusCode == .ok
// response.headers -> response headers as a dictionary
```

The HTTP client can perform network calls using [the new async / await Swift concurrency API](https://theswiftdev.com/introduction-to-asyncawait-in-swift/). It is possible to cancel a network request by wrapping it into a [structured concurrency Task](https://theswiftdev.com/swift-structured-concurrency-tutorial/).

```swift
let task = Task {
    let api = TodoApi()
    _ = try await api.list()
}

DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
    task.cancel()
}

do {
    let _ = try await task.value
}
catch {
    if (error as? URLError)?.code == .cancelled {
        print("cancelled")
    }
}
```

This is a neat tick, you can also check the reason inside the catch block, if it is an URLError with a .cancelled code then the request was cancelled, otherwise it must be some sort of network error.

So this is how you can use the client to perform or cancel a network task, but usually you don't want to work with raw data, but encodable and decodable objects. When you work with such objects, you might want to validate the response headers and send additional headers to inform the server about the type of the body data. Just think about the [Content-Type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) / [Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) header fields. 🤔

So we might want to send additional headers alongside the request, plus it'd be nice to validate the status code and response headers before we try to parse the data. This seems like a flow of common operations, first we encode the data, set the additional header fields, and when the response arrives we validate the status code and the header fields, finally we try to decode the data object. This is a typical use case and SwiftHttp calls this workflow as a pipeline.

There are 4 types of built-in HTTP pipelines:

- Raw - Send a raw data request, return a raw data response
- Encodable - Send an encodable object, return a raw data response
- Decodable - Send a raw data request, return a decodable object
- Codable - Send an encodable object, return a decodable object

We can use a HttpRawPipeline and execute our request using a client as an executor.

```swift
let baseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")
let client = UrlSessionHttpClient(session: .shared, log: true)

let pipeline = HttpRawPipeline(url: baseUrl.path("todos"), method: .get)

let response = try await pipeline.execute(client.dataTask)
let todos = try JSONDecoder().decode([Todo].self, from: response.data)
print(response.statusCode)
print(todos.count)
```

In this case we were using the dataTask function, but if you expect the response to be a huge file, you might want to consider using a downloadTask, or if you're uploading a large amount of data when sending the request, you should choose the uploadTask function. 💡

So in this case we had to manually decode the Todo object from the raw HTTP response data, but we can use the decodable pipeline to make things even more simple.

```swift
let baseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")
let client = UrlSessionHttpClient(session: .shared, log: true)


let pipeline = HttpDecodablePipeline<[Todo]>(url: baseUrl.path("todos"),
                                             method: .get,
                                             decoder: .json(JSONDecoder(), validators: [
                                                HttpStatusCodeValidator(.ok),
                                                HttpHeaderValidator(.key(.contentType)) {
                                                    $0.contains("application/json")
                                                },
                                             ]))

let todos = try await pipeline.execute(client.dataTask)
print(todos.count)
```

As you can see, in this case the instead of returning the response, the pipeline can perform additional validation and the decoding using the provided decoder and validators. You can create your own validators, there is a HttpResponseValidator protocol for this purpose.

The encodable pipeline works like the same, you can specify the encoder, you can provide the encodable object and you'll get back a HttpResponse instance.

```swift
let client = UrlSessionHttpClient(session: .shared, log: true)
        
let todo = Todo(id: 1, title: "lorem ipsum", completed: false)

let pipeline = HttpEncodablePipeline(url: baseUrl.path("todos"),
                                     method: .post,
                                     body: todo,
                                     encoder: .json())

let response = try await pipeline.execute(client.dataTask)

print(response.statusCode == .created)
```

The codable pipeline is a combination of the encodable and decodable pipeline. 🙃

```swift
let baseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")
let client = UrlSessionHttpClient(session: .shared, log: true)

let todo = Todo(id: 1, title: "lorem ipsum", completed: false)

let pipeline = HttpCodablePipeline<Todo, Todo>(url: baseUrl.path("todos", String(1)),
                                               method: .put,
                                               body: todo,
                                               encoder: .json(),
                                               decoder: .json())

let todo = try await pipeline.execute(client.dataTask)
print(todo.title)
```

As you can see this is quite a common pattern, and when we're communicating with a REST API, we're going to perform more or less the exact same network calls for every single endpoint. SwiftHttp has a pipeline collection protocol that you can use to perform requests without the need of explicitly setting up these pipelines. Here's an example:

```swift
import SwiftHttp

struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

struct TodoApi: HttpCodablePipelineCollection {

    let client: HttpClient = UrlSessionHttpClient(log: true)
    let apiBaseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")

    
    func list() async throws -> [Todo] {
        try await decodableRequest(executor: client.dataTask,
                                   url: apiBaseUrl.path("todos"),
                                   method: .get)
    }    
}

let todos = try await api.list()
```

When using a HttpCodablePipelineCollection you can perform an encodable, decodable or codable request using an executor object. This will reduce the boilerplate code needed to perform a request and everything is going to be type safe thanks to the generic protocol oriented networking layer. You can setup as many pipeline collections as you need, it is possible to use a shared client or you can create a dedicated client for each.

By the way, if something goes wrong with the request, or one of the validators fail, you can always check for the errors using a do-try-catch block. 😅

```swift
do {
    _ = try await api.list()
}
catch HttpError.invalidStatusCode(let res) {
    // decode custom error message, if the status code was invalid
    let decoder = HttpResponseDecoder<CustomError>(decoder: JSONDecoder())
    do {
        let error = try decoder.decode(res.data)
        print(res.statusCode, error)
    }
    catch {
        print(error.localizedDescription)
    }
}
catch {
    print(error.localizedDescription)
}
```

That's how SwiftHttp works in a nutshell, of course you can setup custom encoders and decoders, but that's another topic. If you are interested in the project, feel free to give it a star on [GitHub](https://github.com/BinaryBirds/swift-http). We're going to use it in the future quite a lot both on the client and server side. ⭐️⭐️⭐️
