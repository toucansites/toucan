---
type: post
slug: the-future-of-server-side-swift
title: The future of server side Swift
description: What's going to happen with Swift on the Server in 2022? Distributed actors, Vapor 5, some predictions and wishes.
publication: 2022-01-05 16:20:00
tags: Vapor, Swift
authors:
  - tibor-bodecs
---

## The new Swift concurrency model

One of the greatest thing about Swift 5.5 is definitely the new [concurrency model](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html), which introduced quite a lot of new features and APIs. The implementation of the [async / await](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md) proposal allows us completely eliminate the need of unnecessary closures and completion handlers. [Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md) are great for isolating data, they can prevent data races and protect you from unwanted memory issues too. With the [structured concurrency](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md) features we're able to define tasks, we can form dependencies between them and they even have built-in cancellation support.

With these features added we can say that Swift is a great language for writing concurrent code, but what's missing? Well, of course there is always room for improvements and in this case I have some features that I'd love to see coming to Swift. 🤔

For example currently there is no way to define an executor object for an actor. This would be a great addition for SwiftNIO and many more server side related projects, because it'd heavily reduce the overhead of context switching. An actor with a [custom executor](https://forums.swift.org/t/support-custom-executors-in-swift-concurrency/44425) could have an event loop and this way it would be possible to ensure that all the future calls are tied to the exact same event loop.

The other thing I'd like to mention is called [distributed actors](https://www.swift.org/blog/distributed-actors/), this feature is definitely going to come to Swift in the near future. Distributed actors allow developers to scale their programs beyond a single process or node, this means that your code can run on multiple processes or even multiple machines by taking advantage of [location transparency](https://en.wikipedia.org/wiki/Location_transparency). Honestly, I don't know much about distributed actors yet, but I can imagine that this is going to be a game-changer feature. 😍

I know this is just the beginning of a new era, but still the new concurrency model change quite a lot about how we build our programs. Async / await is extremely powerful and as we move forward and learn more about actors our Swift apps will get even better, through the built-in safety features that they provide. Building reliable apps is a must and I really like this direction that we're heading.

## On the road to Vapor 5

Vapor 4 is amazing, but what are the next steps for the web framework? You can find out a little bit more about the future of Vapor by joining the [official discord server](https://discord.com/invite/vapor), there is a vapor-5 channel where people already started to throw in ideas about the next major release.

Personally, I'd like to see some minor changes about Vapor, but I'd like to see a major API redesign for Fluent. Currently Fluent Models are working like repositories and they also provide the structural definition for the database schemas. Sorry to say, but I hate this approach. I believe that the schema definition should be completely separated from the queried models. For example:

```swift
import Vapor
import Fluent

struct TodoCreate: Codable {
    let name: String
    let isCompleted: Bool
}

struct TodoList: Codable {
    let id: UUID
    let name: String
    let isCompleted: Bool
}

struct TodoSchema: DatabaseSchema {

    var name: String = "todos"

    var definition = Definition {
        Migration(id: "v1") {
            Process {
                CreateSchema(name) {
                    Field(type: .id)
                    Field(type: .string, .required, key: "name")
                    Field(type: .bool, .required, key: "isComplete")
                    // Unique(on: "title")
                }
            }
            Revert {
                DeleteSchema(name)
            }
        }
        Migration(id: "seed") {
            Process {
                CreateRecords(schema: name) {
                    TodoCreate(name: "foo", isComplete: true)
                }
            }
            Revert {
                DeleteRecords(schema: name)
            }
        }
    }
}

struct TodoRepository: DatabaseRepository {
    typealias Create = TodoCreate
    typealias List = TodoList
}

extension TodoList: Content {}

func someAsyncRequestHandler(_ req: Request) async throws -> [TodoList] {
    let object = TodoCreate(name: "bar", isCompleted: false)
    try await TodoRepository.create(object, on: req.db) 
    return try await TodoRepository.findAll(on: req.db) 
}
```

As you can see instead of mixing up the Model definition with migration related info this way the schema definition could have its own place and the database repository could take care of all the querying and record alteration features. It would be nice to have a DSL-like approach for migrations, since I don't see any benefits of passing around that stupid database pointer. 😅

Maybe you think, hey you're crazy this idea is stupid, but still my real-world experience is that I need something like this in the future, so yeah, hopefully the core team will see this post and get some inspiration for their future work. Maybe it's too late and they don't want to include such drastic changes, but who knows, I can still hope & wish for such things, right?

My other secret wish is the ability to dynamically reset a Vapor app, because in order to enable and disable a module I'd have to remove all the registered routes, middlewares, commands and migrations from the system. Currently this is just partially possible, but I really hope that the core team will provide some kind of open API that'd let me do this.

```swift
import Vapor

public extension Application {
    func reset() {
        app.middleware.storage = []
        app.routes.all = []
        app.migrations.storage = [:]
        app.commands.commands = [:]
    }
}

try app.reset()
```

If this was possible I could load a dylib and provide a proper install, update, delete mechanism through a module manager. This would allow Feather CMS to open a module store and install extensions with just a single click, that'd be HUGE, so please give me this API. 🙏

Anyway, these are just my wishes, Vapor 5 will be a great release I'm quite sure about that, one more additional thing is that I'd like to see is to reduce the size of the core library (opt-out from websockets, console and multipart libs?, merge async-kit with the core?), it'd be nice to completely drop event loop future based APIs and drop the Async* prefixes. That's all I'd like to see.

## Feather CMS

So, after a bit more than one and a half year of development, now I'm getting ready to release an actual version of my content management system. I've had several ups and downs, personal issues during this period of time, but I never stopped thinking about Feather. 🪶

The main idea and purpose is to provide a reliable type-safe modular CMS, written entirely in Swift. The long term goal is to build a dynamic module system, just like the Wordpress plugin ecosystem and I'd be able to install and remove components with just a single click, without the need of recompiling the code. This is why I've researched so much about dylibs and frameworks. This is the reason why I'm using hook functions and why I'm trying to encapsulate everything inside a module. The good news is that modules will have public API libraries so the server side code can be shared with clients (mostly iOS, but the API code can be easily converted into another languages).

### What are the problems that Feather tries to solve?

- There is no easy to use backend (API) system for mobile apps.
- Building admin interfaces on top of a set of APIs is a pain in the ass.
- API definitions are not shared with the client at all (leads to issues)
- Backend developers don't update API docs properly (or they don't write it at all)
- There is no API / CMS with proper user permission & role management
- Swift is resource (low memory footprint) and cost effective on the server

Hopefully with Feather I'll be able to tackle a few of these issues from the list. Please remember, that this is just my point of view, of course there are many great examples out there and I've seen properly written systems using node.js, golang or PHP. I don't mind using other technologies, I'm a heavy Wordpress user and I like JavaScript too, but I can also see the potential in Swift. 💪

I'd love to see a future where more and more people could use backends written in Swift, maybe even using Feather CMS. I know that changing things will take time and I also know that people don't like changes, but I really hope that they'll realize the importance of Swift.

We are living in a world where resources are limited and by using a more efficient language we could lower our ecological footprint. With the current chip shortage, we should really thik about this. The M1 CPU and Swift could take over the servers and we could drastically reduce the cost that we have to pay for our backend infrastructures. In 10 years I really wish to look back to this period of time as the beginning of the server side Swift era, but who knows, we'll see. 🤐
