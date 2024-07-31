---
type: post
slug: swiftnio-tutorial-the-echo-server
title: SwiftNIO tutorial - The echo server
description: This is a beginner's guide to learn the basics of the SwiftNIO network app framework by building a basic TCP echo server.
publication: 2023-01-26 16:20:00
tags: Swift, SwiftNIO
authors:
  - tibor-bodecs
---

## Intoducing SwiftNIO

If you used a high level web framework, such as [Vapor](https://www.vapor.codes/), in the past, you might had some interaction with event loops or promises. Well, these fundamental building blocks are part of a low level network framework, called [SwiftNIO](https://github.com/apple/swift-nio), which I'm going to talk about in this tutorial.

Don't worry if you haven't heard about event loops or non-blocking IO just yet, I'll try to explain everything in this guide, so hopefully you'll understand everything even if you are a complete beginner to this topic. Let's start with some basics about networks and computers.

## Let's talk about TCP/IP

It all started on January 1st, 1983. The [internet was born](https://www.usg.edu/galileo/skills/unit07/internet07_02.phtml) (as some say) and people started to officially use the [internet protocol suite](https://en.wikipedia.org/wiki/Internet_protocol_suite) (TCP/IP) to communicate between devices. If you don't know much about [TCP/IP](https://www.guru99.com/tcp-ip-model.html) and you are curious about the underlying parts, you can read a few other articles, but in a nutshell this model allows us to talk with remote computers easily. 💬

Let's say that you have two machines, connected by the network. How do they communicate with each other? Well, just like when you send a regular letter, first you have to specify the address of the recipient. In order to send a message to another computer, you have to know its digital address too. This digital address is called [IP address](https://en.wikipedia.org/wiki/IP_address) and it looks like this: 127.0.0.1.

So you've got the address, but sometimes this is not enough, because a building can have multiple apartments and you have to specify the exact letterbox in order to reach the actual person. This can happen with computers too, the letterbox is called port number and the full address of the target can be created by combining the IP address and the port number (we call this full address as a [network socket](https://en.wikipedia.org/wiki/Network_socket) address or simply socket, e.g. 127.0.0.1:80). 💌

After you've specified the exact address, you'll need someone to actually deliver the letter containing your message. The postal delivery service can transfer your letter, there are two ways to send it over to the recipient. The first solution is to simply send it without knowing much about the delivery status, the digital version of this approach is called [User Datagram Protocol](https://en.wikipedia.org/wiki/User_Datagram_Protocol) (UDP).

The other (more reliable) method is to get a receipt about the delivery, this way you can make sure that the letter actually arrived and the recipient got it. Although, the postman can open your letter and alter your message, but it'll be still delivered and you'll get a notification about this. When you communicate through the network, this method is called [Transmission Control Protocol](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) (TCP).

Ok, that's more than enough network theory, I know it's a high level abstraction and not entirely accurate, but hopefully you'll get the basic idea. Now let's talk about what happens inside the machine and how we can place an actual digital letterbox in front of the imaginary house. 📪

## The basic building blocks of SwiftNIO

What do you do if you expect a letter? Apart from the excitement, most people constantly check their mailboxes to see if it's already there or not. They are listening for the noises of the postman, just like computer programs listen on a given port to check if some data arrived or not. 🤓

What happens if a letter arrives? First of all you have to go and get it out from the mailbox. In order to get it you have to walk through the hallway or down the stairs or you can ask someone else to deliver the letter for you. Anyway, should get the letter somehow first, then based on the envelope you can perform an action. If it looks like a spam, you'll throw it away, but if it's an important letter you'll most likely open it, read the contents and send back an answer as soon as possible. Let's stick with this analogy, and let me explain this again, but this time using SwiftNIO terms.

### Channel

A [Channel](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/channel) connects the underlying network socket with the application's code. The channel's responsibility is to handle inbound and outbound events, happening through the socket (or file descriptor). In other words, it's the channel that connects the mailbox with you, you should imagine it as the hallway to the mailbox, literally the messages are going travel to you via a channel. 📨

### ChannelPipeline

The ChannelPipeline describes a set of actions about how to handle the letters. One possible version is to make a decision based on the envelope, you'll throw it away if it looks like a spam, or open it if it looks like a formal letter, it's also an action if you respond to the letter. Actions are called as channel handlers in SwiftNIO. In short: a pipeline is a predefined sequence of handlers.

### ChannelHandler

The [ChannelHandler](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/channelhandler) is the action that you can perform when you open the letter. The channel handler has an input and an output type, which you can use to read the message using the input and respond to it using the output. Okay, just two more important terms, bear with me for a second, I'm going to show you some real examples afterwards. 🐻

### EventLoop

The [EventLoop](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/eventloop) works just like a [run loop](https://developer.apple.com/documentation/foundation/runloop) or a [dispatch queue](https://developer.apple.com/documentation/dispatch/dispatchqueue). What does this mean?

> The event loop is an object that waits for events (usually I/O related events, such as "data received") to happen and then fires some kind of callback when they do.

The modern CPUs have a limited number of cores, apps will most likely associate one thread (of execution) per core. Switching between thread contexts is also inefficient. What happens when an event has to wait for something and a thread becomes available for other tasks? In SwiftNIO the event loop will receive the incoming message, process it, and if it has to wait for something (like a file or database read) it'll execute some other tasks in the meantime. When the IO operation finishes it'll switch back to the task and it'll call back to your code when it's time. Or something like this, but the main takeaway here is that your channel handler is always going to be associated with exactly one event loop, this means actions will be executed using the same context.

### EventLoopGroup

The [EventLoopGroup](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/eventloopgroup) manages threads and event loops. The [MultiThreadedEventLoopGroup](https://swiftpackageindex.com/apple/swift-nio/main/documentation/nioposix/multithreadedeventloopgroup) is going to balance out client over the available threads (event loops) this way the application is going to be efficient and every thread will handle just about the same amount of clients.

### Other components

There are some other SwiftNIO components, we could talk more about [Futures](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/eventloopfuture), [Promises](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/eventlooppromise) and the [ByteBuffer](https://swiftpackageindex.com/apple/swift-nio/main/documentation/niocore/bytebuffer) type, but I suppose this was more than enough theory for now, so I'm not going to dive into these kind of objects, but spare them for upcoming articles. 😇

## Building an echo server using SwiftNIO

You can start by creating a new executable Swift package, using the [Swift Package Manager](https://theswiftdev.com/swift-package-manager-tutorial/). Next you have to add SwiftNIO as a package dependency inside the Package.swift file.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "echo-server",
    platforms: [
       .macOS(.v10_15),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio",
            from: "2.0.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(
                    name: "NIO",
                    package: "swift-nio"
                )
            ]
        ),
    ]
)
```

The next step is to alter the main project file, we can easily create the SwiftNIO based TCP server by using the ServerBootstrap object. First we have to instantiate a MultiThreadedEventLoopGroup with a number of threads, using the CPU cores in the system.

Then we configure the server by adding some channel options. You don't have to know much about these just yet, the interesting part is inside the `childChannelInitializer` block. We create the actual channel pipeline there. Our pipeline will consist of two handlers, the first one is the built-in `BackPressureHandler`, the second one is going to be our custom made EchoHandler object.

If you are interested in the available `ChannelOptions`, you can take a look at the NIO source code, it also contains some very good docs about these things. The final step is to bind the server bootstrap object to a given host and port, and wait for incoming connections. 🧐

```swift
import NIO

@main
public struct Server {
    
    public static func main() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: System.coreCount
        )

        defer {
            try! eventLoopGroup.syncShutdownGracefully()
        }

        let serverBootstrap = ServerBootstrap(
            group: eventLoopGroup
        )
        .serverChannelOption(
            ChannelOptions.backlog,
            value: 256
        )
        .serverChannelOption(
            ChannelOptions.socketOption(.so_reuseaddr),
            value: 1
        )
        .childChannelInitializer { channel in
            channel.pipeline.addHandlers([
                BackPressureHandler(),
                EchoHandler(),
            ])
        }
        .childChannelOption(
            ChannelOptions.socketOption(.so_reuseaddr),
            value: 1
        )
        .childChannelOption(
            ChannelOptions.maxMessagesPerRead,
            value: 16
        )
        .childChannelOption(
            ChannelOptions.recvAllocator,
            value: AdaptiveRecvByteBufferAllocator()
        )

        let defaultHost = "127.0.0.1" // or ::1 for IPv6
        let defaultPort = 8888

        let channel = try serverBootstrap.bind(
            host: defaultHost,
            port: defaultPort
        )
        .wait()

        print("Server started and listening on \(channel.localAddress!)")
        try channel.closeFuture.wait()
        print("Server closed")
    }
}
```

As I mentioned this, in order to handle an event happening on the channel we have can create a custom `ChannelInboundHandler` object. Inside the channelRead function it is possible to unwrap the inbound data into a ByteBuffer object and write the input message onto the output as a wrapped NIOAny object.

Challenge: write a server that can print colorful messages. Hint: [building a text modifying server](https://rderik.com/blog/understanding-swiftnio-by-building-a-text-modifying-server/).

```swift
import NIO

final class EchoHandler: ChannelInboundHandler {

    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    func channelRead(
        context: ChannelHandlerContext,
        data: NIOAny
    ) {
        let input = self.unwrapInboundIn(data)
        guard
            let message = input.getString(at: 0, length: input.readableBytes)
        else {
            return
        }
        
        var buff = context.channel.allocator.buffer(capacity: message.count)
        buff.writeString(message)
        context.write(wrapOutboundOut(buff), promise: nil)
    }


    func channelReadComplete(
        context: ChannelHandlerContext
    ) {
        context.flush()
    }

    func errorCaught(
        context: ChannelHandlerContext,
        error: Error
    ) {
        print(error)

        context.close(promise: nil)
    }
}
```

If you run the app and connect to it using the `telnet 127.0.0.1 8888` command you can enter some text and the server will echo it back to you. Keep in mind that this is a very simple TCP server, without HTTP, but it is possible to write [express-like HTTP servers](https://www.alwaysrightinstitute.com/microexpress-nio2/), [JSON API servers](https://www.kodeco.com/8016626-swiftnio-tutorial-practical-guide-for-asynchronous-problems), even [a game backend](https://www.youtube.com/watch?v=_BGx5THJpvE) and many other cool and crazy performant stuff using SwiftNIO. I hope this tutorial will help you to get started with SwiftNIO, I'm also learning a lot about the framework lately, so please forgive me (or even correct me) if I missed / messed up something. 😅

So again: SwiftNIO a (low-level) non-blocking event-driven network application framework for high performance protocol servers & clients. It's like [Netty](https://netty.io/), but written for Swift.
