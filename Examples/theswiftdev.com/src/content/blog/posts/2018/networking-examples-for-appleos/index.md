---
type: post
slug: networking-examples-for-appleos
title: Networking examples for appleOS
description: Learn how to use Bonjour, with UDP/TCP sockets, streams and how to communicate through CoreBluetooth or the watch APIs.
publication: 2018-02-27 16:20:00
tags: Networking, UDP, TCP, Bonjour
authors:
  - tibor-bodecs
---

> WARN: This article was originally written back in the end of 2015. The source code is deprecated and not compatible with current Swift versions, so I removed it.

If you want to learn how to make a [network connection](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/UsingSocketsandSocketStreams.html#//apple_ref/doc/uid/CH73-SW2) between your devices using [Bonjour discovery](https://help.dyn.com/bonjour-and-dns-discovery/) service you are on the right place. In this post I am going to show you the basics, so for example you will be able to make a remote controller from your watch or iOS device in order to send data directly to any tvOS or macOS machines.

## Multi-platform development

If you want to create an app that supports multiple platforms, you might want to target macOS, iOS, watchOS, tvOS and soon Linux as well. The code snippet below is going to help you detecting the current platform that you are working with.

```swift
#if os(iOS)
    let platform = "iOS"
#elseif os(macOS)
    let platform = "macOS"
#elseif os(watchOS)
    let platform = "watchOS"
#elseif os(tvOS)
    let platform = "tvOS"
#elseif os(Linux)
    let platform = "linux"
#else
    let platform = "unknown"
#endif

print(platform)
```

## Network connection 101

### Bonjour discovery service

[Bonjour](http://dev.eltima.com/post/99996366184/using-bonjour-in-swift), also known as zero-configuration networking, enables automatic discovery of devices and [services](https://developer.apple.com/library/ios/documentation/Networking/Conceptual/NSNetServiceProgGuide/Articles/PublishingServices.html) on a local network using industry standard IP protocols.

So basically with [Bonjour](https://developer.apple.com/bonjour/) you can find network devices on your local network. This comes very handy if you are trying to figure out the list of devices that are connected to your LAN. Using NetService class will help you to detect all the devices with the available services that they support. The whole [Bonjour API](http://code.tutsplus.com/tutorials/creating-a-game-with-bonjour-client-and-server-setup--mobile-16233) is relatively small and well-written. From the aspect of server side you just have to create the NetService object, and listen to the incoming connections through the NetServiceDelegate.

> NOTE: You have to be on the same WiFi network with all devices / simulators.

### TCP connection

TCP provides reliable, ordered, and error-checked delivery of a stream of octets (bytes) between applications running on hosts communicating by an IP network.

With the help of [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) you can build up a reliable network connection. There is a Stream class in Foundation to help you sending data back and forth between devices. If you have a working connection form NetServiceDelegate, just listen to the stream events to handle incoming data through the StreamDelegate. I don't want to go into the details, just download the example [code](https://gitlab.com/theswiftdev/networking-for-appleos) and check it out for yourself.

### UDP connection

With [UDP](https://developer.apple.com/library/mac/samplecode/UDPEcho/Listings/Read_Me_About_UDPEcho_txt.html), computer applications can send messages, in this case referred to as datagrams, to other hosts on an Internet Protocol (IP) network.

If you look at the article about [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol) you'll clearly see that the main difference from TCP is that this protocol will not guarantee you safety of the data delivery. Data may arrives unordered or duplicated, it's your task to handle these scenarios, but the UDP is fast. If you want to build a file transfer app you should definitely go with TCP, but for example controlling a real-time action game UDP is just as good enough.

### CocoaAsyncSocket

This library is the absolute winner for me and probably it is the best option for everyone who wants to set up a network connection really quickly, because it requires way less code than implementing delegates. Of course you'll still need the Bonjour layer above the whole thing, but that's just fine to deal with.

If you are using [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) you will see that the API is straightforward, only after 5 minutes I could relatively easily figure it out what's going on and I was able to [send messages](http://beej.us/net2/html/index.html) through the network. It supports all the Apple platforms, you can seamlessly integrate it using Carthage or CocoaPods.

### CoreBluetooth APIs

I was not really familiar with the CoreBluetooth framework API's, that's the reason why I basically just followed and ported this [tutsplus.com](https://code.tutsplus.com/tutorials/ios-7-sdk-core-bluetooth-theoretical-overview--mobile-20728) code example to Swift 4. Honestly I felt that the API is somehow over-complicated with all those messy delegate functions. If I have to chose between [CoreBluetooth](http://code.tutsplus.com/tutorials/ios-7-sdk-core-bluetooth-practical-lesson--mobile-20741) or CocoaAsyncSocket, I'd go with the last one. So yes, obviously I am not a Bluetooth expert, but this little project was a good first impression about how things are working inside the CB framework.

### WatchConnectivity framework

If you want to communicate between iOS and watchOS you'll probably use the WatchConnectivity framework, especially the WKSession class. It's really not so complicated, with just a few lines of code you can send messages form the watch to the iPhone. You can read this [tutorial](https://www.hackingwithswift.com/read/37/8/communicating-between-ios-and-watchos-wcsession), but if you download my [final sources](https://gitlab.com/theswiftdev/networking-for-appleos) for this article, you'll find almost the same thing inside the package.
