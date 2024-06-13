---
slug: using-swiftnio-fundamentals
title: Using SwiftNIO - Fundamentals
description: Learn the fundamental concepts of SwiftNIO, such as EventLoops and nonblocking I/O
publication: 2024-01-30 18:30:00
tags:
  - swift
  - swiftNIO
  - networking
authors:
  - joannis-orlandos
---

# SwiftNIO Fundamentals

SwiftNIO is a brilliant framework that's developed and maintained by Apple. It's used for network application development, usually but not exclusively by libraries. Whether you're using Swift to write networking clients or servers, or use a framework such as [Hummingbird](https://github.com/hummingbird-project) or [Vapor](https://vapor.codes). SwiftNIO is at the heart of Server-Side Swift.

### What is SwiftNIO?

SwiftNIO is an event-driven network application framework. We'll break down what that means in a bit. It targets Linux and Apple platforms, thereby also defining the platforms that Server-Side Swift libraries support.

SwiftNIO is a _framework_ at heart, meaning that it's not trying to be a purely fast networking library. While performance in SwiftNIO is extremely important, it strives to balance that with ergonomics and maintainability.

While SwiftNIO is not a very easy to use for those new to networking, those familiar with writing network applications find their job significantly easier with NIO than without.

### Event-Driven

Now that we've gone over the definition of NIO a bit, there's a very specific and important topic that we haven't covered yet. Event-Driven is a critical part of how NIO works internally. But it's also critical to building network applications using SwiftNIO, and even finds its way into APIs such as Vapor's.

The concept of an _EventLoop_ rings a bell with many people in the ecosystem, though it's not commonly known what an EventLoop is. It's not a coincidence that both are related to "events".
That's because an EventLoop is very literally what it says on the tin. It's a (while) loop that polls for various types of events.

## Networking and I/O

Before we dive into the specifics of events further, let's cover how networking, and specifically networking I/O, works on your computer.

I/O, or Input/Output, refers to the ability to _read_ and _write_ information.

In a traditional Unix (POSIX) system, such as Linux or macOS, your standard library provides a few very important functions. These are `open`, `read`, `write` and `close`.

The _open_ function allows you to open a file, such as a `note.txt` on your desktop. The result of this function is an integer called the "file descriptor". When reading information from this file, rather than referencing the path to `note.txt`, you'll reference this file descriptor instead. Likewise, when we're done reading or writing a file, we can `close` it as well, passing the file descriptor as a handle.

When reading a file from the disk, reading a file starts at the first byte/character in the file. Assuming no additional interference, when reading 1KB of data, the 'offset' in the file will advance by the same amount. While you can change this offset through various APIs, the next time you ask for 1KB of data, you'll read the information starting where you left off at the previous function call.

### Filesystem and Networking Similarities

While your filesystem and network don't seem to have much in common, in your operating system they do! When creating socket and connecting to a server, your operating systme _also_ returns a file descriptor. Instead of `open`, you use the `socket` and `connect` calls instead. However, from that point forward the APIs are very similar in use.

When calling `read`, you'll receive the information on a socket. And when `write`ing data, you'll send it over the network as well. Unlike your disk, a socket does not have an offset like a filesystem does. But the basic concepts of a file descriptor, reading, writing and closing are the same.

### I/O Events

We've established what I/O is, and how it works on your operating system. There's one more important detail in I/O, namely that I/O is _not_ instant. When working with I/O, receiving new data can take anywhere from small fractions of a second, to multiple minutes. A filesystem is generally relatively fast, though your system is capable of handling much more than one network connection or file at a time. A lot of things can happen in parallel, and your processor can do other things in the precious time that it takes to receive the next chat message from your distant friend.

By default, when you're `read`ing information, your operating system will **block** execution of the function call until new information arrives. That means that your application's execution on this thread will halt until new data arrives. This is extremely inefficient. Moreover, this can also occur when _writing_ data to a disk or network.

In order to solve this, your operating system has APIs that can notify the process of new I/O events. These APIs allow you to continue operation on other application logic, or reading other file descriptors, rather than _waiting_ for new input.

This concept is called _nonblocking I/O_.

## Nonblocking I/O

There are a variety of tools, specific to platforms, that help with nonblocking I/O. `Dispatch` has a type called `DispatchIO`, which calls your function whenever a file descriptor can read new information. This can be when a disk has completed reading the next chunk of data from the disk. But more commonly in network applications, when a remote peer has sent new information to you.

DispatchIO can also notify you when there's an opportunity to _write_ more data to a filesystem or socket.

Closer to the operating system, and a more efficient approach, is to use `epoll`, `uring` or `kqueue` for polling for events. These frameworks can all notify your application of I/O opportunities, and also have means to notify your application at a certain _time_. This is the approach that SwiftNIO takes.

### EventLoops

Contrary to what the name implies, nonblocking I/O _does_ actually block execution at times. It's just very good at avoiding this. An EventLoop is generally run on its own thread. On that thread, it runs a `while` loop that polls for events. When events are receives, it triggers functions that read or write data to the socket when possible. When all I/O operations are handled, it _blocks_ execution until a new event is received.

Blocking in this loop is not a bad thing, because the function will wake up whenever the next event happens. At the same time, it's not wasting CPU time by running around in circles waiting for a new event. This makes the system extremely efficient when it's built around this EventLoop.

### Reading using EventLoops

As mentioned previously, reading data by default is blocking. By setting the file descriptor to nonblocking, you can avoid this. Read operations will return any data that's available, allowing you to continue execution. However, when no data is available, the read operation will return an error. This is where the EventLoop comes in.

When a read operation returns an error, the EventLoop will register the file descriptor to be notified when new data is available. This allows the EventLoop to continue execution on other file descriptors, or other application logic. When new data is available, the EventLoop will wake up the function that was waiting for new data, and execution will continue.

### Blocking the EventLoop

You may have heard that blocking the EventLoop is bad. This is because the EventLoop is a shared resource. If your application does a lot of work on the EventLoop without returning control to the EventLoop, other file descriptors will not get the opportunity to receive new data. If your EventLoop is hosting a web server, this means that one request can block all other requests from being handled.

In the best case, this means that your application will be slower because of it. In the worst case, this means that your application will not be able to receive new data at all.

The EventLoop is a shared resource, not just between HTTP clients, but is also commonly shared with other protocols. Blocking an event loop could affect your database driver for example, as it would prevent the database driver from receiving new data.

When this happens, your database driver cannot receive and process the result of a query. If you're blocking the database driver in the same routine that's waiting for the result, you'll end up with a deadlock.

## Next Steps

We've now covered the most important elements of SwiftNIO. You've learned about the EventLoop, and how it's used to avoid blocking I/O. You've also learned about the importance of not blocking the EventLoop, and how that can affect your application.

In the [next part](/using-swiftnio-channels), we'll cover how sockets are represented in SwiftNIO. And you'll even learn how to write your very own networking application using SwiftNIO!
