---
slug: what-are-the-best-practices-to-learn-ios-swift-in-2020
title: What are the best practices to learn iOS / Swift in 2020?
description: Are you learning iOS development? Looking for Swift best practices? This is the right place to start your journey as a mobile application developer.
publication: 2020-01-06 16:20:00
tags: Swift, iOS
---

## Hello Swift!

Learning a programming language is hard. Even after more than a decade of software developer experience I feel like that I'm only scratching the surface. I don't know much about low level assembly code, I don't know how to create 3D games using shaders and many more. Still we all learn something new every single day. It's a life-long journey and the path is full with obstacles, but if you keep going forward you'll find that there's gold at the end of the road. I still love to create new stuff from literally nothing but plain code. 😍

> Everyone can code

In the beginning it'll feel like that you have to learn a million things, but you shouldn't be afraid because time is your friend. Day-by-day you'll learn something new that'll help you moving forward to achieve your next goal. I believe that the most important thing here is to have fun. If you feel frustrated because you can't understand something just ask for help or take a break. The Swift community a group of amazing people, everybody is really helpful, so if you choose this programming language to bring your ideas to life you'll meet some great people.

Now let me show you what you'll need to start your career as a Swift application developer. 👨‍💻

## Hardware

The first thing you'll need to start your Apple developer career is a Mac. Unfortunately Mac's are quite expensive machines nowadays, also the current series of MacBooks (both Air's and Pro's) have the completely broken butterfly keyboard mechanism. Hopefully this will change real soon.

I'd say that you should go with pre-butterfly models, you can look for the secondary market if you want to have a cheap deal. Otherwise you can go with a Mac mini, but if you buy one you should think about the extra expenses such as the monitor, keyboard & mouse.

If you have unlimited money, you should go with some high-end device like the new MacBook Pro 16", iMac Pro or simply buy a Mac Pro. Nevertheless you should always choose a machine with an SSD. It's kind of a shame that in 2020 a base iMac comes with a ridiculously slow HDD.

Another option is to build a hackintosh, but IMHO that's the worst that you can do. You won't get the same experience, plus you will struggle a lot fighting the system.

> NOTE: You might heard rumors that you're going to be just fine with an iPad & Swift playgrounds. Honestly that's just not the case. You can play around and learn the Swift programming language even with a Linux machine, but if you want to make your own iOS / iPadOS / macOS / watchOS apps, you'll need a Mac for sure.

## Software

So you've got a decent Mac. Let's see what kind of software will you need if you want to start developing iOS apps. You might heard that Apple's operating system is macOS. First of all, if you never used a mac before, you should get familiar with the system itself. When I bought my very first MacBook Pro, it took me about a week to get used to all the apps, system shortcuts and everything else.

If you don't want to figure out everything for yourself, you came to the right place. Let me walk you through of every single app, tool that I'm using to my work as a professional mobile / backend developer.

### Terminal

The most important thing that you should get used to is the Terminal (console) application. If you never heard about terminals before you should simply look for a beginner's guide tutorial, but I highly recommend to learn at least the really basic commands.

### Brew & cask

The very first thing that you should install on your new Mac is [Homebrew](https://brew.sh/). If you have used Linux before, might find this tool familiar (it's working on Linux too). According to [Max Howell](https://x.com/mxcl) (the creator):

> The Missing Package Manager for macOS (or Linux)

You can also install regular applications with brew, by using the cask subcommand. e.g:

```
brew cask install firefox
```

I prefer to create a list of tools that I'm always using, so when I reinstall my machine I simply copy & paste those commands into terminal and I'm more or less ready with the restoration process. This is extremely convenient if you have to reinstall macOS from scratch.

### MAS

You might noticed that I've got a thing for Terminal. If you don't like the interface of the App Store, you can install [MAS](https://github.com/mas-cli/mas), a little helper tool. With the help of it you can install everything available in the store by using Terminal commands.

The readme on GitHub is really good, you should read it carefully. Anyway you don't necessary need the mas-cli to do iOS development, but since it's really convenient, I'd recommend to check it out.

### Xcode

The number one tool that you'll definitely need is [Xcode](https://developer.apple.com/xcode/). There is an alternative IDE tool called [AppCode](https://www.jetbrains.com/objc/), but it's always lagging behind and the vast majority of the community prefers Xcode. 🔨

A new Xcode version is released every single year with brand new features and functionalities. I'd recommend to go with the most recent one (also you should always upgrade your existing projects to support the latest version). You can get Xcode from the App Store, it's completely free.

It'll take a lot of time to install Xcode on your machine, but don't worry after a few hours it'll be ready to help you writing your very first iOS application. So be patient. :)

### Git

> Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

Every single developer should use a [proper version control system](https://en.wikipedia.org/wiki/Version_control) (aka. [Git](https://git-scm.com/)). Git is the de facto standard tool for version control and you can [learn the basics](https://try.github.io/levels/1/challenges/1) in just about 15 minutes. Of course mastering it will take much longer, but it's totally worth to start playing around with it.

### GitHub

> GitHub is a web-based hosting service for version control using git.

To be honest, [GitHub](https://github.com/) it's not just a repository hosting service anymore, it's a complete platform with tools for issue management, project planning, continuous integration support and many more.

GitHub offers you a free tier both for public and private Git repositories for individuals. In 2019 it was acquired by Microsoft (everyone was afraid of this change, since MS has some history about ruining good services), but until for now they introduced lots of amazing new features. Go and get your free account now!

## iOS app development using Swift

I believe that Swift has evolved to a stable & mature language during the past 5 years. If you think about it, it's the only good option to write future proof iOS apps. You should clearly forget Objective-C, since Apple already made his choice. Eventually Swift will be the only programming language that Apple supports, there are already some frameworks that are Swift "only". Just take a look at on [SwiftUI](https://developer.apple.com/xcode/swiftui/). I mean you can't write SwiftUI views in Objective-C, although the framework is 100% compatible with Objective-C based projects.

### Dependency management

At some point in time you don't want to write everything by yourself, because you'd like to make progress fast. This is where external packages are coming into the picture. Take my advice:

> Never connect 3rd-party libraries by hand

The Swift Package Manager is natively integrated into Xcode. In the past [CocoaPods](https://cocoapods.org/) was the ultimate dependency manager (some people preferred [Carthage](https://github.com/Carthage/Carthage)) for iOS projects, but nowadays it's way better to use [SPM](https://swift.org/package-manager/). If you need to integrate external libraries SwiftPM is the right choice in 2020. If you don't know how it works, you should read my comprehensive tutorial about how to use the Swift Package Manager.

I also made a quite popular article about the best / most popular [iOS libraries written in Swift](https://theswiftdev.com/2019/02/25/top-20-ios-libraries-of-2019/) last year. It was featured on Sean Allen's ([Swift News](https://www.youtube.com/seanallen)) YouTube channel. Unfortunately he stopped that show, but he is still making some really good videos, so you should definitely check his channel if you have some time.

Anyway, if you don't know where to start and what to integrate into your Swift project you should go and read my blog post, since it's still up-to-date. Fortunately these things are not changing that often.

### Application architecture

Picking the right architecture for your upcoming iOS project is one of the hardest things. The other one is building up your user interface, but let's keep that topic for another day. You should never be afraid of architectures. Even if you choose MVC, MVP, MVVM or VIPER you can have a really well-written application strucutre. This is really important, because you don't want to make your future self angry with some 2000+ lines [sphagetti coded](https://en.wikipedia.org/wiki/Spaghetti_code) view controller with some nasty side effects.

So how you should pick an architecture? Since there a lots of them, you can even come up with a [random one](https://iosarchitecture.top/). Well, this is a real debate amongst iOS developers. My favorite one is [VIPER](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/), though I get a lot of criticism because of this. Honestly I really don't give a damn about this, because it works for me (and my teams). Whether you go with plain old MVC it really doesn't matters until it can solve your issue.

If you are a completely beginner please don't start with VIPER, unless you can have someone by your side who can answer all your questions. My advice here is just to simply sit down and think through what do you want to achieve and make a basic plan. Of course it helps a lot if you are familiar with the patterns, but in the end of the day, you'll realize that all of them are made by humans and none of them is perfect. 🤔

### Conventions for Xcode

I made some really basic [conventions for Xcode](https://theswiftdev.com/2016/07/06/conventions-for-xcode/) that you should check if you don't know how to organize your projects. If you are not familiar with Xcode formats, targets, schemes, you should search the internet for such a tutorial, there are some well-explained examples about the entire thing.

### Use folders to represent groups in Xcode

You know just like in real life, you don't throw all your clothes into the shelf, right?. Being well organized is the only way to create a good project. Fortunately Apple realized this as well, and now groups are represented as physical folders on your hard drive by default.

### Always try to fix every single warning

There is a reason that warnings exists, but you should never leave any of them in your production code. If you want to be more radical, there is a build flag in Xcode to [treat warnings as errors](http://iosdevelopertips.com/xcode/treat-warnings-as-errors.html). TURN IT ON! Kill all warnings! Haha, don't do that, but you should always try to fix all your warnings.

### Don't let your code to grow on you

You know that awkward situation, when you open a source file, and you start scrolling, scrolling and you have to do even more scrolling. Yep, usually that's a massive view controller problem and you already know that you are lost forever. If you get to this point, you can try to refactor your code by introducing a new object that can take over some of the functionality from your controller class.

### Do not reinvent the wheel

If there is a best practice, use that. You should always look up the problem before you start coding. You should also think through the problem carefully before you start coding. Remember: you are not alone with your coding issues, I can almost guarantee that someone already had the exact same issue that you are working on. [StackOverflow](https://stackoverflow.com/questions/tagged/swift) is the right place to look for solutions. Use the power of the community, don't be afraid to ask questions on the internet, or from your co-workers, but don't expect that others will solve your problem, that's your job.

## Swift advices for beginners

In this section I'm going to give you some real quick advices about how to write proper Swift code. I know I can't have everything in this list, but in my opinion these are some really important ones.

### Learn how to write proper async code

Look, if you know what is the "Great" [Pyramid of Doom](http://www.thomashanning.com/the-pyramid-of-doom/), you'll know what I'm talking about. You're going to write async code eventually, most of the API's have async methods. Even a simple networking task is asynchrounous. It's a smart move to learn how to write proper async code from the beginning.

### There are a few approaches that you can choose from.

Of course you can go old-school by using completion blocks. That's a good way of learning the concept and you can practice a lot, but there are way better options to write good async code in 2020.

Promises are high level abstractions over async tasks, they'll make your life SO MUCH BETTER. You the real power comes from the fact that you can chain & transform them using functional methods. Promises are amazing, but they don't really have built-in support for cancellation.

You can go with NSOperation tasks as well, but if you'd like to have some syntax sugar I'd recommend Promises. My problem is that if you have to [pass data between operations](https://nickharris.wordpress.com/2016/02/09/cloudkit-core-data-nsoperations-introduction/) you'll have to create a new operation to do it, but in exchange of this little inconvenience they can run on queues, they can have priorities and dependencies.

I believe that the brand new Combine framework is the best way to deal with async code in 2020.

### Only use singletons if necessary

They are the root of all evil. Honestly, avoid singletons as much as you can. If you want to deal with mixed-up states & untestable code, just go with them, but your life will be better if you take my advice. If you don't know [how to avoid the singleton pattern](https://www.objc.io/issues/13-architecture/singletons/) please do some research. There are lots of great articles on the net about this topic.

One exception: you can use a singleton if you are especially looking for shared states, like cache mechanisms or a local storage object like UserDefaults. Otherwise don't use a singleton.

### Do not create helpers (or managers)

If you need a helper class, you are doing things wrong! Every single object has it's own place in your codebase, helpers are useless & not good for anything. Rethink, redefine, refactor if you need, but avoid helper classes at all cost. Learn about [Swift design patterns](https://github.com/ochococo/Design-Patterns-In-Swift) or draw a chart about your models, but trust me there is no place for helpers in your code.

### Avoid side effects & global state

Using globals is a really bad practice. Eventually some part of your code will override the global property and things are going to be pretty messed up. You can avoid side effects by simply eliminating those global variables. Also going functional is a neat way to improve your code.

### Write some tests

You should always write tests, I'm not saying that you should go with [TDD](https://en.wikipedia.org/wiki/Test-driven_development), but unit tests are good practice. They'll help you to think through the possible mistakes and they validate your codebase. Also UI tests are good for validating the user interface, plus you can save countless hours if you don't have to run manual tests.

## Non-technical skills

I know it's quite a list. Don't be afraid, you don't have to learn everything at once. Beginning your iOS career is not just all about learning new stuff, but you should have fun on the road. 😊

### Time

Be patient & consistent. Always dedicate a fixed amount of time per day to code. It really doesn't matters if it's just half an hour, if you do it every day you'll form a habit and the numbers will sum up as well. In this busy world, it's really hard to find some time to really focus on something, but if you really want to learn how to write Swift code, this is the most important step that you need to take.

### Motivation

Being motivated is easy if you have a "dream". Do you want to build an app? Do you want to learn how to write something in Swift? Do you want to have a better job? Do you want to make a game for your kids? All of these things can be great motivators. The problem starts when you constantly hit the obstacles.

Don't be afraid! Being a programmer means that sometimes you just try & fail. If you want to be a real good developer you should learn from those mistakes and do better on the second time. Of course you'll learn a lot from other people as well, but sometimes you have to solve your own problems.

### Goals

Don't try to aim for one really big goal. Celebrate the little success stories and achievements. You should also be proud of what you've done "today". It's easy to forget to remember these little things, but making an app or learning a new programming language is a long-term project. If you don't have your small moments that you can celebrate eventually you will lose motivation and interest for the "project".

I think these three things are the most important non-technical skills if you want to learn Swift. Have your very own dedicated time to code every single day. Gain motivation from your dream (follow the big picture), but also celebrate every little success story that you achieved. Go step-by-step and you'll find that there is nothing that you can't learn. Anyway, technical skills are just secondary... 🤷‍♂️

## The Swift community is amazing

It's really good to see that there are still plenty of dedicated people who are keeping up writing about the good and bad parts of iOS / Swift development. Here are the best resources that you should know in 2020.

### Best iOS / Swift tutorial sites

- [Ray Wenderlich](https://www.raywenderlich.com/)
- [nshipster.com](https://nshipster.com/)
- [objc.io](https://www.objc.io/blog/)
- [AppCoda](https://www.appcoda.com/)
- [pointfree.co](https://www.pointfree.co/)

### Best iOS / Swift blogs

- [Paul Hudson](https://hackingwithswift.com/)
- [John Sundell](https://www.swiftbysundell.com/)
- [Antoine van der Lee](https://www.avanderlee.com/)
- [Vadim Bulavin](https://www.vadimbulavin.com/)
- [Keith Harrison](https://useyourloaf.com/)
- [Majid Jabrayilov](https://swiftwithmajid.com/)
- [Bart Jacobs](https://cocoacasts.com/)
- [Soroush Khanlou](http://khanlou.com/)
- [Erica Sadun](https://ericasadun.com/)
- [Andrew Bancroft](https://www.andrewcbancroft.com/)

### Best iOS / Swift newsletters

- [iOS Goodies](http://ios-goodies.com/)
- [iOS Dev Weekly](https://iosdevweekly.com/)
- [Swift Developments](https://andybargh.com/swiftdevelopments/)
- [Indie iOS focus weekly](http://indieiosfocus.com/)

### Best iOS / Swift podcasts

- [iOS Dev Discussions](https://podcasts.apple.com/us/podcast/ios-dev-discussions-sean-allen/id1426167395)
- [Swift over Coffee](https://podcasts.apple.com/us/podcast/swift-over-coffee/id1435076502)
- [Swift by Sundell](https://swiftbysundell.com/podcast/)
- [iPhreaks](https://devchat.tv/iphreaks/)

### Twitter accounts to follow

- [Ankit Aggarwal](https://x.com/aciidb0mb3r)
- [Harlan Haskins](https://x.com/harlanhaskins)
- [Nate Cook](https://x.com/nnnnnnnn)
- [Slava Pestov](https://x.com/slava_pestov)
- [Ted Kremenek](https://x.com/tkremenek)
- [JP Simard](https://x.com/simjp)
- [Daniel Dunbar](https://x.com/daniel_dunbar)
- [Doug Gregor](https://x.com/dgregor79)
- [Joe Groff](https://x.com/jckarter)
- [Ben Cohen](https://x.com/AirspeedSwift)
- [Tanner Wayne Nelson](https://x.com/tanner0101)
- [Ash Furrow](https://x.com/ashfurrow)
- [Ole Begemann](https://x.com/olebegemann)
- [Bart Jacobs](https://x.com/_bartjacobs)
- [Dave Verwer](https://x.com/daveverwer)
- [Ray Wenderlich](https://x.com/rwenderlich)
- [objc.io](https://x.com/objcio)
- [NSHipster](https://x.com/NSHipster)
- [Krzysztof Zabłocki](https://x.com/merowing_)
- [Marcin Krzyzanowski](https://x.com/krzyzanowskim)
- [Peter Steinberger](https://x.com/steipete)
- [Chris Eidhof](https://x.com/chriseidhof)
- [soroush](https://x.com/khanlou)
- [ericasadun](https://x.com/ericasadun)
- [Chris Lattner](https://x.com/clattner_llvm)
- [John Siracusa](https://x.com/siracusa)
- [Sean Allen](https://x.com/seanallen_dev)
- [Marco Arment](https://x.com/marcoarment)
- [Paul Hudson](https://x.com/twostraws)
- [John Sundell](https://x.com/johnsundell)

## Where to go next?

In the past year I've interviewed lots of iOS developer candidates. Absolute beginners are always asking me the same question again and again: where should I go next, what should I learn next?

There is no definite answer, but this year I'm trying help you a lot. This is the very first year when I'll dedicate more time on my blog than on anything else. No more new client projects, no more excuses.
