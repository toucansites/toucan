---
type: post
slug: swift-abstract-factory-design-pattern
title: Swift abstract factory design pattern
description: "Let's combine factory method with simple factory voilá: here is the abstract factory design pattern written in Swift language!"
publication: 2018-06-03 16:20:00
tags: Swift, iOS, design patterns
authors:
  - tibor-bodecs
---

## Abstract factory in Swift

The [abstract factory](https://en.wikipedia.org/wiki/Abstract_factory_pattern) pattern provides a way to encapsulate a group of individual factories that have a common theme without specifying their concrete classes.

So [abstract factory](https://medium.com/jeremy-codes/the-abstract-factory-8bbfffc2f77c) is there for you to create families of related objects. The implementation usually combines simple factory & [factory method](https://stackoverflow.com/questions/5739611/differences-between-abstract-factory-pattern-and-factory-method) principles. Individual objects are created through factory methods, while the whole thing is wrapped in an "abstract" simple factory. Now check the code! 😅

```swift
// service protocols
protocol ServiceFactory {
    func create() -> Service
}

protocol Service {
    var url: URL { get }
}

// staging
class StagingService: Service {
    var url: URL { return URL(string: "https://dev.localhost/")! }
}

class StagingServiceFactory: ServiceFactory {
    func create() -> Service {
        return StagingService()
    }
}

// production
class ProductionService: Service {
    var url: URL { return URL(string: "https://live.localhost/")! }
}

class ProductionServiceFactory: ServiceFactory {
    func create() -> Service {
        return ProductionService()
    }
}

// abstract factory
class AppServiceFactory: ServiceFactory {

    enum Environment {
        case production
        case staging
    }

    var env: Environment

    init(env: Environment) {
        self.env = env
    }

    func create() -> Service {
        switch self.env {
        case .production:
            return ProductionServiceFactory().create()
        case .staging:
            return StagingServiceFactory().create()
        }
    }
}

let factory = AppServiceFactory(env: .production)
let service = factory.create()
print(service.url)
```

As you can see using an abstract factory will influence the whole application logic, while factory methods have effects only on local parts. Implementation can vary for example you could also create a standalone protocol for the abstract factory, but in this example I wanted to keep things as simple as I could.

Abstract factories are often used to achieve object independence. For example if you have multiple different SQL database connectors (PostgreSQL, MySQL, etc.) written in Swift with a common interface, you could easily switch between them anytime using this pattern. Same logic could be applied for anything with a similar scenario. 🤔
