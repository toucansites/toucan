---
slug: building-tree-data-structures-in-swift
title: Building tree data structures in Swift
description: This tutorial is about showing the pros and cons of various Swift tree data structures using structs, enums and classes.
publication: 2021-11-23 16:20:00
tags: Swift, algorithms
---

## What is a tree?

A [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) is an abstract data structure that can be used to represent hierarchies. A tree usually contains nodes with associated data values. Each node can have child nodes and these nodes are linked together via a parent-child relationship.

The name tree comes from the real-world, both digital and the physical trees have branches, there is usually one node that has many children, and those can also have subsequent child nodes. 🌳

Each node in the tree can have an associated data value and a reference to the child nodes.

The root object is where the tree begins, it's the trunk of the tree. A branch node is just some part of the tree that has another branches and we call nodes without further branches as leaves.

Of course there are various types of tree structures, maybe the most common one is the [binary tree](https://en.wikipedia.org/wiki/Binary_tree). Walking through the items in a tree is called traversal, there are multiple ways to step through the tree, in-order, pre-order, post-order and level-order. More about this later on. 😅

## Data trees using structs in Swift

After the quick intro, I'd like to show you how to build a generic [tree object using structs](https://www.hackingwithswift.com/plus/data-structures/trees) in Swift. We're going to create a simple struct that can hold any value type, by using a generic placeholder. We're also going to store the child objects in an array that uses the exact same node type. First we're going to start with a simple Node object that can store a String value.

```swift
struct Node {
    var value: String
    var children: [Node]
}

var child = Node(value: "child", children: [])
var parent = Node(value: "parent", children: [child])

print(parent) 
// Node(value: "parent", children: [Node(value: "child", children: [])])
```

Let's alter this code by introducing a generic variable instead of using a String type. This way we're going to be able to reuse the same Node struct to store all kinds of values of the same type. We're also going to introduce a new init method to make the Node creation process just a bit more simple.

```swift
struct Node<Value> {
    var value: Value
    var children: [Node]
    
    init(_ value: Value, children: [Node] = []) {
        self.value = value
        self.children = children
    }
}

var child = Node(2)
var parent = Node(1, children: [child])

print(parent)
// Node<Int>(value: 1, children: [Node<Int>(value: 2, children: [])])
```

As you can see the underlying type is an Int, Swift is smart enough to figure this out, but you can also explicitly write Node(2) or of course any other type that you'd like to use.

One thing that you have to note when using structs is that these objects are value types, so if you want to modify a tree you'll need a mutating function and you have to be careful when defining nodes, you might want to store them as variables instead of constants if you need to alter them later on. The order of your code also matters in this case, let me show you an example. 🤔

```swift
struct Node<Value> {
    var value: Value
    var children: [Node]
    
    init(_ value: Value, children: [Node] = []) {
        self.value = value
        self.children = children
    }
    
    mutating func add(_ child: Node) {
        children.append(child)
    }
}

var a = Node("a")
var b = Node("b")
var c = Node("c")

a.add(b)

print(a)
// Node<String>(value: "a", children: [Node<String>(value: "b", children: [])])

b.add(c) // this won't affect a at all

print(a)
// Node<String>(value: "a", children: [Node<String>(value: "b", children: [])])

print(b)
// Node<String>(value: "b", children: [Node<String>(value: "c", children: [])])
```

We've tried to add a child node to the b object, but since the copy of b is already added to the a object, it won't affect a at all. You have to be careful when working with structs, since you're going to pass around copies instead of references. This is usually a great advantage, but sometimes it won't give you the expected behavior.

One more thing to note about structs is that you are not allowed to use them as recursive values, so for example if we'd like to build a linked list using a struct, we won't be able to set the next item.

```swift
struct Node {
    let value: String
    // ERROR: Value type `Node` cannot have a stored property that recursively contains it.
    let next: Node?
}
```

The explanation of this issue is well-written [here](https://stackoverflow.com/questions/38785551/swift-struct-type-recursive-value), it's all about the required space when allocating the object. Please try to figure out the reasons on your own, before you click on the link. 🤔

## How to create a tree using a Swift class?

Most [common examples](https://www.raywenderlich.com/1053-swift-algorithm-club-swift-tree-data-structure) of tree structures are using classes as a base type. This solves the recursion issue, but since we're working with reference types, we have to be extremely careful with memory management. For example if we want to place a reference to the parent object, we have to declare it as a weak variable.

```swift
class Node<Value> {
    var value: Value
    var children: [Node]
    weak var parent: Node?

    init(_ value: Value, children: [Node] = []) {
        self.value = value
        self.children = children

        for child in self.children {
            child.parent = self
        }
    }

    func add(child: Node) {
        child.parent = self
        children.append(child)
    }
}

let a = Node("a")
let b = Node("b")

a.add(child: b)

let c = Node("c", children: [Node("d"), Node("e")])
a.add(child: c)

print(a) // tree now contains a, b, c, d, e
```

This time when we alter a node in the tree, the original tree will be updated as well. Since we're now working with a reference type instead of a value type, we can safely build a linked list or binary tree by using the exact same type inside our class.

```swift
class Node<Value> {
    var value: Value
    // the compiler is just fine with these types below...
    var left: Node?
    var right: Node?
    
    init(
        _ value: Value, 
        left: Node? = nil,
        right: Node? = nil
    ) {
        self.value = value
        self.left = left
        self.right = right
    }
}


let right = Node(3)
let left = Node(2)
let tree = Node(1, left: left, right: right)
print(tree) // 1, left: 2, right: 3
```

Of course you can still use protocols and structs if you prefer value types over reference types, for example you can come up with a Node protocol and then two separate implementation to represent a branch and a leaf. This is how a protocol oriented approach can look like.

```swift
protocol Node {
    var value: Int { get }
}

struct Branch: Node {
    var value: Int
    var left: Node
    var right: Node
}

struct Leaf: Node {
    var value: Int
}


let tree = Branch(
    value: 1, 
    left: Leaf(value: 2), 
    right: Leaf(value: 3)
)
print(tree)
```

I like [this solution](https://stackoverflow.com/questions/49399089/binary-tree-with-struct-in-swift) quite a lot, but of course the actual choice is yours and it should always depend on your current use case. Don't be afraid of classes, polymorphism might saves you quite a lot of time, but of course there are cases when structs are simply a better way to do things. 🤓

## Implementing trees using Swift enums

One last thing I'd like to show you in this article is how to implement a tree using the powerful enum type in Swift. Just like the recursion issue with structs, enums are also problematic, but fortunately there is a workaround, so we can use enums that references itself by applying the [indirect keyword](https://www.hackingwithswift.com/example-code/language/what-are-indirect-enums).

```swift
enum Node<Value> {
    case root(value: Value)
    indirect case leaf(parent: Node, value: Value)

    var value: Value {
        switch self {
        case .root(let value):
            return value
        case .leaf(_, let value):
            return value
        }
    }
}
let root = Node.root(value: 1)
let leaf1 = Node.leaf(parent: root, value: 2)
let leaf2 = Node.leaf(parent: leaf1, value: 3)
```

An indirect enum case can reference the enum itself, so it'll allo us to create cases with the exact same type. This way we're going to be able to store a parent node or alternatively a left or right node if we're talking about a [binary tree](https://medium.com/@mrlauriegray/swift-3-enums-and-binary-search-trees-104f5e8d47e9). Enums are freaking powerful in Swift.

```swift
enum Node<Value> {
    case empty
    indirect case node(Value, left: Node, right: Node)
}

let a = Node.node(1, left: .empty, right: .empty)
let b = Node.node(2, left: a, right: .empty)
print(b)
```

These are just a few examples how you can build various tree data structures in Swift. Of course there is a lot more to the story, but for now I just wanted to show you what are the pros and cons of each approach. You should always choose the option that you like the best, there is no silver bullet, but only options. I hope you enjoyed this little post. ☺️

If you want to know more about trees, you should read the linked articles, since they are really well-written and it helped me a lot to understand more about these data structures. [Traversing a tree](https://blog.devgenius.io/data-structure-in-swift-tree-192612915d33) is also quite an interesting topic, you can learn a lot by implementing various traversal methods. 👋
