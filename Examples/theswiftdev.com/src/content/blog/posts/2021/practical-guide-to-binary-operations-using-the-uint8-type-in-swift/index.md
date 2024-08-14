---
type: post
title: Practical guide to binary operations using the UInt8 type in Swift
description: Introduction to the basics of signed number representation and some practical binary operation examples in Swift using UInt8.
publication: 2021-09-16 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## Integer types in Swift

The Swift programming language has a bunch of different integer types. The Swift integer APIs were cleaned up by an old proposal named [Protocol-oriented Integers](https://github.com/apple/swift-evolution/blob/main/proposals/0104-improved-integers.md), which resulted in a more generic way of expressing these kind of data types.

[Numeric data types](https://andybargh.com/swift-numeric-data-types/) in Swift are type safe by default, this makes a bit harder to perform operation using different integer (or floating point) types. Integers are divided into two main groups: signed and unsigned integers. In addition each members of these groups can be categorized by bit sizes. There are 8, 16, 32 & 64 bit long signed & unsigned integers plus generic integers. 🤔

Generic integers:

- [Int](https://developer.apple.com/documentation/swift/int) (32 or 64 bit)
- [UInt](https://developer.apple.com/documentation/swift/uint) (32 or 64 bit)

Signed integers:

- [Int8](https://developer.apple.com/documentation/swift/int8)
- [Int16](https://developer.apple.com/documentation/swift/int16)
- [Int32](https://developer.apple.com/documentation/swift/int32)
- [Int64](https://developer.apple.com/documentation/swift/int64)

Unsigned integers:

- [UInt8](https://developer.apple.com/documentation/swift/uint8)
- [UInt16](https://developer.apple.com/documentation/swift/uint16)
- [UInt32](https://developer.apple.com/documentation/swift/uint32)
- [UInt64](https://developer.apple.com/documentation/swift/uint64)

You should know that the Int and UInt type size may vary on different platforms (32 vs 64 bits), but in order to be consistent, Apple recommends to always prefer the generic Int type over all the other variants. The Swift language always identifies all the integers using the Int type by default, so if you keep using this type you'll be able to perform integer operations without type conversions, your code will be easier to read and it's going to be easier to move between platforms too. 💪

Most of the time you shouldn't care about the length of the integer types, we can say that the generic Int and UInt types are quite often the best choices when you write Swift code. Except in those cases when your goal is to write extremely memory efficient or low level code...

## Representing numbers as integers

Now that we know what kind of integers are available in Swift, it's time to talk a bit about what kind of numbers can we represent using these data types.

```swift
/// generic integers
print(Int.min)      //  -9223372036854775808
print(Int.max)      //   9223372036854775807
print(UInt.min)     //                     0
print(UInt.max)     //  18446744073709551615

/// unsigned integers
print(UInt8.min)    //                     0
print(UInt8.max)    //                   255
print(UInt16.min)   //                     0
print(UInt16.max)   //                 65535
print(UInt32.min)   //                     0
print(UInt32.max)   //            4294967295
print(UInt64.min)   //                     0
print(UInt64.max)   //  18446744073709551615

/// signed integers
print(Int8.min)     //                  -128
print(Int8.max)     //                   127
print(Int16.min)    //                -32768
print(Int16.max)    //                 32767
print(Int32.min)    //           -2147483648
print(Int32.max)    //            2147483647
print(Int64.min)    //  -9223372036854775808
print(Int64.max)    //   9223372036854775807
```

So there is a minimum and maximum value for each integer type that we can store in a given variable. For example, we can't store the value 69420 inside a UInt8 type, because there are simply not enough [bits](https://en.wikipedia.org/wiki/Bit) to represent this huge number. 🤓

Let's examine our 8 bit long unsigned integer type. 8 bit means that we have literally 8 places to store [boolean](https://theswiftdev.com/all-about-the-bool-type-in-swift/) values (ones and zeros) using the [binary number](https://en.wikipedia.org/wiki/Binary_number) representation. 0101 0110 in binary is 86 using the "regular" decimal number format. This binary number is a base-2 numerical system (a positional notation) with a radix of 2. The number 86 can be interpreted as:

```
0*28+1*27+0*26+1*25+0*24 + 1*23+1*22+0*21+0*20
0*128+1*64+0*32+1*16 + 0*8+1*4+1*2+0*1
64+16+4+2
86
```

We can convert back and forth between decimal and binary numbers, it's not that hard at all, but let's come back to this topic later on. In Swift we can check if a type is a signed type and we can also get the length of the integer type through the bitWidth property.

```swift
print(Int.isSigned)     // true
print(UInt.isSigned)    // false
print(Int.bitWidth)     // 64
print(UInt8.bitWidth)   // 8
```

Based on this logic, now it's quite straightforward that an 8 bit long unsigned type can only store 255 as the maximum value (1111 1111), since that's 128+64+32+16+8+4+2+1.

What about signed types? Well, the trick is that 1 bit from the 8 is reserved for the positive / negative symbol. Usually the first bit represents the sign and the remaining 7 bits can store the actual numeric values. For example the Int8 type can store numbers from -128 til 127, since the maximum positive value is represented as 0111 1111, 64+32+16+8+4+2+1, where the leading zero indicates that we're talking about a positive number and the remaining 7 bits are all ones.

So how the hack can we represent -128? Isn't -127 (1111 1111) the minimum negative value? 😅

Nope, that's not how negative binary numbers work. In order to understand negative integer representation using binary numbers, first we have to introduce a new term called [two's complement](https://en.wikipedia.org/wiki/Two%27s_complement), which is a simple method of signed number representation.

## Basic signed number maths

It is relatively easy to add two binary numbers, you just add the bits in order with a carry, just like you'd do addition using decimal numbers. Subtraction on the other hand is a bit harder, but fortunately it can be replaced with an addition operation if we store negative numbers in a special way and this is where two's complement comes in.

Let's imagine that we'd like to add two numbers:

- `0010 1010` (+42)
- `0100 0101` +(+69)
- `0110 1111` =(+111)

Now let's add a positive and a negative number stored using two's complement, first we need to express -6 using a signed 8 bit binary number format:

- `0000 0110` (+6)
- `1111 1001` ([one's complement](https://en.wikipedia.org/wiki/Ones%27_complement) = inverted bits)
- `1111 1010` (two's complement = add +1 (`0000 0001`) to one's complement)

Now we can simply perform an addition operation on the positive and negative numbers.

- `0010 1010` (+42)
- `1111 1010` +(-6)
- `(1) 0010 0100` =(+36)

So, you might think, what's the deal with the extra 1 in the beginning of the 8 bit result? Well, that's called a carry bit, and in our case it won't affect our final result, since we've performed a subtraction instead of an addition. As you can see the remaining 8 bit represents the positive number 36 and 42-6 is exactly 36, we can simply ignore the extra flag for now. 😅

## Binary operators in Swift

Enough from the theory, let's dive in with some real world examples using the UInt8 type. First of all, we should talk [about bitwise operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html) in Swift. In my previous article we've talked about [Bool operators](https://theswiftdev.com/all-about-the-bool-type-in-swift/) (AND, OR, NOT) and the Boolean algebra, now we can say that those functions operate using a single bit. This time we're going to see how bitwise operators can perform various transformations using multiple bits. In our sample cases it's always going to be 8 bit. 🤓

### Bitwise NOT operator

This operator (`~`) inverts all bits in a number. We can use it to create one's complement values.

```swift
// one's complement
let x: UInt8 = 0b00000110    // 6 using binary format
let res = ~x                 // bitwise NOT
print(res)                   // 249, but why?
print(String(res, radix: 2)) // 1111 1001
```

Well, the problem is that we'll keep seeing decimal numbers all the time when using int types in Swift. We can print out the correct 1111 1001 result, using a String value with the base of 2, but for some reason the inverted number represents 249 according to our debug console. 🙃

This is because the meaning of the UInt8 type has no understanding about the sign bit, and the 8th bit is always refers to the 28 value. Still, in some cases e.g. when you do low level programming, such as building a [NES emulator written in Swift](https://github.com/tib/SwiftNES), this is the right data type to choose.

The [Data type](https://developer.apple.com/documentation/foundation/data) from the Foundation framework is considered to be a collection of UInt8 numbers. Actually you'll find quite a lot of use-cases for the UInt8 type if you take a deeper look at the existing frameworks & libraries. Cryptography, data transfers, etc.

Anyway, you can make an extension to easily print out the binary representation for any unsigned 8 bit number with leading zeros if needed. 0️⃣0️⃣0️⃣0️⃣ 0️⃣1️⃣1️⃣0️⃣

```swift
/// UInt8+Binary.swift
import Foundation

fileprivate extension String {
    
    func leftPad(with character: Character, length: UInt) -> String {
        let maxLength = Int(length) - count
        guard maxLength > 0 else {
            return self
        }
        return String(repeating: String(character), count: maxLength) + self
    }
}

extension UInt8 {
    var bin: String {
        String(self, radix: 2).leftPad(with: "0", length: 8)
    }
}

let x: UInt8 = 0b00000110   // 6 using binary format
print(String(x, radix: 2))  // 110
print(x.bin)                // 00000110
print((~x).bin)             // 11111001 - one's complement
let res = (~x) + 1          // 11111010 - two's complement
print(res.bin)
```

We still have to provide our custom logic if we want to express signed numbers using UInt8, but that's only going to happen after we know more about the other bitwise operators.

### Bitwise AND, OR, XOR operators

These operators works just like you'd expect it from the truth tables. The AND operator returns a one if both the bits were true, the OR operator returns a 1 if either of the bits were true and the XOR operator only returns a true value if only one of the bits were true.

- AND `&` - 1 if both bits were 1
- OR `|` - 1 if either of the bits were 1
- XOR `^` - 1 if only one of the bits were 1
- 
Let me show you a quick example for each operator in Swift.

```swift
let x: UInt8 = 42   // 00101010
let y: UInt8 = 28   // 00011100
// AND
print((x & y).bin)  // 00001000
// OR
print((x | y).bin)  // 00111110
// XOR
print((x ^ y).bin)  // 00110110
```

Mathematically speaking, there is not much reason to perform these operations, it won't give you a sum of the numbers or other basic calculation results, but they have a different purpose.

You can use the bitwise AND operator to extract bits from a given number. For example if you want to store 8 (or less) individual true or false values using a single UInt8 type you can use a bitmask to extract & set given parts of the number. 😷

```swift
var statusFlags: UInt8 = 0b00000100

// check if the 3rd flag is one (value equals to 4)
print(statusFlags & 0b00000100 == 4)   // true

// check if the 5th flag is one (value equals to 16)
print(statusFlags & 0b00010000 == 16)  // false

// set the 5th flag to 1
statusFlags = statusFlags & 0b11101111 | 16
print(statusFlags.bin)  // 00010100

// set the 3rd flag to zero
statusFlags = statusFlags & 0b11111011 | 0
print(statusFlags.bin) // 00000100

// set the 5th flag back to zero
statusFlags = statusFlags & 0b11101111 | 0
print(statusFlags.bin) // 00000000

// set the 3rd flag back to one
statusFlags = statusFlags & 0b11101011 | 4
print(statusFlags.bin) // 00000100
```

This is nice, especially if you don't want to mess around with 8 different Bool variables, but one there is one thing that is very inconvenient about this solution. We always have to use the right power of two, of course we could use [pow](https://developer.apple.com/documentation/foundation/1779833-pow), but there is a more elegant solution for this issue.

### Bitwise left & right shift operators

By using a bitwise shift operation you can move a bit in a given number to left or right. Left shift is essentially a multiplication operation and right shift is identical with a division by a factor of two.

> "Shifting an integer’s bits to the left by one position doubles its value, whereas shifting it to the right by one position halves its value." - [swift.org](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID34)

It's quite simple, but let me show you a few practical examples so you'll understand it in a bit. 😅

```swift
let meaningOfLife: UInt8 = 42


// left shift 1 bit (42 * 2)
print(meaningOfLife << 1) // 84

// left shift 2 bits (42 * 2 * 2)
print(meaningOfLife << 2) // 168

// left shift 3 bits (42 * 2 * 2 * 2)
print(meaningOfLife << 3) // 80, it's an overflow !!!


// right shift 1 bit (42 / 2)
print(meaningOfLife >> 1) // 21

// right shift 2 bits (42 / 2 / 2)
print(meaningOfLife >> 2) // 10

// right shift 3 bits (42 / 2 / 2 / 2)
print(meaningOfLife >> 3) // 5

// right shift 4 bits (42 / 2 / 2 / 2 / 2)
print(meaningOfLife >> 4) // 2

// right shift 5 bits (42 / 2 / 2 / 2 / 2 / 2)
print(meaningOfLife >> 5) // 1

// right shift 6 bits (42 / 2 / 2 / 2 / 2 / 2 / 2)
print(meaningOfLife >> 6) // 0

// right shift 7 bits (42 / 2 / 2 / 2 / 2 / 2 / 2 / 2)
print(meaningOfLife >> 7) // 0
```

As you can see we have to be careful with left shift operations, since the result can overflow the 8 bit range. If this happens, the extra bit will just go away and the remaining bits are going to be used as a final result. Right shifting is always going to end up as a zero value. ⚠️

Now back to our status flag example, we can use bit shifts, to make it more simple.

```swift
var statusFlags: UInt8 = 0b00000100

// check if the 3rd flag is one
print(statusFlags & 1 << 2 == 1 << 2)

// set the 3rd flag to zero
statusFlags = statusFlags & ~(1 << 2) | 0
print(statusFlags.bin)

// set back the 3rd flag to one
statusFlags = statusFlags & ~(1 << 2) | 1 << 2
print(statusFlags.bin)
```

As you can see we've used quite a lot of bitwise operations here. For the first check we use left shift to create our mask, bitwise and to extract the value using the mask and finally left shift again to compare it with the underlying value. Inside the second set operation we use left shift to create a mask then we use the not operator to invert the bits, since we're going to set the value using a bitwise or function. I suppose you can figure out the last line based on this info, but if not just practice these operators, they are very nice to use once you know all the little the details. ☺️

I think I'm going to cut it here, and I'll make just another post about overflows, carry bits and various transformations, maybe we'll involve hex numbers as well, anyway don't want to promise anything specific. Bitwise operations are usueful and fun, just practice & don't be afraid of a bit of math. 👾
