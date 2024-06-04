---
slug: using-openapi-with-hummingbird
title: Using OpenAPI Generator with Hummingbird
description: Learn how to use OpenAPI Generator to create Swift APIs with Hummingbird.
publication: 2024-03-05 18:30:00
tags: Hummingbird, OpenAPI, Documentation
author: Joannis Orlandos
authorLink: https://x.com/JoannisOrlandos
authorGithub: joannis
authorAbout: Joannis is a seasoned member of the Swift Server WorkGroup, and the co-founder of Unbeatable Software B.V. If you're looking to elevate your team's capabilities or need expert guidance on Swift backend development, consider hiring him.
cta: Get in touch with Joannis
ctaLink: https://unbeatable.software/mentoring-and-training
company: Unbeatable Software B.V.
companyLink: https://unbeatable.software/
duration: 20 minutes
---

# Using OpenAPI Generator with Hummingbird

The [OpenAPI Generator](https://github.com/apple/swift-openapi-generator) for Swift is a recent addition to the ecosystem that enables you to generate Swift code from OpenAPI specifications. This documentation-first approach allows you to define your API before starting a project, enabling both client and server code generation across multiple languages.

OpenAPI specifications can support a variety of content types, such as JSON, XML, Multipart, binary files and streams of data.
When using OpenAPI to generate a client, you'll get a spec-compliant client implementation at the push of a button.

Servers generated from OpenAPI specifications are also spec-compliant. The generator creates an protocol named `APIProtocol` . Conforming to this type, you'll need to implement all the routes defined in your OpenAPI specification. This ensures that your server is always in sync with your API specification.

The OpenAPI generator ensures that data is handled efficiently and correctly. It also provides a clear and concise way to define your API, making it easy to understand and maintain. It integrates well with Hummingbird, requiring minimal setup to get started.

In this tutorial, we'll show you how to use the OpenAPI Generator to create a Swift API with [Hummingbird](./whats-new-in-hummingbird-2). If you're using Hummingbird with AWS Lambda, you can also use the OpenAPI generator for handling routes in your Lambda function.

## Prerequisites

This tutorial has a [sample project](https://github.com/swift-on-server/using-openapi-with-hummingbird-sample), containing a starter and finished project. You can use this to verify your setup.

## OpenAPI Generation

The [OpenAPI Specification](https://swagger.io/specification/) is a standard for defining HTTP APIs. It allows you to define the endpoints, request and response bodies, and other relevant details of your API in a machine-readable format.

When adding the OpenAPI generator to your project, you'll need to add the following dependencies to your `Package.swift` file:

```swift
.package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.2.0"),
.package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.3.0"),
.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.1"),
.package(url: "https://github.com/swift-server/swift-openapi-hummingbird.git", from: "2.0.0-beta.1"),
```

**Note:** `swift-argument-parser` is not related to Hummingbird or OpenAPI.

<!-- TODO: Update hummingbird dependency after release -->

When working with OpenAPI generator, it's helpful to create a separate module (target) for your generated OpenAPI code. First of all, this allows you to import the generated code into a client implementation. But more importantly, it prevents the Swift compiler from getting confusing about the generated code "not existing" at times. When separating the OpenAPI module, it is compiled first, helping avoid these issues.

In order to complete the setup, add the following to your Package manifest:

```swift
.target(
    name: "MyOpenAPI",
    dependencies: [
        // 1
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
    ],
    // 2
    plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
),
.executableTarget(
    name: "MyApp",
    dependencies: [
        // 3
        .target(name: "MyOpenAPI"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ]
),
```

1. Add the `OpenAPIRuntime` dependency to your OpenAPI module, this allows the generated code to make use of the shared OpenAPI types.
2. Add the `OpenAPIGenerator` plugin to your OpenAPI module. The plugin will generate the Swift code from your OpenAPI specification.
3. Add the `MyOpenAPI` target as a dependency to your application target. By importing this module, you can use the generated code in your application.

OpenAPI generator is setup with a Swift Package Manager (SPM) plugin. The generated code will _not_ be added to your source code, or even be visible in file browser. 

When building the **Finished** project, you can find the generated code in the `.build/plugins` directory:

```
.build/plugins/outputs/finished/MyOpenAPI/OpenAPIGenerator/GeneratedSources
```

## Creating a specification

The OpenAPI specification is a YAML file that describes your API. It contains all public information needed to communicate between your API and clients.

The specification is written in `Sources/MyOpenAPI/openapi.yaml`. Here's an example of a simple OpenAPI specification.

```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0

# The routes on your API
paths:
  /hello:
    # GET /hello
    get:
      operationId: greet
      responses:
        '200': # When the request is successful
          description: A hello message
          content:
            application/json:
              schema: # The returned JSON object
                type: object
                properties:
                  message:
                    type: string
                required:
                  - message
```

In order to generate Swift code from this specification, you'll need to add `openapi-generator-config.yaml` in the same directory as your specification. This file contains the configuration for the OpenAPI generator.

```yaml
generate:
  - types
  - server
accessModifier: public
```

This configuration file tells the OpenAPI generator to generate types and server code, and to use public access modifiers for all types it generates. This ensures that the generated code is accessible from your application's module. You can alternatively use the `package` access modifier to make the generated code accessible from the entire package, but not any apps that depend on this package.

> Note: If you want to generate the code needed to run an HTTP client, you can add `client` to the `generate` list.

Finally, you'll need an empty `.swift` file in your `Sources/MyOpenAPI` directory. This file is necessary for SPM to recognize the directory as a Swift module.

## Implementing the server

Now that you have your OpenAPI specification and configuration, you can generate the Swift code. This happens automatically during `swift build`. In order to use the generated code, you'll need to import the `MyOpenAPI` module in your application. Let's create a new Hummingbird server that responds to the `/hello` route.

First, create a new file called `Sources/MyApp/HelloAPI.swift` with the following content:

```swift
import MyOpenAPI

struct HelloAPI: APIProtocol {
    // 1
}
```

The `APIProtocol` conformance refers to the generated `APIProtocol` from the OpenAPI specification. This protocol contains all the routes and request/response types defined in your OpenAPI specification. By conforming to this protocol, and implementing the required methods, you can create a server that responds to the routes defined in your OpenAPI specification. This guarantees that your server is always in sync with your API specification.

The **operationId** is used for the operationId and the Input/Output namespace. When conforming to `APIProtocol`, you'll need to implement all methods that are defined in your OpenAPI specification. This provides compile-time guarantees that you've implemented all the routes defined in your OpenAPI specification.

Next, you'll need to implement the `greet` method. This method is called when a client sends a `GET` request to `/hello`. Add the following code:

```swift
struct HelloAPI: APIProtocol {
    func greet(_ input: Operations.greet.Input) async throws -> Operations.greet.Output {
        // 1.
        return .ok(.init(body:
            // 2.
            .json(.init(
                // 3
                message: "Hello, world!"
            ))
        ))
    }
}
```

As you see, the `greet` function is a simple generated signature. The `Input` type is the request, and the `Output` type is the response.

Both `Input` and `Output` types are very noticably generated types in OpenAPI, and look very verbose. Let's break down what's being returned:

1. Return an HTTP 200 (OK) response
2. The OK response has a JSON body
3. The JSON body contains a `message` property with the value "Hello, world!"

Note that the JSON body is not directly set in the body. This is necessary, because OpenAPI generator supports multipart and other types of responses. When working with HTTP bodies in `Input`, you'll find back the same design.

### Verbosity and OpenAPI

The verbosity of the generated types can be perceived as a downside to OpenAPI generator. It lacks the 'slimness' of most Swift APIs. However, as you work with OpenAPI more you'll find that the verbosity is one of its strenghts in practice. It makes it very clear what the API expects and returns, making it hard or even impossible to overlook important details.

OpenAPI is a documentation-first approach, with the generated code being a direct reflection of this documentation. This builds a level of reliability and trust to your APIs and client implementations that is hard to achieve otherwise.

## Hosting the HelloAPI

Finally, you'll need to create a Hummingbird server that uses the `HelloAPI` to respond to the `/hello` route. Create a new file called `Sources/MyApp/App.swift` with the following content:

```swift
import ArgumentParser
import Hummingbird
import OpenAPIHummingbird
import OpenAPIRuntime

@main struct HummingbirdArguments: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        // 1
        let router = Router()
        router.middlewares.add(LogRequestsMiddleware(.info))

        // 2
        let api = HelloAPI()

        // 3
        try api.registerHandlers(on: router)
        
        // 4
        let app = Application(
            router: router,
            configuration: .init(address: .hostname(hostname, port: port))
        )

        // 5
        try await app.runService()
    }
}
```

This code registers the `HelloAPI` routes, defined in your `openapi.yaml`

Let's break down the above:

1. Create a new `Router` and add a logging middleware to it, allowing you to see the requests in the console.
2. Create a new `HelloAPI` instance. This is also the point where you can inject dependencies into your API implementation.
3. Register the HelloAPI's handlers on the router. This will make the `HelloAPI` respond to the `/hello` route.
4. Create a new `Application` with the router and a configuration that specifies the hostname and port.
5. Run the application. This will make your route available at [http://localhost:8080/hello](http://localhost:8080/hello).

That's all it takes to create a Hummingbird server that responds to the `/hello` route using the OpenAPI generator. There are many more features and options available in the OpenAPI generator, such as multipart or generating client code for use with a client transport such as [async-http-client](https://github.com/swift-server/async-http-client) and URLSession. We hope this tutorial has given you a good starting point for using the OpenAPI generator with Hummingbird.
