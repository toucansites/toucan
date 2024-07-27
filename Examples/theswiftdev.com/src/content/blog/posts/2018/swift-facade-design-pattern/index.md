---
type: post
slug: swift-facade-design-pattern
title: Swift facade design pattern
description: The facade design pattern is a simplified interface over a complex subsystem. Let me show you a real quick example using Swift.
publication: 2018-09-25 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

## What is a facade?

The name of the [facade](https://medium.com/swiftworld/swift-world-design-patterns-facade-579ef4b3319f) pattern comes from real life building [architecture](https://en.wikipedia.org/wiki/Facade).

> one exterior side of a building, usually the front

In software development this definition can be translated to something like everything that's outside, hiding all the internal parts. So the main purpose of a [facade](https://medium.com/ios-development-tips-and-tricks/design-patterns-with-swift-facade-pattern-f3afc65a1e19) is to provide a beautiful API over some more complex ugly ones. 😅

Usually the facade design pattern comes handy if you have two or more separate subsystems that needs to work together in order to accomplish some kind of tasks. It can hide the underlying complexity, plus if anything changes inside the hidden methods, the interface of the facade can still remain the same. 👍

## A real-life facade pattern example

I promised a quick demo, so let's imagine an application with a toggle button that turns on or off a specific settings. If the user taps it, we change the underlying settings value in the default storage, plus we also want to play a sound as an extra feedback for the given input. That's three different things grouped together. 🎶

```swift
func toggleSettings() {
    // change underlying settings value
    let settingsKey = "my-settings"

    let originalValue = UserDefaults.standard.bool(forKey: settingsKey)
    let newValue = !originalValue

    UserDefaults.standard.set(newValue, forKey: settingsKey)
    UserDefaults.standard.synchronize()

    // positive feedback sound
    AudioServicesPlaySystemSound(1054);

    // update UI
    self.switchButton.setOn(newValue, animated: true)
}
```

Congratulations, we've just created the most simple facade! If this code seems familiar to you, that means you already have utilized facades in your past.

Of course things can be more complicated, for example if you have a web service and you need to upload some data and an attachment file, you can also write a facade to hide the underlying complexity of the subsystems.

Facades are really easy to create, sometimes you won't even notice that you are using one, but they can be extremely helpful to hide, decouple or simplify things. If you want to [learn more about them](https://www.appcoda.com/design-pattern-structural/), please check the linked [articles](https://rubygarage.org/blog/swift-design-patterns). 😉
