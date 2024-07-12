---
slug: asynchronous-validation-for-vapor
title: Asynchronous validation for Vapor
description: Learn how to validate input data using an async technique. Unified request validation API for your server side Swift app.
publication: 2017-10-10 16:20:00
tags: UIKit, iOS
---

## Vapor's validation API

The very first thing I'd like to show you is an issue that I have with the current [validation](https://docs.vapor.codes/4.0/validation/) API for the Vapor framework. I always wanted to use it, because I really like the validator functions but unfortunately the API lacks quite a lot of features that are crucial for my needs.

If we take a look at our previously created [Todo example](https://theswiftdev.com/declarative-unit-tests-for-vapor/) code, you might remember that we've only put some validation on the create API endpoint. That's not very safe, we should fix this. I'm going to show you how to validate endpoints using the built-in API, to see what's the issue with it. 🥲

In order to demonstrate the problems, we're going to add a new Tag model to our Todo items.

```swift
import Vapor
import Fluent

final class TagModel: Model {

    static let schema = "tags"
    static let idParamKey = "tagId"
   
    struct FieldKeys {
        static let name: FieldKey = "name"
        static let todoId: FieldKey = "todo_id"
    }
    
    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @Parent(key: FieldKeys.todoId) var todo: TodoModel
    
    init() { }
    
    init(id: UUID? = nil, name: String, todoId: UUID) {
        self.id = id
        self.name = name
        self.$todo.id = todoId
    }
}
```
So the main idea is that we're going to be able to tag our todo items and save the todoId reference for each tag. This is not going to be a global tagging solution, but more like a simple tag system for demo purposes. The relation will be automatically validated on the database level (if the db driver supports it), since we're going to put a foreign key constraint on the todoId field in the migration.

```swift
import Fluent

struct TagMigration: Migration {

    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.schema(TagModel.schema)
            .id()
            .field(TagModel.FieldKeys.name, .string, .required)
            .field(TagModel.FieldKeys.todoId, .uuid, .required)
            .foreignKey(TagModel.FieldKeys.todoId, references: TodoModel.schema, .id)
            .create()
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.schema(TagModel.schema).delete()
    }
}
```

It is important to mention this again: NOT every single database supports foreign key validation out of the box. This is why it will be extremely important to validate our input data. If we let users to put random todoId values into the database that can lead to data corruption and other problems.

Now that we have our database model & migration, here's how the API objects will look like. You can put these into the TodoApi target, since these DTOs could be shared with a client side library. 📲

```swift
import Foundation

public struct TagListObject: Codable {
    
    public let id: UUID
    public let name: String

    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

public struct TagGetObject: Codable {
    
    public let id: UUID
    public let name: String
    public let todoId: UUID
    
    public init(id: UUID, name: String, todoId: UUID) {
        self.id = id
        self.name = name
        self.todoId = todoId
        
    }
}

public struct TagCreateObject: Codable {

    public let name: String
    public let todoId: UUID
    
    public init(name: String, todoId: UUID) {
        self.name = name
        self.todoId = todoId
    }
}

public struct TagUpdateObject: Codable {
    
    public let name: String
    public let todoId: UUID
    
    public init(name: String, todoId: UUID) {
        self.name = name
        self.todoId = todoId
    }
}

public struct TagPatchObject: Codable {

    public let name: String?
    public let todoId: UUID?
    
    public init(name: String?, todoId: UUID?) {
        self.name = name
        self.todoId = todoId
    }
}
```

Next we extend our `TagModel` to support CRUD operations, if you followed my first tutorial about [how to build a REST API using Vapor](https://theswiftdev.com/how-to-design-type-safe-restful-apis-using-swift-and-vapor/), this should be very familiar, if not please read it first. 🙏

```swift
import Vapor
import TodoApi

extension TagListObject: Content {}
extension TagGetObject: Content {}
extension TagCreateObject: Content {}
extension TagUpdateObject: Content {}
extension TagPatchObject: Content {}

extension TagModel {
    
    func mapList() -> TagListObject {
        .init(id: id!, name: name)
    }

    func mapGet() -> TagGetObject {
        .init(id: id!, name: name, todoId: $todo.id)
    }
    
    func create(_ input: TagCreateObject) {
        name = input.name
        $todo.id = input.todoId
    }
        
    func update(_ input: TagUpdateObject) {
        name = input.name
        $todo.id = input.todoId
    }
    
    func patch(_ input: TagPatchObject) {
        name = input.name ?? name
        $todo.id = input.todoId ?? $todo.id
    }
}
```

The tag controller is going to look very similar to the todo controller, for now we won't validate anything, the following snippet is all about having a sample code that we can fine tune later on.

```swift
import Vapor
import Fluent
import TodoApi

struct TagController {

    private func getTagIdParam(_ req: Request) throws -> UUID {
        guard let rawId = req.parameters.get(TagModel.idParamKey), let id = UUID(rawId) else {
            throw Abort(.badRequest, reason: "Invalid parameter `\(TagModel.idParamKey)`")
        }
        return id
    }

    private func findTagByIdParam(_ req: Request) throws -> EventLoopFuture<TagModel> {
        TagModel
            .find(try getTagIdParam(req), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // MARK: - endpoints
    
    func list(req: Request) throws -> EventLoopFuture<Page<TagListObject>> {
        TagModel.query(on: req.db).paginate(for: req).map { $0.map { $0.mapList() } }
    }
    
    func get(req: Request) throws -> EventLoopFuture<TagGetObject> {
        try findTagByIdParam(req).map { $0.mapGet() }
    }

    func create(req: Request) throws -> EventLoopFuture<Response> {
        let input = try req.content.decode(TagCreateObject.self)

        let tag = TagModel()
        tag.create(input)
        return tag
            .create(on: req.db)
            .map { tag.mapGet() }
            .encodeResponse(status: .created, for: req)
    }
    
    func update(req: Request) throws -> EventLoopFuture<TagGetObject> {
        let input = try req.content.decode(TagUpdateObject.self)

        return try findTagByIdParam(req)
            .flatMap { tag in
                tag.update(input)
                return tag.update(on: req.db).map { tag.mapGet() }
            }
    }
    
    func patch(req: Request) throws -> EventLoopFuture<TagGetObject> {
        let input = try req.content.decode(TagPatchObject.self)

        return try findTagByIdParam(req)
            .flatMap { tag in
                tag.patch(input)
                return tag.update(on: req.db).map { tag.mapGet() }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try findTagByIdParam(req)
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}
```

Of course we could use a [generic CRUD controller](https://theswiftdev.com/a-generic-crud-solution-for-vapor-4/) class that could highly reduce the amount of code required to create similar controllers, but that's a different topic. So we just have to register these newly created functions using a router.

```swift
import Vapor

struct TagRouter: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let tagController = TagController()
        
        let id = PathComponent(stringLiteral: ":" + TagModel.idParamKey)
        let tagRoutes = routes.grouped("tags")
        
        tagRoutes.get(use: tagController.list)
        tagRoutes.post(use: tagController.create)
        
        tagRoutes.get(id, use: tagController.get)
        tagRoutes.put(id, use: tagController.update)
        tagRoutes.patch(id, use: tagController.patch)
        tagRoutes.delete(id, use: tagController.delete)
    }
}
```

Also a few more changes in the `configure.swift` file, since we'd like to take advantage of the Tag functionality we have to register the migration and the new routes using the TagRouter.

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

    app.http.server.configuration.hostname = "192.168.8.103"
    app.migrations.add(TodoMigration())
    app.migrations.add(TagMigration())
    try app.autoMigrate().wait()

    try TodoRouter().boot(routes: app.routes)
    try TagRouter().boot(routes: app.routes)
}
```

One more thing, before we start validating our tags, we have to put a new `@Children(for: \.$todo) var tags: [TagModel]` property into our `TodoModel`, so it's going to be way more easy to fetch tags.

If you run the server and try to create a new tag using cURL and a fake UUID, the database query will fail if the db supports foreign keys.

```sh
curl -X POST "http://127.0.0.1:8080/tags/" \
    -H 'Content-Type: application/json' \
    -d '{"name": "test", "todoId": "94234a4a-b749-4a2a-97d0-3ebd1046dbac"}'
```

This is not ideal, we should protect our database from invalid data. Well, first of all we don't want to allow empty or too long names, so we should validate this field as well, this can be done using the validation API from the Vapor framework, let me show you how.

```swift
// TagModel+Api.swift
extension TagCreateObject: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty)
        validations.add("title", as: String.self, is: .count(...100) && .alphanumeric)
    }
}
// TagController.swift
func create(req: Request) throws -> EventLoopFuture<Response> {
    try TagCreateObject.validate(content: req)
    let input = try req.content.decode(TagCreateObject.self)

    let tag = TagModel()
    tag.create(input)
    return tag
        .create(on: req.db)
        .map { tag.mapGet() }
        .encodeResponse(status: .created, for: req)
}
/* 
curl -X POST "http://127.0.0.1:8080/tags/" \
    -H 'Content-Type: application/json' \
    -d '{"name": "", "todoId": "94234a4a-b749-4a2a-97d0-3ebd1046dbac"}'

{"error":true,"reason":"name is empty"}

/// some other cases:
name: 123
{"error":true,"reason":"name is not a(n) String, name is not a(n) String"}
name: ?
{"error":true,"reason":"name contains '?' (allowed: A-Z, a-z, 0-9)"}
name: very-lenghty-string
{"error":true,"reason":"name is greater than maximum of 100 character(s)"}
*/
```

Ok, it looks great, but this solution lacks a few things:

- You can't provide custom error messages
- The detail is always a concatenated result string (if there are multiple errors)
- You can't get the error message for a given key (e.g. "title": "Title is required")
- Validation happens synchronously (you can't validate based on a db query)

This is very unfortunate, because Vapor has really nice validator functions. You can validate characters (`.ascii`, `.alphanumeric`, `.characterSet(_:)`), various length and range requirements (`.empty`, `.count(_:)`, `.range(_)`), collections (`.in(_:)`), check null inputs, validate emails and URLs. We should try to validate the todo identifier based on the available todos in the database.

It is possible to validate todoId's by running a query with the input id and see if there is an existing record in our database. If there is no such todo, we won't allow the creation (or update / patch) operation. The problem is that we have to put this logic into the controller. 😕

```swift
func create(req: Request) throws -> EventLoopFuture<Response> {
    try TagCreateObject.validate(content: req)
    let input = try req.content.decode(TagCreateObject.self)
    return TodoModel.find(input.todoId, on: req.db)
        .unwrap(or: Abort(.badRequest, reason: "Invalid todo identifier"))
        .flatMap { _ in
            let tag = TagModel()
            tag.create(input)
            return tag
                .create(on: req.db)
                .map { tag.mapGet() }
                .encodeResponse(status: .created, for: req)
        }
}
```
This will do the job, but isn't it strange that we are doing validation in two separate places?

My other problem is that using the validatable protocol means that you can't really pass parameters for these validators, so even if you asynchronously fetch some required data and somehow you move the logic inside the validator, the whole process is going to feel like a very hacky solution. 🤐

Honestly, am I missing something here? Is this really how the validation system works in the most popular web framework? It's quite unbelievable. There must be a better way... 🤔

Async input validation
This method that I'm going to show you is already available in Feather CMS, I believe it's quite an advanced system compared to Vapor's validation API. I'll show you how I created it, first we start with a protocol that'll contain the basic stuff needed for validation & result management.

```swift
import Vapor

public protocol AsyncValidator {
    
    var key: String { get }
    var message: String { get }

    func validate(_ req: Request) -> EventLoopFuture<ValidationErrorDetail?>
}

public extension AsyncValidator {

    var error: ValidationErrorDetail {
        .init(key: key, message: message)
    }
}
```

This is a quite simple protocol that we're going to be the base of our asynchronous validation flow. The key will be used to just like the same way as Vapor uses validation keys, it's basically an input key for a given data object and we're going to use this key with an appropriate error message to display detailed validation errors (as an output content).

```swift
import Vapor

public struct ValidationErrorDetail: Codable {

    public var key: String
    public var message: String
    
    public init(key: String, message: String) {
        self.key = key
        self.message = message
    }
}

extension ValidationErrorDetail: Content {}
```

So the idea is that we're going to create multiple validation handlers based on this AsyncValidator protocol and get the final result based on the evaluated validators. The validation method can look like magic at first sight, but it's just calling the async validator methods if a given key is already invalidated then it'll skip other validations for that (for obvious reasons), and based on the individual validator results we create a final array including the validation error detail objects. 🤓

```swift
import Vapor

public struct RequestValidator {

    public var validators: [AsyncValidator]
    
    public init(_ validators: [AsyncValidator] = []) {
        self.validators = validators
    }
    
    /// this is magic, don't touch it
    public func validate(_ req: Request, message: String? = nil) -> EventLoopFuture<Void> {
        let initial: EventLoopFuture<[ValidationErrorDetail]> = req.eventLoop.future([])
        return validators.reduce(initial) { res, next -> EventLoopFuture<[ValidationErrorDetail]> in
            return res.flatMap { arr -> EventLoopFuture<[ValidationErrorDetail]> in
                if arr.contains(where: { $0.key == next.key }) {
                    return req.eventLoop.future(arr)
                }
                return next.validate(req).map { result in
                    if let result = result {
                        return arr + [result]
                    }
                    return arr
                }
            }
        }
        .flatMapThrowing { details in
            guard details.isEmpty else {
                throw Abort(.badRequest, reason: details.map(\.message).joined(separator: ", "))
            }
        }
    }

    public func isValid(_ req: Request) -> EventLoopFuture<Bool> {
        return validate(req).map { true }.recover { _ in false }
    }
}
```

Don't wrap your head too much about this code, I'll show you how to use it right away, but before we could perform a validation using our new tools, we need something that implements the AsyncValidator protocol and we can actually initialize. I have something that I really like in Feather, because it can perform both sync & async validations, of course you can come up with more simple validators, but this is a nice generic solution for most of the cases.

```swift
import Vapor

public struct KeyedContentValidator<T: Codable>: AsyncValidator {

    public let key: String
    public let message: String
    public let optional: Bool

    public let validation: ((T) -> Bool)?
    public let asyncValidation: ((T, Request) -> EventLoopFuture<Bool>)?
    
    public init(_ key: String,
                _ message: String,
                optional: Bool = false,
                _ validation: ((T) -> Bool)? = nil,
                _ asyncValidation: ((T, Request) -> EventLoopFuture<Bool>)? = nil) {
        self.key = key
        self.message = message
        self.optional = optional
        self.validation = validation
        self.asyncValidation = asyncValidation
    }
    
    public func validate(_ req: Request) -> EventLoopFuture<ValidationErrorDetail?> {
        let optionalValue = try? req.content.get(T.self, at: key)

        if let value = optionalValue {
            if let validation = validation {
                return req.eventLoop.future(validation(value) ? nil : error)
            }
            if let asyncValidation = asyncValidation {
                return asyncValidation(value, req).map { $0 ? nil : error }
            }
            return req.eventLoop.future(nil)
        }
        else {
            if optional {
                return req.eventLoop.future(nil)
            }
            return req.eventLoop.future(error)
        }
    }
}
```

The main idea here is that we can pass either a sync or an async validation block alongside the key, message and optional arguments and we perform our validation based on these inputs.

First we try to decode the generic Codable value, if the value was optional and it is missing we can simply ignore the validators and return, otherwise we should try to call the sync validator or the async validator. Please note that the sync validator is just a convenience tool, because if you don't need async calls it's more easy to return with a bool value instead of an `EventLoopFuture<Bool>`.

So, this is how you can validate anything using these new server side Swift validator components.

```swift
func create(req: Request) throws -> EventLoopFuture<Response> {
    let validator = RequestValidator.init([
        KeyedContentValidator<String>.init("name", "Name is required") { !$0.isEmpty },
        KeyedContentValidator<UUID>.init("todoId", "Todo identifier must be valid", nil) { value, req in
            TodoModel.query(on: req.db).filter(\.$id == value).count().map {
                $0 == 1
            }
        },
    ])
    return validator.validate(req).flatMap {
        do {
            let input = try req.content.decode(TagCreateObject.self)
            let tag = TagModel()
            tag.create(input)
            return tag
                .create(on: req.db)
                .map { tag.mapGet() }
                .encodeResponse(status: .created, for: req)
        }
        catch {
            return req.eventLoop.future(error: Abort(.badRequest, reason: error.localizedDescription))
        }
    }
}
```

This seems like a bit more code at first sight, but remember that previously we moved out our validator into a separate method. We can do the exact same thing here and return an array of AsyncValidator objects. Also a "real throwing flatMap EventLoopFuture" extension method could help us greatly to remove unnecessary do-try-catch statements from our code.

Anyway, I'll leave this up for you, but it's easy to reuse the same validation for all the CRUD endpoints, for patch requests you can set the optional flag to true and that's it. 💡

I still want to show you one more thing, because I don't like the current JSON output of the invalid calls. We're going to build a custom error middleware with a custom context object to display more details about what went wrong during the request. We need a validation error content for this.

```swift
import Vapor

public struct ValidationError: Codable {

    public let message: String?
    public let details: [ValidationErrorDetail]
    
    public init(message: String?, details: [ValidationErrorDetail]) {
        self.message = message
        self.details = details
    }
}

extension ValidationError: Content {}
```

This is the format that we'd like to use when something goes wrong. Now it'd be nice to support custom error codes while keeping the throwing nature of errors, so for this reason we'll define a new ValidationAbort that's going to contain everything we'll need for the new error middleware.

```swift
import Vapor

public struct ValidationAbort: AbortError {

    public var abort: Abort
    public var message: String?
    public var details: [ValidationErrorDetail]

    public var reason: String { abort.reason }
    public var status: HTTPStatus { abort.status }
    
    public init(abort: Abort, message: String? = nil, details: [ValidationErrorDetail]) {
        self.abort = abort
        self.message = message
        self.details = details
    }
}
```

This will allow us to throw ValidationAbort objects with a custom Abort & detailed error description. The Abort object is used to set the proper HTTP response code and headers when building the response object inside the middleware. The middleware is very similar to the built-in error middleware, except that it can return more details about the given validation issues.

```swift
import Vapor

public struct ValidationErrorMiddleware: Middleware {

    public let environment: Environment
    
    public init(environment: Environment) {
        self.environment = environment
    }

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapErrorThrowing { error in
            let status: HTTPResponseStatus
            let headers: HTTPHeaders
            let message: String?
            let details: [ValidationErrorDetail]

            switch error {
            case let abort as ValidationAbort:
                status = abort.abort.status
                headers = abort.abort.headers
                message = abort.message ?? abort.reason
                details = abort.details
            case let abort as Abort:
                status = abort.status
                headers = abort.headers
                message = abort.reason
                details = []
            default:
                status = .internalServerError
                headers = [:]
                message = environment.isRelease ? "Something went wrong." : error.localizedDescription
                details = []
            }

            request.logger.report(error: error)

            let response = Response(status: status, headers: headers)

            do {
                response.body = try .init(data: JSONEncoder().encode(ValidationError(message: message, details: details)))
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            }
            catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
```

Based on the given environment we can report the details or hide the internal issues, this is totally up-to-you, for me this approach works the best, because I can always parse the problematic keys and display error messages inside the client apps based on this response.

We just have to alter one line in the RequestValidator & register our newly created middleware for better error reporting. Here's the updated request validator:

```swift
// RequestValidator.swift
// (simply change the throwed object in the flatMapThrowing block)
.flatMapThrowing { details in
    guard details.isEmpty else {
        throw ValidationAbort(abort: Abort(.badRequest, reason: message), details: details)
    }
}

// configure.swift
app.middleware.use(ValidationErrorMiddleware(environment: app.environment))
```

Now if you run the same invalid cURL request, you should get a way better error response.

```sh
curl -i -X POST "http://192.168.8.103:8080/tags/" \
    -H 'Content-Type: application/json' \
    -d '{"name": "eee", "todoId": "94234a4a-b749-4a2a-97d0-3ebd1046dbac"}'

# HTTP/1.1 400 Bad Request
# content-length: 72
# content-type: application/json; charset=utf-8
# connection: keep-alive
# date: Wed, 12 May 2021 14:52:47 GMT
#
# {"details":[{"key":"todoId","message":"Todo identifier must be valid"}]}
```

You can even add a custom message for the request validator when you call the validate function, that'll be available under the message key inside the output.

As you can see this is quite a nice way to deal with errors and unify the flow of the entire validation chain. I'm not saying that Vapor did a bad job with the official validation APIs, but there's definitely room for improvements. I really love the wide variety of the [available validators](https://docs.vapor.codes/4.0/validation/#validators), but on the other hand I freakin' miss this async validation logic from the core framework. ❤️💩

Another nice thing about this approach is that you can define validator extensions and greatly simplify the amount of Swift code required to perform server side validation.

I know I'm not the only one with these issues, and I really hope that this little tutorial will help you create better (and more safe) backend apps using Vapor. I can only say that feel free to improve the validation related code for this Todo project, that's a good practice for sure. Hopefully it won't be too hard to add more validation logic based on the provided examples. 😉
