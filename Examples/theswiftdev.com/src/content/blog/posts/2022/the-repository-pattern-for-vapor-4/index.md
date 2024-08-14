---
type: post
title: The repository pattern for Vapor 4
description: "In this article I'm going to talk about the repository design pattern and give you a few Fluent ORM tips for your Vapor 4 app."
publication: 2022-03-03 16:20:00
tags: 
    - vapor
    - server
authors:
    - tibor-bodecs
---

## Fluent is essentially broken

The more I use the [Fluent ORM framework](https://docs.vapor.codes/4.0/fluent/overview/) the more I realize how hard it is to work with it. I'm talking about a particular design issue that I also mentioned in [the future of server side Swift article](https://theswiftdev.com/the-future-of-server-side-swift/). I really don't like the idea of property wrappers and abstract database models.

What's the problem with the current database model abstraction? First of all, the optional ID property is confusing. For example you don't have to provide an identifier when you insert a record, it can be an nil value and the ORM system can create a unique identifier (under the hood using a generator) for you. So why do we have an id for create operations at all? Yes, you might say that it is possible to specify a custom identifier, but honestly how many times do we need that? If you want to identify a record that's going to be something like a key, not an id field. 🙃

Also this optional property can cause some other issues, when using fluent you can require an id, which is a throwing operation, alternatively you can unwrap the optional property if you're sure that the identifier already exists, but this is not a safe approach at all.

My other issue is related to initializers, if you define a custom model you always have to provide an empty `init() {}` method for it, otherwise the compiler will complain, because models have to be classes. BUT WHY? IMHO the reason relates to this issue: you can query the database models using the model itself. So the model acts like a repository that you can use to query the fields, and it also represents the the record itself. Isn't this against the clean principles? 🤔

Okay, one last thing. Property wrappers, field keys and migrations. The core members at Vapor told us that this approach will provide a safe way to query my models and I can be sure that field keys won't be messed up, but I'm actually struggling with versioning in this case. I had to introduce a v1, v2, vN structure both for the field keys and the migration, which actually feels a bit worse than using raw strings. It is over-complicated for sure, and it feels like the schema definition is mixed up with the actual query mechanism and the model layer as well.

Sorry folks, I really appreciate the effort that you've put into Fluent, but these issues are real and I know that you can fix them on the long term and make the developer experience a lot better.

## How to make Fluent a bit better?

On the short term I'm trying to fix these issues and fortunately there is a nice approach to separate the query mechanism from the model layer. It is called the [repository pattern](https://docs.vapor.codes/4.0/upgrading/#repositories) and I'd like to give a huge credit to [0xTim](https://x.com/0xTim) again, because he made a cool answer on [StackOverlow](https://stackoverflow.com/questions/63333118/understanding-how-to-initialize-a-vapor-4-repository) about this topic.

Anyway, the main idea is that you wrap the `Request` object into a custom repository, it's usually a struct, then you only call database related queries inside this specific object. If we take a look at at the default project template (you can generate one by using the [vapor toolbox](https://docs.vapor.codes/4.0/install/linux/#install-toolbox)), we can easily create a new repository for the Todo models.

```swift
import Vapor
import Fluent

struct TodoRepository {
    var req: Request
    
    /// initialize the repository with a request object
    init(req: Request) {
        self.req = req
    }
    
    /// query the Todo models using the req.db property
    func query() -> QueryBuilder<Todo> {
        Todo.query(on: req.db)
    }
    
    /// query the models and filter by an identifier
    func query(_ id: Todo.IDValue) -> QueryBuilder<Todo> {
        query().filter(\.$id == id)
    }
    
    /// query the models and filter by multiple identifiers
    func query(_ ids: [Todo.IDValue]) -> QueryBuilder<Todo> {
        query().filter(\.$id ~~ ids)
    }

    /// list all the available Todo items
    func list() async throws -> [Todo] {
        try await query().all()
    }
    
    /// get one Todo item by an identifier if it exists
    func get(_ id: Todo.IDValue) async throws -> Todo? {
        try await get([id]).first
    }

    /// get the list of the Todo items by multiple identifiers
    func get(_ ids: [Todo.IDValue]) async throws -> [Todo] {
        try await query(ids).all()
    }

    /// create a Todo model and return the updated model (with an id)
    func create(_ model: Todo) async throws -> Todo {
        try await model.create(on: req.db)
        return model
    }
    
    /// update a Todo model
    func update(_ model: Todo) async throws -> Todo {
        try await model.update(on: req.db)
        return model
    }

    /// delete a Todo item based on the identifier
    func delete(_ id: Todo.IDValue) async throws {
        try await delete([id])
    }

    /// delete multiple Todo items based on id values
    func delete(_ ids: [Todo.IDValue]) async throws {
        try await query(ids).delete()
    }
}
```

That's how we are can manipulate Todo models, from now on you don't have to use the static methods on the model itself, but you can use an instance of the repository to alter your database rows. The repository can be hooked up to the Request object by using a common pattern. The most simple way is to return a service every time you need it.

```swift
import Vapor

extension Request {
    
    var todo: TodoRepository {
        .init(req: self)
    }
}
```

Of course this is a very basic solution and it pollutes the namespace under the Request object, I mean, if you have lots of repositories this can be a problem, but first let me show you how to refactor the controller by using this simple method. 🤓

```swift
import Vapor

struct TodoController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Todo] {
        try await req.todo.list()
    }

    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        return try await req.todo.create(todo)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("todoID", as: Todo.IDValue.self) else {
            throw Abort(.notFound)
        }
        try await req.todo.delete(id)
        return .ok
    }
}
```

As you can see this way we were able to eliminate the Fluent dependency from the controller, and we can simply call the appropriate method using the repository instance. Still if you want to unit test the controller it is not possible to mock the repository, so we have to figure out something about that issue. First we need some new protocols.

```swift
public protocol Repository {
    init(_ req: Request)
}

public protocol TodoRepository: Repository {
    func query() -> QueryBuilder<Todo>
    func query(_ id: Todo.IDValue) -> QueryBuilder<Todo>
    func query(_ ids: [Todo.IDValue]) -> QueryBuilder<Todo>
    func list() async throws -> [Todo]
    func get(_ ids: [Todo.IDValue]) async throws -> [Todo]
    func get(_ id: Todo.IDValue) async throws -> Todo?
    func create(_ model: Todo) async throws -> Todo
    func update(_ model: Todo) async throws -> Todo
    func delete(_ ids: [Todo.IDValue]) async throws
    func delete(_ id: Todo.IDValue) async throws
}
```

Next we're going to define a shared repository registry using the `Application` extension. This registry will allow us to register repositories for given identifiers, we'll use the RepositoryId struct for this purpose. The `RepositoryRegistry` will be able to return a factory instance with a reference to the required request and registry service, this way we're going to be able to create an actual Repository based on the identifier. Of course this whole ceremony can be avoided, but I wanted to come up with a generic solution to store repositories under the `req.repository` namespace. 😅

```swift
public struct RepositoryId: Hashable, Codable {

    public let string: String
    
    public init(_ string: String) {
        self.string = string
    }
}

public final class RepositoryRegistry {

    private let app: Application
    private var builders: [RepositoryId: ((Request) -> Repository)]

    fileprivate init(_ app: Application) {
        self.app = app
        self.builders = [:]
    }

    fileprivate func builder(_ req: Request) -> RepositoryFactory {
        .init(req, self)
    }
    
    fileprivate func make(_ id: RepositoryId, _ req: Request) -> Repository {
        guard let builder = builders[id] else {
            fatalError("Repository for id `\(id.string)` is not configured.")
        }
        return builder(req)
    }
    
    public func register(_ id: RepositoryId, _ builder: @escaping (Request) -> Repository) {
        builders[id] = builder
    }
}

public struct RepositoryFactory {
    private var registry: RepositoryRegistry
    private var req: Request
    
    fileprivate init(_ req: Request, _ registry: RepositoryRegistry) {
        self.req = req
        self.registry = registry
    }

    public func make(_ id: RepositoryId) -> Repository {
        registry.make(id, req)
    }
}

public extension Application {

    private struct Key: StorageKey {
        typealias Value = RepositoryRegistry
    }
    
    var repositories: RepositoryRegistry {
        if storage[Key.self] == nil {
            storage[Key.self] = .init(self)
        }
        return storage[Key.self]!
    }
}

public extension Request {
    
    var repositories: RepositoryFactory {
        application.repositories.builder(self)
    }
}
```

As a developer you just have to come up with a new unique identifier and extend the RepositoryFactory with your getter for your own repository type.

```swift
public extension RepositoryId {
    static let todo = RepositoryId("todo")
}

public extension RepositoryFactory {

    var todo: TodoRepository {
        guard let result = make(.todo) as? TodoRepository else {
            fatalError("Todo repository is not configured")
        }
        return result
    }
}
```

We can now register the FluentTodoRepository object, we just have to rename the original TodoRepository struct and conform to the protocol instead.

```swift
// repository file
public struct FluentTodoRepository: TodoRepository {
    var req: Request
    
    public init(_ req: Request) {
        self.req = req
    }
    
    func query() -> QueryBuilder<Todo> {
        Todo.query(on: req.db)
    }

    // ... same as before
}

// configure.swift
app.repositories.register(.todo) { req in
    FluentTodoRepository(req)
}
```

We're going to be able to get the repository through the `req.repositories.todo` property. You don't have to change anything else inside the controller file.

```swift
import Vapor

struct TodoController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Todo] {
        try await req.repositories.todo.list()
    }

    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        return try await req.repositories.todo.create(todo)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("todoID", as: Todo.IDValue.self) else {
            throw Abort(.notFound)
        }
        try await req.repositories.todo.delete(id)
        return .ok
    }
}
```

The best part of this approach is that you can simply replace the `FluentTodoRepository` with a `MockTodoRepository` for testing purposes. I also like the fact that we don't pollute the req.* namespace, but every single repository has its own variable under the repositories key.

You can come up with a generic `DatabaseRepository` protocol with an associated database Model type, then you could implement some basic features as a protocol extension for the Fluent models. I'm using this approach and I'm quite happy with it so far, what do you think? Should the Vapor core team add better support for repositories? Let me know on Twitter. ☺️
