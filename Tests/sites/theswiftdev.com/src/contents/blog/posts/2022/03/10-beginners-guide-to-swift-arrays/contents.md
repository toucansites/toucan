---
slug: beginners-guide-to-swift-arrays
title: Beginner's guide to Swift arrays
description: Learn how to manipulate arrays in Swift like a pro. This tutorial covers lots of useful array related methods, tips and tricks.
publication: 2022-03-10 16:20:00
tags: Swift, arrays
---

An [array](https://developer.apple.com/documentation/swift/array) can hold multiple elements of a given type. We can use them to store numbers, strings, classes, but in general elements can be anything. With the Any type you can actually express this and you can put anything into this random access collection. There are quite many ways to create an array in Swift. You can explicitly write the Array word, or use the [] shorthand format. 🤔

```swift
// array of integers
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
// array of strings
let strings = ["a", "b", "c"]
// array of any items
let anything: [Any] = [1, "a", 3.14]

// array init
let empty = Array<Int>()
let a: Array<Int> = Array()
let b: [Int] = [Int]()
let d = [Int](repeating: 1, count: 3)
let e = Array<String>(repeating: "a", count: 3)
```

The `Array` struct is a generic `Element` type, but fortunately the Swift compiler is smart enough to figure out the element type, so we don't have to explicitly write it every time. The Array type implements both the [Sequence](https://developer.apple.com/documentation/swift/sequence) and the [Collection](https://developer.apple.com/documentation/swift/collection) protocols, this is nice because the standard library comes with many powerful functions as protocol extensions on these interfaces.

```swift
let array = [1, 2, 3, 4]

// check if an array is empty
print(array.isEmpty) // false

// count the elements of the array
print(array.count) // 4

// check if contains an element
print(array.contains(2)) // true

// get the element at the zero index
print(array[0]) // 1

// elements between the 1st and 2nd index
print(array[1...2]) // [2, 3]

// first 2 elements
print(array.prefix(2)) // [1, 2]

// last 2 elements
print(array.suffix(2)) // [3, 4]
```

Above are some basic functions that you can use to get values from an array. You have to be careful when working with indexes, if you provide an index that is out of range your app will crash (e.g. anything smaller than `0` or greater than `4` for the sample code). 💥

Working with [collection types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html) can be hard if it comes to index values, but there are some cool helper methods available. When you work with an array it's very likely that you won't use these methods that much, but they are derived from a lower layer and it's nice to have them.

```swift
let array = [1, 2, 3, 4]

// start index of the array
print(array.startIndex) // 0

// end index of the array
print(array.endIndex) // 4

// range of index values
print(array.indices) // 0..<4

// start index + count
print(array.startIndex.advanced(by: array.count)) // 4

// first index of the value 3
print(array.firstIndex(of: 3) ?? "n/a") // 2

// first index for the value greater than 3
print(array.firstIndex { $0 > 3 } ?? "n/a") // 3

// the value at the start index + 1
print(array[array.startIndex.advanced(by: 1)]) // 2

// returns the index after a given index
print(array.index(after: 2))

// returns the index before a given index
print(array.index(before: 2))

// returns an index from an start index with an offset, limited by an end index
print(array.index(array.startIndex, offsetBy: 2, limitedBy: array.endIndex) ?? "n/a")
```

We can also manipulate the elements of a given array by using the following methods. Please note that these methods won't alter the original array, in other words they are non-mutating methods.

```swift
let array = [1, 5, 2, 3, 2, 4]

// drop the first 2 elements
print(array.dropLast(2)) // [1, 5, 2, 3]

// drop the last 2 elements
print(array.dropFirst(2)) // [2, 3, 2, 4]

// reverse the elements in the array
print(Array(array.reversed())) // [4, 2, 3, 2, 5, 1]

// get the unique elements from the array using a set
print(Array(Set(array))) // [2, 1, 3, 4, 5]

// split the array into an array of arrays using a needle
print(array.split(separator: 2)) // [[1, 5], [3], [4]]

// iterate through the elements of the array using index values
for index in array.indices {
    print(array[index]) // 1 2 3 4
}

// iterate through the elements of the array
for element in array {
    print(element) // 1 2 3 4
}

/// iterate through the index and element values using an enumerated tuple
for (index, element) in array.enumerated() {
    print(index, "-", element) // 0 - 1, 1 - 2, 2 - 3, 3 - 4
}
```

There are mutating methods that you can use to alter the original array. In order to call a mutating method on an array you have to create it as a variable (var), instead of a constant (let).

```swift
var array = [4, 2, 0]

// set element at index with a value
array[2] = 3
print(array) // [4, 2, 3]

// add new elements to the array
array += [4]
print(array) // [4, 2, 3, 4]

// replace elements at range with a new collection
array.replaceSubrange(0...1, with: [1, 2])
print(array) // [1, 2, 3, 4]

// removes the last element and returns it
let element = array.popLast() // 4
print(array) // [1, 2, 3]

// add a new element to the end of the array
array.append(4)
print(array) // [1, 2, 3, 4]

// insert an element to a given index (shift others)
array.insert(5, at: 1)
print(array) // [1, 5, 2, 3, 4]

// remove elements matching the criteria
array.removeAll { $0 > 3 }
print(array) // [1, 2, 3]

// swap elements at the given indexes
array.swapAt(0, 2)
print(array) // [3, 2, 1]

// removes the first element
array.removeFirst()
print(array) // [2, 1]

// removes the last element
array.removeLast()
print(array) // [2]

// add the contents of a sequence
array.append(contentsOf: [1, 2, 3])
print(array) // [2, 1, 2, 3]

// remove element at index
array.remove(at: 0)
print(array) // [1, 2, 3]
```

One last thing I'd like to show you are the [functional methods](https://theswiftdev.com/beginners-guide-to-functional-swift/) that you can use to transform or manipulate the elements of a given array. Personally I use these functions on a daily basis, they are [extremely useful](https://useyourloaf.com/blog/swift-guide-to-map-filter-reduce/) I highly recommend to learn more about them, especially [map](https://developer.apple.com/documentation/swift/array/3017522-map) & [reduce](https://developer.apple.com/documentation/swift/array/2298686-reduce). 💪

```swift
let array = [1, 5, 2, 3, 2, 4]

// sort the elements using an ascending order
print(array.sorted(by: <)) // [1, 2, 2, 3, 4, 5]

// sort the elements using a descending order
print(array.sorted { $0 > $1 }) // [5, 4, 3, 2, 2, 1]

// get the first element that matches the criteria
print(array.first { $0 == 3 } ?? "n/a") // 3

// filter the array, only return elements greater than 3
print(array.filter { $0 > 3 }) // [5, 4]

// transform every element, double their values
print(array.map { $0 * 2 }) // [2, 10, 4, 6, 4, 8]

// map the elements to strings and join them using a separator
print(array.map(String.init).joined(separator: ", ")) // 1, 5, 2, 3, 2, 4

// check if all the elements are greater than 1
print(array.allSatisfy { $0 > 1 }) // false

// sum the values of all the elements
print(array.reduce(0, +)) // 17

// check if there is an element matching the criteria (some)
print(array.reduce(false) { $0 || $1 > 3 }) // true

// check if all the elements are matching the criteria (every / allSatisfy)
print(array.reduce(true) { $0 && $1 > 1 }) // false
```

As you can see arrays are quite capable data structures in Swift. With the power of functional methods we can do amazing things with them, I hope this little cheat-sheet will help you to understand them a bit better. 😉
