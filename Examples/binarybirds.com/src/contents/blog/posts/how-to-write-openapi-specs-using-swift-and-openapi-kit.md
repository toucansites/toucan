---
slug: how-to-write-openapi-specs-using-swift-and-openapi-kit
title: How to write OpenAPI specs using Swift and OpenAPIKit?
description: In this tutorial I'll show you how to build OpenAPI 3.0+ specifications efficiently using Swift & OpenAPIKit.
image: ./how-to-write-openapi-specs-using-swift-and-openapi-kit/cover.jpg
publication: 2023-07-06 16:15:54
tags:
  - swift
  - openapi
authors:
  - tibor-bodecs
---

## Getting started

Have you ever written an OpenAPI spec using YAML / JSON files? Well, I have created several documents and I had some problems with those formats. My main issue is that I constantly want to separate components, and I always end up using standalone files for those. This sounds fine, but if you decompose everything, including parameters, responses and other stuff it can cause some issues when you host your documentation online. The [SwaggerUI](https://github.com/swagger-api/swagger-ui) library renders the documentation extremely slow when it has to pull the specification from multiple source files. One possible solution is to combine your spec into a large `swagger.json` file, there are some tools for this purpose, but lately I've discovered an alternative... using Swift & the [OpenAPIKit](https://github.com/mattpolzin/OpenAPIKit) library. 📦

---

This tutorial is a practical walkthrough, but you can also download the [sample repository from GitHub](https://github.com/binarybirds/swagger-petstore) right away.

---

Let's get started with a new Swift package, you can setup the project using the following `Package.swift` file:

```swift
// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "swagger-petstore",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(
            url: "https://github.com/mattpolzin/OpenAPIKit",
            from: "3.0.0-alpha.8"
        ),
        .package(
            url: "https://github.com/jpsim/Yams",
            from: "5.0.6"
        ),
    ],
    targets: [
        .executableTarget(
            name: "SwaggerPetstore",
            dependencies: [
                .product(name: "OpenAPIKit30", package: "OpenAPIKit"),
                .product(name: "Yams", package: "Yams"),
            ]
        )
    ]
)
```

We just need a simple executable target that will serve as a generator, to build our swagger files. Anyway, working with OpenAPIKit is not that hard, but for me it's a bit more easy to reference components by using the following extensions. Feel free to place them inside a `OpenAPI+Extensions.swift` file somewhere inside your project.

```swift
import Foundation
import OpenAPIKit30
import OpenAPIKitCore

extension OpenAPI.Content {

    static func ref(_ name: String) -> Self {
        .init(schemaReference: .internal(.component(name: name)))
    }
}

extension JSONSchema {

    static func ref(_ name: String) -> JSONSchema {
        .reference(.component(named: name))
    }
}

extension Either<JSONReference<OpenAPI.Parameter>, OpenAPI.Parameter> {

    static func ref(_ name: String) -> Self {
        Self.reference(.component(named: name))
    }
}

extension Either<JSONReference<OpenAPI.Response>, OpenAPI.Response> {

    static func ref(_ name: String) -> Self {
        Self.reference(.component(named: name))
    }
}
```

The next thing that we're going to create is the `Server` namespace, this will contain some generic stuff that can be applied to the entire API.

```swift
import Foundation

enum Server {}
```

We're going to use UUID values as primary identifiers, so it seems like a good idea to add a `Field` extension with a static `uuid` function for this purpose. We're also going to use image URLs so, let's define one more field inside the `Server+Fields.swift` extension. 🤔

```swift
import Foundation
import OpenAPIKit30

extension Server {

    enum Fields {

        static func uuid(
            required: Bool = true,
            description: String = "Unique identifier"
        ) -> JSONSchema {
            .string(
                format: .extended(.uuid),
                required: required,
                description: description,
                example: "4DB59768-CDFA-4608-BA60-4673A3CB015E"
            )
        }

        static func url(
            required: Bool = true,
            description: String = "URL"
        ) -> JSONSchema {
            .string(
                format: .extended(.uri),
                required: required,
                description: description,
                example: "https://placekitten.com/512/512"
            )
        }
    }
}
```

We're going to use the fields inside the JSON objects, but we can also come up with a `Server+Parameters.swift` namespace to define generic path and query parameters that we can reuse inside the operations.

```swift
import Foundation
import OpenAPIKit30

extension Server {

    enum Parameters {

        static var page: OpenAPI.Parameter {
            let name = "page"
            return .init(
                name: name,
                context: .query,
                schema: .integer(
                    title: name,
                    minimum: (1, exclusive: false),
                    defaultValue: 1,
                    example: 1
                ),
                description: "Page offset of the list"
            )
        }

        static var size: OpenAPI.Parameter {
            let name = "size"
            return .init(
                name: name,
                context: .query,
                schema: .integer(
                    title: name,
                    minimum: (1, exclusive: false),
                    defaultValue: 50,
                    example: 50
                ),
                description: "Number of items per page"
            )
        }

        static var search: OpenAPI.Parameter {
            let name = "search"
            return .init(
                name: name,
                context: .query,
                schema: .string(
                    example: ""
                ),
                description: "Search with some value"
            )
        }

        static var order: OpenAPI.Parameter {
            .init(
                name: "order",
                context: .query,
                schema: .string(
                    allowedValues: "asc", "desc",
                    defaultValue: "asc",
                    example: "asc"
                ),
                description: "Order the results ascending or descending (asc, desc)"
            )
        }
    }
}
```

Same thing goes for the security schemes, in this case we just simply define a `bearerAuth` reference to a component, which we're going to implement inside the OpenAPI doc. 📄

```swift
import Foundation
import OpenAPIKit30

extension Server {

    enum Security {

        static let bearerAuth: [OpenAPI.SecurityRequirement] = [
            [
                .component(named: "bearerAuth"): []
            ]
        ]
    }
}

```

The very last thing seems like a bit complex, but it's just a generic error message and a list object that can contain other JSON elements. This is how you can generate the OpenAPI definition for that using static Swift helper functions:

```swift
import Foundation
import OpenAPIKit30

extension Server {

    enum Components {

        static var error: JSONSchema {
            .object(
                properties: [
                    "message": .string(
                        required: true,
                        description: "The user facing error message.",
                        example: "Something went wrong with the request."
                    ),
                    "details": .array(
                        items: .object(
                            properties: [
                                "key": .string(
                                    required: true,
                                    description: "The error key",
                                    example: "field"
                                ),
                                "message": .string(
                                    required: true,
                                    description: "The user facing error message",
                                    example: "Something is wrong with the field."
                                ),
                            ]
                        )
                    ),
                ]
            )
        }

        static func page() -> JSONSchema {
            .object(
                properties: [
                    "size": .integer(
                        required: true,
                        maximum: (1000, exclusive: false),
                        minimum: (10, exclusive: false),
                        defaultValue: 50,
                        example: 25
                    ),
                    "current": .integer(
                        required: true,
                        minimum: (0, exclusive: false),
                        defaultValue: 0,
                        example: 12
                    ),
                    "total": .integer(
                        required: true,
                        minimum: (0, exclusive: false),
                        defaultValue: 0,
                        example: 42
                    ),
                ]
            )
        }

        static func list(
            reference: String,
            orderKeys: [String]? = nil
        ) -> JSONSchema {
            .object(
                properties: [
                    "items": .array(
                        items: .reference(.component(named: reference))
                    ),
                    "metadata": .object(
                        properties: [
                            "page": Self.page(),
                            "items": .object(
                                properties: [
                                    "total": .integer(
                                        required: true,
                                        minimum: (0, exclusive: false),
                                        defaultValue: 0,
                                        example: 69
                                    )
                                ]
                            ),
                            "sort": .object(
                                properties: [
                                    "by": .string(
                                        required: false,
                                        description: "Sort the list by ascending or descending order",
                                        allowedValues: "asc", "desc",
                                        defaultValue: "asc"
                                    ),
                                    "order": .string(
                                        required: false,
                                        description: "Field key to order the list",
                                        allowedValues: orderKeys as? [AnyCodable]
                                    ),
                                ]
                            ),
                            "search": .string(
                                required: false,
                                description: "Search term"
                            ),
                        ]
                    ),
                ]
            )
        }
    }
}

```

Now that we're ready with the basic building blocks, let's start creating some actual endpoints. I'm going to show you how to create a complete REST API for a category object type and based on this you should be able to apply the very same pattern to other REST objects. 🔄

Again, we start with a namespace, by using a Swift enum:

```swift
import Foundation

enum Category {}

```

Next, we define some helpers for the fields of the category object. Note that we don't have to create a helper for the `id` field, because we already have that one in the `Server.Fields` namespace. Apart from the unique identifier, a category will only have a `name` field.

```swift
import Foundation
import OpenAPIKit30

extension Category {

    enum Fields {

        static func name(required: Bool = true) -> JSONSchema {
            .string(
                required: required,
                description: "Name of the category",
                example: "Cat"
            )
        }
    }
}

```

By using the previously defined helpers, we can simply come up with the component structure for the Category model. I always like to separate the DTOs (Date Transfer Object) for every REST call, so in our case:

- reference - for references in other objects
- list - `GET /models/`
- detail - `GET /models/{id}`
- create - `POST /models/`
- update - `PUT /models/{id}`
- patch - `PATCH /models/{id}`

This might looks like an overkill, but on the long term it's worth to separate these contexts (or maybe not, who knows... 😅).

```swift
import Foundation
import OpenAPIKit30

extension Category {

    enum Components {

        static var reference: JSONSchema {
            .object(
                properties: [
                    "id": Server.Fields.uuid(),
                    "name": Fields.name(),
                ]
            )
        }

        static var list: JSONSchema {
            .object(
                properties: [
                    "id": Server.Fields.uuid(),
                    "name": Fields.name(),
                ]
            )
        }

        static var detail: JSONSchema {
            .object(
                properties: [
                    "id": Server.Fields.uuid(),
                    "name": Fields.name(),
                ]
            )
        }

        static var create: JSONSchema {
            .object(
                properties: [
                    "name": Fields.name()
                ]
            )
        }

        static var update: JSONSchema {
            .object(
                properties: [
                    "name": Fields.name()
                ]
            )
        }

        static var patch: JSONSchema {
            .object(
                properties: [
                    "name": Fields.name(required: false)
                ]
            )
        }
    }

}
```

Before we deal with the REST operations, we still have to define some parameters. We're going to create a `categoryId` path parameter for category id references, and a sort parameter for the list operation, this way we can specify the allowed sort keys (`name` only in this case).

```swift
import Foundation
import OpenAPIKit30

extension Category {

    enum Parameters {

        static var id: OpenAPI.Parameter {
            .init(
                name: "categoryId",
                context: .path,
                schema: Server.Fields.uuid()
            )
        }

        static var sort: OpenAPI.Parameter {
            return .init(
                name: "sort",
                context: .query,
                schema: .string(
                    allowedValues: "name",
                    defaultValue: "name",
                    example: "name"
                ),
                description: "Sort with the given value"
            )
        }
    }
}
```

Building the operations for the REST endpoints is pretty straightforward if you are already familiar with the [OpenAPI specification](https://swagger.io/specification/). We're not going to explain that in this tutorial, but here's the complete example, to serve as a pattern for you.

```swift
import Foundation
import OpenAPIKit30

extension Category {

    enum Operations {

        static var list: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Find categories",
                description: "List categories",
                operationId: "listCategories",
                parameters: [
                    .ref("page"),
                    .ref("size"),
                    .ref("search"),
                    .ref("categorySort"),
                    .ref("order"),
                ],
                responses: [
                    200: .response(
                        description: "List of categories",
                        content: [
                            .json: .init(
                                schema: Server.Components.list(
                                    reference: "CategoryList"
                                )
                            )
                        ]
                    ),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        static var create: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Create a category",
                description: "Creates a new category object",
                operationId: "createCategory",
                requestBody: .init(content: [
                    .json: .ref("CategoryCreate")
                ]),
                responses: [
                    200: .response(
                        description: "The details of a category object",
                        content: [
                            .json: .ref("CategoryDetail")
                        ]
                    ),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        static var bulkDelete: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Bulk delete categories",
                description: "Removes multiple categories objects at once",
                operationId: "deleteCategories",
                requestBody: .init(content: [
                    .json: .init(
                        schema: .array(
                            items: Server.Fields.uuid()
                        )
                    )
                ]),
                responses: [
                    204: .ref("204"),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        // MARK: - currency id

        static var detail: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Category details",
                description: "Get the details of a category object",
                operationId: "getCategory",
                parameters: [
                    .ref("categoryId")
                ],
                responses: [
                    200: .response(
                        description: "The details of a category object",
                        content: [
                            .json: .ref("CategoryDetail")
                        ]
                    ),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                    404: .ref("404"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        static var update: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Update a category object",
                description: "Updates an entire category object",
                operationId: "updateCategory",
                parameters: [
                    .ref("categoryId")
                ],
                requestBody: .init(content: [
                    .json: .ref("CategoryUpdate")
                ]),
                responses: [
                    200: .response(
                        description:
                            "The details of the patched category object",
                        content: [
                            .json: .ref("CategoryDetail")
                        ]
                    ),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        static var patch: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Patch a category object",
                description: "Patch the properties of a given category object",
                operationId: "patchCategory",
                parameters: [
                    .ref("categoryId")
                ],
                requestBody: .init(content: [
                    .json: .ref("CategoryPatch")
                ]),
                responses: [
                    200: .response(
                        description:
                            "The details of the patched category object",
                        content: [
                            .json: .ref("CategoryDetail")
                        ]
                    ),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                    404: .ref("404"),
                ],
                security: Server.Security.bearerAuth
            )
        }

        static var delete: OpenAPI.Operation {
            .init(
                tags: ["Categories"],
                summary: "Delete a category object",
                description:
                    "Removes a category object using the unique identifier",
                operationId: "deleteCategory",
                parameters: [
                    .ref("categoryId")
                ],
                responses: [
                    204: .ref("204"),
                    400: .ref("400"),
                    401: .ref("401"),
                    403: .ref("403"),
                    404: .ref("404"),
                ],
                security: Server.Security.bearerAuth
            )
        }
    }
}

```

As you can see there are some `.ref()` calls inside the code and we still have to create the entire document specification including the reference points defined as components. We're going to do this now by creating an extension over the `OpenAPI.Document` type. 🥳

```swift
import OpenAPIKit30

extension OpenAPI.Document {

    static var definition: OpenAPI.Document {
        .init(
            info: .init(
                title: "Swagger Petstore - written in Swift",
                description:
                    "This is a sample Pet Store Server based on the OpenAPI 3.0 specification generated using Swift & OpenAPIKit.",
                contact: .init(
                    name: "Binary Birds",
                    url: .init(string: "https://binarybirds.com")!,
                    email: "info@binarybirds.com"
                ),
                version: "1.0.0"
            ),
            servers: [
                .init(
                    url: .init(string: "http://127.0.0.1:8080")!,
                    description: "dev"
                ),
                .init(
                    url: .init(string: "http://127.0.0.1:8081")!,
                    description: "live"
                ),
            ],
            paths: [
                "/categories": .init(
                    get: Category.Operations.list,
                    post: Category.Operations.create,
                    delete: Category.Operations.bulkDelete
                ),
                "/categories/{categoryId}": .init(
                    get: Category.Operations.detail,
                    put: Category.Operations.update,
                    delete: Category.Operations.delete,
                    patch: Category.Operations.patch
                ),
            ],
            components: .init(
                schemas: [
                    "ErrorResponse": Server.Components.error,

                    "CategoryReference": Category.Components.reference,
                    "CategoryList": Category.Components.list,
                    "CategoryDetail": Category.Components.detail,
                    "CategoryCreate": Category.Components.create,
                    "CategoryUpdate": Category.Components.update,
                    "CategoryPatch": Category.Components.patch,

                ],
                responses: [
                    "204": .init(description: "No content"),
                    "400": .init(
                        description: "Bad request",
                        content: [
                            .json: .init(
                                schema: .reference(
                                    .component(named: "ErrorResponse")
                                )
                            )
                        ]
                    ),
                    "401": .init(
                        description: "Unauthorized",
                        content: [
                            .json: .init(
                                schema: .reference(
                                    .component(named: "ErrorResponse")
                                )
                            )
                        ]
                    ),
                    "403": .init(
                        description: "Forbidden",
                        content: [
                            .json: .init(
                                schema: .reference(
                                    .component(named: "ErrorResponse")
                                )
                            )
                        ]
                    ),
                    "404": .init(
                        description: "Not found",
                        content: [
                            .json: .init(
                                schema: .reference(
                                    .component(named: "ErrorResponse")
                                )
                            )
                        ]
                    ),
                ],
                parameters: [
                    "categoryId": Category.Parameters.id,
                    "categorySort": Category.Parameters.sort,

                    "page": Server.Parameters.page,
                    "size": Server.Parameters.size,
                    "search": Server.Parameters.search,
                    "order": Server.Parameters.order,
                ],
                examples: [:],
                requestBodies: [:],
                headers: [:],
                securitySchemes: [
                    "bearerAuth": .init(
                        type: .http(
                            scheme: "bearer",
                            bearerFormat: "token"
                        ),
                        description: "Authorization header using a Bearer token"
                    )
                ]
            ),
            tags: [
                .init(
                    name: "Categories",
                    description: "Pet categories, such as cat, dog, etc."
                ),
            ]
        )
    }
}

```

Finally in the `main.swift` file we're going to generate both the YAML and the JSON output.

```swift
import Foundation
import OpenAPIKit30
import Yams

let basePath =
    "/"
    + #file
    .split(separator: "/")
    .dropLast(3)
    .joined(separator: "/")
    .appending("/dist")

if !FileManager.default.fileExists(atPath: basePath) {
    try FileManager.default.createDirectory(
        atPath: basePath,
        withIntermediateDirectories: true
    )
}

let doc = OpenAPI.Document.definition
let yamlEncoder = YAMLEncoder()
let yamlData = try yamlEncoder.encode(doc)
let yamlPath = "\(basePath)/swagger.yaml"
try yamlData.write(
    to: URL(fileURLWithPath: yamlPath),
    atomically: true,
    encoding: .utf8
)

let jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = [
    .prettyPrinted,
    .withoutEscapingSlashes,
]
let jsonData = try jsonEncoder.encode(doc)
let jsonPath = "\(basePath)/swagger.json"
try jsonData.write(
    to: URL(fileURLWithPath: jsonPath),
    options: .atomic
)

```

Of course we have a working template repository that you can [download for free](https://github.com/binarybirds/swagger-petstore). This repository contains some more common patterns, including N to many relations and some other useful stuff, that you might encounter when you try to build an API specification for your backend service. 😊
