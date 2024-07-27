---
type: post
slug: building-a-global-storage-for-vapor
title: Building a global storage for Vapor
description: This tutorial is about a shared global storage that you can implement using a common design pattern in Vapor 4.
publication: 2021-12-16 16:20:00
tags: Vapor, storage
authors:
  - tibor-bodecs
---

## The problem with app services

Vapor has a thing called [services](https://docs.vapor.codes/4.0/services/), you can add new functionality to the system by following the pattern described in the documentation. Read-only services are great there is no issue with them, they always return a new instance of a given object that you want to access.

The problem is when you want to access a shared object or in other words, you want to define a writable service. In my case I wanted to create a shared cache dictionary that I could use to store some preloaded variables from the database.

My initial attempt was to create a writable service that I can use to store these key-value pairs. I also wanted to use a middleware and load everything there upfront, before the route handlers. 💡

```swift
import Vapor

private extension Application {
    
    struct VariablesStorageKey: StorageKey {
        typealias Value = [String: String]
    }

    var variables: [String: String] {
        get {
            self.storage[VariablesStorageKey.self] ?? [:]
        }
        set {
            self.storage[VariablesStorageKey.self] = newValue
        }
    }
}

public extension Request {
    
    func variable(_ key: String) -> String? {
        application.variables[key]
    }
}

struct CommonVariablesMiddleware: AsyncMiddleware {

    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let variables = try await CommonVariableModel.query(on: req.db).all()
        var tmp: [String: String] = [:]
        for variable in variables {
            if let value = variable.value {
                tmp[variable.key] = value
            }
        }
        req.application.variables = tmp
        return try await next.respond(to: req)
    }
}
```

Now you might think that hey this looks nice and it'll work and you are right, it works, but there is a HUGE problem with this solution. It's not thread-safe at all. ⚠️

When you open the browser and type `http://localhost:8080/` the page will load, but when you start bombarding the server with multiple requests using multiple threads (`wrk -t12 -c400 -d30s http://127.0.0.1:8080/`) the application will simply crash.

There is a similar issue on [GitHub](https://github.com/vapor/vapor/issues/2330), which describes the exact same problem. Unfortunately I was unable to solve this with [locks](https://docs.vapor.codes/4.0/services/#locks), I don't know why but it messed up even more things with strange errors and since I'm also not able to run instruments on my M1 Mac Mini, because Swift packages are not [code signed](https://developer.apple.com/forums/thread/681687) by default. I've spent so many hours on this and I've got very frustrated.

## Building a custom global storage

After a break this issue was still bugging my mind, so I've decided to do some more research. [Vapor's discord](https://discord.com/invite/vapor) server is usually a great place to get the right answers.

I've also looked up other web frameworks, and I was quite surprised that [Hummingbird](https://github.com/hummingbird-project/hummingbird) offers an [EventLoopStorage](https://hummingbird-project.github.io/hummingbird/current/hummingbird/Classes/HBApplication/EventLoopStorage.html) by default. Anyway, I'm not going to switch, but still it's a nice to have feature.

As I was looking at the suggestions I realized that I need something similar to the `req.auth` property, so I've started to investigate the [implementation](https://github.com/vapor/vapor/blob/main/Sources/Vapor/Authentication/AuthenticationCache.swift) details more closely.

First, I removed the protocols, because I only needed a plain `[String: Any]` dictionary and a generic way to return the values based on the keys. If you take a closer look it's quite a simple design pattern. There is a helper struct that stores the reference of the request and this struct has an private Cache class that will hold our pointers to the instances. The cache is available through a property and it is stored inside the `req.storage`.

```swift
import Vapor

public extension Request {

    var globals: Globals {
        return .init(self)
    }

    struct Globals {
        let req: Request

        init(_ req: Request) {
            self.req = req
        }
    }
}

public extension Request.Globals {

    func get<T>(_ key: String) -> T? {
        cache[key]
    }
    
    func has(_ key: String) -> Bool {
        get(key) != nil
    }
    
    func set<T>(_ key: String, value: T) {
        cache[key] = value
    }
    
    func unset(_ key: String) {
        cache.unset(key)
    }
}


private extension Request.Globals {

    final class Cache {
        private var storage: [String: Any]

        init() {
            self.storage = [:]
        }

        subscript<T>(_ type: String) -> T? {
            get { storage[type] as? T }
            set { storage[type] = newValue }
        }
        
        func unset(_ key: String) {
            storage.removeValue(forKey: key)
        }
    }

    struct CacheKey: StorageKey {
        typealias Value = Cache
    }

    var cache: Cache {
        get {
            if let existing = req.storage[CacheKey.self] {
                return existing
            }
            let new = Cache()
            req.storage[CacheKey.self] = new
            return new
        }
        set {
            req.storage[CacheKey.self] = newValue
        }
    }
}
```

After changing the original code I've come up with this solution. Maybe it's still not the best way to handle this issue, but it works. I was able to store my variables inside a global storage without crashes or leaks. The `req.globals` storage property is going to be shared and it makes possible to store data that needs to be loaded asynchronously. 😅

```swift
import Vapor

public extension Request {
    
    func variable(_ key: String) -> String? {
        globals.get(key)
    }
}

struct CommonVariablesMiddleware: AsyncMiddleware {

    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let variables = try await CommonVariableModel.query(on: req.db).all()
        for variable in variables {
            if let value = variable.value {
                req.globals.set(variable.key, value: value)
            }
            else {
                req.globals.unset(variable.key)
            }
        }
        return try await next.respond(to: req)
    }
}
```

After I've run several more tests using [wrk](https://github.com/wg/wrk) I was able to confirm that the solution works. I had no issues with threads and the app had no memory leaks. It was a relief, but still I'm not sure if this is the best way to handle my problem or not. Anyway I wanted to share this with you because I believe that there is not enough information about thread safety.

The introduction of [async / await in Vapor](https://theswiftdev.com/beginners-guide-to-the-asyncawait-concurrency-api-in-vapor-fluent/) will solve many concurrency problems, but we're going to have some new ones as well. I really hope that Vapor 5 will be a huge improvement over v4, people are already throwing in ideas and they are having discussions about the future of Vapor on discord. This is just the beginning of the async / await era both for Swift and Vapor, but it's great to see that finally we're going to be able to get rid of [EventLoopFutures](https://docs.vapor.codes/4.0/fluent/transaction/#asyncawait). 🥳
