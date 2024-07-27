---
type: post
slug: how-to-make-a-swift-framework
title: How to make a Swift framework?
description: Creating a Swift framework shouldn't be hard. This tutorial will help you making a universal framework for complex projects.
publication: 2017-10-23 16:20:00
tags: Swift
authors:
  - tibor-bodecs
---

## What is a framework?

A [framework](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html) is a hierarchical directory that encapsulates shared resources, such as a dynamic shared library, nib files, image files, localized strings, header files, and reference documentation in a single package.

> So in a nutshell, a framework is a highly reusable component for your apps.

## How to make it?

There is an article about [Xcode conventions](https://theswiftdev.com/2016/07/06/conventions-for-xcode/) which will help you organize your projects, you should check that first, if you haven't before.

### Traditional way

There is a traditional way to [make a framework](https://www.raywenderlich.com/126365/ios-frameworks-tutorial) in Xcode. I'm going to create a [shared framework](http://ilya.puchka.me/xcode-cross-platform-frameworks/) for all the apple platforms (iOS, macOS, tvOS, watchOS), which is going to be capable of logging things to the standard console.

Let's make the project:

- Create a new project using one of the framework targets
- Follow the instructions fill & name all the fields
- Add all the other platform framework targets
- Rename all targets according to the platform names

Now in Finder:

- Create a Sources folder and move all the Swift and header files there
- Create an Assets folder with platforms subfolders
- Move all the Info.plist files into the correct platfrom subdirectory
- Create a Tests folder and move test files there

Back to Xcode:

- Remove every group and add the new Folders from Finder
- Check that every target has the correct files (framework & tests)
- Inside the header file, replace UIKit depencency with Foundation

The goal is to achieve a structure somewhat like this:

![Xcode project framework setup](xcode-project-framework-setup.png)


Project settings:

- Select the correct plist files for the targets
- Set your bundle identifiers (use my conventions)
- Setup platform versions (advice: support 1 older version too)
- Setup the plist files for the tests from the build settings pane
- Set the product name (Console) in your framework build settings
- Check your build phases and add the public header file.

Scheme settings:

- Go to the scheme settings and setup shared schemes for the frameworks
- Gather coverage data if you need it
- Write your framework you can use Swift "macros" to detect platforms

> NOTE: There is a flag in Xcode to allow app extension API only, if you are embedding your framework inside an application extension it should be enabled!

Congratulations, now you have your brand new Swift framework made in the traditional way. Let's continue with a neat trick.

## Universal cross platform framework

It is possible to create a multiplatform single scheme Xcode project with cross platform support for every platform, but it's not recommended because it's a hack. However multiple open source libraries do the same way, so why shouldn't we.

- Delete all the targets, schemes, except macOS!!!
- Rename the remaining target, scheme (we don't need platform names)
- Use the project configuration file, set the xcconfig on the project
- Delete Info.plist files, use one for the framework and one for the tests
- Rename bundle identifier (we don't need platform names there too)

> WARN: States can be mixed up if you are building for multiple platforms, however this is a nice clean way to support every platforms, without duplications.

## How to use a Swift framework?

Embedding your framework is the most straightforward thing to do. You can simply drag the framework project to another Xcode project, the only thing left to do is to the embedded the framework into the application. You can go to the embedded binaries section inside the general project info tab and add the framework as a dependency.

### Swift Package Manager

With [SPM](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/), you have to make a Package.swift file first, then you'll be able to build your targets with the swift build command. Now that Xcode supports the Swift Package Manager, it's really easy to integrate third party frameworks by using it.

You can download the final framework examples from [GitHub](https://github.com/theswiftdev/tutorials).

Make sure that you don't miss out my [deep dive into swift frameworks](https://theswiftdev.com/2018/01/25/deep-dive-into-swift-frameworks/) post.

