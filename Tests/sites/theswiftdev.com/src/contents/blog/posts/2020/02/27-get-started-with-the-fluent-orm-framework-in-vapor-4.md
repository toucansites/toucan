---
slug: get-started-with-the-fluent-orm-framework-in-vapor-4
title: Get started with the Fluent ORM framework in Vapor 4
description: Learn how to use the Fluent ORM framework. Migrations, schemas, relations powered by PostgreSQL, written in Swift.
publication: 2020-02-27 16:20:00
tags: Vapor, Fluent
---

> NOTE: If you want to learn Fluent, but you don't have a working PostgreSQL installation, you should check my [tutorial about how to install and use pgSQL](https://theswiftdev.com/how-to-set-up-pgsql-for-fluent-4/) before you start reading this one.

## Using the Fluent ORM framework

The beauty of an [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping) framework is that it hides the complexity of the underlying database layer. [Fluent 4](https://docs.vapor.codes/4.0/fluent/config/) comes with multiple database driver implementations, this means that you can easily replace the recommended PostgreSQL driver with [SQLite](https://sqlite.org/index.html), [MySQL](https://www.mysql.com/) or [MongoDB](https://www.mongodb.com/) if you want. [MariaDB](https://mariadb.com/) is also supported through the MySQL driver.

If you are using the SQLite database driver you might have to install the corresponding package (`brew install sqlite`) if you run into the following error: "missing required module 'CSQLite'". 😊

In this tutorial we'll use PostgreSQL, since that's the new default driver in Vapor 4. First you have to create a database, next we can start a new Vapor project & write some Swift code using Fluent. If you create a new project using the toolbox (`vapor new myProject`) you'll be asked which database driver to use. If you are creating a project from scratch you can alter the `Package.swift` file:

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "pgtut",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
```

Open the `Package.swift` file in Xcode, wait until all the dependencies are loaded.

Let's configure the psql database driver in the `configure.swift` file. We're going to use a database URL string to provide the connection details, loaded from the local environment.

```swift
import Vapor
import Fluent
import FluentPostgresDriver

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

public func configure(_ app: Application) throws {
    
    try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)
    
    //...
}
```

Create a new `.env.development` file in the project directory with the following contents:

```
DB_URL=postgres://myuser:mypass@localhost:5432/mydb
```

You can also [configure](https://docs.vapor.codes/4.0/fluent/config/) the driver using other methods, but I personally prefer this approach, since it's very easy and you can also put other specific environmental variables right next to the DB_URL.

> NOTE: You can also use the `.env` file in production mode to set your environmental variables.

Run the application, but first make sure that the current working directory is set properly, read more about this in my previous tutorial about [the leaf templating engine](https://theswiftdev.com/how-to-create-your-first-website-using-vapor-4-and-leaf/).

Well done, you have a working project that connects to the pgSQL server using Fluent. 🚀

## Model definition

The [official documentation](https://docs.vapor.codes/4.0/fluent/overview/) pretty much covers all the important concepts, so it's definitely worth a read. In this section, I'm only going to focus on some of the "missing parts".

The API template sample code comes with a `Todo` model which is pretty much a good starting point for us.

### Field keys

Field keys are available from the [5th major beta](https://github.com/vapor/fluent-kit/releases/tag/1.0.0-beta.5) version of Fluent 4. Long story short, you don't have to repeat yourself anymore, but you can define a key for each and every database field. As a gratis you never have to do the same for id fields, since fluent has built-in support for identifiers.

```swift
extension FieldKey {
    static var title: Self { "title" }
}

// model definition
@ID() var id: UUID?
@Field(key: .title) var title: String

// migration
.id()
.field(.title, .string, .required)
```

### Identifiers are now UUID types by default

Using the new `@ID` property wrapper and the `.id()` migration function will automatically require your models to have a `UUID` value by default. This is a great change, because I don't really like serial identifiers. If you want to go use integers as identifiers you can still do it. Also you can define `UUID` fields with the old-school syntax, but if you go so you can have some troubles with switching to the new MongoDB driver, so please don't do it. 🥺

```swift
// custom int identifier (won't work with MongoDB driver)
@ID(custom: "todo_id")
var id: Int?

// custom id type & field name (you have to generate it)
@ID(custom: "todo_identifier", generatedBy: .user)
var id: String?

// old-school uuid field migration
.field("id", .uuid, .identifier(auto: false))
```

### How to store native database enums?

If you want to store enums using Fluent you have two options now. The first one is that you simply save your enums as native values (int, string, etc.), if you do so you just need an enum with a new field of the given type, plus you have to conform the enum to the Codable protocol.

```swift
// model definition
enum Status: String, Codable {
    case pending
    case completed
}

@Field(key: "status") var status: Status

// migration (you can use the .int or .string type)
.field("status", .string, .required)
```

The second option is to use the new `@Enum` field type and migrate everything using the enum builder. This method requires more setup, but I think it's going to worth it on the long term.

```swift
// model definition
extension FieldKey {
    static var status: Self { "status" }
}

enum Status: String, Codable, CaseIterable {
    static var name: FieldKey { .status }

    case pending
    case completed
}

@Enum(key: .status) var status: Status

// migration
struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        var enumBuilder = database.enum(Todo.Status.name.description)
        for option in Todo.Status.allCases {
            enumBuilder = enumBuilder.case(option.rawValue)
        }
        return enumBuilder.create()
        .flatMap { enumType in
            database.schema(Todo.schema)
                .id()
                .field(.title, .string, .required)
                .field(.status, enumType, .required)
                .create()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Todo.schema).delete().flatMap {
            database.enum(Todo.Status.name.description).delete()
        }
    }
}
```

The main advantage of this approach that Fluent can take advantage of the database driver's built-in enum type support. Also if you want to store native enums you have to migrate the fields if you introduce a new case. You can read more about this in the [beta release notes](https://github.com/vapor/fluent-kit/releases/tag/1.0.0-beta.5). I can't tell you which one is the best way, since this is a brand new feature, I have to run some tests. ✅

### Saving option sets in Fluent

There is a great post written by [Bastian Inuk](https://x.com/BastianInuk/) about [managing user roles using option sets](https://www.inuk.blog/vapor-fluent-4-and-enums/) in Fluent. You should definitely take a look if you want to use an OptionSet as a Fluent property. Anyway, I'll show you how to create this type, so we'll be able to flag our todo items. 🔴🟣🟠🟡🟢🔵⚪️

```swift
// model definition
extension FieldKey {
    static var labels: Self { "labels" }
}

struct Labels: OptionSet, Codable {
    var rawValue: Int
    
    static let red = Labels(rawValue: 1 << 0)
    static let purple = Labels(rawValue: 1 << 1)
    static let orange = Labels(rawValue: 1 << 2)
    static let yellow = Labels(rawValue: 1 << 3)
    static let green = Labels(rawValue: 1 << 4)
    static let blue = Labels(rawValue: 1 << 5)
    static let gray = Labels(rawValue: 1 << 6)
    
    static let all: Labels = [.red, .purple, .orange, .yellow, .green, .blue, .gray]
}

@Field(key: .labels) var labels: Labels

// migration
.field(.labels, .int, .required)
```

> NOTE: There is a nice Option protocol [OptionSet](https://nshipster.com/optionset/)

### Storing dates

Fluent can also store dates and times and convert them back-and-forth using the built-in `Date` object from Foundation. You just have to choose between the `.date` or `.datetime` storage types. You should go with the first one if you don't care about the hours, minutes or seconds. The second one is good if you simply want to save the day, month and year. 💾

> WARN: You should always go with the exact same `TimeZone` when you save / fetch dates from the database. When you save a date object that is in UTC, next time if you want to filter those objects and you use a different time zone (e.g. PDT), you'll get back a bad set of results.

Here is the final example of our `Todo` model including the migration script:

```swift
// model definition
final class Todo: Model, Content {

    static let schema = "todos"
    
    enum Status: String, Codable {
        case pending
        case completed
    }

    struct Labels: OptionSet, Codable {
        var rawValue: Int
        
        static let red = Labels(rawValue: 1 << 0)
        static let purple = Labels(rawValue: 1 << 1)
        static let orange = Labels(rawValue: 1 << 2)
        static let yellow = Labels(rawValue: 1 << 3)
        static let green = Labels(rawValue: 1 << 4)
        static let blue = Labels(rawValue: 1 << 5)
        static let gray = Labels(rawValue: 1 << 6)
        
        static let all: Labels = [
            .red,
            .purple,
            .orange,
            .yellow,
            .green,
            .blue,
            .gray
        ]
    }

    @ID() var id: UUID?
    @Field(key: .title) var title: String
    @Field(key: .status) var status: Status
    @Field(key: .labels) var labels: Labels
    @Field(key: .due) var due: Date?

    init() { }

    init(id: UUID? = nil,
         title: String,
         status: Status = .pending,
         labels: Labels = [],
         due: Date? = nil)
    {
        self.id = id
        self.title = title
        self.status = status
        self.labels = labels
        self.due = due
    }
}

// migration
struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Todo.schema)
            .id()
            .field(.title, .string, .required)
            .field(.status, .string, .required)
            .field(.labels, .int, .required)
            .field(.due, .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Todo.schema).delete()
    }
}
```

One more thing...

### Nested fields & compound fields

Sometimes you might need to save additional structured data, but you don't want to introduce a relation (e.g. attributes with different keys, values). This is when the `@NestedField` property wrapper comes extremely handy. I won't include here an example, since I had no time to try this feature yet, but you can read more about it [here](https://github.com/vapor/fluent-kit/releases/tag/1.0.0-beta.5) with a working sample code.

The difference between a `@CompoundField` and a `@NestedField` is that a compound field is stored as a flat top level field in the database, but the other will be stored as a nested object.

> NOTE: Sets are now compatible with the array database type, you can use them like this: `.field(.mySetField, .array(of: .string), .required)`

I think we pretty much covered everything that you'll need in order to create DB entities. We'll have a quick detour here before we get into relations. 🚧

## Schemas & migrations

The `Todo` object is more or less ready to use, but this is just one part of the whole story. We still need to create the actual database table that can store our objects in PostgreSQL. In order to create the DB schema based on our Swift code, we have to run the migration command.

Migration is the process of creating, updating or deleting one or more database tables. In other words, everything that alters the database schema is a migration. You should know that you can register multiple migration scripts and Vapor will run them always in the order they were added.

> NOTE: The name of your database table & the fields are declared in your model. The schema is the name of the table, and the property wrappers are containing the name of each field.

Nowadays I prefer to use a semantic version suffix for all my migration objects, this is really handy because I don't have to think too much about the naming conventions, migration_v1_0_0 is always the create operation, everything comes after this version is just an altering the schema.

You can implement a `var name: String { "custom-migration-name" }` property inside the migration struct / class, so you don't have to put special characters into your object's name

> WARN: You should be careful with relations! If you are trying to use a table with a field as a foreign key you have to make sure that the referenced object already exists, otherwise it'll fail.

During the first migration Fluent will create an internal lookup table named `_fluent_migrations`. The migration system is using this table to detect which migrations were already performed and what needs to be done next time you run the migrate command.

In order to perform a migration you can launch the Run target with the migrate argument. If you pass the `--auto-migrate` flag you don't have to confirm the migration process. Be careful. 😳

```sh
swift run Run migrate
```

You can revert the last batch of migrations by running the command with the --revert flag.

```sh
swift run Run migrate --revert
```

Here is a quick example how to run multiple schema updates by using flatten function. This migration simply removes the existing title field, and creates new unique name field.

```swift
extension FieldKey {
    static var name: Self { "name" }
}

struct UpdateTodo: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Todo.schema)
                .deleteField(.title)
                .update(),
            database.schema(Todo.schema)
                .field(.name, .string, .required)
                .unique(on: .name)
                .update(),
            // you can also create objects in migration scripts
            Todo(name: "Hello world").save(on: database),
        ])
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Todo.schema)
                .deleteField(.name)
                .update(),
            database.schema(Todo.schema)
                .field(.title, .string, .required)
                .update(),
        ])
    }
}
```

Feel free to go ahead, migrate the `Todo` scheme so we can write some queries.

## Querying
Again I have to refer to the [official 4.0 Fluent docs](https://docs.vapor.codes/4.0/fluent/overview/#querying). Please go ahead read the querying section carefully, and come back to this article. The `TodoController` also provides a basic Swift sample code. IMHO a controller is an interactor, nowadays I'm using VIPER on the backend side as well (article coming soon). Here are a few CRUD practices. 😅

### Creating multiple records at once

This one is simple, please note that the `save` method in Fluent behaves like an upsert command. If your model exists, it'll `update` otherwise it calls the `create` function. Anyway you can always call create on a bunch of models to perform a batch insert.

```swift
let todos = [
    Todo(title: "Publish new article tomorrow"),
    Todo(title: "Finish Fluent tutorial"),
    Todo(title: "Write more blog posts"),
]
todos.create(on: req.db)
```

### Batch delete records

You can query all the required records using filters and call the .delete() method on them.

```swift
Todo.query(on: req.db)
        .filter(\.$status == .completed)
        .delete()
```

### How to update or delete a single record?

If you know the object identifier it's pretty simple, the `Model` protocol has a find method for this purpose. Otherwise you can query the required object and request the first one.

> NOTE: Fluent is asynchronous by default, this means that you have to work a lot with Futures and Promises. You can read my [tutorial for beginners about promises in Swift](https://theswiftdev.com/promises-in-swift-for-beginners/).

You can use the `.map` or `.flatMap` methods to perform the necessary actions & return a proper response. The `.unwrap` function is quite handy, since you don't have to unwrap optionals by hand in the other blocks. Block based syntax = you have to deal with memory management. 💩

```swift
// update an existing record (find by uuid)
_ = Todo.find(uuid, on: req.db)
.unwrap(or: Abort(.notFound))
.flatMap { todo -> EventLoopFuture<Void> in
    todo.title = ""
    return todo.save(on: req.db)
}

//delete an existing record (find first using filters)
_ = Todo.query(on: req.db)
    .filter(\.$title == "Hello world")
    .first()
    .unwrap(or: Abort(.notFound))
    .flatMap { $0.delete(on: req.db) }
```

That's it about creating, requesting, updating and deleting entities.

## Relations

Sometimes you want to store some additional information in a separate database. In our case for example we could make a dynamic tagging system for the todo items. These tags can be stored in a separate table and they can be connected to the todos by using a relation. A relation is nothing more than a foreign key somewhere in the other table or inside a pivot.

### One-to-one relations

Fluent supports one-to-many [relations](https://docs.vapor.codes/4.0/fluent/overview/#relations) out of the box. The documentation clearly explains everything about them, but I'd like to add a few notes, time to build a one-to-many relation.

If you want to model a one-to-one relation the foreign key should be unique for the related table. Let's add a detail table to our todo items with a separately stored description field.

```swift
extension FieldKey {
    static var todoId: Self { "todo_id" }
    static var description: Self { "description" }
}

final class Detail: Model, Content {

    static let schema = "details"

    @ID() var id: UUID?
    @Parent(key: .todoId) var todo: Todo
    @Field(key: .description) var description: String

    init() { }

    init(id: UUID? = nil, description: String, todoId: UUID) {
        self.id = id
        self.description = description
        self.$todo.id = todoId
    }
}
```

The model above has a parent relation to a `Todo` object through a `todo_id` field. In other words, we simply store the original todo identifier in this table. Later on we'll be able to query the associated descriptions by using this foreign key. Let me show you the migration:

```swift
struct CreateTodo: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Todo.schema)
                .id()
                .field(.title, .string, .required)
                .field(.status, .string, .required)
                .field(.labels, .int, .required)
                .field(.due, .datetime)
                .create(),
            database.schema(Detail.schema)
                .id()
                .field(. todoId, .uuid, .required)
                .foreignKey(.todoId, references: Todo.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                .field(.description, .string, .required)
                .unique(on: .todoId)
                .create(),
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Detail.schema).delete(),
            database.schema(Todo.schema).delete(),
        ])
    }
}
```
The final step here is to extend the `Todo` model with the child reference.

```swift
@Children(for: \.$todo) var details: [Detail]
```

Creating a relation only takes a few lines of Swift code

```swift
let todo = Todo(title: "Finish the Fluent article already")
todo.create(on: app.db)
.flatMap { _ in
    Detail(description: "write some cool things about Fluent relations",
           todoId: todo.id!).create(on: req.db)
}
```

Now if you try to add multiple details to the same todo object the you won't be able to perform that DB query, since the `todo_id` has a unique constraint, so you must be extremely carful with these kind of operations. Apart from this limitation (that comes alongside with a one-to-one relation) you use both objects as usual (find by id, eager load the details from the todo object, etc.). 🤓

### One-to-many relations

A one-to-many relation is just like a one-to-one, except that you can associate multiple objects with the parent. You can even use the same code from above, you just have to remove the unique constraint from the migration script. I'll add some grouping feature to this todo example.

```swift
// todo group model
final class Group: Model, Content {

    static let schema = "groups"

    @ID() var id: UUID?
    @Field(key: .name) var name: String
    @Children(for: \.$group) var todos: [Todo]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// extended todo model
final class Todo: Model, Content {
    //...other fields
    @Parent(key: .groupId) var group: Group
    @Children(for: \.$todo) var details: [Detail]

    init() { }

    init(id: UUID? = nil,
         title: String,
         status: Status = .pending,
         labels: Labels = [],
         due: Date? = nil,
         groupId: UUID)
    {
        self.id = id
        self.title = title
        self.status = status
        self.labels = labels
        self.due = due
        self.$group.id = groupId
    }
}

// migration
struct CreateTodo: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Group.schema)
                .id()
                .field(.name, .string, .required)
                .create(),
            database.schema(Todo.schema)
                .id()
                .field(.title, .string, .required)
                .field(.status, .string, .required)
                .field(.labels, .int, .required)
                .field(.due, .datetime)
                .field(. groupId, .uuid, .required)
                .foreignKey(.groupId, references: Group.schema, .id)
                .create(),
            database.schema(Detail.schema)
                .id()
                .field(. todoId, .uuid, .required)
                .foreignKey(.todoId, references: Todo.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                .field(.description, .string, .required)
                .unique(on: .todoId) //enforce a one-to-one relation
                .create(),
            Group(name: "Default").create(on: database),
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Detail.schema).delete(),
            database.schema(Todo.schema).delete(),
            database.schema(Group.shcema).delete(),
        ])
    }
}
```

From now on, you'll have to insert the todos into a group. It's ok to create a default one in the migration script, so later on it's possible to get the id reference of the pre-existing group.

```swift
// fetch default group & add a new todo
Group.query(on: req.db)
.first()
.flatMap { group in
    Todo(title: "This belongs to a group", groupId: group!.id!).create(on: app.db)
}
// eager load todos in the group
Group.query(on: req.db)
    .with(\.$todos)
    .all()
.whenSuccess { groups in
    for group in groups {
        print(group.name)
        print(group.todos.map { "- \($0.title)" }.joined(separator: "\n"))
    }
}
```

If you want to change a parent, you can simply set the new identifier using the `.$id` syntax. Don't forget to call update or save on the object, since it's not enough just to update the relation in memory, but you have to persist everything back to the database. 💡

### Many-to-many relations

You can create an association between two tables by using a third one that stores foreign keys from both of the original tables. Sounds fun? Welcome to the world of many-to-many relations. They are useful if you want to build a tagging system or a recipe book with ingredients.

Again, Bastian Inuk has a great post about [how to use siblings in Fluent 4](https://www.inuk.blog/fluent-in-siblings/). I just want to add one extra thing here: you can store additional information on the pivot table. I'm not going to show you this time how to associate ingredients with recipes & amounts, but I'll put some tags on the todo items with an important flag option. Thanks buddy! 😜

```swift
extension FieldKey {
    static var name: Self { "name" }
    static var todoId: Self { "todo_id" }
    static var tagId: Self { "tag_id" }
    static var important: Self { "important" }
}

// Tag.swift
final class Tag: Model, Content {

    static let schema = "tags"

    @ID() var id: UUID?
    @Field(key: .name) var name: String
    @Siblings(through: TodoTags.self, from: \.$tag, to: \.$todo) var todos: [Todo]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// a cross table for the relation between the todos and the tags
final class TodoTags: Model {

    static let schema = "todo_tags"
    
    @ID() var id: UUID?
    @Parent(key: .todoId) var todo: Todo
    @Parent(key: .tagId) var tag: Tag
    @Field(key: .important) var important: Bool
    
    init() {}
    
    init(todoId: UUID, tagId: UUID, important: Bool) {
        self.$todo.id = todoId
        self.$tag.id = tagId
        self.important = important
    }
}

// Todo.swift property extension
//...
@Siblings(through: TodoTags.self, from: \.$todo, to: \.$tag) var tags: [Tag]
//...

// the migration script extension
//...
database.schema(Tag.schema)
    .id()
    .field(.name, .string, .required)
    .create(),
database.schema(TodoTags.schema)
    .id()
    .field(.todoId, .uuid, .required)
    .field(.tagId, .uuid, .required)
    .field(.important, .bool, .required)
    .create(),
//...
database.schema(Tag.schema).delete(),
database.schema(TodoTags.schema).delete(),
//...
```

The only new thing here is the siblings property wrapper which defines the connection between the two tables. It's awesome that Fluent can handle these complex relations in such a nice way.

> WARN: The code snippet below is for educational purposes only, you should never use the `.wait()` method in a real-world application, use futures & promises instead.

Finally we're able to tag our todo items, plus we can mark some of them as important. 🎊

```swift
let defaultGroup = try Group.query(on: app.db).first().wait()!

let shoplist = Group(name: "Shoplist")
let project = Group(name: "Awesome Fluent project")
try [shoplist, project].create(on: app.db).wait()

let family = Tag(name: "family")
let work = Tag(name: "family")
try [family, work].create(on: app.db).wait()

let smoothie = Todo(title: "Make a smoothie",
                    status: .pending,
                    labels: [.purple],
                    due: Date(timeIntervalSinceNow: 3600),
                    groupId: defaultGroup.id!)

let apples = Todo(title: "Apples", groupId: shoplist.id!)
let bananas = Todo(title: "Bananas", groupId: shoplist.id!)
let mango = Todo(title: "Mango", groupId: shoplist.id!)

let kickoff = Todo(title: "Kickoff meeting",
                   status: .completed,
                   groupId: project.id!)

let code = Todo(title: "Code in Swift",
                labels: [.green],
                groupId: project.id!)

let deadline = Todo(title: "Project deadline",
                    labels: [.red],
                    due: Date(timeIntervalSinceNow: 86400 * 7),
                    groupId: project.id!)

try [smoothie, apples, bananas, mango, kickoff, code, deadline].create(on: app.db).wait()

let familySmoothie = TodoTags(todoId: smoothie.id!, tagId: family.id!, important: true)
let workDeadline = TodoTags(todoId: deadline.id!, tagId: work.id!, important: false)

try [familySmoothie, workDeadline].create(on: app.db).wait()
```

That's it, now we're ready with our awesome todo application. 😎

### Conclusion

Fluent is a crazy powerful tool. You can easily make the switch between the available drivers. You don't even have to write SQL if you are using an ORM tool, but only Swift code, which is nice.

Server side Swift and all the related tools are evolving fast. The whole Vapor community is doing such a great job. I hope this article will help you to understand Fluent way better. 💧
