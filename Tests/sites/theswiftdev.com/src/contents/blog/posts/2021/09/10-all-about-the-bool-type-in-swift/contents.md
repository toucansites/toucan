---
slug: all-about-the-bool-type-in-swift
title: All about the Bool type in Swift
description: Learn everything about logical types and the Boolean algebra using the Swift programming language and some basic math.
publication: 2021-09-10 16:20:00
tags: Swift, Booleans
---

## Booleans in the Swift language

Computers essentially understand two things: ones and zeros. Of course the whole story it's a bit more complicated, but if we dig down deep enough the underlying data it's going to be either a true or a false value that represents something. 1 means true, 0 means false. 🙃

In Swift we can express these kind of boolean values by using the [Bool data type](https://developer.apple.com/documentation/swift/bool), which you can create using `true` or `false` literals. The Bool type is a struct, that you can create multiple ways.

```swift
let thisIsTrue: Bool = true

let thisIsFalse = false

let foo = Bool(true) 

let bar = Bool("false")!

let baz = Bool.random() // true or false
```

It is possible to transform these values, there are plenty of logical operators available on the Bool struct, the most common ones are the following:

- NOT: `!` -> toggle a boolean value
- OR: `||` -> if one of the conditions are true, it's true
- AND: `&&` -> if both conditions are true, it's true otherwise false

All the [comparison operators](https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html#ID70) produce boolean values to indicate whether the statement is true or false. In Swift you can compare most of the basic data types, in this example I'll show you a few number comparison statements, since it's quite a trivial showcase for demoing the bool results. ☺️

```swift
var foo = true
foo.toggle()            // foo is now false
print(foo)              // false

print(!foo)             // true
print(foo && true)      // false
print(foo || true)      // true

print(3 == 4)           // false
print(3 != 4)           // true
print(3 > 2)            // true
print(3 >= 3)           // true
print(3 < 1)            // false
print(3 <= 4)           // true

// it works with other built-in types as well...
print("foo" == "bar")   // false
print(3.14 < 5.23)      // true
print(true != false)    // true
```

This is quite straightforward so far, but what can you do with a boolean in Swift? Well, turns out there are quite a lot of options. First of all, conditional statements (if, else if, else) usually require a true boolean value to execute the code inside the conditional block.

```swift
let foo = Bool.random()
/// it the condition is true, perfrom the first if block, otherwise the else
if foo {
    print("I was lucky. 🍀")
}
else {
    print("No luck this time. 🥲")
}

// or 

print(foo ? "I was lucky. 🍀" : "No luck this time. 🥲")
```

You can evaluate multiple conditions by using a logical operator, this way you can create more complex conditions, but it is worth to mention that if you combine them with and operators and the condition is dynamically calculated (e.g. a return of a function call), the entire chain will be called until you reach the very first false condition. This optimization is very handy in most of the cases.

```swift
var firstCondition = false

func secondCondition() -> Bool {
    print("⚠️ This won't be called at all.")
    return true
}

if firstCondition && secondCondition() {
    print("if branch is called")
}
else {
    print("else branch is called")
}
```

We also use a Bool value to run a cycle until a specific condition happens. In Swift there are multiple types of loops to execute a blcok of code multiple types. In this case here is an example using the [while loop](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html#ID124). While the condition is true, the loop will continue iterating, but if you make it false, the cycle will break. It is possible to have 0 iterations if the initial condition is false. 👌

The [repeat-while](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html#ID124) loop is kind of a special form of the while loop, if you are sure that you want to execute your code at least 1 times before evaluating the 'escape' condition you should use this one. Until the condition is true the loop goes on, when it is false, it'll break and it'll exit the cycle. ☝️

```swift
var counter = 0
var counterIsNotTen = true
// while the condition is true, perform the code in the block
while counterIsNotTen {
    counter += 1
    print(counter)
    counterIsNotTen = counter != 10
}

// or

var counter = 0
var counterIsNotTen = true
// repeat the block while the condition is true 
repeat {
    counter += 1
    print(counter)
    counterIsNotTen = counter != 10
} while counterIsNotTen
```

There are some 'special' functions that require a block that returns a Bool value in order to make something happen. This might sounds complicated at first sight, but it's quite simple if you take a closer look at the example. There is a [filter](https://developer.apple.com/documentation/swift/sequence/3018365-filter) method defined on the [Sequence](https://developer.apple.com/documentation/swift/sequence) protocol that you can use and provide a custom Bool returning [closure](https://docs.swift.org/swift-book/LanguageGuide/Closures.html) to filter elements.

In our case the sequence is a simple array that contains numbers from 0 until 100. Now the task is to get back only the elements under 50. We could use a for cycle and apply a where condition to collect all the elements into a new array, but fortunately the filter method gives us a better alternative. We pass a closure using the brackets and check if the current element ($0) value is less than 50. If the condition is true, the element will be returned and our bar array will be filled with only those elements that match the condition inside the block / closure.

```swift
let foo = Array(0...100)

for x in foo where x < 50 {
    print(x)
}

let bar = foo.filter { $0 < 50 }
print(bar)
```

It is also possible to create a custom object that represents a bool value. There is a really [old blog post](https://developer.apple.com/swift/blog/?id=8) about this on the official Apple dev blog, but let me show you how to define such a value using Swift 5. There are just a few changes and I'll ignore the bitwise operators for now, that's going to be a topic of another blog post in the future... 😉

```swift
enum MyBool {
    case myTrue
    case myFalse
    
    init() {
        self = .myFalse
    }
}

extension MyBool: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.myTrue,.myTrue), (.myFalse,.myFalse):
            return true
        default:
            return false
        }
    }
}

extension MyBool: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: BooleanLiteralType) {
        self = value ? .myTrue : .myFalse
    }
}

extension MyBool {
    var boolValue: Bool {
        switch self {
        case .myTrue:
            return true
        case .myFalse:
            return false
        }
    }
}

let foo = MyBool()          // init with false default
print(foo)                  // myFalse
print(foo.boolValue)        // false
print(foo == true)          // .myFalse == .myTrue -> false
```

Did you know that there is a [legacy boolean type](https://stackoverflow.com/questions/27304158/type-boolean-does-not-conform-to-protocol-booleantype/27304432#27304432), coming from the Objective-C times?

## Boolean algebra in Swift

If it comes to the Bool type in any programming language, I feel like it is necessary to talk a bit about the [Boolean algebra](https://en.wikipedia.org/wiki/Boolean_algebra) and truth tables. There are some basic operations that we can perform on Bool values (NOT, AND, OR), we've already talked about these, here is how we can express the corresponding truth tables in Swift (don't worry it's pretty easy). 💪

```swift
// not   x   is    z
print(!true)    // false
print(!false)   // true

//     x   and   y    is     z
print(false && false)   // false
print(true && false)    // false
print(false && true)    // false
print(true && true)     // true

//      x   or   y    is     z
print(false || false)   // false
print(true || false)    // true
print(false || true)    // true
print(true || true)     // true
```

We can also visualize the AND and OR operations using set algebra. The AND operation is often called [conjunction](https://en.wikipedia.org/wiki/Logical_conjunction) which means the common elements from both sets. The OR operation is called logical [disjunction](https://en.wikipedia.org/wiki/Logical_disjunction) and it refers to elements from either sets. Ok, that's enough math for now. 😅

There are some secondary operations that we still have to talk about, this might involves some more basic math, but I'll try to explain it as simple as possible. Let's start with the exclusive or operation (XOR), which only results in a true result if exactly one of the conditions is true and the other is false. Compared to the OR operation it excludes the possibility of two true values.
```swift
/// custom XOR operator
infix operator ⊕
func ⊕(_ lhs: Bool, _ rhs: Bool) -> Bool {
    lhs && !rhs || !lhs && rhs
}

//      x   xor   y    is     z
print(false ⊕ false)     // false
print(false ⊕ true)      // true
print(true ⊕ false)      // true
print(true ⊕ true)       // false
```

In Swift you can create [custom operator functions](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46), in our case we've assigned the ⊕ symbol as our XOR infix operator and used the equation from Wikipedia to compose the actual implementation of the function body from the basic logical operations.

Let's do the same for the next secondary operation called: [material conditional](https://en.wikipedia.org/wiki/Material_conditional).

```swift
/// custom material conditional operation
infix operator →
func →(_ lhs: Bool, _ rhs: Bool) -> Bool {
    !lhs || rhs
}

//      x   →   y    is     z
print(false → false)     // true
print(false → true)      // true
print(true → false)      // false
print(true → true)       // true
```

I'll not go too much into the details here, you can read all about material implication on the linked Wikipedia article. Our final secondary operation is the [logical equivalence](https://en.wikipedia.org/wiki/Logical_equivalence), here's how it looks like:

```swift
/// custom logical equivalence operator
infix operator ≡
func ≡(_ lhs: Bool, _ rhs: Bool) -> Bool {
    lhs && rhs || !lhs && !rhs
}

//      x   ≡   y    is     z
print(false ≡ false)     // true
print(false ≡ true)      // false
print(true ≡ false)      // false
print(true ≡ true)       // true
```

Of course we could talk a lot more about laws, completeness and other things, but in most of the cases you don't need the secondary operations, except the XOR, that's quite "popular". As you can see conditions are everywhere and it is possible to do some magical things using boolean values. Anyway, I hope you enjoyed this tutorial about the Bool type in the Swift language. 🤓
