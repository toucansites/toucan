---
type: post
title: Declarative unit tests for Vapor
description: Learn how to test your server side Swift backend app in a declarative style using a lightweight library called Spec.
publication: 2021-05-04 16:20:00
tags: 
    - vapor
    - server
authors:
    - tibor-bodecs
---

## Writing tests using XCTVapor

In my previous article I showed you how to build a [type safe RESTful API using Vapor](https://theswiftdev.com/how-to-design-type-safe-restful-apis-using-swift-and-vapor/). This time we're going to extend that project a bit and write some tests using the Vapor testing tool to discover the underlying issues in the API layer. First we're going to use XCTVapor library, then we migrate to a lightweight declarative testing framework ([Spec](https://github.com/binarybirds/spec/)) built on top of that.

Before we start testing our application, we have to make sure that if the app runs in testing mode we register an inMemory database instead of our local SQLite file. We can simply alter the configuration and check the environment and set the db driver based on it.

```swift
import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {

    if app.environment == .testing {
        app.databases.use(.sqlite(.memory), as: .sqlite, isDefault: true)
    }
    else {
        app.databases.use(.sqlite(.file("Resources/db.sqlite")), as: .sqlite)
    }

    app.migrations.add(TodoMigration())
    try app.autoMigrate().wait()

    try TodoRouter().boot(routes: app.routes)
}
```

Now we're ready to create our very first unit test using the XCTVapor testing framework. The [official docs](https://docs.vapor.codes/4.0/testing/) are short, but quite useful to learn about the basics of testing Vapor endpoints. Unfortunately it won't tell you much about testing websites or complex API calls. ✅

We're going to make a simple test that checks the return type for our Todo list endpoint.

```swift
@testable import App
import TodoApi
import Fluent
import XCTVapor

final class AppTests: XCTestCase {

    func testTodoList() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "/todos/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
            _ = try res.content.decode(Page<TodoListObject>.self)
        })
    }
}
```

As you can see first we setup & configure our application, then we send a GET request to the `/todos/` endpoint. After we have a response we can check the status code, the content type and we can try to decode the response body as a valid paginated todo list item object.

This test case was pretty simple, now let's write a new unit test for the todo item creation.

    
```swift
@testable import App
import TodoApi
import Fluent
import XCTVapor

final class AppTests: XCTestCase {

    //...
    
    func testCreateTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let title = "Write a todo tutorial"
        
        try app.test(.POST, "/todos/", beforeRequest: { req in
            let input = TodoCreateObject(title: title)
            try req.content.encode(input)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let todo = try res.content.decode(TodoGetObject.self)
            XCTAssertEqual(todo.title, title)
            XCTAssertEqual(todo.completed, false)
            XCTAssertEqual(todo.order, nil)
        })
    }
}
```

This time we'd like to submit a new TodoCreateObject as a POST data, fortunately XCTVapor can help us with the beforeRequest block. We can simply encode the input object as a content, then in the response handler we can check the HTTP status code (it should be created) decode the expected response object (TodoGetObject) and validate the field values.

I also updated the TodoCreateObject, since it does not make too much sense to have an optional Bool field and we can use a default nil value for the custom order. 🤓

```swift
public struct TodoCreateObject: Codable {
    
    public let title: String
    public let completed: Bool
    public let order: Int?
    
    public init(title: String, completed: Bool = false, order: Int? = nil) {
        self.title = title
        self.completed = completed
        self.order = order
    }
}
```

The test will still fail, because we're returning an `.ok` status instead of a `.created` value. We can easily fix this in the create method of the TodoController Swift file.

```swift
import Vapor
import Fluent
import TodoApi

struct TodoController {

    // ...

    func create(req: Request) throws -> EventLoopFuture<Response> {
        let input = try req.content.decode(TodoCreateObject.self)
        let todo = TodoModel()
        todo.create(input)
        return todo
            .create(on: req.db)
            .map { todo.mapGet() }
            .encodeResponse(status: .created, for: req)
    }
    
    // ...
}
```

Now we should try to create an invalid todo item and see what happens...

```swift
func testCreateInvalidTodo() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)

    /// title shouldn't be empty
    let title = ""
    
    try app.test(.POST, "/todos/", beforeRequest: { req in
        let input = TodoCreateObject(title: title)
        try req.content.encode(input)
    }, afterResponse: { res in
        XCTAssertEqual(res.status, .created)
        let todo = try res.content.decode(TodoGetObject.self)
        XCTAssertEqual(todo.title, title)
        XCTAssertEqual(todo.completed, false)
        XCTAssertEqual(todo.order, nil)
    })
}
```

Well, this is bad, we shouldn't be able to create a todo item without a title. We could use the built-in [validation API](https://docs.vapor.codes/4.0/validation/) to check user input, but honestly speaking that's not the best approach.

My issue with validation is that first of all you can't return custom error messages and the other main reason is that validation in Vapor is not async by default. Eventually you'll face a situation when you need to validate an object based on a db call, then you can't fit that part of the object validation process into other non-async field validation. IMHO, this should be unified. 🥲

Fort the sake of simplicity we're going to start with a custom validation method, this time without any async logic involved, later on I'll show you how to build a generic validation & error reporting mechanism for your JSON-based RESTful API.

```swift
import Vapor
import TodoApi

extension TodoModel {
    
    // ...
    
    func create(_ input: TodoCreateObject) {
        title = input.title
        completed = input.completed
        order = input.order
    }

    static func validateCreate(_ input: TodoCreateObject) throws {
        guard !input.title.isEmpty else {
            throw Abort(.badRequest, reason: "Title is required")
        }
    }
}
```

In the create controller we can simply call the throwing validateCreate function, if something goes wrong the Abort error will be returned as a response. It is also possible to use an async method (return with an `EventLoopFuture`) then await (`flatMap`) the call and return our newly created todo if everything was fine.

```swift
func create(req: Request) throws -> EventLoopFuture<Response> {
    let input = try req.content.decode(TodoCreateObject.self)
    try TodoModel.validateCreate(input)
    let todo = TodoModel()
    todo.create(input)
    return todo
        .create(on: req.db)
        .map { todo.mapGet() }
        .encodeResponse(status: .created, for: req)
}
```

The last thing that we have to do is to update our test case and check for an error response.

```swift
// ...

struct ErrorResponse: Content {
    let error: Bool
    let reason: String
}

func testCreateInvalidTodo() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    try app.test(.POST, "/todos/", beforeRequest: { req in
        let input = TodoCreateObject(title: "")
        try req.content.encode(input)
    }, afterResponse: { res in
        XCTAssertEqual(res.status, .badRequest)
        let error = try res.content.decode(ErrorResponse.self)
        XCTAssertEqual(error.reason, "Title is required")
    })
}
```

Writing tests is a great way to debug our server side Swift code and double check our API endpoints. My only issue with this approach is that the code isn't too much self-explaining.

Declarative unit tests using Spec
XCTVapor and the entire test framework works just great, but I had a small problem with it. If you ever worked with JavaScript or TypeScript you might have heard about the [SuperTest](https://www.npmjs.com/package/supertest) library. This little `npm` package gives us a declarative syntactical sugar for testing HTTP requests, which I liked way too much to go back to regular XCTVapor-based test cases.

This is the reason why I've created the [Spec](https://github.com/binarybirds/spec/) "micro-framework", which is literally one file with with an extra thin layer around Vapor's unit testing framework to provide a declarative API. Let me show you how this works in practice, using a real-world example. 🙃

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
        .package(url: "https://github.com/binarybirds/spec", from: "1.0.0"),
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
            .product(name: "Spec", package: "spec"),
        ])
    ]
)
```

We had some expectations for the previous calls, right? How should we test the update todo endpoint? Well, we can create a new item, then update it and check if the results are valid.

```swift
import Spec

// ...
func testUpdateTodo() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    
    var existingTodo: TodoGetObject?
    
    try app
        .describe("A valid todo object should exists after creation")
        .post("/todos/")
        .body(TodoCreateObject(title: "sample"))
        .expect(.created)
        .expect(.json)
        .expect(TodoGetObject.self) { existingTodo = $0 }
        .test()

    XCTAssertNotNil(existingTodo)

    let updatedTitle = "Item is done"
    
    try app
        .describe("Todo should be updated")
        .put("/todos/" + existingTodo!.id.uuidString)
        .body(TodoUpdateObject(title: updatedTitle, completed: true, order: 2))
        .expect(.ok)
        .expect(.json)
        .expect(TodoGetObject.self) { todo in
            XCTAssertEqual(todo.title, updatedTitle)
            XCTAssertTrue(todo.completed)
            XCTAssertEqual(todo.order, 2)
        }
        .test()
}
```

The very first part of the code expects that we were able to create a todo object, it is the exact same create expectation as we used to write with the help of the XCTVapor framework.

IMHO the overall code quality is way better than it was in the previous example. We described the test scenario then we set our expectations and finally we run our test. With this format it's going to be more straightforward to understand test cases. If you compare the two versions the create case the second one is trivial to understand, but in the first one you actually have to take a deeper look at each line to understand what's going on.

Ok, one more test before we stop, let me show you how to describe the delete endpoint. We're going to refactor our code a bit, since there are some duplications already.

```swift
@testable import App
import TodoApi
import Fluent
import Spec

final class AppTests: XCTestCase {

    // MARK: - helpers
    
    private struct ErrorResponse: Content {
        let error: Bool
        let reason: String
    }

    @discardableResult
    private func createTodo(app: Application, input: TodoCreateObject) throws -> TodoGetObject {
        var existingTodo: TodoGetObject?

        try app
            .describe("A valid todo object should exists after creation")
            .post("/todos/")
            .body(input)
            .expect(.created)
            .expect(.json)
            .expect(TodoGetObject.self) { existingTodo = $0 }
            .test()
        
        XCTAssertNotNil(existingTodo)

        return existingTodo!
    }
    
    // MARK: - tests
    
    func testTodoList() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app
            .describe("A valid todo list page should be returned.")
            .get("/todos/")
            .expect(.ok)
            .expect(.json)
            .expect(Page<TodoListObject>.self)
            .test()
    }
    
    func testCreateTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try createTodo(app: app, input: TodoCreateObject(title: "Write a todo tutorial"))
    }

    func testCreateInvalidTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app
            .describe("An invalid title response should be returned")
            .post("/todos/")
            .body(TodoCreateObject(title: ""))
            .expect(.badRequest)
            .expect(.json)
            .expect(ErrorResponse.self) { error in
                XCTAssertEqual(error.reason, "Title is required")
            }
            .test()
    }

    func testUpdateTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let todo: TodoGetObject? = try createTodo(app: app, input: TodoCreateObject(title: "Write a todo tutorial"))

        let updatedTitle = "Item is done"
        
        try app
            .describe("Todo should be updated")
            .put("/todos/" + todo!.id.uuidString)
            .expect(.ok)
            .expect(.json)
            .body(TodoUpdateObject(title: updatedTitle, completed: true, order: 2))
            .expect(TodoGetObject.self) { todo in
                XCTAssertEqual(todo.title, updatedTitle)
                XCTAssertTrue(todo.completed)
                XCTAssertEqual(todo.order, 2)
            }
            .test()
    }
    
    func testDeleteTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let todo: TodoGetObject? = try createTodo(app: app, input: TodoCreateObject(title: "Write a todo tutorial"))

        try app
            .describe("Todo should be updated")
            .delete("/todos/" + todo!.id.uuidString)
            .expect(.ok)
            .test()
    }
}
```

This is how you can create a complete unit test scenario for a REST API endpoint using the Spec library. Of course there are a dozen other issues that we could fix, such as better input object validation, unit test for the patch endpoint, better tests for edge cases. Well, next time. 😅

By using Spec you can build your expectations by describing the use case, then you can place your expectations on the described "specification" run the attached validators. The nice thing about this declarative approach is the clean self-explaining format that you can understand without taking too much time on investigating the underlying Swift / Vapor code.

I believe that [Spec](https://github.com/binarybirds/spec/) is a fun little tool that helps you to write better tests for your Swift backend apps. It has a very lightweight footprint, and the API is straightforward and easy to use. 💪
