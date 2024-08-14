---
type: post
title: Swift 5 and ABI stability
description: Apple's Swift 5 language version will be a huge milestone for the developer community, let's see what are the possible benefits of it.
publication: 2018-11-16 16:20:00
tags: 
    - swift
    - tooling
authors:
    - tibor-bodecs
---

## ABI stability

Everyone talks about that [Swift 5](https://developerinsider.co/what-will-be-new-in-swift-5/) is will have a [stable Application Binary Interface](https://swift.org/abi-stability/), but what exactly is this mysterious ABI thing that's so important for Swift devs?.

> ABI is an interface between two binary program modules.

You can read a well-written definition of ABI on [Wikipedia](https://en.wikipedia.org/wiki/Application_binary_interface) or you can get a brief technical explanation through this [reddit thread](https://www.reddit.com/r/swift/comments/67z7dy/what_is_abi_stability_and_why_does_it_matter/), but I'm trying to translate the core concepts of the Application Binary Interface to human language. 🤖

[ABI](https://medium.com/swift-india/swift-5-abi-stability-769ccb986d79) is literally a binary communication interface for applications. Just like an API (application programming interface for devs = what was the name of that function?), ABI is a set of rules, so apps and program components like frameworks or libraries can speak the same "binary language", so they can communicate with each other. 😅

The ABI usually covers the following things:

- CPU instructions (registers, stack organization, memory access type)
- sizes, layouts and alignments of data types
- calling convention (how to call functions, pass arguments, return values)
- system calls to the OS

So just like with APIs if you change something for example the name of a given method - or a size of a data type if we talk about ABIs - your older API clients will break. This is the exact same case here, older Swift versions are incompatible because the underlying changes in the ABI & API. So to make things work the proper version of Swift dynamic library has to be embedded into your bundle. That means bigger app sizes, but all the apps can run even with different Swift versions. 🤐

As you can see these are pretty nasty low level stuff, usually you don't have to worry about any of these details, but it's always good to know what the heck is an ABI in general. Maybe you'll need this knowledge in one day. 👍

## Integrated into the core of the OS

When a language is ABI-stable, that means it can be packaged and linked directly into the operating system itself. Currently if you build a Swift application a Swift dynamic library is going to be embedded to that bundle, in order to support your specific Swift version. This leads to bigger app sizes, and version incompatibility issues. After Swift is going to be an ABI stable language there is no need to package the dylib into apps, so Swift will have a smaller footprint on the system, also you can benefit from the OS provided under-the-hood improvements. 😎

## Swift version compatibility

Another big win is version compatiblity. In the past if you had a project that was written in Swift N it was a real pain-in-the-ass to upgrade it to N+1. Especially applies to Swift 2 > Swift 3 migrations. In the future after both the ABI & API are going to be stabilized, you won't need to upgrade (that much) at all. You can already see this happening, Swift 3 to Swift 4 was a much more easy step than the horrible one I mentioned above. After Swift 5, we can hope that everything is going to be backward compatible, so devs can focus on real tasks instead of migrations. 🙏

## Closed-source Swift packages

Developers will be able to create closed source 3rd-party libraries written in Swift and distribute them as pre-compiled frameworks. This one is a HUGE one, because until the ABI stable version of Swift arrives, this is only possible with Objective-C. 🦕

Framework authors can ship the pre-compiled binaries instead of source files, so if you have to integrate multiple external dependencies into your project, clean build times can be significantly faster. This is also a nice advantage, but let's talk about my personal favorite... 😎

## SPM support for appleOS & Xcode

If the Swift language will be part of the core operating system, Apple should definitely provide Swift Package Manager support both for iOS, macOS, tvOS and watchOS. It would be a logical step forward and I can see some signs that points into this direction. Please Apple give the people what they want and sherlock CocoaPods once and for all. The iOS developer community will be a better place without Podfiles. 😅

Xcode should gain a deeply intergrated support for Swift Package Manager. Also it'd be nice to have a package discovery / search option, even it is centralized & controlled by Apple. It'd be truely amazing to have a neat UI to search for packages & integrate them just with one click to my iOS project. Works like magic! 💫
