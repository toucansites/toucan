---
type: post
title: Table joins in Fluent 4
description: In this quick tutorial I'm going to show you how to join and query database models using the Fluent ORM framework in Vapor 4.
publication: 2020-06-11 16:20:00
tags: 
    - vapor
    - server
authors:
    - tibor-bodecs
---

## Database models

Fluent is a [Swift ORM framework](https://theswiftdev.com/get-started-with-the-fluent-orm-framework-in-vapor-4/) written for Vapor. You can use models to represent rows in a table, migrations to create the structure for the tables and you can define relations between the models using Swift property wrappers. That's quite a simple way of representing parent, child or sibling connections. You can "eager load" models through these predefined relation properties, which is great, but sometimes you don't want to have static types for the relationships.

I'm working on a modular CMS and I can't have hardcoded relationship properties inside the models. Why? Well, I want to be able to load modules at runtime, so if module `A` depends from module `B` through a relation property then I can't compile module `A` independently. That's why I dropped most of the cross-module relations, nevertheless I have to write joined queries. 😅

### Customer model

In this example we are going to model a simple Customer-Order-Product relation. Our customer model will have a basic identifier and a name. Consider the following:

```swift
final class CustomerModel: Model, Content {
    static let schema = "customers"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
```

Nothing special, just a basic Fluent model.

### Order model

Customers will have a one-to-many relationship to the orders. This means that a customer can have multiple orders, but an order will always have exactly one associated customer.

```swift
final class OrderModel: Model, Content {
    static let schema = "orders"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "date") var date: Date
    @Field(key: "customer_id") var customerId: UUID

    init() { }

    init(id: UUID? = nil, date: Date, customerId: UUID) {
        self.id = id
        self.date = date
        self.customerId = customerId
    }
}
```

We could take advantage of the `@Parent` and `@Child` property wrappers, but this time we are going to store a customerId reference as a UUID type. Later on we are going to put a foreign key constraint on this relation to ensure that referenced objects are valid identifiers.

### Product model

The product model, just like the customer model, is totally independent from anything else. 📦

```swift
final class ProductModel: Model, Content {
    static let schema = "products"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
```

We can create a property with a `@Sibling` wrapper to express the relationship between the orders and the products, or use joins to query the required data. It really doesn't matter which way we go, we still need a cross table to store the related product and order identifiers.

### OrderProductModel

We can describe a many-to-many relation between two tables using a third table.

```swift
final class OrderProductModel: Model, Content {
    static let schema = "order_products"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "order_id") var orderId: UUID
    @Field(key: "product_id") var productId: UUID
    @Field(key: "quantity") var quantity: Int

    init() { }

    init(id: UUID? = nil, orderId: UUID, productId: UUID, quantity: Int) {
        self.id = id
        self.orderId = orderId
        self.productId = productId
        self.quantity = quantity
    }
}
```

As you can see we can store extra info on the cross table, in our case we are going to associate quantities to the products on this relation right next to the product identifier.

### Migrations

Fortunately, Fluent gives us a simple way to create the schema for the database tables.

```swift
struct InitialMigration: Migration {

    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.eventLoop.flatten([
            db.schema(CustomerModel.schema)
                .id()
                .field("name", .string, .required)
                .create(),
            db.schema(OrderModel.schema)
                .id()
                .field("date", .date, .required)
                .field("customer_id", .uuid, .required)
                .foreignKey("customer_id", references: CustomerModel.schema, .id, onDelete: .cascade)
                .create(),
            db.schema(ProductModel.schema)
                .id()
                .field("name", .string, .required)
                .create(),
            db.schema(OrderProductModel.schema)
                .id()
                .field("order_id", .uuid, .required)
                .foreignKey("order_id", references: OrderModel.schema, .id, onDelete: .cascade)
                .field("product_id", .uuid, .required)
                .foreignKey("product_id", references: ProductModel.schema, .id, onDelete: .cascade)
                .field("quantity", .int, .required)
                .unique(on: "order_id", "product_id")
                .create(),
        ])
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.eventLoop.flatten([
            db.schema(OrderProductModel.schema).delete(),
            db.schema(CustomerModel.schema).delete(),
            db.schema(OrderModel.schema).delete(),
            db.schema(ProductModel.schema).delete(),
        ])
    }
}
```

If you want to avoid invalid data in the tables, you should always use the foreign key and unique constraints. A foreign key can be used to check if the referenced identifier exists in the related table and the unique constraint will make sure that only one row can exists from a given field.

## Joining database tables using Fluent 4

We have to run the `InitialMigration` script before we start using the database. This can be done by passing a command argument to the backend application or we can achieve the same thing by calling the `autoMigrate()` method on the application instance.

> NOTE: For the sake of simplicity I'm going to use the wait method instead of async Futures & Promises, this is fine for demo purposes, but in a real-world server application you should never block the current event loop with the wait method.

This is one possible setup of our dummy database using an SQLite storage, but of course you can use PostgreSQL, MySQL or even MariaDB through the available Fluent SQL drivers. 🚙

```swift
public func configure(_ app: Application) throws {

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(InitialMigration())

    try app.autoMigrate().wait()

    let customers = [
        CustomerModel(name: "Bender"),
        CustomerModel(name: "Fry"),
        CustomerModel(name: "Leela"),
        CustomerModel(name: "Hermes"),
        CustomerModel(name: "Zoidberg"),
    ]
    try customers.create(on: app.db).wait()
    
    let products = [
        ProductModel(name: "Hamburger"),
        ProductModel(name: "Fish"),
        ProductModel(name: "Pizza"),
        ProductModel(name: "Beer"),
    ]
    try products.create(on: app.db).wait()

    // Bender + pizza & beer
    let order = OrderModel(date: Date(), customerId: customers[0].id!)
    try order.create(on: app.db).wait()

    let beerProduct = OrderProductModel(orderId: order.id!, productId: products[3].id!, quantity: 6)
    try beerProduct.create(on: app.db).wait()
    let pizzaProduct = OrderProductModel(orderId: order.id!, productId: products[2].id!, quantity: 1)
    try pizzaProduct.create(on: app.db).wait()
}
```

We have created 5 customers (Bender, Fry, Leela, Hermes, Zoidberg), 4 products (Hamburger, Fish, Pizza, Beer) and one new order for Bender containing 2 products (6 beers and 1 pizza). 🤖

### Inner join using one-to-many relations

Now the question is: how can we get the customer data based on the order?

```swift
let orders = try OrderModel
    .query(on: app.db)
    .join(CustomerModel.self, on: \OrderModel.$customerId == \CustomerModel.$id, method: .inner)
    .all()
    .wait()

for order in orders {
    let customer = try order.joined(CustomerModel.self)
    print(customer.name)
    print(order.date)
}
```

The answer is pretty simple. We can use an inner join to fetch the customer model through the `order.customerId` and `customer.id` relation. When we iterate through the models we can ask for the related model using the joined method.

### Joins and many to many relations

Having a customer is great, but how can I fetch the associated products for the order? We can start the query with the `OrderProductModel` and use a join using the `ProductModel` plus we can filter by the order id using the current order.

```swift
for order in orders {
    //...

    let orderProducts = try OrderProductModel
        .query(on: app.db)
        .join(ProductModel.self, on: \OrderProductModel.$productId == \ProductModel.$id, method: .inner)
        .filter(\.$orderId == order.id!)
        .all()
        .wait()

    for orderProduct in orderProducts {
        let product = try orderProduct.joined(ProductModel.self)
        print(product.name)
        print(orderProduct.quantity)
    }
}
```

We can request the joined model the same way as we did it for the customer. Again, the very first parameter is the model representation of the joined table, next you define the relation between the tables using the referenced identifiers. As a last parameter you can specify the type of the join.

### Inner join vs left join

There is a great SQL tutorial about joins on [w3schools.com](https://www.w3schools.com/sql/sql_join.asp), I highly recommend reading it. The main difference between an inner join and a left join is that an inner join only returns those records that have matching identifiers in both tables, but a left join will return all the records from the base (left) table even if there are no matches in the joined (right) table.

There are many different types of SQL joins, but inner and left join are the most common ones. If you want to know more about the other types you should read the linked article. 👍

## Summary

Table joins are really handy, but you have to be careful with them. You should always use proper foreign key and unique constraints. Also consider using indexes on some rows when you work with joins, because it can improve the performance of your queries. Speed can be an important factor, so never load more data from the database than you actually need.

There is an issue on [GitHub](https://github.com/vapor/fluent-kit/issues/11) about the Fluent 4 API, and [another one](https://github.com/vapor/fluent-kit/issues/274) about querying specific fields using the `.field` method. Long story short, joins can be great and we need better docs. 🙉
