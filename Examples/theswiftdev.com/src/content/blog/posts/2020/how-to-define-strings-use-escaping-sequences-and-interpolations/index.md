---
type: post
title: How to define strings, use escaping sequences and interpolations?
description: As a beginner it can be hard to understand String interpolation and escaping sequences, in this tutorial I'll teach you the basics.
publication: 2020-09-16 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

## What is a string?

According to [swift.org](https://docs.swift.org/swift-book/LanguageGuide/StringsAndCharacters.html) and [Wikipedia](https://en.wikipedia.org/wiki/String_(computer_science)) we can simply say that:

> A string is a series of characters

It's dead simple. This sentence for example is a string. When you write computer programs, you usually have to mark the beginning and the end of your strings with a special character, these surrounding characters are sometimes called as [delimiters](https://en.wikipedia.org/wiki/Delimiter). Most of the programming languages use single or double quotation marks or backticks to specify the boundaries of a string. 💀

## Constants, literals, variables and escaping

In Swift you can define string literals ([constants](https://en.wikipedia.org/wiki/Constant_(computer_programming))) by using the `let` keyword, or string [variables](https://en.wikipedia.org/wiki/Variable_(computer_science)) through the `var` keyword. If you don't want to change the value in the future at all you can use a string constant, but if you need a more dynamically changing value you should use a variable.

```swift
let message = "Hello World!"
print(message)
```

As you can see we are using double quotation marks `"` as delimiters and we gave a name to our string literal (or string constant, which is literally just a non-changing string, hence the name), in this example we can simply call the literal as `message`.

Now here comes the interesting part, how can I put a double quotation mark inside a string literal if that always represents the beginning and / or the end of a string? Well, for this reason the creators of many programming languages introduced escaping characters. 😱

```swift
let quote = "\"One more thing...\" - Steve Jobs"
```

The backslash (`\`) character is a very special one if it comes to the Swift programming language. We can also use it to write an actual backslash by escaping one (`\\`), but the newline (`\n`), tab (`\t`) and return (`\r`), [characters](https://stackoverflow.com/questions/15423001/how-are-r-t-and-n-different-from-one-another) are also created by using a backslash. It is also possible to write [unicode characters](https://en.wikipedia.org/wiki/List_of_Unicode_characters) using the `\u{CODE}` pattern. Here is how it works...

```swift
let newline = "\n"
let tab = "\t"
let `return` = "\r"
let unicode = "\u{2023}"

print(unicode) // ‣
```

Okay, okay, I know, why the backticks around the return keyword? Well, in Swift you can define a constant or variable name with almost any given name that is not a language keyword, you can even use emojis as names, but if you want to define a variable by using a reserved keyword, you have to escape it, aka. put it in between backticks. In our case the `return` was an already taken word, so we had to escape it. Now let's get back to the more interesting part.

If you take a look at a [unicode character chart](https://unicode.org/charts/) you'll see that the 2023 belongs to the play symbol. Unicode has so many characters and the list is constantly growing. Fortunately Swift can handle them very well, you can print unicode characters straight ahead or you can use the escape sequence by providing the hexa code of the [unicode](https://home.unicode.org/) character.

```
// old Hungarian letter p
let p1 = "𐳠"
let p2 = "\u{10CE0}"

// smiling face emoji
let s1 = "😊"
let s2 = "\u{1F60A}"
```

You can play around with emojis and look up unicode character codes for them on the [Emojipedia](https://emojipedia.org/) website. Since we were talking about escaping quite a lot, let me show you a few more things that you can do with the backslash character in Swift.

## String interpolation

So we've already seen how to put special characters into strings, what if I want to put another constant or variable in a string? This is a perfectly valid use case and we can actually use the following syntax to place variables into strings in Swift.

```swift
let name = "World"
let message = "Hello \(name)!"

print(message)
```

Long story short, this escape format (`\(VARIABLE)`) is called string interpolation and it's a really convenient & powerful tool for every beginner Swift programmer. You know in some other languages you have to use format strings to put variables into other strings, which can be extremely painful in some circumstances, but in Swift, you can simply interpolate almost anything. 🎉

Since we're talking about interpolations, I'd like to show how to concatenate two strings in Swift.

```swift
let welcome = "Hello"
let name = "World"

let m1 = welcome + " " + name + "!"
let m2 = "\(welcome) \(name)!"

print(m1)
print(m2)
```

The two final message strings will be identical, the only difference is the way we joined the parts together. In the first scenario we used the `+` sign to combine the strings, but in the second version we've simply used interpolation to construct a new string using the previously defined constants.

## Custom String interpolation

This is a more advanced topic, but I believe that not so many people are aware of this function in Swift, so let's talk a little bit about it. The main idea here is that you can create your own custom interpolation methods to format strings. I'll show you a working example real quick.

```swift
extension String.StringInterpolation {
    mutating func appendInterpolation(sayHelloTo value: String) {
        appendLiteral("Hello " + value + "!")
    }
}

let message = "\(sayHelloTo: "World")"
print(message)
```

This way you can put your string formatter code into a custom `String.StringInterpolation` extension and you don't have to deal with the rest when you create your variable. The `appendInterpolation` function can have multiple parameters and you have to use them inside the interpolation brackets when using it. No worries if this is too much, this topic is quite an advanced one, just remember that something like this exists and come back later. 💡

I highly recommend reading [Paul Hudson's article](https://www.hackingwithswift.com/articles/178/super-powered-string-interpolation-in-swift-5-0) about super-powered string interpolation.

## Multi-line string literals interpolation

Back to a relatively simple issue, what about multi-line strings? Do I have to concatenate everything line by line to construct such a thing? The answer is no. [Multi-Line String Literals](https://github.com/apple/swift-evolution/blob/master/proposals/0168-multi-line-string-literals.md) were introduced in Swift 4 and it was a really great addition to the language.

```swift
let p1 = """
    Please, remain calm, the end has arrived
    We cannot save you, enjoy the ride
    This is the moment you've been waiting for
    Don't call it a warning, this is a war

    It's the parasite eve
    Got a feeling in your stomach 'cause you know that it's coming for ya
    Leave your flowers and grieve
    Don't forget what they told ya, ayy ayy
    When we forget the infection
    Will we remember the lesson?
    If the suspense doesn't kill you
    Something else will, ayy ayy
    Move
    """
```
You can use three double quotes (`"""`) as a delimiter if you want to define long strings. These kind of string literals can contain newlines and individual double quote characters without the need of escaping. It is also good to know that if the closing delimiter alignment matters, so if you place a tab or a few spaces before that you also have to align everything before to the same column, this way those hidden space / tab characters will be ignored. Fell free to try it out. 🔨

Newline escape in strings interpolation
There is one problem with really long one-liner strings. They are hard to read, because... those strings are freaking long. Consider the following example.

```swift
let p1 = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    """
```

Wouldn't be cool if we could break this mess into some little pieces somehow? Yes or course, you can use string concatenation, but fortunately there is a more elegant solution.

```swift
// Shorter lines that are easier to read, but represent the same long line 
let text2 = """ Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod \ tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, \ quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. """
```

The [String Newline Escaping](https://github.com/apple/swift-evolution/blob/master/proposals/0182-newline-escape-in-strings.md) Swift evolution proposal was also implemented a long time ago so we can use the backslash character to work with shorter lines and escape the newline marker from the end of every single line. It's a pretty small but nice to have feature that can make our life more pleasant when we have to work with multi-line string literals. No more: \n\n\n. 👍

## Raw String escaping

The very last thing I want to show you is based on the [Enhancing String Literals Delimiters to Support Raw Text](https://github.com/apple/swift-evolution/blob/master/proposals/0200-raw-string-escaping.md) proposal. The motivation behind this one was that there are some cases when you have to escape too much in a string and we should be able to avoid this somehow.

```swift
let regex1 = "\\\\[A-Z]+[A-Za-z]+\\.[a-z]+"
let regex2 = #"\\[A-Z]+[A-Za-z]+\.[a-z]+"#
```

In my opinion the regular expression above is a very good example for this case. By defining a custom delimiter (`#"` and `"#`) we can avoid further escaping inside our string definition. The only downside is that now we can't simply interpolate substrings, but we have to place a a delimiter string there as well. Here, let me show you another example.

```swift
let name = "Word"
let message  = #"Hello "\#(name)"!"#

print(message)
```

As you can see it makes quite a big difference, but don't worry you won't have to use this format that much. Honestly I only used this feature like one or two times so far. 😅

## Summary

Strings in Swift are easy to learn, but don't get fooled: they are extremely complicated under the hood. In this article we've learned about unicode characters, encoding, escaping, literals and many more. I hope this will help you to understand Strings just a little bit better.

We've also examined a few Swift evolution proposals, but you can find a complete list of them on the [Swift evolution dashboard](https://apple.github.io/swift-evolution/). These proposals are [open source](https://github.com/apple/swift-evolution) and they help us to make Swift an even better programming language through the help of the community. ❤️
