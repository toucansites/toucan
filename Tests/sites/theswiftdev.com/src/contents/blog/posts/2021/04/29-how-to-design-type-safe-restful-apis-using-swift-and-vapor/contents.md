---
slug: how-to-design-type-safe-restful-apis-using-swift-and-vapor
title: How to design type safe RESTful APIs using Swift & Vapor?
description: Learn to make proper data transfer objects for CRUD operations and integrate them both into the client and server side API layer.
publication: 2021-04-29 16:20:00
tags: Vapor
---

## Full stack Swift & BFF

A little more than a year have passed since I published my article about A [generic CRUD solution for Vapor 4](https://theswiftdev.com/a-generic-crud-solution-for-vapor-4/). Quite a lot happened in a year, and I've learned so much about Vapor and server side Swift in general. I believe that it is time to polish this article a bit and share the new ideas that I'm using lately to design and build backend APIs.

Swift is on the server side, and last 2020 was definitely a HUGE milestone. Vapor 4 alpha release started in May 2019, then a year later in April 2020, the very first stable version of the framework arrived. Lots of new server side libraries were open sourced, there is a great integration with AWS services, including a native Swift AWS library (Soto) and Lambda support for Swift.

More and more people are asking: "is Vapor / server side Swift ready for production?" and I truly believe that the anser is definitely: yes it is. If you are an iOS developer and you are looking for an API service, I belive Swift can be a great choice for you.

Of course you still have to learn a lot about how to build a backend service, including the basic understanding of the HTTP protocol and many more other stuff, but no matter which tech stack you choose, you can't avoid learning these things if you want to be a backend developer.

The good news is that if you choose Swift and you are planning to build a client application for an Apple platform, you can reuse most of your data objects and create a shared Swift library for your backend and client applications. [Tim Condon](https://x.com/0xtim) is a huge full-stack Swift / Vapor advocate (also member of the Vapor core team), he has some nice presentation videos on YouTube about [Backend For Frontend](https://www.youtube.com/watch?v=XqQJ6-l26QM) (BFF) systems and [full-stack development with Swift and Vapor](https://www.youtube.com/watch?v=fpWOD3JpSrI).

Anyway, in this article I'm going to show you how to design a shared Swift package including an API service that can be a good starting point for your next Swift client & Vapor server application. You should know that I've created [Feather CMS](https://github.com/feathercms/feather/) to simplify this process and if you are looking for a real full-stack Swift CMS solution you should definitely take a look.

## Project setup

As a starting point you can generate a new project using the [default template](https://github.com/vapor/template) and the [Vapor toolbox](https://docs.vapor.codes/4.0/install/linux/#install-toolbox), alternatively you can re-reate the same structure by hand using the Swift Package Manager. We're going to add one new target to our project, this new TodoApi is going to be a public library product and we have to use it as a dependency in our App target.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "myProject",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "TodoApi", targets: ["TodoApi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.44.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
    ],
    targets: [
        .target(name: "TodoApi"),
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .target(name: "TodoApi")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
```

You should note that if you choose to use Fluent when using the vapor toolbox, then the generated Vapor project will contain a basic Todo example. [Christian Weinberger](https://x.com/_cweinberger) has a great tutorial about [how to create a Vapor 4 todo backend](https://betterprogramming.pub/vapor-4-todo-backend-5035c9d7e295) if you are interested more in the [todobackend.com](https://www.todobackend.com/) project, you should definitely read it. In our case we're going to build our todo API, in a very similar way.

First, we need a Todo model in the App target, that's for sure, because we'd like to model our database entities. The Fluent ORM framework is quite handy, because you can choose a database driver and switch between database provides, but unfortunately the framework is stuffing too much responsibilities into the models. Models always have to be classes and property wrappers can be annyoing sometimes, but it's more or less easy to use and that's also a huge benefit.

```swift
import Vapor
import Fluent

final class Todo: Model {
    static let schema = "todos"
   
    struct FieldKeys {
        static let title: FieldKey = "title"
        static let completed: FieldKey = "completed"
        static let order: FieldKey = "order"
        
    }
    
    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.title) var title: String
    @Field(key: FieldKeys.completed) var completed: Bool
    @Field(key: FieldKeys.order) var order: Int?
    
    init() { }
    
    init(id: UUID? = nil, title: String, completed: Bool = false, order: Int? = nil) {
        self.id = id
        self.title = title
        self.completed = completed
        self.order = order
    }
}
```

A model represents a line in your database, but you can also query db rows using the model entity, so there is no separate repository that you can use for this purpose. You also have to define a migration object that defines the database schema / table that you'd like to create before you could operate with models. Here's how to create one for our Todo models.

```swift
import Fluent

struct TodoMigration: Migration {

    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.schema(Todo.schema)
            .id()
            .field(Todo.FieldKeys.title, .string, .required)
            .field(Todo.FieldKeys.completed, .bool, .required)
            .field(Todo.FieldKeys.order, .int)
            .create()
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.schema(Todo.schema).delete()
    }
}
```

Now we're mostly ready with the database configuration, we just have to configure the selected db driver, register the migration and call the autoMigrate() method so Vapor can take care of the rest.

```swift
import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {

    app.databases.use(.sqlite(.file("Resources/db.sqlite")), as: .sqlite)

    app.migrations.add(TodoMigration())
    try app.autoMigrate().wait()
}
```

That's it, we have a working SQLite database with a TodoModel that is ready to persist and retreive entities. In [my old CRUD article](https://theswiftdev.com/a-generic-crud-solution-for-vapor-4/) I mentioned that Models and Contents should be separated. I still believe in clean architectures, but back in the days I was only focusing on the I/O (input, output) and the few endpoints (list, get, create, update, delete) that I implemented used the same input and output objects. I was so wrong. 😅

A response to a list request is usually quite different from a get (detail) request, also the create, update and patch inputs can be differentiated quite well if you take a closer look at the components. In most of the cases ignoring this observation is causing so much trouble with APIs. You should NEVER use the same object for creating and entity and updating the same one. That's a bad practice, but only a few people notice this. We are talking about JSON based RESTful APIs, but come on, every company is trying to re-invent the wheel if it comes to APIs. 🔄

But why? Because developers are lazy ass creatures. They don't like to repeat themselves and unfortunately creating a proper API structure is a repetative task. Most of the participating objects look like the same, and no in Swift you don't want to use inheritance to model these Data Transfer Objects. The DTO layer is your literal communication interface, still we use unsafe crappy tools to model our most important part of our projects. Then we wonder when an app crashes because of a change in the backend API, but that's a different story, I'll stop right here... 🔥

Anyway, Swift is a nice way to model the communication interface. It's simple, type safe, secure, reusable, and it can be converted back and forth to JSON with a single line of code. Looking back to our case, I imagine an RESTful API something like this:


- `GET /todos/` => `() -> Page<[TodoListObject]>`
- `GET /todos/:id/` => `() -> TodoGetObject`
- `POST /todos/` => `(TodoCreateObject) -> TodoGetObject`
- `PUT /todos/:id/` => `(TodoUpdateObject) -> TodoGetObject`
- `PATCH /todos/:id/` => `(TodoPatchObject) -> TodoGetObject`
- `DELETE /todos/:id/` => `() -> ()`

As you can see we always have a HTTP method that represents an CRUD action. The endpoint always contains the referred object and the object identifier if you are going to alter a single instance. The input parameter is always submitted as a JSON encoded HTTP body, and the respone status code (200, 400, etc.) indicates the outcome of the call, plus we can return additional JSON object or some description of the error if necessary. Let's create the shared API objects for our TodoModel, we're going to put these under the TodoApi target, and we only import the Foundation framework, so this library can be used everywhere (backend, frontend).

```swift
import Foundation

struct TodoListObject: Codable {
    let id: UUID
    let title: String
    let order: Int?
}

struct TodoGetObject: Codable {
    let id: UUID
    let title: String
    let completed: Bool
    let order: Int?
}

struct TodoCreateObject: Codable {
    let title: String
    let completed: Bool
    let order: Int?
}

struct TodoUpdateObject: Codable {
    let title: String
    let completed: Bool
    let order: Int?
}

struct TodoPatchObject: Codable {
    let title: String?
    let completed: Bool?
    let order: Int?
}
```

The next step is to extend these objects so we can use them with Vapor (as a Content type) and furthermore we should be able to map our TodoModel to these entities. This time we are not going to take care about validation or relations, that's a topic for a different day, for the sake of simplicity we're only going to create basic map methods that can do the job and hope just for valid data. 🤞

```swift
import Vapor
import TodoApi

extension TodoListObject: Content {}
extension TodoGetObject: Content {}
extension TodoCreateObject: Content {}
extension TodoUpdateObject: Content {}
extension TodoPatchObject: Content {}

extension TodoModel {
    
    func mapList() -> TodoListObject {
        .init(id: id!, title: title, order: order)
    }

    func mapGet() -> TodoGetObject {
        .init(id: id!, title: title, completed: completed, order: order)
    }
    
    func create(_ input: TodoCreateObject) {
        title = input.title
        completed = input.completed ?? false
        order = input.order
    }
    
    func update(_ input: TodoUpdateObject) {
        title = input.title
        completed = input.completed
        order = input.order
    }
    
    func patch(_ input: TodoPatchObject) {
        title = input.title ?? title
        completed = input.completed ?? completed
        order = input.order ?? order
    }
}
```

There are only a few differences between these map methods and of course we could re-use one single type with optional property values everywhere, but that wouldn't describe the purpose and if something changes in the model data or in an endpoint, then you'll be ended up with side effects no matter what. FYI: in Feather CMS most of this model creation process will be automated through a generator and there is a web-based admin interface (with permission control) to manage db entries.

So we have our API, now we should build our `TodoController` that represents the API endpoints. Here's one possible implementation based on the CRUD function requirements above.

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

The very last step is to attach these endpoints to Vapor routes, we can create a RouteCollection object for this purpose.

```swift
import Vapor

struct TodoRouter: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let todoController = TodoController()
        
        let id = PathComponent(stringLiteral: ":" + TodoModel.idParamKey)
        let todoRoutes = routes.grouped("todos")
        
        todoRoutes.get(use: todoController.list)
        todoRoutes.post(use: todoController.create)
        
        todoRoutes.get(id, use: todoController.get)
        todoRoutes.put(id, use: todoController.update)
        todoRoutes.patch(id, use: todoController.patch)
        todoRoutes.delete(id, use: todoController.delete)
    }
}
```

Now inside the configuration we just have to boot the router, you can place the following snippet right after the auto migration call: `try TodoRouter().boot(routes: app.routes)`. Just build and run the project, you can try the API using some basic cURL commands.

```sh
# list
curl -X GET "http://localhost:8080/todos/"
# {"items":[],"metadata":{"per":10,"total":0,"page":1}}

# create
curl -X POST "http://localhost:8080/todos/" \
    -H "Content-Type: application/json" \
    -d '{"title": "Write a tutorial"}'
# {"id":"9EEBD3BB-77AC-4511-AFC9-A052D62E4713","title":"Write a tutorial","completed":false}
    
#get
curl -X GET "http://localhost:8080/todos/9EEBD3BB-77AC-4511-AFC9-A052D62E4713"
# {"id":"9EEBD3BB-77AC-4511-AFC9-A052D62E4713","title":"Write a tutorial","completed":false}

# update
curl -X PUT "http://localhost:8080/todos/9EEBD3BB-77AC-4511-AFC9-A052D62E4713" \
    -H "Content-Type: application/json" \
    -d '{"title": "Write a tutorial", "completed": true, "order": 1}'
# {"id":"9EEBD3BB-77AC-4511-AFC9-A052D62E4713","title":"Write a tutorial","order":1,"completed":true}

# patch
curl -X PATCH "http://localhost:8080/todos/9EEBD3BB-77AC-4511-AFC9-A052D62E4713" \
    -H "Content-Type: application/json" \
    -d '{"title": "Write a Swift tutorial"}'
# {"id":"9EEBD3BB-77AC-4511-AFC9-A052D62E4713","title":"Write a Swift tutorial","order":1,"completed":true}

# delete
curl -i -X DELETE "http://localhost:8080/todos/9EEBD3BB-77AC-4511-AFC9-A052D62E4713"
# 200 OK
```

Of course you can use any other helper tool to perform these HTTP requests, but I prefer cURL because of simplicity. The nice thing is that you can even build a Swift package to battle test your API endpoints. It can be an advanced type-safe SDK for your future iOS / macOS client app with a test target that you can run as a standalone product on a CI service.

I hope you liked this tutorial, next time I'll show you how to validate the endpoints and build some test cases both for the backend and client side. Sorry for the huge delay in the articles, but I was busy with building Feather CMS, which is by the way amazing... more news are coming soon. 🤓
