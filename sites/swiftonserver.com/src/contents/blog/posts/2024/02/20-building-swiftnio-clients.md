---
slug: building-swiftnio-clients
title: Building an HTTP client using SwiftNIO
description: Learn how to build a simple HTTP client using SwiftNIO and structured concurrency.
publication: 2024-02-20 18:30:00
tags:
  - swift
  - swiftNIO
  - networking
authors:
  - joannis-orlandos
---

# Building a SwiftNIO HTTP client

In the previous [SwiftNIO tutorial](/using-swiftnio-channels), you learned how to use SwiftNIO to build a simple TCP echo server. In this tutorial, you'll build a simple HTTP client using SwiftNIO.

We'll use the `NIOHTTP1` package for parsing and serializing HTTP messages. In addition, SwiftNIO's structured concurrency is used to manage the lifecycle of our client.

By the end of this tutorial, you'll know how to configure a SwiftNIO Channel's pipeline, and are able to send HTTP requests to a server.

[Download the Samples](https://github.com/swift-on-server/building-swiftnio-clients-sample) to get started. It has a dev container for a quick start.

> Note: This tutorial will emit some `Sendable` warnings. These are expected, and should be resolved in a production ready client implementation. However, for the purposes of this tutorial, ignore them.

## Creating a Client Channel

In SwiftNIO, Channels are created through a bootstrap. For TCP clients, you'd generally use a `ClientBootstrap`. There are alternative clients as well, such as Apple's Transport Services for Apple platforms. In addition, the `NIOHTTP1` module is used to simplify the process of creating a client channel.

Add these dependencies to your executable target in your `Package.swift` file:

```swift
.executableTarget(
    name: "swift-nio-part-3",
    dependencies: [
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOHTTP1", package: "swift-nio"),
    ]
),
```

Now, let's create a `ClientBootstrap` and configure it to use the `NIOHTTP1` module's handlers. First, import the necessary modules:

```swift
import NIOCore
import NIOPosix
import NIOHTTP1
```

Then, create a `ClientBootstrap`:

```swift
// 1
let httpClientBootstrap = ClientBootstrap(group: NIOSingletons.posixEventLoopGroup)
    // 2
    .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    // 3
    .channelInitializer { channel in
        // 4
        channel.pipeline.addHTTPClientHandlers(
            position: .first,
            leftOverBytesStrategy: .fireError
        )
    }
```

This code prepares a template for creating a client channel. Let's break it down:

1. Create a `ClientBootstrap` using the `NIOSingletons.posixEventLoopGroup` as the event loop group. This is a shared event loop group that can be reused across multiple components of our application.
2. NIO Channels can have options set on them. Here, the `SO_REUSEADDR` option is set to `1` to allow the reuse of local addresses.
3. Then, provide an initializer that is used to configure the pipeline of newly created channels.
4. Finally, the `channelInitializer` adds the necessary HTTP client handlers to the channel's pipeline. This uses a helper function provided by NIOHTTP1.

## Creating Types

Before creating the HTTP client, it's necessary to add a few types that are needed for processing HTTP requests and responses.

When a `connect` fails, NIO already throws an error. There is no need to catch or represent those. However, the HTTP Client might encounter errors when processing the response. Create an enum to represent these errors:

```swift
enum HTTPClientError: Error {
    case malformedResponse
    case unexpectedEndOfStream
}
```

Finally, add an enum to represent the state of processing the response:

```swift
enum HTTPPartialResponse {
    case none
    case receiving(HTTPResponseHead, ByteBuffer)
}
```

The enum if pretty simple, and is not representative of a _mature_ HTTP client implementation such as [AsyncHTTPClient](https://github.com/swift-server/async-http-client). However, it's enough to get started with building a (TCP) client.

## Implementing the HTTP Client

Now that the necessary types have been created, create the `HTTPClient` type with a simple function that sends a request and returns the response.

```swift
struct HTTPClient {
    let host: String

    func request(
        _ uri: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = [:]
    ) async throws -> (HTTPResponseHead, ByteBuffer) {
        // 5
        let clientChannel = try await httpClientBootstrap.connect(
            host: host,
            port: 80
        ).flatMapThrowing { channel in
            // 6
            try NIOAsyncChannel(
                wrappingChannelSynchronously: channel,
                configuration: NIOAsyncChannel.Configuration(
                    inboundType: HTTPClientResponsePart.self, // 7
                    outboundType: HTTPClientRequestPart.self // 8
                )
            )
        }.get() // 9

        // TODO: Send request & process response
    }
}
```

Let's break it down:

1. Use the `httpClientBootstrap` to create a new client channel. This returns an `EventLoopFuture` containing a regular NIO `Channel`. By using `flatMapThrowing` to transform the result of this future, it's possible to convert the `EventLoopFuture` into a `NIOAsyncChannel`.
2. In order to use structured concurrency, it's necessary to wrap the `Channel` in an `NIOAsyncChannel`. The inbound and outbound types must be `Sendable`, and need to be configured to match the pipeline's input and output. This is based on the handlers added in the bootstrap's `channelInitializer`.
3. The `NIOAsyncChannel` is configured to receive `HTTPClientResponsePart` objects. This is the type that the HTTP client will receive from the server.
4. The `NIOAsyncChannel` is configured to send `SendableHTTPClientRequestPart` objects. This is the type that the HTTP client will send to the server.
5. The `get()` method is called to _await_ for the result of the `EventLoopFuture`.

### Sending a Request

In place of the TODO comment, add the code to send a request and process the response. First, create a `HTTPRequestHead`. Note that this function does not currently support sending a body with the request. Do so by adding the following code:

```swift
// 10
return try await clientChannel.executeThenClose { inbound, outbound in
    // 11
    let requestHead = HTTPRequestHead(version: .http1_1, method: method, uri: uri, headers: headers)
    try await outbound.write(.head(requestHead))
    try await outbound.write(.end(nil))

    // TODO: Process response
}
```

This is a structured concurrency block that sends the request:

1.  The `executeThenClose` method is used to obtain a read and write half of the channel. This function returns the result of it's trailing closure.
2.  The writer called `outbound` is used to send the request's part - the head and 'end'. This is also where the request's body would be sent.

Below that, receive and process the response parts as such:

```swift
var partialResponse = HTTPPartialResponse.none

// 12
for try await part in inbound {
    // 13
    switch part {
    case .head(let head):
        guard case .none = partialResponse else {
            throw HTTPClientError.malformedResponse
        }

        let buffer = clientChannel.channel.allocator.buffer(capacity: 0)
        partialResponse = .receiving(head, buffer)
    case .body(let buffer):
        guard case .receiving(let head, var existingBuffer) = partialResponse else {
            throw HTTPClientError.malformedResponse
        }

        existingBuffer.writeImmutableBuffer(buffer)
        partialResponse = .receiving(head, existingBuffer)
    case .end:
        guard case .receiving(let head, let buffer) = partialResponse else {
            throw HTTPClientError.malformedResponse
        }

        return (head, buffer)
    }
}

// 14
throw HTTPClientError.unexpectedEndOfStream
```

This sets up a state variable to keep track of the response parts received. It then
processes the response parts as they come in:

12. A `for` loop is used to iterate over the response parts. This is a structured concurrency block that will continue to run until the channel is closed by the remote, an error is thrown, or a `return` statement ends the function.
13. The `part` is matched against the `HTTPClientResponsePart` enum. If the part is a head, it's stored in the `partialResponse` variable. If the part is a body, it's appended to the buffer in the `partialResponse` variable. If the part is an end, the `partialResponse` is returned.
14. If the loop ends without a return, an error is thrown, since the code was unable to receive a complete response.

## Using the Client

Now that the HTTP client is complete, it's time to use it. Add the following code to the `main.swift` file:

```swift
let client = HTTPClient(host: "example.com")
let (response, body) = try await client.request("/", headers: ["Host": "example.com"])
print(response)
print(body.getString(at: 0, length: body.readableBytes)!)
```

This creates a client and sends a GET request to `example.com`. The response is then printed to the console.

If everything is set up correctly, you should see roughly the following output:

```
HTTPResponseHead { version: HTTP/1.1, status: 200 OK, headers: [("Accept-Ranges", "bytes"), ("Age", "464157"), ("Cache-Control", "max-age=604800"), ("Content-Type", "text/html; charset=UTF-8"), ("Date", "Wed, 07 Feb 2024 21:22:33 GMT"), ("Etag", "\"3147526947\""), ("Expires", "Wed, 14 Feb 2024 21:22:33 GMT"), ("Last-Modified", "Thu, 17 Oct 2019 07:18:26 GMT"), ("Server", "ECS (dce/26CD)"), ("Vary", "Accept-Encoding"), ("X-Cache", "HIT"), ("Content-Length", "1256")] }
<!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
    ....
```

And that's it! You've built a simple HTTP client using SwiftNIO. You can now use this client to send requests to any server that supports HTTP/1.1.
