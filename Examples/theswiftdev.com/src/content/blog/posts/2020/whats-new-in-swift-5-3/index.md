---
type: post
title: What's new in Swift 5.3?
description: Swift 5.3 is going to be an exciting new release. This post is a showcase of the latest Swift programming language features.
publication: 2020-05-14 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

The [Swift 5.3 release process](https://swift.org/blog/5-3-release-process/) started in late March, there are lots of new features that are already implemented on the 5.3 branch. If you are curious what are those you can try it out by installing the latest snapshot using [swiftenv](https://github.com/kylef/swiftenv) for example, you can grab them from [swift.org](https://swift.org/download/).

## Package Manager updates

Swift Package tools version 5.3 will feature some really great additions.

## Resources

With the implementation of [SE-0271](https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md) the Swift Package Manager can finally bundle resource files alongside code. I believe that this was quite a popular request, since there are some libraries that embed asset files, they were not able to add SPM support, until now.

## Localized resources

[SE-0278](https://github.com/apple/swift-evolution/blob/master/proposals/0278-package-manager-localized-resources.md) extends the resource support, with this implementation you can declare localized resources for your Swift packages. The description explains well the proposed structure, you should take a look if you are interested in shipping localized files with your package.

## Binary dependencies

The other great thing is that SPM will finally be able to use binary dependencies. [SE-0272](https://github.com/apple/swift-evolution/blob/master/proposals/0272-swiftpm-binary-dependencies.md) adds this capability so people who want to ship closed source code can now take advantage of this feature. This will make it possible to have a `binaryTarget` dependency at a given path or location and you can use the binary as a product in a library or executable.

## Conditional Target Dependencies

[SE-0273](https://github.com/apple/swift-evolution/blob/master/proposals/0273-swiftpm-conditional-target-dependencies.md) gives us a nice little addition so we can use dependencies based on given platforms. This means that you can use a product for a target when you build for a specific platform.

These features are great additions to the SPM, hopefully Xcode will benefit from these things as well, and we will see some great new enhancements in the upcoming version of the IDE too.

## Language features

There are many new interesting proposals that got into the 5.3 version.

## Multiple Trailing Closures

[SE-0279](https://github.com/apple/swift-evolution/blob/master/proposals/0279-multiple-trailing-closures.md) is one of the most debated new proposal. When I first saw it I was not sure about the need of it, why would someone put so much effort to eliminate a few brackets? 🤔

```swift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // old
        UIView.animate(withDuration: 0.3, animations: {
          self.view.alpha = 0
        }, completion: { _ in
          self.view.removeFromSuperview()
        })
        // still old
        UIView.animate(withDuration: 0.3, animations: {
          self.view.alpha = 0
        }) { _ in
          self.view.removeFromSuperview()
        }

        // new
        UIView.animate(withDuration: 0.3) {
          self.view.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
}
```
As you can see this is mostly a syntactic sugar, but I convinced myself that it is nice to have.

### Synthesized Comparable conformance for enum types

Enum types don't have to explicitly implement the Comparable protocol thanks to [SE-0266](https://github.com/apple/swift-evolution/blob/master/proposals/0266-synthesized-comparable-for-enumerations.md).

```swift
enum Membership: Comparable {
    case premium(Int)
    case preferred
    case general
}
([.preferred, .premium(1), .general, .premium(0)] as [Membership]).sorted()
```

The `Comparable` protocol is automatically synthesized, just like the `Equatable` and `Hashable` conformances for eligible types. Of course you can provide your own implementation if needed.

### Enum cases as protocol witnesses

Swift enums are crazy powerful building blocks and now they just got better. 💪

```swift
protocol DecodingError {
  static var fileCorrupted: Self { get }
  static func keyNotFound(_ key: String) -> Self
}

enum JSONDecodingError: DecodingError {
  case fileCorrupted
  case keyNotFound(_ key: String)
}
```

The main goal of [SE-0280](https://github.com/apple/swift-evolution/blob/master/proposals/0280-enum-cases-as-protocol-witnesses.md) to lift an existing restriction, this way enum cases can be protocol witnesses if they provide the same case names and arguments as the protocol requires.

### Type-Based Program Entry Points

[SE-0281](https://github.com/apple/swift-evolution/blob/master/proposals/0281-main-attribute.md) gives us a new `@main` attribute that you can use to define entry points for your apps. This is a great addition, you don't have to write the `MyApp.main()` method anymore, but simply mark the MyApp object with the main attribute instead.

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static func main() {
        print("App will launch & exit right away.")
    }
}
```

The `UIApplicationMain` and `NSApplicationMain` attributes will be deprecated in favor of `@main`, I'd bet this is coming with the next major release...

### Multi-Pattern Catch Clauses

[SE-0276](https://github.com/apple/swift-evolution/blob/master/proposals/0276-multi-pattern-catch-clauses.md) is another syntactic sugar, it's really handy to catch multiple cases at once.

```swift
do {
    try performTask()
}
catch TaskError.someRecoverableError {
    recover()
}
catch TaskError.someFailure(let msg), TaskError.anotherFailure(let msg) {
    showMessage(msg)
}
```

This eliminates the need of using a switch case in the catch block. ✅

### Float16

Nothing much to say here, [SE-0277](https://github.com/apple/swift-evolution/blob/master/proposals/0277-float16.md) adds `Float16` to the standard library.

```swift
let f16: Float16 = 3.14
```

[Generic math functions](https://github.com/apple/swift-evolution/blob/master/proposals/0246-mathable.md) are also coming soon...

### Self changes

[SE-0269](https://github.com/apple/swift-evolution/blob/master/proposals/0269-implicit-self-explicit-capture.md) aka. Increase availability of implicit self in @escaping closures when reference cycles are unlikely to occur is a nice addition for those who don't like to write self. 🧐

```swift
//old
execute {
    let foo = self.doFirstThing()
    performWork(with: self.bar)
    self.doSecondThing(with: foo)
    self.cleanup()
}

//new
execute { [self] in
    let foo = doFirstThing()
    performWork(with: bar)
    doSecondThing(with: foo)
    cleanup()
}
```

This will allow us to write `self` in the capture list only and omit it later on inside the block.

### Refine didSet Semantics

[SE-0268](https://github.com/apple/swift-evolution/blob/master/proposals/0268-didset-semantics.md) is an under the hood improvement to make didSet behavior better & more reliable. 😇

```swift
class Foo {
    var bar = 0 {
        didSet { print("didSet called") }
    }

    var baz = 0 {
        didSet { print(oldValue) }
    }
}

let foo = Foo()
// This will not call the getter to fetch the oldValue
foo.bar = 1
// This will call the getter to fetch the oldValue
foo.baz = 2
```

In a nutshell previously the getter of a property was always called, but from now on it'll be only invoked if we use to the `oldValue` parameter in our `didSet` block.

### Add Collection Operations on Noncontiguous Elements

[SE-0270](https://github.com/apple/swift-evolution/blob/master/proposals/0270-rangeset-and-collection-operations.md) adds a `RangeSet` type for representing multiple, noncontiguous ranges, as well as a variety of collection operations for creating and working with range sets.

```swift
var numbers = Array(1...15)

// Find the indices of all the even numbers
let indicesOfEvens = numbers.subranges(where: { $0.isMultiple(of: 2) })

// Perform an operation with just the even numbers
let sumOfEvens = numbers[indicesOfEvens].reduce(0, +)
// sumOfEvens == 56

// You can gather the even numbers at the beginning
let rangeOfEvens = numbers.moveSubranges(indicesOfEvens, to: numbers.startIndex)
// numbers == [2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15]
// numbers[rangeOfEvens] == [2, 4, 6, 8, 10, 12, 14]
```

This proposal also extends the Collection type with some API methods using the RangeSet type, you should take a look if you are working a lot with ranges. 🤓

### Where clauses on contextually generic declarations

With [SE-0267](https://github.com/apple/swift-evolution/blob/master/proposals/0267-where-on-contextually-generic.md) you'll be able to implement functions and put a where constraint on them if you are only referencing generic parameters. Consider the following snippet:

```swift
protocol P {
    func foo()
}

extension P {
    func foo() where Self: Equatable {
        print("lol")
    }
}
```

This won't compile on older versions, but it'll work like magic after Swift 5.3.

Add a String Initializer with Access to Uninitialized Storage

[SE-0263](https://github.com/apple/swift-evolution/blob/master/proposals/0263-string-uninitialized-initializer.md) adds a new `String` initializer that allows you to work with an uninitialized buffer.

```swift
let myCocoaString = NSString("The quick brown fox jumps over the lazy dog") as CFString
var myString = String(unsafeUninitializedCapacity: CFStringGetMaximumSizeForEncoding(myCocoaString, ...)) { buffer in
    var initializedCount = 0
    CFStringGetBytes(
        myCocoaString,
        buffer,
        ...,
        &initializedCount
    )
    return initializedCount
}
// myString == "The quick brown fox jumps over the lazy dog"
```

By using this new init method you don't have to mess around with unsafe pointers anymore.

## Future evolution of Swift

Currently there are 6 more accepted proposals on the [Swift evolution dashboard](https://apple.github.io/swift-evolution/) and one is under review. Swift 5.3 is going to contain some amazing new features that were long awaited by the community. I'm really happy that the language is evolving in the right direction. 👍
