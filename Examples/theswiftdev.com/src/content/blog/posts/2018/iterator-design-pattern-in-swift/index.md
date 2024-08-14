---
type: post
title: Iterator design pattern in Swift
description: Learn the iterator design pattern by using some custom sequences, conforming to the IteratorProtocol from the Swift standard library.
publication: 2018-08-19 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

This time I'm going to focus on the [iterator design pattern](https://en.wikipedia.org/wiki/Iterator_pattern). The pattern is heavily used in the [Swift standard library](https://developer.apple.com/documentation/swift/swift_standard_library), there are protocols that will give you support if you need to create an iterator, but honestly: I've never implemented this pattern directly. 😅

The truth is that probably in 99% of the use cases you'll never have to deal with this pattern, because there is amazing support for iterators built-in directly into Swift. Always use sequences, arrays, dictionaries instead of directly implementing this pattern, but it's good to know how things are working under the hood, isn't it? 🙃

## What is the iterator design pattern?

As the name suggests, the pattern enables you to iterate over a collection of elements. Here is the definition from the gang of four book:

Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation.

Long story short the [iterator](https://agostini.tech/2018/06/10/design-patterns-in-swift-iterator-pattern/) gives you an interface that will enable you to iterate over collections regardless of how they are implemented in the background. Here is a quick example of the theory above using a string iterator.

```swift
import Foundation

protocol StringIterator {
    func next() -> String?
}

class ArrayStringIterator: StringIterator {

    private let values: [String]
    private var index: Int?

    init(_ values: [String]) {
        self.values = values
    }

    private func nextIndex(for index: Int?) -> Int? {
        if let index = index, index < self.values.count - 1 {
            return index + 1
        }
        if index == nil, !self.values.isEmpty {
            return 0
        }
        return nil
    }

    func next() -> String? {
        if let index = self.nextIndex(for: self.index) {
            self.index = index
            return self.values[index]
        }
        return nil
    }
}


protocol Iterable {
    func makeIterator() -> StringIterator
}

class DataArray: Iterable {

    private var dataSource: [String]

    init() {
        self.dataSource = ["🐶", "🐔", "🐵", "🦁", "🐯", "🐭", "🐱", "🐮", "🐷"]
    }

    func makeIterator() -> StringIterator {
        return ArrayStringIterator(self.dataSource)
    }
}

let data = DataArray()
let iterator = data.makeIterator()

while let next = iterator.next() {
    print(next)
}
```

As you can see there are two main protocols and a really simple implementation for both of them. Our `DataArray` class now acts like a real array, the underlying elements can be iterated through using a loop. Let's ditch the theory and re-implement the example from above by using real Swift standard library components. 😉

## Custom sequences in Swift

Swift has a built-in sequence protocol to help you creating iterators. Implementing your own sequence in Swift is all about hiding your underlying data structure by creating a custom iterator object. You just have to store the current index and return your next element according to that each time the next function gets called. 😛

```swift
import Foundation

struct Emojis: Sequence {
    let animals: [String]

    func makeIterator() -> EmojiIterator {
        return EmojiIterator(self.animals)
    }
}

struct EmojiIterator: IteratorProtocol {

    private let values: [String]
    private var index: Int?

    init(_ values: [String]) {
        self.values = values
    }

    private func nextIndex(for index: Int?) -> Int? {
        if let index = index, index < self.values.count - 1 {
            return index + 1
        }
        if index == nil, !self.values.isEmpty {
            return 0
        }
        return nil
    }

    mutating func next() -> String? {
        if let index = self.nextIndex(for: self.index) {
            self.index = index
            return self.values[index]
        }
        return nil
    }
}

let emojis = Emojis(animals: ["🐶", "🐔", "🐵", "🦁", "🐯", "🐭", "🐱", "🐮", "🐷"])
for emoji in emojis {
    print(emoji)
}
```

So the [Sequence protocol](https://developer.apple.com/documentation/swift/sequence) is a generic counterpart of our custom iterable protocol used in the first example. The [IteratorProtocol](https://developer.apple.com/documentation/swift/iteratorprotocol) is somewhat like the string iterator protocol used before, but more *Swift-ish* and of course more generic.

So, this is great. Finally you know how to create a custom sequence. Which is good if you'd like to hide your data structure and provide a generic iterable interface. Imagine what would happen if you were about to start using a dictionary instead of an array for storing named emojis without an iterator that wraps them. 🤔

Now the thing is that there is one more super useful thing in the Swift standard library that I'd like to talk about. That's right, one abstraction level up and here we are:

## Custom collections in Swift

[Collections](https://developer.apple.com/documentation/swift/collection) are one step beyond sequences. Elements inside of them can be accessed via subscript they also define both a startIndex and an endIndex, plus individual elements of a collection can be accessed multiple times. Sounds good? 👍

Sometimes it can be useful to create a [custom collection](https://www.swiftbysundell.com/posts/creating-custom-collections-in-swift) type. For example if you'd like to eliminate optional values. Imagine a categorized favorite mechanism, for every category you'd have an array of favorites, so you'd have to deal with empty and non-existing cases. With a [custom collection](https://www.raywenderlich.com/867-building-a-custom-collection-in-swift) you could hide that extra code inside your custom data structure and provide a clean interface for the rest of your app. 😍

```swift
class Favorites {

    typealias FavoriteType = [String: [String]]

    private(set) var list: FavoriteType

    public static let shared = Favorites()

    private init() {
        self.list = FavoriteType()
    }
}


extension Favorites: Collection {

    typealias Index = FavoriteType.Index
    typealias Element = FavoriteType.Element

    var startIndex: Index {
        return self.list.startIndex
    }
    var endIndex: Index {
        return self.list.endIndex
    }

    subscript(index: Index) -> Iterator.Element {
        return self.list[index]
    }

    func index(after i: Index) -> Index {
        return self.list.index(after: i)
    }
}

extension Favorites {

    subscript(index: String) -> [String] {
        return self.list[index] ?? []
    }

    func add(_ value: String, category: String) {
        if var values = self.list[category] {
            guard !values.contains(value) else {
                return
            }
            values.append(value)
            self.list[category] = values
        }
        else {
            self.list[category] = [value]
        }
    }

    func remove(_ value: String, category: String) {
        guard var values = self.list[category] else {
            return
        }
        values = values.filter { $0 == value }

        if values.isEmpty {
            self.list.removeValue(forKey: category)
        }
        else {
            self.list[category] = values
        }
    }
}

Favorites.shared.add("apple", category: "fruits")
Favorites.shared.add("pear", category: "fruits")
Favorites.shared.add("apple", category: "fruits")

Favorites.shared["fruits"]

Favorites.shared.remove("apple", category: "fruits")
Favorites.shared.remove("pear", category: "fruits")
Favorites.shared.list
```

I know, this is a really dumb example, but it demonstrates why collections are more advanced compared to pure sequences. Also in the links below there are great demos of well written collections. Feel free to learn more about these super protocols and custom data types hidden (not so deep) inside the Swift standard library. 🤐

