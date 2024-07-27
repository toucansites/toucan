---
type: post
slug: hummingbird-routing-and-requests
title: Hummingbird routing and requests
description: Beginner's guide to learn all about routing and request handling using the Hummingbird server-side Swift framework.
publication: 2023-03-17 16:20:00
tags: Swift, Hummingbird
authors:
  - tibor-bodecs
---

Routing on the server side means the server is going to send a response based on the URL path that the client called when firing up the HTTP request. Of course the server can check additional parameters and headers to build the final response, but when we talk about routing in general, we usually refer to the path components. [Hummingbird](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/router/) uses a [trie-based](https://en.wikipedia.org/wiki/Trie) router, which is a fast and efficient way of looking up routes. It's quite simple to respond to HTTP request using the built-in router, you can simply add your basic route handlers like this:

```swift
/// on path X, when method is Y, call the handler... 
router.on("foo", method: .HEAD) { _ -> HTTPResponseStatus in .ok }
router.on("foo", method: .GET) { _ -> HTTPResponseStatus in .ok }
router.on("foo", method: .POST) { _ -> HTTPResponseStatus in .ok }
router.on("foo", method: .PUT) { _ -> HTTPResponseStatus in .ok }
router.on("foo", method: .PATCH) { _ -> HTTPResponseStatus in .ok }
router.on("foo", method: .DELETE) { _ -> HTTPResponseStatus in .ok }

/// short version (for some HTTP methods)
router.head("foo") { _ -> HTTPResponseStatus in .ok }
router.get("foo") { _ -> HTTPResponseStatus in .ok }
router.put("foo") { _ -> HTTPResponseStatus in .ok }
router.post("foo") { _ -> HTTPResponseStatus in .ok }
router.patch("foo") { _ -> HTTPResponseStatus in .ok }
router.delete("foo") { _ -> HTTPResponseStatus in .ok }
```

In Hummingbird it is also possible to register use a function instead of a block. Handler functions can be async and throwing too, so you can mark the blocks with these keywords or use asynchronous Swift functions when registering route handlers. If you don't provide the first parameter, the path as a string, the route handler is going to be attached to the base group. 👍

You can also prefix a path component with a colon, this will turn that component into a dynamic route parameter. The parameter is going to be named after the path component, by simply dropping the colon prefix. You can access parameters inside your route handler through the req.parameters property. It is also possible to register multiple components using a / character.

```swift
public extension HBApplication {
    
    func configure() throws {

        router.get { _ async throws in "Hello, world!" }

        router.get("hello/:name") { req throws in
            guard let name = req.parameters.get("name") else {
                throw HBHTTPError(
                    .badRequest,
                    message: "Invalid name parameter."
                )
            }
            return "Hello, \(name)!"
        }

        let group = router.group("todos")
        group.get(use: list)
        group.post(use: create)
        
        let idGroup = group.group(":todoId")
        idGroup.head(use: check)
        idGroup.get(use: fetch)
        idGroup.put(use: update)
        idGroup.patch(use: patch)
        idGroup.delete(use: delete)

        /// short version
        router.group("todos")
            .get(use: list)
            .post(use: create)
            .group(":todoId")
                .head(use: check)
                .get(use: fetch)
                .put(use: update)
                .patch(use: patch)
                .delete(use: delete)

    }

    func list(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func check(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func fetch(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func create(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func update(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func patch(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
    func delete(_ req: HBRequest) async throws -> HTTPResponseStatus { .ok }
}
```
It is possible to use a wildcard character (*) when detecting path components and the recursive version (**) to catch everything. Also you can use the ${name} syntax to catch a named request parameter even with a prefix or suffix, but you can't insert this in the middle of a path component. (e.g. "prefix-${name}.jpg" won't work, but "${name}.jpg" is just fine) 💡

```swift
import Hummingbird
import HummingbirdFoundation

extension HBApplication {

    func configure(_ args: AppArguments) throws {

        router.get("foo-${name}", use: catchPrefix)
        router.get("${name}.jpg", use: catchSuffix)
        
        router.get("*", use: catchOne)
        router.get("*/*", use: catchTwo)

        router.get("**", use: catchAll)
        
    }
    
    // http://localhost:8080/bar
    func catchOne(_ req: HBRequest) async throws -> String {
        "one"
    }

    // http://localhost:8080/bar/baz/
    func catchTwo(_ req: HBRequest) async throws -> String {
        "two"
    }
    
    // http://localhost:8080/bar/baz/foo/bar/baz
    func catchAll(_ req: HBRequest) async throws -> String {
        "all: " + req.parameters.getCatchAll().joined(separator: ", ")
    }
    
    // http://localhost:8080/foo-bar
    func catchPrefix(_ req: HBRequest) async throws -> String {
        "prefix: " + (req.parameters.get("name") ?? "n/a")
    }
    
    // http://localhost:8080/bar.jpg
    func catchSuffix(_ req: HBRequest) async throws -> String {
        "suffix: " + (req.parameters.get("name") ?? "n/a")
    }
}
```

It is also possible to [edit the auto-generated response](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/router/#Editing-response-in-handler) if you specify the .editResponse option.

```swift
router.get("foo", options: .editResponse) { req -> String in
    req.response.status = .ok
    req.response.headers.replaceOrAdd(
        name: "Content-Type", 
        value: "application/json"
    )
    return #"{"foo": "bar"}"#
}
```

Hummingbird support for body streaming is amazing, you can stream a HTTP request body by using the .streamBody option. The body stream has a sequence property, which you can use to iterate through the incoming [ByteBuffer](https://swiftinit.org/reference/swift-nio/niocore/bytebuffer) chunks when handling the request. 🔄

```swift
func configure() throws { 
    router.post("foo", options: .streamBody) { req async throws -> String in
        guard
            let rawLength = req.headers["Content-Length"].first,
            let length = Int(rawLength),
            let stream = req.body.stream
        else {
            throw HBHTTPError(
                .badRequest,
                message: "Missing or invalid body stream."
            )
        }
        var count: Int = 0
        for try await chunk in stream.sequence {
            count += chunk.readableBytes
        }
        return String("\(length) / \(count)")
    }
}

// main.swift
let app = HBApplication(
    configuration: .init(
        address: .hostname(hostname, port: port),
        serverName: "Hummingbird",
        maxUploadSize: 1 * 1024 * 1024 * 1024 // 1GB
    )
)
```

As you can see you can easily access all the incoming headers via the req.headers container, you should note that this method will return header values in a case-insensitive way. If you want to stream larger files, you also have to set a custom maxUploadSize using the configuration object when initializing the HBApplication instance.

```sh
curl -X POST http://localhost:8080/foo \
    -H "Content-Length: 3" \
    --data-raw 'foo'

curl -X POST http://localhost:8080/foo \
    -H "content-Length: 5242880" \
    -T ~/test
```

You can try out streaming with a simple cURL script, feel free to experiment with these.

Another thing I'd like to show you is how to access query parameters and other properties using the request object. Here is an all-in-one example, which you can use as a cheatsheet... 😉

```swift
// curl -X GET http://localhost:8080/bar?q=foo&key=42
router.get("bar") { req async throws -> String in
            
    struct Foo: Codable {
        var a: String
    }

    print(req.method)
    print(req.headers)
    print(req.headers["accept"])
    print(req.uri.queryParameters.get("q") ?? "n/a")
    print(req.uri.queryParameters.get("key", as: Int.self) ?? 0)

    if let buffer = req.body.buffer {
        let foo = try? JSONDecoder().decode(Foo.self, from: buffer)
        print(foo ?? "n/a")
    }
    return "Hello, world!"
}
```

Anyway, there is one additional super cool feature in Hummingbird that I'd like to show you. It is possible to define a route handler, this way you can encapsulate everything into a single object. There is an async version of the [route handler protocol](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/router/#Route-handlers), if you don't need async, you can simply drop the keyword both from the protocol name & the method. I love this approach a lot. 😍

```swift
struct MyRouteHandler: HBAsyncRouteHandler {

    struct Input: Decodable {
        let foo: String
    }

    struct Output: HBResponseEncodable {
        let id: String
        let foo: String
    }
    
    let input: Input

    init(from request: HBRequest) throws {
        self.input = try request.decode(as: Input.self)
    }

    func handle(request: HBRequest) async throws -> Output {
        .init(
            id: "id-1",
            foo: input.foo
        )
    }
}
```

The request.decode method uses the built-in decoder, which you have to explicitly set for the application, since we're going to communicate using JSON data, we can use the JSON encoder / decoder from Foundation to automatically transform the data.

In order to make use of the custom route handler, you can simply register the object type.

```swift
import Hummingbird
import HummingbirdFoundation

public extension HBApplication {

    func configure() throws {
        
        encoder = JSONEncoder()
        decoder = JSONDecoder()
                
        //    curl -i -X POST http://localhost:8080/foo \
        //        -H "Content-Type: application/json" \
        //        -H "Accept: application/json" \
        //        --data-raw '{"foo": "bar"}'
        router.post("foo", use: MyRouteHandler.self)
    }
}
```

You can read more about how the [encoding and decoding](https://hummingbird-project.github.io/hummingbird-docs/documentation/hummingbird/encoding-and-decoding/) works in Hummingbird, but maybe that topic deserves its own blog post. If you have questions or suggestions, feel free to contact me. 🙈

