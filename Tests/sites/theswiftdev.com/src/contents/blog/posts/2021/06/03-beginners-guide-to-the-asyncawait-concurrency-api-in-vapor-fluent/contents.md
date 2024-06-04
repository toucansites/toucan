---
slug: beginners-guide-to-the-asyncawait-concurrency-api-in-vapor-fluent
title: Beginner's guide to the async/await concurrency API in Vapor & Fluent
description: Learn how to convert your existing EventLoopFuture based Vapor server app using the new async/await Swift feature.
publication: 2021-06-03 16:20:00
tags: Vapor, Concurrency
---

## Is async/await going to improve Vapor?

So you might wonder why do we even need to add async/await support to our codebase? Well, let me show you a dirty example from a generic controller inside the [Feather CMS](https://github.com/feathercms/feather/) project.

```swift
func update(req: Request) throws -> EventLoopFuture<Response> {
    accessUpdate(req: req).flatMap { hasAccess in
        guard hasAccess else {
            return req.eventLoop.future(error: Abort(.forbidden))
        }
        let updateFormController = UpdateForm()
        return updateFormController.load(req: req)
            .flatMap { updateFormController.process(req: req) }
            .flatMap { updateFormController.validate(req: req) }
            .throwingFlatMap { isValid in
                guard isValid else {
                    return renderUpdate(req: req, context: updateFormController).encodeResponse(for: req)
                }
                return findBy(try identifier(req), on: req.db)
                    .flatMap { model in
                        updateFormController.context.model = model as? UpdateForm.Model
                        return updateFormController.write(req: req).map { model }
                    }
                    .flatMap { beforeUpdate(req: req, model: $0) }
                    .flatMap { model in model.update(on: req.db).map { model } }
                    .flatMap { model in updateFormController.save(req: req).map { model } }
                    .flatMap { afterUpdate(req: req, model: $0) }
                    .map { req.redirect(to: req.url.path) }
            }
    }
}
```

What do you think? Is this code readable, easy to follow or does it look like a good foundation of a [historical monumental building](https://en.wikipedia.org/wiki/Pyramid_of_doom_(programming))? Well, I'd say it's hard to reason about this piece of Swift code. 😅

I'm not here to scare you, but I suppose that you've seen similar (hopefully more simple or better) EventLoopFuture-based code if you've worked with Vapor. [Futures and promises](https://theswiftdev.com/promises-in-swift-for-beginners/) are just fine, they've helped us a lot to deal with asynchronous code, but unfortunately they come with maps, flatMaps and other block related solutions that will eventually lead to quite a lot of trouble.

Completion handlers (callbacks) have many problems:

- Pyramid of doom
- Memory management
- Error handling
- Conditional block execution

We can say it's easy to make mistakes if it comes to completion handlers, that's why we have a shiny new feature in Swift 5.5 called [async/await](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md) and it aims to solve these problems I mentioned before. If you are looking for an [introduction to async/await](https://theswiftdev.com/introduction-to-asyncawait-in-swift/) in Swift you should read my other tutorial first, to learn the basics of this new concept.

So Vapor is full of EventLoopFutures, these objects are coming from the [SwiftNIO](https://github.com/apple/swift-nio) framework, they are the core building blocks of all the async APIs in both frameworks. By introducing the async/await support we can eliminate quite a lot of unnecessary code (especially completion blocks), this way our codebase will be more easy to follow and maintain. 🥲

Most of the Vapor developers were waiting for this to happen for quite a long time, because everyone felt that EventLoopFutures (ELFs) are just freakin' hard to work with. If you search a bit you'll find quite a lot of complains about them, also the 4th major version of Vapor dropped the old shorthand typealiases and [exposed NIO's async API directly](https://docs.vapor.codes/4.0/upgrading/#nio). I think this was a good decision, but still the framework god many complaints about this. 👎

Vapor will greatly benefit from adapting to the new async/await feature. Let me show you how to convert an existing ELF-based Vapor project and take advantage of the new concurrency features.

## How to convert a Vapor project to async/await?

We're going to use our previous Todo project as a base template. It has a type-safe RESTful API, so it's happens to be just the perfect candidate for our async/await migration process. ✅


The new async/await API for Vapor & Fluent are only available yet as a feature branch, so we have to alter our Package.swift manifest file if we'd like to use these new features.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "myProject",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-kit", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
    ]
)
```

We're going to convert the following TodoController object, because it has quite a lot of ELF related functions that can take advantage of the new Swift concurrency features.

```swift
import Vapor
import Fluent
import TodoApi

struct TodoController {

    private func getTodoIdParam(_ req: Request) throws -> UUID {
        guard let rawId = req.parameters.get(TodoModel.idParamKey), let id = UUID(rawId) else {
            throw Abort(.badRequest, reason: "Invalid parameter `\(TodoModel.idParamKey)`")
        }
        return id
    }

    private func findTodoByIdParam(_ req: Request) throws -> EventLoopFuture<TodoModel> {
        TodoModel
            .find(try getTodoIdParam(req), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // MARK: - endpoints
    
    func list(req: Request) throws -> EventLoopFuture<Page<TodoListObject>> {
        TodoModel.query(on: req.db).paginate(for: req).map { $0.map { $0.mapList() } }
    }
    
    func get(req: Request) throws -> EventLoopFuture<TodoGetObject> {
        try findTodoByIdParam(req).map { $0.mapGet() }
    }

    func create(req: Request) throws -> EventLoopFuture<TodoGetObject> {
        let input = try req.content.decode(TodoCreateObject.self)
        let todo = TodoModel()
        todo.create(input)
        return todo.create(on: req.db).map { todo.mapGet() }
    }
    
    func update(req: Request) throws -> EventLoopFuture<TodoGetObject> {
        let input = try req.content.decode(TodoUpdateObject.self)

        return try findTodoByIdParam(req)
            .flatMap { todo in
                todo.update(input)
                return todo.update(on: req.db).map { todo.mapGet() }
            }
    }
    
    func patch(req: Request) throws -> EventLoopFuture<TodoGetObject> {
        let input = try req.content.decode(TodoPatchObject.self)

        return try findTodoByIdParam(req)
            .flatMap { todo in
                todo.patch(input)
                return todo.update(on: req.db).map { todo.mapGet() }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try findTodoByIdParam(req)
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}
```

The very first method that we're going to convert is the `findTodoByIdParam`. Fortunately this version of FluentKit comes with a set of async functions to query and modify database models.

We just have to remove the `EventLoopFuture` type and write async before the throws keyword, this will indicate that our function is going to be executed asynchronously.

> NOTE: It is worth to mention that you can only call an async function from async functions. If you want to call an async function from a sync function you'll have to use a special (deatch) method. You can call however sync functions inside async methods without any trouble. 🔀

We can use the new async find method to fetch the TodoModel based on the UUID parameter. When you call an async function you have to await for the result. This will let you use the return type just like it it was a sync call, so there is no need for completion blocks anymore and we can simply guard the optional model result and throw a notFound error if needed. Async functions can throw as well, so you might have to write try await when you call them, note that the order of the keywords is fixed, so try always comes before await, and the signature is always async throws.

```swift
func findTodoByIdParam(_ req: Request) async throws -> TodoModel {
    guard let model = try await TodoModel.find(try getTodoIdParam(req), on: req.db) else {
        throw Abort(.notFound)
    }
    return model
}
```

Compared to the previous method I think this one changed just a little, but it's a bit cleaner since we were able to use a regular guard statement instead of the "strange" unwrap thingy. Now we can start to convert the REST functions, first let me show you the async version of the list handler.

```swift
func list(req: Request) async throws -> [TodoListObject] {
    try await TodoModel.query(on: req.db).all().map { $0.mapList() }
}
```

Same pattern, we've replaced the EventLoopFuture generic type with the async function signature and we can return the TodoListObject array just as it is. In the function body we were able to take advantage of the async all() method and map the returned array of TodoModels using a regular Swift map instead of the mapEach function from the SwiftNIO framework. This is also a minor change, but it's always better to used standard Swift functions, because they tend to be more efficient and future proof, sorry NIO authors, you did a great job too. 😅🚀

```swift
func get(req: Request) throws -> EventLoopFuture<TodoGetObject> {
    try findTodoByIdParam(req).map { $0.mapGet() }
}
```

The get function is relatively straightforward, we call our findTodoByIdParam method by awaiting for the result and use a regular map to convert our TodoModel item into a TodoGetObject.

In case you haven't read my previous article (go and read it please), we're always converting the TodoModel into a regular Codable Swift object so we can share these API objects as a library (iOS client & server side) without additional dependencies. We'll use such DTOs for the create, update & patch operations too, let me show you the async version of the create function next. 📦

```swift
func create(req: Request) async throws -> TodoGetObject {
    let input = try req.content.decode(TodoCreateObject.self)
    let todo = TodoModel()
    todo.create(input)
    try await todo.create(on: req.db)
    return todo.mapGet()
}
```

This time the code looks more sequential, just like you'd expect when writing synchronous code, but we're actually using async code here. The change in the update function is even more notable.

```swift
func update(req: Request) async throws -> TodoGetObject {
    let input = try req.content.decode(TodoUpdateObject.self)
    let todo = try await findTodoByIdParam(req)
    todo.update(input)
    try await todo.update(on: req.db)
    return todo.mapGet()
}
```

Instead of utilizing a flatMap and a map on the futures, we can simply await for both of the async function calls, there is no need for completion blocks at all, and the entire function is more clean and it makes more sense even if you just take a quick look at it. 😎

```swift
func patch(req: Request) async throws -> TodoGetObject {
    let input = try req.content.decode(TodoPatchObject.self)
    let todo = try await findTodoByIdParam(req)
    todo.patch(input)
    try await todo.update(on: req.db)
    return todo.mapGet()
}
```

The patch function looks just like the update, but as a reference let me insert the original snippet for the patch function here real quick. Please tell me, what do you think of both versions... 🤔

```swift
func patch(req: Request) throws -> EventLoopFuture {
    let input = try req.content.decode(TodoPatchObject.self)

    return try findTodoByIdParam(req)
        .flatMap { todo in
            todo.patch(input)
            return todo.update(on: req.db).map { todo.mapGet() }
        }
}
```

Yeah, I thought so. Code should be self-explanatory, the second one is harder to read, you have to examine it line-by-line, even take a look at the completion handlers to understand what does this function actually does. By using the new concurrency API the patch handler function is just trivial.

```swift

func delete(req: Request) async throws -> HTTPStatus {
    let todo = try await findTodoByIdParam(req)
    try await todo.delete(on: req.db)
    return .ok
}
```

Finally the delete operation is a no-brainer, and the good news is that Vapor is also updated to support async/await route handlers, this means that we don't have to alter anything else inside our Todo project, except this controller of course, we can now build and run the project and everything should work just fine. This is a great advantage and I love how smooth is the transition.

So what do you think? Is this new Swift concurrency solution something that you could live with on a long term? I strongly believe that async/await is going to be utilized way more on the server side. iOS (especially SwiftUI) projects can take more advantage of the Combine framework, but I'm sure that we'll see some new async/await features there as well. 😉
