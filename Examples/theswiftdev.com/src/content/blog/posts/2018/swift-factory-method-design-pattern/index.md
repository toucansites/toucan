---
type: post
slug: swift-factory-method-design-pattern
title: Swift factory method design pattern
description: The factory method design pattern is a dedicated non-static method for hiding the creation logic of an object. Let's make it in Swift!
publication: 2018-05-31 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

## Factory method is just a non-static method

Let's face it, this pattern is just a method usually backed by simple protocols & classes. Start with a really simple example: imagine a class that can create a base URL for your service endpoint. Let's call it service factory. 😅

```swift
class ServiceFactory {
    func createProductionUrl() -> URL {
        return URL(string: "https://localhost/")!
    }
}
let factory = ServiceFactory()
factory.createProductionUrl()
```

You might think, that hey, this is not even close to a [factory method](https://medium.com/jeremy-codes/factory-method-in-swift-d5222dd6e61d) pattern, but wait for it... let's make things a little bit complicated by creating a protocol for the service class and a protocol for returning the URL as well. Now we can implement our base production URL protocol as a separate class and return that specific instance from a production service factory class. Just check the code you'll get it:

```swift
protocol ServiceFactory {
    func create() -> Service
}

protocol Service {
    var url: URL { get }
}

class ProductionService: Service {
    var url: URL { return URL(string: "https://localhost/")! }
}

class ProductionServiceFactory: ServiceFactory {
    func create() -> Service {
        return ProductionService()
    }
}

let factory = ProductionServiceFactory()
let request = factory.create()
```

Why did we separated all the logic into two classes and protocols? Please believe me decoupling is a good thing. From now on you could easily write a mocked service with a dummy URL to play around with. Obviously that'd need a matching factory class.

Those mock instances would also implement the service protocols so you could add new types in a relatively painless way without changing the original codebase. The [factory method](https://medium.com/@NilStack/swift-world-design-patterns-factory-method-2be4bb3c73cc) solves one specific problem of a simple factory pattern. If the list - inside the switch-case - becomes too long, maintaining new objects will be hell with just one factory. [Factory method](https://stackoverflow.com/questions/69849/factory-pattern-when-to-use-factory-methods) solves this by introducing multiple factory objects.
