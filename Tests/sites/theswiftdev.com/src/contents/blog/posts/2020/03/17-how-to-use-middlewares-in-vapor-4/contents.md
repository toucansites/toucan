---
slug: how-to-use-middlewares-in-vapor-4
title: How to use middlewares in Vapor 4?
description: Learn how to create middlewares for a Vapor based server side Swift application to handle common routing functionalities.
publication: 2020-03-17 16:20:00
tags: Vapor
---

## What is a middleware?

A [middleware](https://docs.vapor.codes/4.0/routing/#middleware) is basically a function that will be executed every time before the request handler. This way you can hook up special functionalities, such as altering the request before your handler gets the chance to respond to it. Let me show you a real-world example real quick.

```swift
import Vapor

final class ExtendPathMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if !request.url.path.hasSuffix("/") {
            let response = request.redirect(to: request.url.path + "/", type: .permanent)
            return request.eventLoop.makeSucceededFuture(response)
        }
        return next.respond(to: request)
    }
}
```

I'm using this middleware to always extend my paths with a trailing slash character. Just try to delete the last char from the URL here on my site & press enter, you'll be redirected to the original path with a "/" suffix, since the middleware is doing its job. 👨‍💻

A middleware function has two input parameters. The first one is the `Request` object that you can check or even alter its properties. The second one is the next reference in the `Responder` chain, so you can respond as usual (with your route handlers) if the middleware has nothing to do with the incoming request. You should always call the `next.respond(to: request)` method.

## Using a middleware

In order to use the middleware from above you have to register it first. It is possible to use a middleware globally, you can hook up your middleware using the `app.middleware.use(_)` method. This way the registered middleware will be applided for every single route in your Vapor server.

```swift
import Vapor

public func configure(_ app: Application) throws {
    // ...
    app.middleware.use(ExtendPathMiddleware())
}
```

The other option is to apply a middleware to specific subset of routes.

```swift
let middlewareRoutes = app.grouped(ExtendPathMiddleware())
middlewareRoutes.get("hello") { req in
    return "hello"
}
```

You can read more about routing in the [official Vapor 4 docs](https://docs.vapor.codes/4.0/routing/). I also prefer to have a dedicated router class for my modules (I'm using kind of a VIPER architecture on the server side). 😜

```swift
final class MyRouter: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ExtendPathMiddleware()).get("hello", use: self.hello)
    }
    
    func hello(req: Request) -> String {
        return "hello"
    }
}
// config
try app.routes.register(collection: routes)
```

That's how I utilize middlewares in my Vapor apps. Honestly I don't have that much custom middlewares, but the ones I implemented helps me a lot to solve common problems.

## Built-in middlewares

There are some useful middlewares built right into Vapor.

### File middleware

The `FileMiddleware` allows you to serve static assets from a given folder. This comes handy if you are using Vapor without an nginx server, so you can serve images, stylesheets, javascript files with the client (browser). You can setup the middleware like this:

```swift
import Vapor

public func configure(_ app: Application) throws {
    // ...

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
}
```

You can configure the path of your resources by passing the `publicDirectory` input parameter.

### CORS middleware

In short, [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) allows you to share resources between multiple domains.

> Cross-origin resource sharing (CORS) is a mechanism that allows restricted resources on a web page to be requested from another domain outside the domain from which the first resource was served.

This comes handy if you are [developing frontend apps by using Leaf & Vapor](https://theswiftdev.com/how-to-create-your-first-website-using-vapor-4-and-leaf/). This middleware will replace or add the necessary CORS headerss to the response. You can use the default config or initialize a custom one, here is the Swift code for using the CORS middleware:

```swift
import Vapor

public func configure(_ app: Application) throws {
    // ...
    
    // using default configuration
    app.middleware.use(CORSMiddleware(configuration: .default()))
    
    // using custom configuration
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))
}
```

If you want to learn more about how these middlewares work you should option+click on the name of the middleware in Xcode. This way you can browse the source files directly. 🔍

### Error middleware

Route handlers can throw erros. You can catch those by using the `ErrorMiddlware` and turn them into proper HTTP responses if necessary. Here is how to setup the middleware:

```swift
import Vapor

public func configure(_ app: Application) throws {
    // ...
    // using the default error handler
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // using a custom error handler
    app.middleware.use(ErrorMiddleware { req, error -> Response in
        // implement custom response...
        .init(status: .internalServerError, version: req.version, headers: .init(), body: .empty)
    })
}
```

If you are developing an API service, this middleware is kind of an essential component. 💥

### Auth related middlewares

The `Authenticator` protocol conforms to the `Middleware` protocol, so we can register anything that implements any of the Authenticator protocols. You can read more about how the auth layer works in Vapor 4 from my [authentication tutorial](https://theswiftdev.com/all-about-authentication-in-vapor-4/).

The `Authenticatable` protocol has two static methods, they returns middlewares too. The first one is the guard middleware, which will throw an error if the user is not logged in. The second one is the redirect middleware, that redirects unauthenticated requests to the supplied path.

```swift
// The UserModelAuthenticator is an Authenticator
app.routes.grouped(UserModelAuthenticator())

// The UserModel object is Authenticatable
app.routes.grouped([
    UserModel.guardMiddleware(),
    UserModel.redirectMiddleware(path: "/"),
])
```

Multiple middlewares can be registered at once using an array.

## Middlewares vs route handlers

Sometimes it's useful to write a middleware, but in other cases a simple route handler can be more than enough. I'm not against middlewares at all, but you should consider which approach is the best for your needs. I usually go with simple handlers and blocks in 95% of the cases.

Middlwares are good for solving global problems, for example if you want to add a new header to every request it's safe to use a middleware. Checking user permission levels? Not necessary, but yeah if you want to simplify things a middleware could work here as well. 🤔

## Fun fact

This URL: `https://www.google.com/////search?????client=safari&&&&&q=swift+vapor` still works, despite the fact that it contains 5 slashes, question marks and ampersands. I don't know why, but most of the websites are not checking for duplicates. Try with other domains as well.

If you want to learn how to build a custom middleware I think it's a good practice to solve this issue. Write one that removes the unnecessary characters and redirects to the "right" URL.

