---
slug: using-swiftnio-channels
title: Using SwiftNIO - Channels
description: Create a TCP server using SwiftNIO and structured concurrency
publication: 2024-02-08 18:30:00
tags: Swift, SwiftNIO, Networking
author: Joannis Orlandos
authorLink: https://x.com/JoannisOrlandos
authorGithub: joannis
authorAbout: Joannis is a seasoned member of the Swift Server WorkGroup, and the co-founder of Unbeatable Software B.V. If you're looking to elevate your team's capabilities or need expert guidance on Swift backend development, consider hiring him.
cta: Get in touch with Joannis
ctaLink: https://unbeatable.software/mentoring-and-training
company: Unbeatable Software B.V.
companyLink: https://unbeatable.software/
duration: 30 minutes
---

# SwiftNIO Channels

In the [previous tutorial](/using-swiftnio-fundamentals), you've learned the fundamentals of SwiftNIO. You're now familiar with the concept of an `EventLoop`.

In this tutorial, you'll be building a TCP server that echoes back any data that it receives. This is a very common pattern in network applications, and is a great way to get started with SwiftNIO. You'll learn what **Channels** and **Channel Pipelines** are, and how SwiftNIO uses them to represent network connections. You'll also learn about **Channel Handlers** and applying this knowledge using structured concurrency.

In order to start with this tutorial, [Download the Samples](https://github.com/swift-on-server/using-swiftnio-channels-sample). If you're stuck, you can keep at the Finished product within that repo as well.

The samples make use of [VSCode DevContainers](/developing-with-swift-in-visual-studio-code/) to provide a consistent development environment. If you're not using VSCode, you can also use the latest Xcode.

## Channels

In the previous aricle, you learned the concepts of an `EventLoop`, Network I/O and sockets. You now know that a socket is represented by a file descriptor, and that you can read and write data to it.

The Sockets covered in the previous article are represented as a "Channel" in SwiftNIO. However, a Channel can be anything that is capable of I/O operations. This includes TCP and UDP connections, but can also extend to things such as Unix Domain Sockets, Pipes and even Serial USB connections.

A Channel is a very important concept in NIO, and is used extensivley throughout any networking application.

### A Channel's Anatomy

Channel is fundamentally a protocol that any connection can conform to. The protocol defines a variety of properties and functions that are relevant to connections. For example, many connections have a `localAddress` and `remoteAddress` property. These properties are used to identify the local and remote peer of a connection. Because Channel does not exclusively represent network connections, these properties are optional.

Most importantly, a Channel has a `ChannelPipeline`. The pipeline processes all data that is sent and received by the Channel. You can think of the pipeline as an array of `ChannelHandler`s. These handlers are called in order, and can modify the data that is sent and received by the Channel.

Each ChannelHandler is usually responsible for a specific task. For example, the `NIOSSLHandler` is responsible for encrypting and decrypting data using TLS. For HTTP/1, you have a specific handler that parses HTTP requests. And another handler that serializes HTTP responses.

### Pipelines

A channel can receive data, such as when it's received from the network or a USB device. When this happens, the data is passed to the `ChannelPipeline` at the head. This calls the first [`InboundHandler`](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/channelinboundhandler) in the pipeline. The flow of data makes its way from front-to-back, ending at the tail, calling only InboundHandlers. Each of these handlers can 'process' the data, by transforming the information or even changing the type of data in the pipeline.

When a channel is asked to send data, the data also goes through the pipeline, but starts at the tail. This calls the last handler in the pipeline, and only calls [`OutboundHandler`s](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/channeloutboundhandler). Each of these handlers can also process the data, and can also change the type of data in the pipeline.

The type of data that a pipeline receives at the head when data is read, is specified by the Channel. This means that the first InboundHandler's must accept the type of data that the `Channel` emits when reading data off the network. Likewise, whatever the Pipeline ends up writing data to a `Channel`, the type of data written must match what the `Channel` can handle. Note that if these types don't match, SwiftNIO will crash your application at **runtime**.

### Channel Handlers

An InboundHandler specifies two associated types, the `InboundIn` and `InboundOut`. The _InboundIn_ type is the input of the handler when reading data. For example, `ByteBuffer` is used by NIO to represent binary data. The _InboundOut_ specifies any output that this handler _outputs_. When parsing an HTTP Request using the built-in HTTP/1 parser, the handler accepts `ByteBuffer` for input and produces an `HTTPServerRequestPart` when it parses a part of the HTTP request.

When the handler has processed the data, it can pass the transformed data on to the next handler in the pipeline. If a channel handler does not modify the output, it can simply pass on the data to the next handler. When the handler modifies data, this is done by calling `fireChannelRead` on the `ChannelHandlerContext`. This context is provided during the `channelRead` function call where you receive inbound data.

The data you emit (InboundOut) must match the expected input type of the next handler in the pipeline. If the types don't match, SwiftNIO will also crash your application at runtime. This is why it's important to understand the types that each handler accepts and emits.

Using code such as [Omnibus](https://github.com/orlandos-nl/omnibus), you can create these pipeline in a type-checked way. This ensures that your pipeline is valid at compile-time, rather than runtime.

The OutboundHandler works in an identical way to the InboundHandler. The `OutboundIn` type is the type of data that the handler accepts, and the `OutboundOut` type is the type of data that the handler emits. Processing data instead happens in the `write` function, rather than the `channelRead` function.

## Creating a TCP Echo Server

Now that you understand the basics of Channels and Pipelines, let's apply our knowledge to create a TCP Echo Server. This server, built using structured concurrency, will accept TCP connections. When it receives a message, itll echo back any data that it receives.

### Creating a ServerBootstrap

In order to create a TCP server, you'll first need to create a `ServerBootstrap`. This is a type that's provided by SwiftNIO, and is used to create a server Channel that emits client channels.

ServerBootstrap requires an `EventLoopGroup` to run on. This is a group of EventLoops that the server will use to run on. Each client will be handled by a single specific `EventLoop`, that is randomly assigned. This helps your server scale to many threads (and cores) without having to worry about thread-safety.

```swift
import NIOCore
import NIOPosix

// 1. 
let server = try await ServerBootstrap(group: NIOSingletons.posixEventLoopGroup)
    .bind( // 2.
        host: "0.0.0.0", // 3.
        port: 2048 // 4.
    ) { channel in
        // 5.
        channel.eventLoop.makeCompletedFuture {
            // Add any handlers for parsing or serializing messages here
            // We don't need any for this echo example

            // 6.
            return try NIOAsyncChannel(
                wrappingChannelSynchronously: channel,
                configuration: NIOAsyncChannel.Configuration(
                    inboundType: ByteBuffer.self, // Read the raw bytes from the socket
                    outboundType: ByteBuffer.self // Write raw bytes to the socket
                )
            )
        }
    }
```

The above code can create a TCP server, without any logic to accept or communicate with clients. Let's go over the code step-by-step:

1. Create a bootstrap using a global `EventLoopGroup`. This is a recommended default EventLoopGoup.
2. Bind the socket to a specific host and port. This will start listening for incoming connections.
3. The host speciifes the IP address that the server will listen on. `0.0.0.0` is a special IP address that means "all IP addresses", allowing connections from all network interfaces.
4. Set the port that the server will listen on. This port is what clients will connect to.
5. This closure is called for every client that connects to the server. This allows us to set up the pipeline for each client. In this case we don't need any configuration. Note that this is one of the few remaining APIs where you can't use `async`/`await`.
6. Wrap the `Channel` in an `NIOAsyncChannel`. This is a type that's provided by SwiftNIO, and allows interating with Channels in a way that fully embraces structured concurrency.

### Accepting Clients

With this newly created server, this code can start accepting clients.
Let's implement that:

```swift
// 1.
try await withThrowingDiscardingTaskGroup { group in
    // 2.
    try await server.executeThenClose { clients in
        // 3.
        for try await client in clients {
            // 4.
            group.addTask {
                // 5.
                try await handleClient(client)
            }
        }
    }
}
```

This code is an implementation of the server bootstrap that was created in the previous snippet. Let's go over the code step-by-step:

1. Create a task group to manage the lifetime of our server
2. By calling `executeAndClose`, receive a sequence of incoming clients. Once this sequence ends, the end of the function is reached and the server is closed.
3. A for-loop is used to iterate over each new client, allowing us to handle their traffic.
4. By adding a task to the task group, this Swift code can handle many clients in parallel
5. Call `handleClient` to handle the client. This will be a separate function that will be implemented in a moment.

### Handling a Client

The server is not able to accept client, but can not yet communicate with them. Let's implement that:

```swift
func handleClient(_ client: NIOAsyncChannel<ByteBuffer, ByteBuffer>) async throws {
    // 1.
    try await client.executeThenClose { inboundMessages, outbound in
        // 2.
        for try await inboundMessage in inboundMessages {
            // 3.
            try await outbound.write(inboundMessage)

            // MARK: A
        }
    }
}
```

This code receives messages from a client, and echoes it back. It's functional, efficient and easy to understand. Let's go over the code step-by-step:

1. Call `executeThenClose` on the client. This allows us to receive a sequence of inbound messages, and a handle to write messages back.
2. Iterate over each inbound message, using a for-loop.
3. Write the inbound message back to the client.

When the client closes the connection, the sequence of inbound messages will end. This causes the `executeThenClose` function will return, and the client will be cleaned up.

You can try connecting yourself by running the following in your terminal. If a connection is successful, you'll get prompt where you can type a message. When you press enter, the message will be echoed back to you.

```bash
nc localhost 2048
```

If you want, close the connection from our side as well. I've placed a marker where you can close the connection from our side.
Because `executeThenClose` will close the connection when the function ends, simply place a `return` statement here.

## Conclusion

In this tutorial, you've learned the concept of Channels and Pipelines. You've also created a simple TCP server using SwiftNIO. All with structured concurrency!

In the [next tutorial](/building-swiftnio-clients), we'll cover how to suppport a protocol (HTTP/1) by using Channel Handlers, by building an HTTP client.
