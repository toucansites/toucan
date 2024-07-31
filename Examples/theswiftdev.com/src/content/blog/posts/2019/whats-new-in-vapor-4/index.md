---
type: post
slug: whats-new-in-vapor-4
title: What's new in Vapor 4?
description: Vapor is the most popular server side Swift web application framework. This time we'll cover what's new in Vapor 4.
publication: 2019-08-26 16:20:00
tags: Vapor
authors:
  - tibor-bodecs
---

## Swift 5.1

Vapor 3 was built on top of some great new features of Swift 4.1, that's why it was only released shortly (2 months) after the new programming language arrived. This is the exact same situation with Vapor 4. [Property wrappers](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md) are heavily used in the latest version of the Vapor framework, this feature is only going to be finalized in Swift 5.1 during the fall, which means that we can expect [Vapor 4 shortly after](https://medium.com/@codevapor/vapor-4-alpha-1-releases-begin-94a4bc79dd9a). 🍁

## SwiftNIO v2 and HTTP2 support

A HUGE step forward and a long awaited feature, because HTTP2 is amazing. Multiplexed streams, server push, header compression, binary data format instead of the good old textual one over a secure layer by default. These are just a few important changes that the new protocol brings to the table. The basic implementation is already there in Vapor 4 alpha 2, I tried to setup my own HTTP2 server, but I faced a constant crash, as soon as I can make it work, I'll write a tutorial about it. 🤞

## Fluent is amazing in Vapor 4!

Controllers now have an associated database object, this means you can query directly on this database, instead of the incoming request object. Note that the Future alias is now gone, it's simply EventLoopFuture from SwiftNIO.

```swift
// Vapor 3

import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}

// Vapor 4

import Fluent
import Vapor

final class TodoController {
    let db: Database

    init(db: Database) {
        self.db = db
    }

    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: self.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        return todo.save(on: self.db).map { todo }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: self.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: self.db) }
            .transform(to: .ok)
    }
}
```

Fluent has dynamic models, also the entire database layer is more sophisticated. You can define your own keys, schemas and many more which I personally love it, because it reminds me of my really old PHP based web framework. It's really amazing that you don't have to deal the underlying database provider anymore. It's just Fluent so it really doesn't matter if it's pgsql or sqlite under the hood. ❤️

```swift
// Vapor 3

import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class Todo: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String

    /// Creates a new `Todo`.
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }

// Vapor 4

import Fluent
import Vapor

final class Todo: Model, Content {
    static let schema = "todos"

    @ID(key: "id")
    var id: Int?

    @Field(key: "title")
    var title: String

    init() { }

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
```
There is a brand new migration layer with a ridiculously easy to learn API. 👍

```swift
import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
```

## SwiftLog

A [native logger library](https://github.com/apple/swift-log) made by Apple is now the default logger in Vapor 4.

The entire logging system is bootstrapped during the boot process which I like quite a lot, because in the past I had some issues with the logger configuration in Vapor 3. 🤔

```swift
import Vapor

func boot(_ app: Application) throws {
    try LoggingSystem.bootstrap(from: &app.environment)
    try app.boot()
}
```

## "Syntactic sugar"

Some little changes were introduced in the latest version of the framework.

For example the input parameter names in the config and the routes file are just one letter long (you don't need to type that much). I personally don't like this, because we have auto-complete. I know, it's just a template and I can change it, but still... 🤐

Another small change is that the entire application launch / configuration process is way more simple than it was before, plus from now on you can shut down your app server gracefully. Overall it feels like all the API's in Vapor were polished just the right amount, I really like the changes so far. 😉

## ... and many many more!

[Tanner Nelson](https://x.com/tanner0101) posted quite a list on [Vapor's discord server](https://discord.gg/BnXmVGA) (it's such an amazing community, you should join too). I'm going to shamelessly rip that off to show you most of the things that are going to be included in Vapor 4. Here is the list:

### Vapor

- services on controllers
- synchronous content decoding
- upload / download streaming
- backpressure
- http/2
- extensible route builder (for openapi)
- apple logging
- improved session syntax
- dotenv support
- validation included
- authentication included
- XCTVapor testing module
- swift server http client
- simplified websocket endpoints
- graceful shutdown
- nio 2

### ConsoleKit

- type safe signatures

### RoutingKit

- performance improvements
- performance testing bot

### Fluent

- dynamic models
- simplified driver requirements
- eager loading: join + subquery
- partial selects
- dirty updates

### LeafKit

- improved body syntax
- separate lexer + parser

### Toolbox

- dynamic project init

## How to set up a Vapor 4 project (on macOS)?

If you want to play around with Vapor 4, you can do it right now. You just have to install [Xcode 11](https://developer.apple.com/develop/), the [Vapor toolbox](https://docs.vapor.codes/3.0/getting-started/toolbox/) and run the following command from Terminal:

```
#optional: select Xcode 11
sudo xcode-select --switch /Applications/Xcode-beta.app/Contents/Developer

#create a brand new Vapor 4 project
vapor new myproject --branch=4
cd myproject
vapor update -y
```

Personally I really love these new changes in Vapor, especially the HTTP2 support and the new Fluent abstraction. Vapor 3 was quite a big hit, I believe that this trend will continue with Vapor 4, because it's going to be a really nice refinement update. 💧

I can't wait to see some new benchmarks, because of the underlying changes in vapor, plus all the optimizations in Swift 5.1 will have such a nice impact on the overall performance. Vapor 3 was already crazy fast, but [Vapor 4 will be on fire](https://forums.swift.org/t/whats-new-in-vapor-4/31832)! 🔥
