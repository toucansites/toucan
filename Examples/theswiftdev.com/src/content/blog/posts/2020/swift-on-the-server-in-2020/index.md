---
type: post
title: Swift on the Server in 2020
description: Why choose Swift as a backend language in 2020? What are the available frameworks to build your server? Let me guide you.
publication: 2020-08-28 16:20:00
tags: 
    - vapor
    - server
authors:
    - tibor-bodecs
---

## Swift is everywhere

Swift is a modern, interactive, type-safe programming language with performance in mind. It is one of the fastest growing programming languages in the industry. Swift has gained so much attraction over the last few years, some people love it, others might hate it, but one thing is for sure:

> Swift is here to stay for a very long time.

Swift is as easy to use as a scripting language, without sacrificing any performance. This means C-like performance in most of the cases, which should be more than enough for most of the people.

In the beginning Swift was considered as a replacement for Objective-C for Apple platforms, but don't get fooled. Swift is a generic purpose programming language, so you can build anything with it. It runs on embedded systems, of course you can make iOS apps and great desktop class applications using Swift, you can use it to write great Machine Learning algorithms ([TensorFlow](https://www.tensorflow.org/swift)), build backend servers, even experimental operating systems, but let me just stop here. ✋🏻

Swift is everywhere, it has changed a lot, but now we can consider it as a mature programming language. There are still some missing / annoying things, it'd be great to have more (lightweight) tools (e.g. you still can't run tests for packages without installing Xcode), but we are slowly getting there. Apple will build a new generation of hardware devices using [Apple Silicon](https://developer.apple.com/documentation/apple_silicon), they've put a lot of effort to rewrite the underlying software components (I bet there is plenty of Swift code already), so I'd say this is just the beginning of the story. 🚀

## Swift Server Work Group (SSWG)

The [SSWG](https://swift.org/server/) is on the right track. In the beginning I think they dictated a very slow pace, but now it seems like they know how to work together in an efficient way. It is worth to mention that this group has some very talented people from big companies, such as Apple, Amazon, MongoDB or the Vapor community. They are responsible for priorizing "what needs to be done" for the server community, they run an incubation process for backend related packages and channel feedbacks to the Swift Core Team so they can quickly address the underlying issues in the language itself.

Unfortunately in the very end of last year, [IBM announced](https://forums.swift.org/t/december-12th-2019/31735/32) that they are moving away from Swift on the server, but it turns out that the community is going to be able to save and maintain the [Kitura](https://github.com/IBM-Swift/Kitura) web framework. Anyway, Vapor 4 is almost ready if you are looking for an alternative solution. 🙈

Later on this year Tom Doron, member of the Swift Core Team and the Swift Server Work Group, [announced](https://swift.org/blog/additional-linux-distros/) that more Linux distributions are going to be supported. This is a great news, you can now [download official Swift releases](https://swift.org/download/#releases) for seven different platform. Nightly and official Docker images are also available for Swift, this was announced by Mishal Shah on the [Swift Forums](https://forums.swift.org/t/nightly-swift-docker-images/33029).

## Language stability

As [Swift evolved](https://apple.github.io/swift-evolution/) more and more great features were added to the language. Those implementations also pushed forward server side projects. When Swift was open sourced back in 2015 (it became available for Linux) the standard library, Foundation were quite buggy and many language features that we have today were completely missing. Fortunately this changed a lot. I'd say Swift 5 is the first version of the language that was stable enough to build a reliable backend server. 🤖

With Swift 5.0 [ABI stability](https://swift.org/blog/abi-stability-and-more/) has arrived, so finally we were able to build an app without the entire standard library and runtime included in the binary. We still had to wait about half a year for [module stability](https://www.donnywals.com/what-is-module-stability-in-swift-and-why-should-you-care/), that arrived with the [release of Swift 5.1](https://swift.org/blog/swift-5-1-released/) in late 2019. If you are interested in developing a framework or a library, you should also read about [Library Evolution in Swift](https://swift.org/blog/library-evolution/).

## Swift Package Manager

The [SPM library](https://github.com/apple/swift-package-manager) is here with us for quite a long time now, but in the beginning we weren't able to use it for AppleOS platforms. Xcode 11 finally brought us a complete integration and developers started to use SPM to integrate third party dependencies with iOS apps. Sorry that I have to say this, but currently [SPM is half-baked](https://apple.github.io/swift-evolution/#?search=package%20manager). We will only be able to ship binary dependencies and resources when Swift 5.3 will be released. In the beginning SPM was clearly designed to help boosting open source Swift packages, libraries and tools mostly on the server side.

Honestly I think this approach was quite a success, the project clearly had some issues in the beginning, but eventually SPM will become a de-facto tool for most of us. I'm quite sure that the authors are putting tremendous effort to make this project amazing and they need time to solve the hard parts under the hood (dependency resolution, etc.), so we (regular Swift developers) can integrate our projects with external packages in a pleasant way. 🙏

What do I miss from SPM? Well, I'd like to be able to update just one package in Xcode instead of refreshing the entire dependency tree. When you work with multiple dependencies this could take a while (especially when a dependency is quite big). Ok, ok, this is more like an Xcode feature, but here is another one: I'd like to be able to build and [distrubute dynamic libraries](https://bugs.swift.org/browse/SR-12303) via SPM. This way framework authors could provide a dynamic version that could be reused in multiple packages. I'm not the only one with this particular [issue](https://github.com/pointfreeco/swift-composable-architecture/issues/70). Please help us. 😢

## Swift packages for backend developers

Anyway, SPM is a great way to distribute Swift packages and I'm really glad that we have so many options to build a backend. Let me show you some of the most inspiring open source projects that you can use to develop your server application. Most of these libraries are backed by Apple, so they won't go anywhere, we can be sure that such a big organization will update and support them. Apple is using this stuff to build up the infrastructure for some cloud based platforms. ☁️

## SwiftNIO

[SwiftNIO](https://github.com/apple?q=swift-nio&type=&language=) is a cross-platform asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients. In other words it's an extremely performant low-level network framework that you can use to [build your own server or client](https://github.com/apple/swift-nio-examples) using a non-blocking approach.

> It's like Netty, but written for Swift.

You can find plenty of great tutorials, for example how to build [a text modifying server](https://rderik.com/blog/understanding-swiftnio-by-building-a-text-modifying-server/) or [a practical guide](https://www.raywenderlich.com/8016626-swiftnio-tutorial-practical-guide-for-asynchronous-problems) for asynchronous problems even about how to make a clone called ["microexpress"](https://www.alwaysrightinstitute.com/microexpress-nio/) of the famous [express](https://expressjs.com/) web framework from the [Node.js](https://nodejs.org/en/) world.

You'll also find great [documentation](https://apple.github.io/swift-nio/docs/current/NIO/index.html) about SwiftNIO, but I have to repeat myself, it is a very low level framework, so if don't have prior network programming experience maybe it's better to choose a high level framework such as [Vapor](https://vapor.codes/) or even a [CMS written in Swift](https://github.com/binarybirds/feather) to begin with.

## AsyncHTTPClient

If you are looking for a HTTP client library, the [AsyncHTTPClient](https://github.com/swift-server/async-http-client) package can be a great candidate. The framework uses a non-blocking asynchronous model for request methods, it can also follow redirects, supports streaming body download, TLS and cookie parsing.

## Swift AWS Lambda Runtime

A few months ago the [Swift AWS Lambda Runtime](https://github.com/swift-server/swift-aws-lambda-runtime/) package was [introduced](https://swift.org/blog/aws-lambda-runtime/) via the official Swift blog. If you want to develop serverless functions using the AWS Lambda service and the Swift programming language you have to take a closer look on this package. Fabian Fett wrote a great tutorial about [getting started with Swift on AWS Lambda](https://fabianfett.de/getting-started-with-swift-aws-lambda-runtime), also there is a WWDC20 session video about using [Swift on AWS Lambda with Xcode](https://developer.apple.com/videos/play/wwdc2020/10644/). Honestly I had no time to play with this library, because I was mostly focusing on my CMS, but I can't wait to go serverless using Swift. 🤔

## AWS SDK Swift

The [AWS SDK Swift](https://github.com/swift-aws/aws-sdk-swift) library provides access to all AWS services. The 5th major version is almost feature complete, Adam Fowler recently made a [blog post](https://opticalaberration.com/2020/08/aws-sdk-swift-v5-preview.html) about the latest changes. Personally I was using this package to store images on AWS S3 and it worked like a charm. The only downside of having such a huge library is that it takes a pretty long time for SPM to fetch it as a dependency (I was only using S3, but still I had to load the entire package). Anyway, if your infrastructure highly depends on Amazon Web Services and you have to access most of the available solutions through Swift, this is the framework that you should pick. 😎

## Swift Service Lifecycle

The [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) package is an elegant way to manage your server. It provides a basic mechanism to cleanly start up and shut down backend apps so you can free resources before exiting. It also provides a signal based shutdown hook, so you can listen to specific events.

For more info you should read the [introduction blog post](https://swift.org/blog/swift-service-lifecycle/) or the readme on GitHub.

## Swift Cluster Membership

Apple recently [introduced](https://swift.org/blog/swift-cluster-membership/) the [Swift Cluster Membership](https://github.com/apple/swift-cluster-membership) repository. Honestly I don't know much about the [SWIM protocol](https://research.cs.cornell.edu/projects/Quicksilver/public_pdfs/SWIM.pdf), but it seems like it's important of you want to build and manage a lifecycle of a distributed system. This library aims to help building clustered mutli-node environments with the help of Swift. For me, this is a completely new area, but I think it's definitely an interesting stuff and I want to learn a lot about more this in the future. 🤓

## Backtrace, Crypto, Metrics, Log and more...

Here are a few other libraries that you can utilize when you build a backend server using Swift.

The first one helps you to print a crash [backtrace](https://github.com/swift-server/swift-backtrace) when your app fails.

[Crypto](https://github.com/apple/swift-crypto) is a cross-platform Swift implementation of Apple's [CryptoKit framework](https://developer.apple.com/documentation/cryptokit). It is quite a young project announced by Cory Benfield at the dotSwift conference, but it the project already features most of the functionalities from CryptoKit.

If you have a server side or cross platform Swift application you might want to measure some of your code. The [Swift Metrics API](https://github.com/apple/swift-metrics) package is a great way to emit such records.

There is an offical [Logging API](https://github.com/apple/swift-log) package for Swift that you can use to persist log messages in files or simply print out various messages to the console using a standardized way.

In the beginning of the article I mentioned that SSWG has an incubation process for server related packages. If you have a specific need, it is always a good idea to check the [status of the currently available projects](https://swift.org/server/#projects) on the official Swift programming language website. 🔍

## Vapor

[Vapor](https://vapor.codes/) is the most popular web framework written in Swift. If you want to get started with Vapor 4 you should definitely take a look at my Practical Server Side Swift book, or you can use all the FREE resources on my blog. 

## The future of Swift (on the server)

As you can see the server side Swift infrastructure is evolving real quick. Swift is available on more and more platforms (Windows support is coming next), plus the language itself is on a good way and it has the potential to ["fulfill the prophecy"](https://oleb.net/blog/2017/06/chris-lattner-wwdc-swift-panel/). 🌎 💪 😅

Apart from the missing parts, such as the long awaited (pun intended) [async / await](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) feature, on the long term [Swift 6](https://forums.swift.org/t/on-the-road-to-swift-6/32862) is definitely going to be a huge milestone. Don't expect that this will happen anytime soon, we still need a 5.3 release before and who knows, maybe Swift 5.4 and more.

So back to the original question...

## Why choose Swift in 2020 as a backend language?

I know better: why choose Swift as your main language? Well, Swift is modern, fast and safe. It can run on many platforms and it has a great learning curve. Swift has a bright future not because of Apple, but because the huge community that loves (and sometimes hate) using it.

> NOTE: You don't need an expensive Apple device to start learning Swift. You can build your own apps using a PC with Linux. You can even get started using a small & cheap [Raspberry PI](https://lickability.com/blog/swift-on-raspberry-pi/), a [SwiftIO machine](https://www.madmachine.io/) or maybe this [online Swift playground](http://online.swiftplayground.run/) can do the job. 💡

I don't want to compare Swift to another languages, let's just say I think of it as a love child of JavaScript & C. I hope this analogy pretty much explains it (in a good way). 😂
