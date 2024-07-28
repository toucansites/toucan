---
type: post
slug: lazy-initialization-in-swift
title: Lazy initialization in Swift
description: Learn how to use lazy properties in Swift to improve performance, avoid optionals or just to make the init process more clean.
publication: 2018-12-17 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

According to [Wikipedia](https://en.wikipedia.org/wiki/Lazy_initialization):

> In computer programming, lazy initialization is the tactic of delaying the creation of an object, the calculation of a value, or some other expensive process until the first time it is needed.

That little quote pretty much sums up everything, however because we're working with the Swift programming language, we have a thing called [optionals](https://developer.apple.com/documentation/swift/optional). If you don't know what are those, please read [the linked articles](https://hackernoon.com/swift-optionals-explained-simply-e109a4297298) first, and come back afterwards. 🤐

## The ultimate guide of being lazy

When a [property](https://docs.swift.org/swift-book/LanguageGuide/Properties.html) is only needed at some point in time, you can prefix it with the lazy keyword so it'll be "excluded" from the initialization process and it's default value will be assigned on-demand. This can be useful for types that are expensive to create, or needs more time to be created. Here is a quick tale of a lazy princess. 👸💤

```swift
class SleepingBeauty {

    init() {
        print("zzz...sleeping...")
        sleep(2)
        print("sleeping beauty is ready!")
    }
}

class Castle {

    var princess = SleepingBeauty()

    init() {
        print("castle is ready!")
    }
}

print("a new castle...")
let castle = Castle()
```

The output of this code snippet is something like below, but as you can see the princess is sleeping for a very long time, she is also "blocking" the castle. 🏰

```
a new castle...
zzz...sleeping...
sleeping beauty is ready!
castle is ready!
```

Now, we can speed things up by adding the lazy keword, so our hero will have time to slay the dragon and our princess can sleep in her bed until she's needed... 🐉 🗡 🤴

```swift
class SleepingBeauty {

    init() {
        print("zzz...sleeping...")
        sleep(2)
        print("sleeping beauty is ready!")
    }
}

class Castle {

    lazy var princess = SleepingBeauty()

    init() {
        print("castle is ready!")
    }
}

print("a new castle...")
let castle = Castle()
castle.princess
```

Much better! Now the castle is instantly ready for the battle, so the prince can wake up his loved one and... they lived happily ever after. End of story. 👸 ❤️ 🤴

```
a new castle...
castle is ready!
zzz...sleeping...
sleeping beauty is ready!
```

I hope you enjoyed the fairy tale, but let's do some real coding! 🤓

## Avoiding optionals with lazyness

As you've seen in the previous example lazy properties can be used to improve the performance of your Swift code. Also you can eliminate optionals in your objects. This can be useful if you're dealing with `UIView` derived classes. For example if you need a `UILabel` for your view hierarchy you usually have to declare that property as optional or as an implicitly unwrapped optional stored property. Let's remake this example by using lazy & eliminating the need of the evil optional requirement. 😈

```swift
class ViewController: UIViewController {

    lazy var label: UILabel = UILabel(frame: .zero)

    override func loadView() {
        super.loadView()

        self.view.addSubview(self.label)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.textColor = .black
        self.label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
}
```

It isn't so bad, however I still prefer to declare my views as implicitly unwrapped optionals. Maybe I'll change my mind later on, but old habits die hard... 💀

## Using a lazy closure

You can use a [lazy closure](https://www.bobthedeveloper.io/blog/swift-lazy-initialization-with-closures) to wrap some of your code inside it. The main advantage of being lazy - over stored properties - is that your block will be executed ONLY if a read operation happens on that variable. You can also populate the value of a [lazy property](https://useyourloaf.com/blog/swift-lazy-property-initialization/) with a regular stored proeprty. Let's see this in practice.

```swift
class ViewController: UIViewController {

    lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
}
```

This one is a nice practice if you'd like to declutter your init method. You can put all the object customization logic inside a closure. The closure executes itself on read (self-executing closure), so when you call `self.label` your block will be executed and voilá: your view will be ready to use.

> You can't use self in stored properties, but you are allowed to do so with lazy blocks. Be careful: you should always use `[unowned self]`, if you don't want to create reference cycles and memory leaks. ♻️

## Lazy initialization using factories

I already have a couple of articles about [factories in Swift](https://theswiftdev.com/2018/06/06/comparing-factory-design-patterns/), so now i just want to show you how to use a factory method & a static factory combined with a lazy property.

### Factory method

If you don't like self-executing closures, you can move out your code into a [factory method](https://theswiftdev.com/2018/05/31/swift-factory-method-design-pattern/) and use that one with your [lazy variable](https://medium.com/@abhimuralidharan/lazy-var-in-ios-swift-96c75cb8a13a). It's simple like this:

```swift
class ViewController: UIViewController {

    lazy var label: UILabel = self.createCustomLabel()

    private func createCustomLabel() -> UILabel {
        print("called")
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }
}
```

Now the factory method works like a private initializer for your lazy property. Let's bring this one step further, so we can improve reusability a little bit...

### Static factory

Outsourcing your lazy initializer code into a [static factory](https://theswiftdev.com/2018/05/29/swift-static-factory-design-pattern/) can be a good practice if you'd like to reuse that code in multiple parts of your application. For example this is a good fit for initializing custom views. Also creating a custom view is not really a view controller task, so the responsibilities in this example are more separated.

```swift
class ViewController: UIViewController {

    lazy var label: UILabel = UILabel.createCustomLabel()
}

extension UILabel {

    static func createCustomLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }
}
```

As a gratis you can enjoy the advantages of static factory properties / methods, like caching or returning specific subtypes. Pretty neat! 👍

## Conclusion

Lazy variables are a really convenient way to optimize your code, however they can only used on structs and classes. You can't use them as computed properties, this means they won't return the closure block every time you are trying to access them.

Another important thing is that lazy properties are **NOT thread safe**, so you have to be careful with them. Plus you don't always want to eliminate implicitly unwrapped optional values, sometimes it's just way better to simply crash! 🐛

> Don't be lazy!

...but feel free to use lazy properties whenever you can! 😉
