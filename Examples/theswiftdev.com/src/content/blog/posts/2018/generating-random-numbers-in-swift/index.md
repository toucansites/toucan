---
type: post
title: Generating random numbers in Swift
description: Learn everything what you'll ever need to generate random values in Swift using the latest methods and covering some old techniques.
publication: 2018-08-07 16:20:00
tags: 
    - swift
authors:
  - tibor-bodecs
---

## How to generate random numbers using Swift?

Fortunately [random number generation](https://github.com/apple/swift-evolution/blob/master/proposals/0202-random-unification.md) has been unified since [Swift 4.2](https://www.hackingwithswift.com/articles/102/how-to-generate-random-numbers-in-swift). This means that you don't have to mess around with imported C APIs anymore, you can simply generate random values by using native Swift methods on all platforms! 😍

```swift
let randomBool = Bool.random()
let randomInt = Int.random(in: 1...6) //dice roll
let randomFloat = Float.random(in: 0...1)
let randomDouble = Double.random(in: 1..<100)
```

As you can see generating a dice roll is now super easy, thanks to the cryptographically secure randomizer that's built into the Swift language. The [new random generator API](https://developer.apple.com/videos/play/wwdc2018/401/) also better at distributing the numbers. The old `arc4random` function had some issues, because the generated values were not uniformly distributed for example in between 1 and 6 due to the modulo bias side effect. 🎲

### Random Number Generator (RNG)

These examples above are implicitly using the default [random number](https://oleb.net/blog/2018/06/random-numbers-in-swift/) generator ([SystemRandomNumberGenerator](https://developer.apple.com/documentation/swift/systemrandomnumbergenerator)) provided by the Swift standard library. There is a second parameter for every method, so you can use a different RNG if you want. You can also implement your own RNG or [extend the built-in generator](https://github.com/t-ae/rng-extension), if you'd like to alter the behavior of distribution (or just give it some more "entropy"! 🤪).

```swift
var rng = SystemRandomNumberGenerator()
let randomBool = Bool.random(using: &rng)
let randomInt = Int.random(in: 1...6, using: &rng) //dice roll
let randomFloat = Float.random(in: 0...1, using: &rng)
let randomDouble = Double.random(in: 1..<100, using: &rng)
```

### Collections, random elements, shuffle

The new random API introduced some nice extensions for collection types. Picking a random element and mixing up the order of elements inside a collection is now ridiculously easy and performant (with custom RNG support as well). 😉

```swift
let array = ["🐶", "🐱", "🐮", "🐷", "🐔", "🐵"]
let randomArrayElement = array.randomElement()
let shuffledArray = array.shuffled()

let dictionary = [
    "🐵": "🍌",
    "🐱": "🥛",
    "🐶": "🍖",
]
let randomDictionaryElement = dictionary.randomElement()
let shuffledDictionary = dictionary.shuffled()

let sequence = 1..<10
let randomSequenceElement = sequence.randomElement()
let shuffledSequence = sequence.shuffled()

let set = Set<String>(arrayLiteral: "🐶", "🐱", "🐮", "🐷", "🐔", "🐵")
let randomSetElement = set.randomElement()
let shuffledSet = set.shuffled()
```

### Randomizing custom types

You can implement random functions on your custom types as well. There are two simple things that you should keep in mind in order to follow the Swift standard library pattern:

- provide a static method that has a (`inout`) parameter for the custom RNG
- make a `random()` method that uses the `SystemRandomNumberGenerator`

```swift

enum Animal: String, CaseIterable {
    case dog = "🐶"
    case cat = "🐱"
    case cow = "🐮"
    case pig = "🐷"
    case chicken = "🐔"
    case monkey = "🐵"
}

extension Animal {

    static func random<T: RandomNumberGenerator>(using generator: inout T) -> Animal {
        return self.allCases.randomElement(using: &generator)!
    }

    static func random() -> Animal {
        var rng = SystemRandomNumberGenerator()
        return Animal.random(using: &rng)
    }
}

let random: Animal = .random()
random.rawValue
```

## Generating random values using GameplayKit

The [GameplayKit](https://developer.apple.com/documentation/gameplaykit) provides lots of things to help you dealing with [random number](https://learnappmaking.com/random-numbers-swift/) generation. Various random sources and distributions are available inside the framework, let's have a quick look at them.

### Random sources in GameplayKit

GameplayKit has three random source algorithms implemented, the reason behind it is that [random number](https://stackoverflow.com/questions/24007129/how-does-one-generate-a-random-number-in-apples-swift-language) generation is hard, but usually you're going to go with arc4 random source. You should note that Apple recommends resetting the first 769 values (just round it up to 1024 to make it look good) before you're using it for something important, otherwise it will generate sequences that can be guessed. 🔑

- `GKARC4RandomSource` - okay performance and randomness
- `GKLinearCongruentialRandomSource` - fast, less random
- `GKMersenneTwisterRandomSource` - good randomness, but slow

You can simply generate a [random number](https://www.netguru.co/codestories/generating-random-numbers-in-swift) from int min to int max by using the `nextInt()` method on any of the sources mentioned above or from 0 to upper bound by using the `nextInt(upperBound:)` method.

```swift
import GameplayKit

let arc4 = GKARC4RandomSource()
arc4.dropValues(1024) //drop first 1024 values first
arc4.nextInt(upperBound: 20)
let linearCongruential = GKLinearCongruentialRandomSource()
linearCongruential.nextInt(upperBound: 20)
let mersenneTwister = GKMersenneTwisterRandomSource()
mersenneTwister.nextInt(upperBound: 20)
```

### Random distribution algorithms

> GKRandomDistribution - A generator for random numbers that fall within a specific range and that exhibit a specific distribution over multiple samplings.

Basically we can say that this implementation is trying to provide randomly distributed values for us. It's the default value for shared random source. 🤨

> GKGaussianDistribution - A generator for random numbers that follow a Gaussian distribution (also known as a normal distribution) across multiple samplings.

The gaussian distribution is a shaped random number generator, so it's more likely that the numbers near the middle are more frequent. In other words elements in the middle are going to occure significantly more, so if you are going to simulate dice rolling, 3 is going to more likely happen than 1 or 6. Feels like the real world, huh? 😅

> GKShuffledDistribution - A generator for random numbers that are uniformly distributed across many samplings, but where short sequences of similar values are unlikely.

A fair random number generator or shuffled distribution is one that generates each of its possible values in equal amounts evenly distributed. If we keep the dice rolling example with 6 rolls, you might get 6, 2, 1, 3, 4, 5 but you would never get 6 6 6 1 2 6.

```swift
// 6 sided dice
let randomD6 = GKRandomDistribution.d6()
let shuffledD6 = GKShuffledDistribution.d6()
let gaussianD6 = GKGaussianDistribution.d6()
randomD6.nextInt()   // completely random
shuffledD6.nextInt() // see below... // eg. 1
gaussianD6.nextInt() // mostly 3, most likely 2, 4 less likely 1, 6

//goes through all the possible values again and again...
shuffledD6.nextInt() // eg. 3
shuffledD6.nextInt() // eg. 5
shuffledD6.nextInt() // eg. 2
shuffledD6.nextInt() // eg. 6
shuffledD6.nextInt() // eg. 4

// 20 sided dice
let randomD20 = GKRandomDistribution.d20()
let shuffledD20 = GKShuffledDistribution.d20()
let gaussianD20 = GKGaussianDistribution.d20()
randomD20.nextInt()
shuffledD20.nextInt()
gaussianD20.nextInt()

// using custom random source, by default it uses arc4
let mersenneTwister = GKMersenneTwisterRandomSource()
let mersoneTwisterRandomD6 = GKRandomDistribution(randomSource: mersenneTwister, lowestValue: 1, highestValue: 6)
mersoneTwisterRandomD6.nextInt()
mersoneTwisterRandomD6.nextInt(upperBound: 3) //limiting upper bound
```

### How to shuffle arrays using GameplayKit?

You can use the `arrayByShufflingObjects(in:)` method to mix up elements inside an array. Also you can use a seed value in order to shuffle elements identically. It's going to be a random order, but it can be predicted. This comes handy if you need to sync two random arrays between multiple devices. 📱

```swift
let dice = [Int](1...6)

let random = GKRandomSource.sharedRandom()
let randomRolls = random.arrayByShufflingObjects(in: dice)

let mersenneTwister = GKMersenneTwisterRandomSource()
let mersenneTwisterRolls = mersenneTwister.arrayByShufflingObjects(in: dice)

let fixedSeed = GKMersenneTwisterRandomSource(seed: 1001)
let fixed1 = fixedSeed.arrayByShufflingObjects(in: dice) // always the same order
```

### GameplayKit best practice to generate random values

There is also a shared random source that you can use to generate random numbers. This is ideal if you don't want to mess around with distributions or sources. This shared random object uses arc4 as a source and random distribution. 😉

```swift
let sharedRandomSource = GKRandomSource.sharedRandom()
sharedRandomSource.nextBool() // true / false
sharedRandomSource.nextInt() //from int min - to int max
sharedRandomSource.nextInt(upperBound: 6) //dice roll
sharedRandomSource.nextUniform() //float between 0 - 1
```

Please note that none of these random number generation solutions provided by the GameplayKit framework are recommended for cryptography purposes!

## Pre-Swift 4.2 random generation methods

I'll leave this section here for historical reasons. 😅

### arc4random

```swift
arc4random() % 6 + 1 // dice roll
```

This C function was very common to generate a dice roll, but it's also dangerous, because it can lead to a [modulo bias](https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#Modulo_bias) (or pigenhole principle), that means some numbers are generated more frequently than others. Please don't use it. 😅

### arc4random_uniform

This method will return a uniformly distributed random numbers. It was the best / recommended way of generating random numbers before Swift 4.2, because it avoids the modulo bias problem, if the upper bound is not a power of two.

```swift
func rndm(min: Int, max: Int) -> Int {
    if max < min {
        fatalError("The max value should be greater than the min value.")
    }
    if min == max {
        return min
    }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}
rndm(min: 1, max: 6) //dice roll
```

### drand48

The `drand48` function returns a random floating point number between of 0 and 1. It was really useful for generating color values for random UIColor objects. One minor side note that it generates a pseudo-random number sequence, and you have to [provide a seed value](https://bendodson.com/weblog/2016/09/10/generating-random-colour-with-seed-in-swift/) by using `srand48` and usually a time parameter. 🤷‍♂️

```swift
let red = CGFloat(drand48())
let green = CGFloat(drand48())
let blue = CGFloat(drand48())
```

### Linux support, glibc and the rand method

I was using this snippet below in order to generate random numbers on both appleOS and Linux platform. I know it's not perfect, but it did the job for me. 🤐

```swift
#!/usr/bin/env swift

#if os(iOS) || os(tvOS) || os(macOS) || os(watchOS)
    import Darwin
#endif
#if os(Linux)
    import Glibc
#endif

public func rndm(to max: Int, from min: Int = 0) -> Int {
    #if os(iOS) || os(tvOS) || os(macOS) || os(watchOS)
        let scale = Double(arc4random()) / Double(UInt32.max)
    #endif
    #if os(Linux)
        let scale = Double(rand()) / Double(RAND_MAX)
    #endif
    var value = max - min
    let maximum = value.addingReportingOverflow(1)
    if maximum.overflow {
        value = Int.max
    }
    else {
        value = maximum.partialValue
    }
    let partial = Int(Double(value) * scale)
    let result = partial.addingReportingOverflow(min)
    if result.overflow {
        return partial
    }
    return result.partialValue
}

rndm(to: 6)
```

Now that we have Swift 4.2 just around the corner I'd like to encourage everyone to adapt the new random number generation API methods. I'm really glad that Apple and the community tackled down this issue so well, the results are amazing! 👏
