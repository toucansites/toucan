---
slug: swift-enum-all-values
title: Swift enum all values
description: In this quick tutorial I'll show you how to get all the possible values for a Swift enum type with a generic solution written in Swift.
publication: 2017-10-11 16:20:00
tags: Swift
---

From [Swift 4.2](https://forums.developer.apple.com/thread/4404) you can simply conform to the `CaseIterable` protocol, and you'll get the `allCases` static property for free. If you are reading this blog post in 2023, you should definitely upgrade your Swift language version to the latest. 🎉

```swift
enum ABC: String, CaseIterable {
    case a, b, c
}


print(ABC.allCases.map { $0.rawValue })
```

If you are targeting below Swift 4.2, feel free to use the following method.

## The EnumCollection protocol approach

First we need to define a new EnumCollection protocol, and then we'll make a protocol extension on it, so you don't have to write too much code at all.

```swift
public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}

public extension EnumCollection {

    public static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }

    public static var allValues: [Self] {
        return Array(self.cases())
    }
}
```

From now on you only have to conform your `enum` types to the EnumCollection protocol and you can enjoy the brand new cases method and `allValues` property which will contain all the possible values for that given enumeration.

```swift
enum Weekdays: String, EnumCollection {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

for weekday in Weekdays.cases() {
    print(weekday.rawValue)
}

print(Weekdays.allValues.map { $0.rawValue.capitalized })
```

Note that the base type of the enumeration needs to be `Hashable`, but that's not a big deal. However this solution feels like past tense, just like Swift 4, please consider upgrading your project to the latest version of Swift. 👋


