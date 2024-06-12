---
slug: swift-delegate-design-pattern
title: Swift delegate design pattern
description: The delegate design pattern is a relatively easy way to communicate between two objects through a common interface, protocol in Swift.
publication: 2018-06-27 16:20:00
tags: Swift, iOS, design patterns
---

## Implementing delegation in Swift

You'll need a delegate protocol, a [delegator](https://blog.bobthedeveloper.io/the-meaning-of-delegate-in-swift-347eaa9674d) who actually delegates out the tasks and a delegate object that implements the delegate protocol and does the actual work that was requested by the "boss". Let's translate this into human.

> The client reports a bug. The project manager creates an issue and tells one of the developers to fix the problem asap.

See? That's [delegation](http://www.andrewcbancroft.com/2015/03/26/what-is-delegation-a-swift-developers-guide/). At some point an event happened, so the delegator (manager) utilized an external resource (a developer) using a common interface (issue describing the problem for both party) to do achieve something (fix the 🐛).

To demonstrate [how delegation works](https://www.andrewcbancroft.com/2015/04/08/how-delegation-works-a-swift-developer-guide/) in real life I made a pretty simple example. I'm going to use a similar approach (because Xcode playgrounds are still freezing every 1-5 minutes) like I did for [the command pattern](https://theswiftdev.com/2018/06/13/swift-command-design-pattern/), but the purpose of this one is going to be almost entirely different, because we're talking about delegation. 😅

```swift
#!/usr/bin/env swift

import Foundation


protocol InputDelegate {

    var shouldContinueListening: Bool { get }

    func didStartListening()
    func didReceive(input: String)
}


class InputHandler {

    var delegate: InputDelegate?

    func listen() {
        self.delegate?.didStartListening()

        repeat {
            guard let input = readLine() else {
                continue
            }
            self.delegate?.didReceive(input: input)
        }
        while self.delegate?.shouldContinueListening ?? false
    }
}


struct InputReceiver: InputDelegate {

    var shouldContinueListening: Bool {
        return true
    }

    func didStartListening() {
        print("👻 Please be nice and say \"hi\", if you want to leave just tell me \"bye\":")
    }

    func didReceive(input: String) {
        switch input {
        case "hi":
            print("🌎 Hello world!")
        case "bye":
            print("👋 Bye!")
            exit(0)
        default:
            print("🔍 Command not found! Please try again:")
        }
    }
}

let inputHandler = InputHandler()
let inputReceiver = InputReceiver()
inputHandler.delegate = inputReceiver
inputHandler.listen()
```

This is how you can create your own [delegate pattern in Swift](https://www.appcoda.com/swift-delegate/). You can imagine that Apple is doing the same thing under the hood, with `UICollectionViewDataSource`, `UICollectionViewDelegate` etc. You only have to implement the delegate, they'll provide the protocol and the delegator. 🤔

## Weak properties, delegates and classes

Memory management is a very important thing so it's worth to mention that all the class delegates should be weak properties, or you'll create a really bad retain cycle. 😱

```swift
protocol InputDelegate: class { /*...*/ }

class InputHandler {

    weak var delegate: InputDelegate?

    /*...*/
}

class InputReceiver: InputDelegate {
    /*...*/
}
```

Here is the altered Swift code snippet, but now using a class as the delegate. You just have to change your protocol a little bit and the property inside the delegator. Always use weak delegate variables if you are going to assign a class as a delegate. ⚠️

As you can see delegation is pretty easy, but it can be dangerous. It helps decoupling by providing a common interface that can be used by anyone who implements the delegate (sometimes data source) protocol. There are really amazing articles about delegates, if you'd like to know more about this pattern, you should check them out.
