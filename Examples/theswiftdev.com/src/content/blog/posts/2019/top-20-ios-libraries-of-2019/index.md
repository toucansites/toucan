---
type: post
title: Top 20 iOS libraries written in Swift
description: I gathered the best open source Swift frameworks on github that will help you to speed up mobile application development in 2019.
publication: 2017-10-10 16:20:00
tags: 
    - uikit
    - ios
authors:
    - tibor-bodecs
---

Sometimes it's just better to use a 3rd-party framework instead of reinventing the wheel, but there are some important questions that you should ask first:

- do I really need a library?
- what should I use?
- is it going to be supported?
- what if it's buggy? 🐛

Adding a dependency to your project can also lead to a [technical debt](https://en.wikipedia.org/wiki/Technical_debt). Don't be lazy, learn the underlying technology first (or at least read about it or ask someone who actually knows about it) and if you're sure that the framework is a good choice, then give it a chance. In this list I've tried to collect future proof, trusted and well-known iOS libraries used by most of the developer community. ⭐️

## Selection criteria:

- the framework has to be written in Swift
- the library should not be design specific (there is [cocoacontrols](https://www.cocoacontrols.com/) for that)
- it should be a runtime framework not a toolkit (aka. import XY)
- should have some package manager support (Carthage, CocoaPods, SPM)
- it has to support the latest major version of Swift
- must have at least 1000 stars on GitHub

## 🌎 Network related libraries

Connecting to...

### [Alamofire](https://github.com/Alamofire/Alamofire)

Alamofire is an HTTP networking library written in Swift.

### [Kingfisher](https://github.com/onevcat/Kingfisher)

Kingfisher is a powerful, pure-Swift library for downloading and caching images from the web. It provides you a chance to use a pure-Swift way to work with remote images in your next app.

### [Starscream](https://github.com/daltoniam/Starscream)

Starscream is a conforming WebSocket ([RFC 6455](http://tools.ietf.org/html/rfc6455)) client library in Swift.

## 📦 Server side Swift

Listening...

### [Vapor](https://github.com/vapor/vapor)

Vapor is a web framework for Swift. It provides a beautifully expressive and easy to use foundation for your next website, API, or cloud project.

### [SwiftNIO](https://github.com/apple/swift-nio)

SwiftNIO is a cross-platform asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients.

## 🔨 Reactive Programming

Streams, observers, etc...

### [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)

ReactiveSwift offers composable, declarative and flexible primitives that are built around the grand concept of streams of values over time. These primitives can be used to uniformly represent common Cocoa and generic programming patterns that are fundamentally an act of observation.

### [RxSwift](https://github.com/ReactiveX/RxSwift)

Rx is a [generic abstraction of computation](https://youtu.be/looJcaeboBY) expressed through `Observable<Element>` interface. This is a Swift version of [Rx](https://github.com/Reactive-Extensions/Rx.NET).

## 🦋 Animation

UIView.animated...

### [Hero](https://github.com/HeroTransitions/Hero)

Hero is a library for building iOS view controller transitions. It provides a declarative layer on top of the UIKit's cumbersome transition APIs—making custom transitions an easy task for developers.

### [Spring](https://github.com/MengTo/Spring)

A library to simplify iOS animations in Swift.

## 📐 Auto layout helpers

Anchors vs...

### [SnapKit](https://github.com/SnapKit/SnapKit)

SnapKit is a DSL to make Auto Layout easy on both iOS and OS X.

### [TinyConstraints](https://github.com/roberthein/TinyConstraints)

TinyConstraints is the syntactic sugar that makes Auto Layout sweeter for human use.

## ❌ Testing

TDD FTW...

### [Quick](https://github.com/Quick/Quick)

Quick is a behavior-driven development framework for Swift and Objective-C. Inspired by [RSpec](https://github.com/rspec/rspec), [Specta](https://github.com/specta/specta), and [Ginkgo](https://github.com/onsi/ginkgo).

### [Nimble](https://github.com/Quick/Nimble)

Use Nimble to express the expected outcomes of Swift or Objective-C expressions. Inspired by [Cedar](https://github.com/pivotal/cedar).

## ⚙️ Utilities

Did I miss something?

### [PromiseKit](https://github.com/mxcl/PromiseKit)

PromiseKit is a thoughtful and complete implementation of promises for any platform that has a swiftc.

### [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)

CryptoSwift is a growing collection of standard and secure cryptographic algorithms implemented in Swift.

### [SwiftDate](https://github.com/malcommac/SwiftDate)

SwiftDate is the definitive toolchain to manipulate and display dates and time zones on all Apple platform and even on Linux and Swift Server Side frameworks like Vapor or Kitura.

### [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)

Convenient logging during development & release in Swift 2, 3 & 4

### [Swinject](https://github.com/Swinject/Swinject)

Swinject is a lightweight [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) framework for Swift.

### [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

SwiftyJSON makes it easy to deal with JSON data in Swift.

If you are looking for more Swift libraries you can always explore the top Swift repositories on [GitHub](https://github.com/topics/swift), and please remember: always connect your dependencies through a package manager. 😉
