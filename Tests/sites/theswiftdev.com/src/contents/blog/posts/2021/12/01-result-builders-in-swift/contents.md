---
slug: result-builders-in-swift
title: Result builders in Swift
description: If you want to make a result builder in Swift, this article will help you to deal with the most common cases when creating a DSL.
publication: 2017-10-10 16:20:00
tags: UIKit, iOS
---

## Swift result builder basics

The [result builder proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md) (originally it was called function builders) was implemented in Swift 5.4. This feature allows us to build up a result value using a sequence of components. At first sight, you might think, hey this looks like an array with a series of elements, except the coma in between the items, but nope, this is completely different. But why is it good for us?

Result builder can be used to create entirely new Domain-Specific Languages (DSLs) inside Swift. Creating a DSL has many advantages, since DSLs are usually tied to a specific problem, the syntax that you use to describe the language is very lightweight, yet powerful and capable. Since Swift DSLs are type safe, it is much safer to use one instead of manually concatenate objects. Swift DSLs also allows us to use basic control flows inside these embedded micro-languages. 🤔

Let me give you an example: you can [write HTML in Swift](https://github.com/BinaryBirds/swift-html), you can simply write out all the tags and glue a bunch of String values together, but that wouldn't be so safe, right?

```swift
func buildWebpage(title: String, body: String) -> String {
    """
    <html>
        <head>
            <title>\(title)</title>
        </head>
        <body>
            <h1>\(title)</h1>
            <h1>\(body)</h1>
        </body>
    </html>
    """
}

let html = buildWebpage(title: "Lorem ipsum", body: "dolor sit amet")
print(html)
```

We can all agree that this is ugly and the compiler won't help you to detect the semantic issues at all. Now if we replace the following code with a DSL, we will greatly benefit of the Swift compiler features. Swift will give us type safety, so our code will be less error prone. A DSL can have many constraints and restrictions that'll help others to write better code. In our case the list of tags is going to be a predefined set of values, so you won't be able to provide a wrong tag or miss the closing tag, in other words your DSL is going to be syntactically valid. Of course you still can have logical mistakes, but that's always the case, no matter what tool you choose. 🧠

```swift
import SwiftHtml

func buildWebpage(title: String, body: String) -> String {
    let doc = Document(.unspecified) {
        Html {
            Head {
                Title(title)
            }
            Body {
                H1(title)
                P(body)
            }
        }
    }
    return DocumentRenderer().render(doc)
}
```
As you can see the snippet above looks way more Swifty and we were also able to remove the duplicate HTML closing tags from the code. We don't have to write the `<` and `>` characters at all and the compiler can type check everything for us, so type-o accidents can't happen. ✅

Before you think that result builders are just syntactic sugar over underlying data types, I have to assure you that they are far more complex than this. It is an extremely advanced and powerful feature that you should definitely know about.

You can create all kinds of result builders, for example I'm using them to build validators, user interface elements and layout constraints. Of course SGML (HTML, XML) and CSS is also a great use-case, but the list is endless. Let me show you how to build a simple result builder.

## Building a HTML tree structure

I'm going to show you how I created my [SwiftHtml](https://github.com/BinaryBirds/swift-html) HTML DSL library, because it was a fun project to work with and I've learned a lot about it, it's also going to replace the Leaf/Tau template in my future projects. The main idea behind SwiftHtml was that I wanted to follow the HTML specifications as closely as possible. So I've created a Node structure to represent a node inside the document tree.

```swift
public struct Node {

    public enum `Type` {
        case standard     // <name>contents</name>
        case comment      // <!-- contents -->
        case empty        // <name>
        case group        // *group*<p>Lorem ipsum</p>*group*
    }

    public let type: `Type`
    public let name: String?
    public let contents: String?

    public init(type: `Type` = .standard,
                name: String? = nil,
                contents: String? = nil) {
        self.type = type
        self.name = name
        self.contents = contents
    }
}
```

A node has four variants defined by the Type. A standard node will render as a standard HTML tag using the name and the contents. A comment will only use the contents and empty tag won't have a closing tag and use the name property as a tag name. Finally the group node will be used to group together multiple nodes, it won't render anything, it's just a grouping element for other tags.

The trick in my solution is that these Node objects only contain the visual representation of a tag, but I've decided to separate the hierarchical relationship from this level. That's why I actually introduced a Tag class that can have multiple children. In my previous article I showed multiple ways to [build a tree structure using Swift](https://theswiftdev.com/building-tree-data-structures-in-swift/), I've experimented with all the possible solutions and my final choice was to use reference types instead of value types. Don't hate me. 😅

```swift
open class Tag {

    public var node: Node
    public var children: [Tag]

    public init(_ node: Node, children: [Tag] = []) {
        self.node = node
        self.children = children
    }

}
```

Now this is how a Tag object looks like, it's pretty simple. It has an underlying node and a bunch of children. It is possible to extend this tag and provide functionalities for all the HTML tags, such as the capability of adding common attributes and I'm also able to create subclasses for the tags.

```swift
public final class Html: Tag {

    public init(_ children: [Tag]) {
        super.init(.init(type: .standard, name: "html", contents: nil), children: children)
    }
}

public final class Head: Tag {

    public init(_ children: [Tag]) {
        super.init(.init(type: .standard, name: "head", contents: nil), children: children)
    }
}

public final class Title: Tag {

    public init(_ contents: String) {
        super.init(.init(type: .standard, name: "title", contents: contents))
    }
}

public final class Body: Tag {

    public init(_ children: [Tag]) {
        super.init(.init(type: .standard, name: "body", contents: nil), children: children)
    }
}

public final class H1: Tag {

    public init(_ contents: String) {
        super.init(.init(type: .standard, name: "h1", contents: contents))
    }
}

public final class P: Tag {

    public init(_ contents: String) {
        super.init(.init(type: .standard, name: "p", contents: contents))
    }
}
```

All right, now we are able to initialize our Tag tree, but I warn you, it's going to look very awkward.

```swift
func buildWebpage(title: String, body: String) -> Html {
    Html([
        Head([
            Title(title),
        ]),
        Body([
            H1(title),
            P(body),
        ]),
    ])
}
```

It is still not possible to render the tree and the syntax is not so eye-catchy. It's time to make things better and we should definitely introduce some result builders for good.

The anatomy of Swift result builders
Now that we have our data structure prepared, we should focus on the DSL itself. Before we dive in, I highly recommend to carefully read the [official proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md) and watch this [WWDC video](https://developer.apple.com/videos/play/wwdc2021/10253/) about result builders, since both resources are amazing. 🤓

### Building an array of elements

The main thing that I don't like about our previous buildWebpage function is that I have to constantly write brackets and comas, in order to build our structure. This can be easily eliminated by introducing a new result builder for the Tag objects. We just have to mark an enum with the @resultBuilder attribute and provide a static buildBlock method with the given type.

```swift
@resultBuilder
public enum TagBuilder {
    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }
}
```

This will allow us to use a list of components inside of our DSL building blocks, but before we could use it we also have to change our specific HTML tag init methods to take advantage of this newly created result builder. Just use a closure with the return type that we want to use and mark the entire function argument with the @TagBuilder keyword.

```swift
public final class Html: Tag {
    public init(@TagBuilder _ builder: () -> [Tag]) {
        super.init(.init(type: .standard, name: "html", contents: nil), children: builder())
    }
}

public final class Head: Tag {
    public init(@TagBuilder _ builder: () -> [Tag]) {
        super.init(.init(type: .standard, name: "head", contents: nil), children: builder())
    }
}

public final class Body: Tag {
    public init(@TagBuilder _ builder: () -> [Tag]) {
        super.init(.init(type: .standard, name: "body", contents: nil), children: builder())
    }
}
```

Now we can refactor the build webpage method since it can now use the underlying result builder to construct the building blocks based on the components. If you take a look at the [introduction section](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md#introduction) inside the proposal you'll get a better idea about what happens under the hood.

```swift
func buildWebpage(title: String, body: String) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            H1(title)
            P(body)
        }
    }
}

let html = buildWebpage(title: "title", body: "body")
```

Anyway, it's quite magical how we can transform our complex array based code into something clean and nice by taking advantage of the Swift compiler. I love this approach, but there is more.

### Optionals and further build blocks

If you want to provide if support inside your DSL you have to implement some additional methods inside your result builder object. Try this code, but it won't compile:

```swift
func buildWebpage(title: String, body: String) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            if title == "magic" {
                H1(title)
                P(body)
            }
        }
    }
}
```

The build an optional result with an if statement we have to think about what happens here. If the title is magic we would like to return an array of Tags, otherwise nil. So this could be expressed as a `[Tag]?` type but we always want to have a bunch of `[Tag]` elements, now this is easy.

```swift
@resultBuilder
public enum TagBuilder {

    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }

    public static func buildOptional(_ component: [Tag]?) -> [Tag] {
        component ?? []
    }
}
```

But wait, why is it not working? Well, since we return an array of tags, but the outer Body element was expecting Tag elements one after another, so a `[Tag]` array won't fit our needs there. What can we do about this? Well, we can introduce a new buildBlock method that can transform our `[Tag]...` values into a plain Tag array. Let me show you real this quick.

```swift
@resultBuilder
public enum TagBuilder {

    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }
    
    public static func buildBlock(_ components: [Tag]...) -> [Tag] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Tag]?) -> [Tag] {
        component ?? []
    }
}

func buildWebpage(title: String, body: String) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body { // expects Tag... 
            // but the first build block transforms it to [Tag]

            // returns [Tag], but we'd need Tag...
            if title == "magic" { 
                H1("Hello")
                P("World")
            } 

            // this could also returns [Tag]
            // if title = "other" {
            //    H1("Other")
            //    P("World")  
            //} 

            // both if block returns [Tag], that's [Tag]... here

            // ...the new build block transforms [Tag]... into [Tag], 
            // which is just fine for the body init method
    }
}
```

I hope it's not too complicated, but it's all about building the proper return type for the underlying method. We wanted to have just an array of tags, but with the if support we've ended up with a list of tag arrays, that's why we have to transform it back to a flattened array of tags with the new build block. If you want to take a look at a more simple example, you should [read this post](https://swiftsenpai.com/swift/result-builders-basics/). ☺️

### If and else support and either blocks

If blocks can return optional values, now what about if-else blocks? Well, it's quite a similar approach, we just want to return either the first or the second array of tags.

```swift
@resultBuilder
public enum TagBuilder {

    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }
    
    public static func buildBlock(_ components: [Tag]...) -> [Tag] {
        components.flatMap { $0 }
    }    

    public static func buildOptional(_ component: [Tag]?) -> [Tag] {
        component ?? []
    }

    public static func buildEither(first component: [Tag]) -> [Tag] {
        component
    }

    public static func buildEither(second component: [Tag]) -> [Tag] {
        component
    }
}

func buildWebpage(title: String, body: String) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            if title == "magic" {
                H1("Hello")
                P("World")
            }
            else {
                P(body)
            }
        }
    }
}

let html = buildWebpage(title: "title", body: "body")
```

As you can see now we don't need additional building blocks, since we've already covered the variadic Tag array issue with the optional support. Now it is possible to write if and else blocks inside our HTML DSL. Looks pretty nice so far, what's next? 🧐

### Enabling for loops and maps through expressions

Imagine that you have a bunch of paragraphs inside of the body that you'd like to use. Pretty easy, right? Just change the body into an array of strings and use a for loop to transform them into P tags.

```swift
func buildWebpage(title: String, paragraphs: [String]) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            H1(title)
            for item in paragraphs {
                P(item)
            }
        }
    }
}

let html = buildWebpage(title: "title", paragraphs: ["a", "b", "c"])
```

Not so fast, what's the actual return type here and how can we solve the problem? Of course the first impression is that we are returning a Tag, but in reality we'd like to be able to return multiple tags from a for loop, so it's a `[Tag]`, in the end, it's going to be an array of Tag arrays: `[[Tag]]`.

The buildArray method can transform these array of tag arrays into Tag arrays, that's good enough to provide for support, but we still need one more method to be able to use it properly. We have to build an expression from a single Tag to turn it into an array of tags. 🔖

```swift
@resultBuilder
public enum TagBuilder {

    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }
    
    public static func buildBlock(_ components: [Tag]...) -> [Tag] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: [Tag]) -> [Tag] {
        component
    }

    public static func buildEither(second component: [Tag]) -> [Tag] {
        component
    }

    public static func buildOptional(_ component: [Tag]?) -> [Tag] {
        component ?? []
    }

    public static func buildExpression(_ expression: Tag) -> [Tag] {
        [expression]
    }

    public static func buildArray(_ components: [[Tag]]) -> [Tag] {
        components.flatMap { $0 }
    }
}
```

This way our for loop will work. The build expression method is very powerful, it enables us to provide various input types and turn them into the data type that we actually need. I'm going to show you one more build expression example in this case to support the map function on an array of elements. This is the final result builder:

```swift
@resultBuilder
public enum TagBuilder {

    public static func buildBlock(_ components: Tag...) -> [Tag] {
        components
    }
    
    public static func buildBlock(_ components: [Tag]...) -> [Tag] {
        components.flatMap { $0 }
    }


    public static func buildEither(first component: [Tag]) -> [Tag] {
        component
    }

    public static func buildEither(second component: [Tag]) -> [Tag] {
        component
    }

    public static func buildOptional(_ component: [Tag]?) -> [Tag] {
        component ?? []
    }

    public static func buildExpression(_ expression: Tag) -> [Tag] {
        [expression]
    }

    public static func buildExpression(_ expression: [Tag]) -> [Tag] {
        expression
    }

    public static func buildArray(_ components: [[Tag]]) -> [Tag] {
        components.flatMap { $0 }
    }
}
```

Now we can use maps instead of for loops if we prefer functional methods. 😍

```swift
func buildWebpage(title: String, paragraphs: [String]) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            H1(title)
            paragraphs.map { P($0) }
        }
    }
}

let html = buildWebpage(title: "title", paragraphs: ["a", "b", "c"])
```

That's how I was able to create a DSL for my Tag hierarchy. Please note that I might had some things wrong, this was the very first DSL that I've made, but so far so good, it serves all my needs.

## A simple HTML renderer

Before we close this article I'd like to show you how I created my HTML document renderer.

```swift
struct Renderer {

    func render(tag: Tag, level: Int = 0) -> String {
        let indent = 4
        let spaces = String(repeating: " ", count: level * indent)
        switch tag.node.type {
        case .standard:
            return spaces + open(tag) + (tag.node.contents ?? "") + renderChildren(tag, level: level, spaces: spaces) + close(tag)
        case .comment:
            return spaces + "<!--" + (tag.node.contents ?? "") + "-->"
        case .empty:
            return spaces + open(tag)
        case .group:
            return spaces + (tag.node.contents ?? "") + renderChildren(tag, level: level, spaces: spaces)
        }
    }

    private func renderChildren(_ tag: Tag, level: Int, spaces: String) -> String {
        var children = tag.children.map { render(tag: $0, level: level + 1) }.joined(separator: "\n")
        if !children.isEmpty {
            children = "\n" + children + "\n" + spaces
        }
        return children
    }
    
    private func open(_ tag: Tag) -> String {
        return "<" + tag.node.name! + ">"
    }
    
    private func close(_ tag: Tag) -> String {
        "</" + tag.node.name! + ">"
    }
}
```

As you can see it's a pretty simple, yet complex struct. The open and close methods are straightforward, the interesting part happens in the render methods. The very first render function can render a tag using the node type. We just switch the type and return the HTML value according to it. if the node is a standard or a group type we also render the children using the same method.

Of course the final implementation is a bit more complex, it involves HTML attributes, it supports minification and custom indentation level, but for educational purposes this lightweight version is more than enough. Here's the final code snippet to render a HTML structure:

```swift
func buildWebpage(title: String, paragraphs: [String]) -> Html {
    Html {
        Head {
            Title(title)
        }
        Body {
            H1(title)
            paragraphs.map { P($0) }
        }
    }
}

let html = buildWebpage(title: "title", paragraphs: ["a", "b", "c"])
let output = Renderer().render(tag: html)
print(output)
```

If we compare this to our very first string based solution we can say that the difference is huge. Honestly speaking I was afraid of result builders for a very long time, I thought it's just unnecessary complexity and we don't really need them, but hey things change, and I've also changed my mind about this feature. Now I can't live without result builders and I love the code that I'm able to write by using them. I really hope that this article helped you to understand them a bit better. 🙏
