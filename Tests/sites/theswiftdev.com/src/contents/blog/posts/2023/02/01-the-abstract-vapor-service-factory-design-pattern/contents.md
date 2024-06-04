---
slug: the-abstract-vapor-service-factory-design-pattern
title: The abstract Vapor service factory design pattern
description: In this tutorial I'm going to show you how you can create an abstract driver-based component for the Vapor framework.
publication: 2023-02-01 16:20:00
tags: Vapor
---

I've written several articles about factory design patterns on my blog and this time I'd like to talk about a special one, which you can encounter if you work with Vapor. Here's a little recap about my factory design pattern blog posts, all written in Swift:

- [Swift factory method design pattern](https://theswiftdev.com/swift-factory-method-design-pattern/)
- [Swift static factory design pattern](https://theswiftdev.com/swift-static-factory-design-pattern/)
- [Swift simple factory design pattern](https://theswiftdev.com/swift-simple-factory-design-pattern/)
- [Swift abstract factory design pattern](https://theswiftdev.com/swift-abstract-factory-design-pattern/)
- [Comparing factory design patterns](https://theswiftdev.com/comparing-factory-design-patterns/)

Now let's dive in to the "Fluent pattern". In order to understand this architecture, first we should examine the related Swift packages first. There is the [FluentKit](https://github.com/vapor/fluent-kit) library and several Fluent database driver implementations ([SQLite](https://github.com/vapor/fluent-sqlite-driver), [PostgreSQL](https://github.com/vapor/fluent-postgres-driver), [MySQL](https://github.com/vapor/fluent-mysql-driver), etc.), all based on the FluentKit product. Also there is one package that connects Fluent with Vapor, this one is simply called: [Fluent](https://github.com/vapor/fluent). 📀

- FluentKit - contains the abstract interface (without Vapor, using SwiftNIO)
- Fluent[xy]Driver - contains the implementation defined in FluentKit
- Fluent - connects FluentKit with Vapor, by extending Vapor

This is the base structure, the FluentKit library provides the following abstract interfaces, which you have to implement if you want to create your own driver implementation. Unfortunately you won't be able to find proper documentation for these interfaces, so I'll explain them a bit:

- Database - Query execution and transaction related functions
- DatabaseContext - Holds the config, logger, event loop, history and page size limit
- DatabaseDriver - A factory interface to create and shutdown Database instances
- DatabaseID - A unique ID to store database configs, drivers and instances
- DatabaseError - A generic database related error protocol
- DatabaseConfiguration - A protocol to create DatabaseDriver objects
- DatabaseConfigurationFactory - A box-like object to hide driver related stuff
- Databases - Shared config, driver and running instance storage

As you can see there are many protocols involved in this architecture, but I'll try to walk you through the entire driver creation flow and hopefully you'll be able to understand how the pieces are related, and how can build your own drivers or even Vapor components based on this.

Fluent is written as a [service for Vapor](https://docs.vapor.codes/advanced/services/) using the underlying shared storage object, this is what stores a reference to the [Databases](https://github.com/vapor/fluent-kit/blob/main/Sources/FluentKit/Database/Databases.swift) instance. This object has two hash maps, for storing configurations and running driver instances using the DatabaseID as a key for both. 🔑

When you ask for a driver, the Databases object will check if that driver exists, if yes, it'll simply return it and story over. The interesting part happens when the driver does not exists yet in the Databases storage. First the system will check for a pre-registered driver implementation.

```swift
app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
```

This line above registers a new driver configuration for the shared Databases. The `.sqlite()` method is a static function on the `DatabaseConfigurationFactory` which creates a new SQLite specific configuration and hides it using the `init(make:)` call. The [SQLite related configuration](https://github.com/vapor/fluent-sqlite-driver/blob/main/Sources/FluentSQLiteDriver/FluentSQLiteConfiguration.swift) implements the DatabaseConfiguration protocol, so it can be used as a valid config when the system creates the actual database context.

The config object is also responsible for creating the specific driver object using the Databases object if needed. At this point we've got a configuration and a driver instance registered in the databases storage. What happens if someone asks for a database instance?

Depending on the context, you can ask for a Database implementation through the app.db or req.db properties. This is defined in the [FluentProvider code](https://github.com/vapor/fluent/blob/main/Sources/Fluent/FluentProvider.swift) and behind the scenes everything can be traced back to the Databases class. Since you only want to have a single shared storage for all the drivers, but you also want to avoid the singleton pattern, you should hook this service up to the Application class. This is how the Vapor folks did it anyway. 🤓

```swift
let db: Database = req.db
let db: Database = req.db(.sqlite)

let db: Database = app.db
let db: Database = app.db(.sqlite)
```

When you ask for a database, or a database with an explicit identifier, you are essentially calling a make method inside the Databases class, which is going look for a registered configuration and a driver implementation using the hashes and it'll call the driver's make method and pass around the logger, the event loop and the current database configuration as a database context object.

We can say that after you ask for an abstract `Database` driver, a new `DatabaseDriver` instance reference (associated with a given `DatabaseID`) will be stored inside the Databases class and it'll always make you a new Database reference with the current `DatabaseContext`. If the driver already exists, then it'll be reused, but you still get new Database references (with the associated context) every time. So, it is important to note that there is only one DatabaseDriver instance per configuration / database identifier, but it can create multiple Database objects. 🤔

Ok, I know, it's quite complicated, but here's an oversimplified version in Swift:

```swift
final class Databases {
    var configs: [DatabaseID: DatabaseConfiguration] = [:]
    var drivers: [DatabaseID: DatabaseDriver] = [:]

    func make(
        _ id: DatabaseID,
        logger: Logger,
        on eventLoop: EventLoop
    ) -> Database {
        let config = configs[id]!

        if drivers[id] == nil {
            drivers[id] = config.make(self)
        }
        let context = DatabaseContext(config, logger, eventLoop)
        return drivers[id]!.make(context)
    }

    func use(_ config: DatabaseConfiguration, for id: DatabaseID) {
        configs[id] = config
    }
}
```

And the Vapor service extension could be interpreted somewhat like this:

```swift
extension Application {

    var databases: Databases {
        get {
            if storage[DatabasesKey.self] == nil {
                storage[DatabasesKey.self] = .init()
            }
            return storage[DatabasesKey.self]
        }
        set {
            self.storage[MyConfigurationKey.self] = newValue
        }
    }

    var db: Database {
        databases.make(
            .default, 
            logger: logger, 
            eventLoop: eventLoopGroup.next()
        )
    }
}
```

You can apply the same principles and create an extension over the Request object to access a Database instance. Of course there's a lot more happening under the hood, but the purpose of this article is to get a basic overview of this pattern, so I'm not going into those details now. 🙃

Honestly I really like this approach, because it's elegant and it can completely hide driver specific details through these abstractions. I followed the exact same principles when I created the [Liquid file storage driver for Vapor](https://github.com/binarybirds/liquid/) and learned a lot during the process. Although, you should note that not everything is a good candidate for being implemented an "abstract Vapor service factory" design pattern (or whatever we call this approach). Anyway, I really hope that this quick tutorial will help you to create your own Vapor components, if needed. 🤷‍♂️
