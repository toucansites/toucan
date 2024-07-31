---
type: post
slug: unsafe-memory-pointers-in-swift
title: Unsafe memory pointers in Swift
description: Learn how to use raw pointer references, interact with unsafe pointers and manually manage memory addresses in Swift.
publication: 2021-03-18 16:20:00
tags: Swift, memory
authors:
  - tibor-bodecs
---

## Pointers in Swift

What's is a pointer? A pointer is a variable that stores the memory address of a referenced object. As I mentioned this in my previous article, [about the memory layout of various objects](https://theswiftdev.com/memory-layout-in-swift/) in Swift, a memory address is just a hexadecimal representation of a data located somewhere in the memory. You use instances of various unsafe pointer types to access data of a specific type in memory.

Why do we want to use these kind of pointers at the first place? By default you don't have to write unsafe Swift code, and in most of the cases you can live without unsafe memory pointers. These pointers come handy if you have to interoperate with other "unsafe" languages, such as C. There are other low level or legacy APIs that require the use of [manual memory management](https://developer.apple.com/documentation/swift/swift_standard_library/manual_memory_management), but you shouldn't be afraid, once you get familiar with unsafe Swift pointer types you'll know a lot more about how memory works and you'll see how thin is the layer between C libraries and Swift. 😱

What kind of pointers are there? In order to understand pointer types better in Swift, let's get back to C just for a second. Consider the following C code example:

```c
#include <stdio.h>

int main () {

    int x = 20;
    int* xPointer = &x;

    printf("x address: `%p`\n", &x);
    printf("x value: `%u`\n", x);
    printf("pointer address: `%p`\n", &xPointer);
    printf("pointer reference: `%p`\n", xPointer); // equals the address of x
    printf("pointer reference value: `%u`\n", *xPointer);

    *xPointer = 420;
    printf("x value: `%u`\n", x);
    printf("pointer reference value: `%u`\n", *xPointer);

    x = 69;
    printf("x value: `%u`\n", x);
    printf("pointer reference value: `%u`\n", *xPointer);

    return 0;
}
```
You can save this code snippet using the `main.c` name, then compile & run it using the `clang main.c -o main && ./main` command. It will provide a quite similar output.

```sh
$ clang main.c -o main && ./main
x address: `0x16b0c7a38`
x value: `20`
pointer address: `0x16b0c7a30`
pointer reference: `0x16b0c7a38`
pointer reference value: `20`
pointer value `20`
tib@~: clang main.c -o main && ./main
x address: `0x16d52fa38`
x value: `20`
pointer address: `0x16d52fa30`
pointer reference: `0x16d52fa38`
pointer reference value: `20`
x value: `420`
pointer reference value: `420`
x value: `69`
pointer reference value: `69`
```

So what's going on here? Well, we simply created an integer variable and a pointer variable with an integer type. We used the address of our x variable (&x) to associate our pointer with the memory address of x. Now both variables points to the same memory address.

We can confirm this by logging the memory address of both variables. We can also alter the value of x by updating the referenced value of the pointer (we can use the * character for this) or go with the usual make x = something line. We've simply logged the changed values to confirm that the pointer value update also changed the value of x. We could say that xPointer is just a reference to x.

Now how do we achieve the same thing in Swift? First we have to learn how to define a pointer type. Here's a quick list of all of the unsafe pointer objects available in the [Swift standard library](https://developer.apple.com/documentation/swift/swift_standard_library):

- [UnsafePointer\<T\>](https://developer.apple.com/documentation/swift/unsafepointer)
- [UnsafeMutablePointer\<T\>](https://developer.apple.com/documentation/swift/unsafemutablepointer)
- [UnsafeBufferPointer\<T\>](https://developer.apple.com/documentation/swift/unsafebufferpointer)
- [UnsafeMutableBufferPointer\<T\>](https://developer.apple.com/documentation/swift/unsafemutablebufferpointer)
- [UnsafeRawPointer](https://developer.apple.com/documentation/swift/unsaferawpointer)
- [UnsafeMutableRawPointer](https://developer.apple.com/documentation/swift/unsafemutablerawpointer)
- [UnsafeRawBufferPointer](https://developer.apple.com/documentation/swift/unsaferawbufferpointer)
- [UnsafeMutableRawBufferPointer](https://developer.apple.com/documentation/swift/unsafemutablerawbufferpointer)

You might have noticed a pattern here: `Unsafe|[Mutable][Raw][Buffer]Pointer[<T>]`.

Unsafe pointers are just direct memory addresses. Everything that is mutable can be changed, in other words you can write to that address. Raw means that there is no associated (generic, T) type to the given pointer, it's just a blob of raw bytes. Buffers are batches (collections) of pointers.

Don't worry if these types are quite confusing for you right now, it'll all make sense in a few minutes. Let's get back to our original C sample code and port it to Swift real quick.

```swift
var x: Int = 20
var xPointer: UnsafeMutablePointer<Int> = .init(&x)

print("x address:", UnsafeRawPointer(&x));
print("x value:", x);
print("pointer address:", UnsafeRawPointer(&xPointer));
print("pointer reference:", xPointer);
print("pointer reference value:", xPointer.pointee);


xPointer.pointee = 420;
print("x value:", x);
print("pointer reference value:", xPointer.pointee);

x = 69;
print("x value:", x);
print("pointer reference value:", xPointer.pointee);
```

We've created an `UnsafeMutablePointer<Int>` reference to our x value, this is basically an int* type if we go back to the C example. We can use the same ampersand (&) character to create pointers from variables. We've created a typed mutable pointer, since we'd like to change the value of the referenced integer object (through the pointee property) later on.

To print the memory address of a variable we can simply use an `UnsafeRawPointer` type, because we don't really care about the underlying "pointee" value, but we just need the address of the reference. If you print a pointer type the debug description will contain the underlying memory address of the referenced object. In this case the address of x and xPointer. 🤔

## Working with typed pointers in Swift

How can we store some values at "unsafe" memory addresses in Swift? The most simple way is that we start with a generic mutable pointer. We can allocate pointers using the required capacity, since we're working with unsafe memory, we also have to deallocate memory after we've finished using it. We also have to manually initialize pointer reference values, unsafe pointers can already contain some sort of leftover data, so the safe approach is to initialize them with a new default value.

```swift
let numbers = [4, 8, 15, 16, 23, 42]

let pointer = UnsafeMutablePointer<Int>.allocate(capacity: numbers.count)
pointer.initialize(repeating: 0, count: numbers.count)
defer {
    pointer.deinitialize(count: numbers.count)
    pointer.deallocate()
}

for (index, value) in numbers.enumerated() {
    pointer.advanced(by: index).pointee = value
}

print(pointer.advanced(by: 5).pointee); //42

let bufferPointer = UnsafeBufferPointer(start: pointer, count: numbers.count) // UnsafeBufferPointer<Int>
for (index, value) in bufferPointer.enumerated() {
    print(index, "-", value)
}

/// change values using a mutable buffer pointer
let bufferPointer = UnsafeMutableBufferPointer(start: pointer, count: numbers.count)
for (index, _) in bufferPointer.enumerated() {
    bufferPointer[index] = index + 1
}
```

After we have the allocated memory storage, we can set the appropriate `pointee` values, since we've allocated the pointer with a capacity of six integer values, we can store up to 6 numbers using this pointer. You can use the advanced(by:) method (pointer arithmetic `(pointer + 5).pointee = 42`) works as well) to move to the next address and set the `pointee` value of it.

The very last thing I'd like to let you know is that you can use a typed buffer pointer to iterate through these number references. You can think of buffer pointers as an array of pointer references. It is possible to enumerate through pointer values and indexes directly. You can update buffer pointer values by using the subscript syntax on a mutable buffer pointer. 💡

We already talked about the `UnsafePointer`, `UnsafeMutablePointer`, `UnsafeRawPointer`, `UnsafeBufferPointer` and `UnsafeMutableBufferPointer` type let's dive in to raw pointers.

## Memory management using raw pointers

Typed pointers provide some kind of safety if it comes to pointers, but how do we work with raw pointers? We've already seen how easy is to print out an address of a given value type using an `UnsafeRawPointer` reference, now it's time to connect the dots and allocate some unsafe raw memory. If you need to know more about memory layout in Swift, please read my previous [article](https://theswiftdev.com/memory-layout-in-swift/).

First of all, we'll need to know how much memory to allocate. We can use the MemoryLayout struct to get info about a value type. We can use the stride and the number of items to count how much byte is required to store our data type using a raw memory storage.

```swift
let numbers = [4, 8, 15, 16, 23, 42]

let stride = MemoryLayout<Int>.stride
let alignment = MemoryLayout<Int>.alignment
let byteCount = stride * numbers.count

let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
defer {
    pointer.deallocate()
}
  
for (index, value) in numbers.enumerated() {
    pointer.advanced(by: stride * index).storeBytes(of: value, as: Int.self)
}
  
//print(pointer.advanced(by: stride * 5).load(as: Int.self)) // 42

let bufferPointer = UnsafeRawBufferPointer(start: pointer, count: byteCount)
for index in 0..&lt;numbers.count {
    let value = bufferPointer.load(fromByteOffset: stride * index, as: Int.self)
    print(index, "-", value)
}
```

After we've allocated the required space, we can use the pointer and the advanced(by:) method to store byte values of a given type (`storeBytes(of:as:)`) as raw bytes. We can load a given type using the load(as:) method. It is worth to mention that if the memory does not contain a value that can be represented as the given type, incompatible value types can crash your app. ☠️

Anyway, if you stored multiple values using a pointer you can use the raw buffer collection to iterate through them and load back the types as values from a given byte offset. If you enumerate through a raw byte buffer you can also print the byte representation for the pointer.

If you want to know more about how to [Safely manage pointers in Swift](https://developer.apple.com/videos/play/wwdc2020/10167), I highly recommend watching the linked WWDC video. It's a fresh one, the sample code is compatible with Swift 5. 💪

## Memory binding can be dangerous

You can use the `bindMemory` and the `asssumingMemoryBound` methods to convert a raw pointer to a typed pointer. The first will actually bind the memory to a given type, but the second function just returns a referenced pointer assuming it's already bound to the specified type. You can read more about the key differences [here](https://stackoverflow.com/questions/47940167/unsaferawpointer-assumingmemorybound-vs-bindmemory) or check the original [UnsafeRawPointer API proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md#memory-model-explanation).

```swift
let stride = MemoryLayout<Int>.stride
let alignment = MemoryLayout<Int>.alignment
let count = 1
let byteCount = stride * count

let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
defer {
    rawPointer.deallocate()
}
let pointer = rawPointer.bindMemory(to: Int.self, capacity: count)
//let pointer = rawPointer.assumingMemoryBound(to: Int.self)
pointer.initialize(repeating: 0, count: count)
defer {
    pointer.deinitialize(count: count)
}

pointer.pointee = 42
print(rawPointer.load(as: Int.self))
rawPointer.storeBytes(of: 69, toByteOffset: 0, as: Int.self)
print(pointer.pointee)
```

Binding memory can be dangerous, there are a [few rules](https://medium.com/swlh/unsafe-swift-a-road-to-memory-15e7d7e701f9) that you should follow:

- Never return the pointer from a `withUnsafeBytes` call
- Only bind to one type at a time
- Be careful with off-by-one errors

[This article](https://www.raywenderlich.com/7181017-unsafe-swift-using-pointers-and-interacting-with-c#toc-anchor-010) lists the issues that can happen if you re-bind a memory address.

```swift
// don't do this, use withMemoryRebound instead...
let badPointer = rawPointer.bindMemory(to: Bool.self, capacity: count)
print(badPointer.pointee) // true, but that's not what we expect, right?
 
pointer.withMemoryRebound(to: Bool.self, capacity: count) { boolPointer in
    print(boolPointer.pointee) // false
}

// never return the pointer variable inside the block
withUnsafeBytes(of: &pointer.pointee) { pointer -> Void in
    for byte in pointer {
        print(byte)
    }
    // don't return pointer ever
}

// off-by-one error...
let bufferPointer = UnsafeRawBufferPointer(start: pointer, count: byteCount + 1)
for byte in bufferPointer {
    print(byte) // ...the last byte will be problematic
}
```

I also recommend checking [this article](https://quickbirdstudios.com/blog/swift-unsafe-raw-bytes-pointers-ios/) about memory management and byte computation in Swift. It is also possible to copy or move a memory to a given destination using the `assign(from:count:)` or `moveAssign(from:count:)` methods. You can read more about these functions [here](https://medium.com/@shoheiyokoyama/manual-memory-management-in-swift-c31eb20ea8f).

## Opaque and managed Swift pointers

If unsafe pointers weren't just enough, you should know that Swift has a few other pointer types.

- [OpaquePointer](https://developer.apple.com/documentation/swift/opaquepointer)
- [AutoreleasingUnsafeMutablePointer](https://developer.apple.com/documentation/swift/autoreleasingunsafemutablepointer)
- [Unmanaged](https://developer.apple.com/documentation/swift/unmanaged)
- [ManagedBufferPointer](https://developer.apple.com/documentation/swift/managedbufferpointer)
- [CVaListPointer](https://developer.apple.com/documentation/swift/cvalistpointer)

As [Vadim Bulavin](https://x.com/V8tr) describes this in [his article](https://www.vadimbulavin.com/swift-pointers-overview-unsafe-buffer-raw-and-managed-pointers/), with the help of the `Unmanaged` type you can bypass Automatic Reference Counting (ARC) that is otherwise enforced to every Swift class. The other case is to convert objects between opaque pointers back and forth.

```swift
class MyPoint {

    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    deinit {
        print("deinit", x, y)
    }
}

let unmanaged = Unmanaged.passRetained(MyPoint(x: 4, y: 20))
unmanaged.release()

_ = Unmanaged.passUnretained(MyPoint(x: 6, y: 9))

let opaque = Unmanaged.passRetained(MyPoint(x: 1, y: 0)).toOpaque()
Unmanaged<MyPoint>.fromOpaque(opaque).release()
```

Opaque pointers are used when you have to work with incomplete C data structures which cannot be represented in Swift. [For example](https://www.objc.io/blog/2018/01/30/opaque-vs-unsafe-pointers/) if you have a struct that contains a pointer type, that variable is going to be imported to Swift as an `OpaquePointer` type when [interacting with C code](https://tech.bakkenbaeck.com/post/swift-c-interop).

`ManagedBufferPointer` and the `ManagedBuffer` type allows you to implement your own copy-on-write data structure. This way you can achieve the exact same behavior as the built-in array, set or dictionary types have. [Russ Bishop](https://x.com/xenadu02?lang=en) has a great post [related to this topic](https://academy.realm.io/posts/russ-bishop-unsafe-swift/).

`AutoreleasingUnsafeMutablePointer` is a pointer that points to an Objective-C reference that doesn't own its target. you can read more about it [here](https://useyourloaf.com/blog/how-to-dereference-an-unsafe-mutable-pointer-in-swift/) by [Keith Harrison](https://x.com/kharrison)

The `CVaListPointer` is a simple wrapper around a C [va_list](https://www.cprogramming.com/tutorial/c/lesson17.html) pointer.
