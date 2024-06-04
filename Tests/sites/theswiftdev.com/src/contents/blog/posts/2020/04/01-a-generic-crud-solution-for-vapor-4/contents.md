---
slug: a-generic-crud-solution-for-vapor-4
title: A generic CRUD solution for Vapor 4
description: Learn how to build a controller component that can serve models as JSON objects through a RESTful API written in Swift.
publication: 2020-04-01 16:20:00
tags: Vapor, CRUD
---

## CRUD ~ Create, Read, Update and Delete

We should start by implementing the non-generic version of our code, so after we see the pattern we can turn it into a more generalized Swift code. If you start with the [API template](https://github.com/vapor/api-template) project there is a pretty good example for almost everything using a Todo model.

> NOTE: Start a new project using the [toolbox](http://docs.vapor.codes/3.0/getting-started/toolbox/), just run `vapor new myProject`

Open the project by double clicking the `Package.swift` file, that'll fire up Xcode (you should be on version 11.4 or later). If you open the `Sources/App/Controllers` folder you'll find a sample controller file there called `TodoController.swift`. We're going to work on this, but first...

> A controller is a collection of request handler functions around a specific model.

## HTTP basics: Request -> Response

[HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol) is a text transfer protocol that is widely used around the web. In the beginning it was only used to transfer HTML files, but nowadays you can use it to request almost anything. It's mostly a stateless protocol, this means you request something, you get back a response and that's it.

It's like ordering a pizza from a place through phone. You need a number to call (URL), you pick up the phone, dial the place, the phone company initializes the connection between (you & the pizza place) the two participants (the network layer does the same thing when you request an URL from a server). The phone on the other side starts ringing. 📱

Someone picks up the phone. You both introduce yourselves, also exchange some basic info such as the delivery address (server checks HTTP headers & discovers what needs to be delivered to where). You tell the place what kind of pizza you'd like to have & you wait for it. The place cooks the pizza (the server gathers the necessary data for the response) & the pizza boy arrives with your order (the server sends back the actual response). 🍕

> Everything happens asynchronously, the place (server) can fulfill multiple requests. If there is only one person who is taking orders & cooking pizzas, sometimes the cooking process will be blocked by answering the phone. Anyways, using non-blocking i/o is important, that's why Vapor uses Futures & Promises from [SwiftNIO](https://github.com/apple/swift-nio) under the hood.

In our case the request is a URL with some extra headers (key, value pairs) and a request body object (encoded data). The response is usually made of a HTTP status code, optional headers and response body. If we are talking about a RESTful API, the encoding of the body is usually JSON.

All right then, now you know the basics it's time to look at some Swift code.

## Contents and models in Vapor

Defining a data structure in Swift is pretty easy, you just have to create a struct or a class. You can also convert them back and forth to JSON using the built-in [Codable protocol](https://theswiftdev.com/how-to-parse-json-in-swift-using-codable-protocol/). Vapor has an extension around this called Content. If you conform the the protocol (no need to implement any new functions, the object just needs to be Codable) the system can decode these objects from requests and encode them as responses.

Models on the other hand represent rows from your database. The [Fluent](https://theswiftdev.com/a-tutorial-for-beginners-about-the-fluent-postgresql-driver-in-vapor-4/) ORM layer can take care of the low level abstractions, so you don't have to mess around with SQL queries. This is a great thing to have, read my other article if you like to know more about Fluent. 💾

The problem starts when you have a model and it has different fields than the content. Imagine if this Todo model was a User model with a secret password field? Would you like to expose that to the public when you encode it as a response? Nope, I don't think so. 🙉

I believe that in most of the Cases the Model and the Content should be separated. Taking this one step further, the content of the request (input) and the content of the response (output) is sometimes different. I'll stop it now, let's change our Todo model according to this.

```swift
import Fluent
import Vapor

final class Todo: Model {
    
    struct Input: Content {
        let title: String
    }

    struct Output: Content {
        let id: String
        let title: String
    }
    
    static let schema = "todos"

    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
```

We expect to have a title when we insert a record (we can generate the id), but when we're returning Todos we can expose the id property as well. Now back to the controller.

> WARN: Don't forget to run Fluent migrations first: `swift run Run migrate`

### Create

The flow is pretty simple. Decode the Input type from the content of the request (it's created from the HTTP body) and use it to construct a new Todo class. Next save the newly created item to the database using Fluent. Finally after the save operation is done (it returns nothing by default), map the future into a proper Output, so Vapor can encode this to JSON format.

```swift
import Fluent
import Vapor

struct TodoController {

    /*
         curl -i -X POST "http://127.0.0.1:8080/todos" \
         -H "Content-Type: application/json" \
         -d '{"title": "Hello World!"}'
     */
    func create(req: Request) throws -> EventLoopFuture<Todo.Output> {
        let input = try req.content.decode(Todo.Input.self)
        let todo = Todo(title: input.title)
        return todo.save(on: req.db)
            .map { Todo.Output(id: todo.id!.uuidString, title: todo.title) }
    }

    // ...
}
```

I prefer cURL to quickly check my endpoints, but you can also create unit tets for this purpose. Run the server using Xcode or type `swift run Run` to the command line. Next if you copy & paste the commented snippet it should create a new todo item and return the output with some additional HTTP info. You should also validate the input, but this time let's just skip that part. 😅

### Read

Getting back all the `Todo` objects is a simple task, but returning a paged response is not so obvious. Fortunately with Fluent 4 we have a built-in solution for this. Let me show you how it works, but first I'd like to alter the routes a little bit.

```swift
import Fluent
import Vapor

func routes(_ app: Application) throws {
    let todoController = TodoController()
    app.post("todos", use: todoController.create)
    app.get("todos", use: todoController.readAll)
    app.get("todos", ":id", use: todoController.read)
    app.post("todos", ":id", use: todoController.update)
    app.delete("todos", ":id", use: todoController.delete)
}
```

As you can see I tend to use read instead of index, plus `:id` is a much shorter parameter name, plus I'll already know the returned model type based on the context, no need for additional prefixes here. Ok, let me show you the controller code for the read endpoints:

```swift
struct TodoController {

    /*
       curl -i -X GET "http://127.0.0.1:8080/todos?page=2&per=2" \
        -H "Content-Type: application/json"
    */
    func readAll(req: Request) throws -> EventLoopFuture<Page<Todo.Output>> {
        return Todo.query(on: req.db).paginate(for: req).map { page in
            page.map { Todo.Output(id: $0.id!.uuidString, title: $0.title) }
        }
    }

    //...
}
```

As I mentioned this before Fluent helps with pagination. You can use the `page` and `per` query parameters to retrieve a page with a given number of elements. The newly returned response will contain two new (`items` & `metadata`) keys. Metadata inclues the total number of items in the database. If you don't like the metadata object you can ship your own paginator:

```swift
// the first 10 items
Todo.query(on: req.db).range(..<10)

// returns 10 items from the 2nd element
Todo.query(on: req.db).range(2..<10).all()

// limit - offset
Todo.query(on: req.db).range(offset..<limit).all()

// page - per
Todo.query(on: req.db).range(((page - 1) * per)..<(page * per)).all()
The QueryBuilder range support is a great addition. Now let's talk about reading one element.

struct TodoController {

    /*
        curl -i -X GET "http://127.0.0.1:8080/todos/<id>" \
            -H "Content-Type: application/json"
     */
    func read(req: Request) throws -> EventLoopFuture<Todo.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { Todo.Output(id: $0.id!.uuidString, title: $0.title) }
    }

    //...
}
```

You can get named parameters by key, I already mentioned this in my [beginner's guide article](https://theswiftdev.com/beginners-guide-to-server-side-swift-using-vapor-4/). The new thing here is that you can `throw Abort(error)` anytime you want to break something. Same thing happens in the `unwrap` method, that just checks if the value wrapped inside the future object. If it is `nil` it'll throws the given error, if the value is present the promise chain will continue.

### Update

Update is pretty straightforward, it's somewhat the combination of the read & create methods.

```swift
struct TodoController {

    /*
        curl -i -X POST "http://127.0.0.1:8080/todos/<id>" \
            -H "Content-Type: application/json" \
            -d '{"title": "Write Vapor 4 book"}'
     */
    func update(req: Request) throws -> EventLoopFuture<Todo.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let input = try req.content.decode(Todo.Input.self)
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                todo.title = input.title
                return todo.save(on: req.db)
                    .map { Todo.Output(id: todo.id!.uuidString, title: todo.title) }
            }
    }
    
    //...
}
```

You need an id to find the object in the database, plus some input to update the fields. You fetch the item, update the corresponding properties based on the input, save the model and finally return the newly saved version as a public output object. Piece of cake. 🍰

### Delete

Delete is just a little bit tricky, since usually you don't return anything in the body, but just a simple status code. Vapor has a nice `HTTPStatus` enum for this purpose, so e.g. `.ok` is 200.

```swift
struct TodoController {

    /*
        curl -i -X DELETE "https://127.0.0.1:8080/todos/<id>"
     */
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }

    //...
}
```

Pretty much that sums everything. Of course you can extend this with a PATCH method, but that's quite a good task for practicing. I'll leave this "unimplemented" just for you... 😈

## A protocol oriented generic CRUD

Long story short, if you introduce new models you'll have to do this exact same thing over and over again if you want to have CRUD endpoints for every single one of them.

That's a boring task to do, plus you'll end up having a lot of boilerplate code. So why not come up with a more generic solution, right? I'll show you one possible implementation.

```swift
protocol ApiModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content

    init(_: Input) throws
    var output: Output { get }
    func update(_: Input) throws
}
```

The first thing I did is that I created a new protocol called ApiModel, it has two `associatedType` requirements, those are the i/o structs from the non-generic example. I also want to be able to initialize or update a model using an `Input` type, and transform it to an `Output`.

```swift
protocol ApiController {
    var idKey: String { get }

    associatedtype Model: ApiModel

    // generic helper functions
    func getId(_: Request) throws -> Model.IDValue
    func find(_: Request) throws -> EventLoopFuture<Model>

    // generic crud methods
    func create(_: Request) throws -> EventLoopFuture<Model.Output>
    func readAll(_: Request) throws -> EventLoopFuture<Page<Model.Output>>
    func read(_: Request) throws -> EventLoopFuture<Model.Output>
    func update(_: Request) throws -> EventLoopFuture<Model.Output>
    func delete(_: Request) throws -> EventLoopFuture<HTTPStatus>
    
    // router helper
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder
}
```

Next thing todo (haha) is to come up with a controller interface. This is also going to be "generic", plus I'd like to be able to set a custom id parameter key. One small thing here is that you can't 100% generalize the decoding of the identifier parameter, but only if it's `LosslessStringConvertible`.

```swift
extension ApiController where Model.IDValue: LosslessStringConvertible {

    func getId(_ req: Request) throws -> Model.IDValue {
        guard let id = req.parameters.get(self.idKey, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return id
    }
}
```

Trust me in 99.9% of the cases you'll be just fine right with this. Final step is to have a generic version of what we've just made above with each CRUD endpoint. 👻

```swift
extension ApiController {
    
    var idKey: String { "id" }

    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.find(try self.getId(req), on: req.db).unwrap(or: Abort(.notFound))
    }

    func create(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        let model = try Model(request)
        return model.save(on: req.db).map { _ in model.output }
    }
    
    func readAll(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> {
        Model.query(on: req.db).paginate(for: req).map { $0.map { $0.output } }
    }

    func read(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        try self.find(req).map { $0.output }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        return try self.find(req).flatMapThrowing { model -> Model in
            try model.update(request)
            return model
        }
        .flatMap { model in
            return model.update(on: req.db).map { model.output }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try self.find(req).flatMap { $0.delete(on: req.db) }.map { .ok }
    }
    
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder {
        let base = routes.grouped(PathComponent(stringLiteral: endpoint))
        let idPathComponent = PathComponent(stringLiteral: ":\(self.idKey)")
        
        base.post(use: self.create)
        base.get(use: self.readAll)
        base.get(idPathComponent, use: self.read)
        base.post(idPathComponent, use: self.update)
        base.delete(idPathComponent, use: self.delete)

        return base
    }
}
```

Example time. Here is our generic model:

```swift
final class Todo: ApiModel {
    
    struct _Input: Content {
        let title: String
    }

    struct _Output: Content {
        let id: String
        let title: String
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    // MARK: - model

    static let schema = "todos"

    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
    // MARK: - api
    
    init(_ input: Input) throws {
        self.title = input.title
    }
    
    func update(_ input: Input) throws {
        self.title = input.title
    }
    
    var output: Output {
        .init(id: self.id!.uuidString, title: self.title)
    }
}
```

> NOTE: If the input is the same as the output, you just need one (`Context`?) struct instead of two.

This is what's left off the controller (not much, haha):

```swift
struct TodoController: ApiController {
    typealias Model = Todo
}
```

The router object also shortened a bit:

```swift
func routes(_ app: Application) throws {
    let todoController = TodoController()
    todoController.setup(routes: routes, on: "todos")
}
```

Try to run the app, everything should work just as before.

This means that you don't have to write controllers anymore? Yes, mostly, but still this method lacks a few things, like fetching child objects for nested models or relations. If you are fine with that please go ahead and copy & paste the snippets into your codebase. You won't regret, because this code is as simple as possible, plus you can override everything in your controller if you don't like the default implementation. This is the beauty of the protocol oriented approach. 😎

## Conclusion

There is no silver bullet, but if it comes to CRUD, but please [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). Using a generic code can be a proper solution, but maybe it won't cover every single use case. Taken together I like the fact that I don't have to focus anymore on writing API endpoints, but only those that are quite unique. 🤓
