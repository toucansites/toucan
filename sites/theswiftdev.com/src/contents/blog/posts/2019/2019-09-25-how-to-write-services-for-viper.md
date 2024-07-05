---
slug: how-to-write-services-for-viper
title: How to write services for VIPER?
description: Not everything is a VIPER module. In this article I'll show you how do I separate the service layer from the modules, using Swift.
publication: 2019-09-25 16:20:00
tags: VIPER
---

I can imagine that you just started to write your [first VIPER module](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/) and you might wonder: where should I put all my network communication, CoreLocation, CoreData or "whatever service" code, that's not related to the [user interface](https://theswiftdev.com/2019/03/11/viper-best-practices-for-ios-developers/) at all?

> To the service layer!

I usually call these the API, location, storage as a service, because they serve your modules with some kind of information. Plus they can encapsulate the underlying layer, providing a well-defined API interface for your VIPER modules. 😅

Ok, but what about interactors? Shouldn't I implement this kind of stuff there?

Well, my answer is no, because there is a major difference between services and interactors. While a service is just a "dummy" wrapper around e.g. a RESTful API, another one around the CoreData storage, an interactor however could use both of them to request some kind of data though the API, and save it locally using the storage service. Interactors can also do sorting, filtering, transformation between Data Transfer Objects (DTOs) and entities, more about them later.

Enough theory for now, let's create a new service.

## Service interfaces

This time as the Protocol Objective Programming paradigm says:

> We start designing our system by defining protocols.

Our first one is going to be a really simple one for all the services:

```swift
protocol ServiceInterface: class {
    func setup()
}

extension ServiceInterface {

    func setup() {
        // do nothing...
    }
}
```
The setup will be called for each service during the service initialization process. We can extend the base service so we don't have to implement this method, but only if we really have to do something, like setting up our CoreData stack.

Next we can come up with our API service, in this case I'm going to implement a dummy endpoint that loads some data using [the new Combine framework with URLSession](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/), but of course you can go with completion blocks or [Promises](https://theswiftdev.com/2019/05/28/promises-in-swift-for-beginners/) as well.

```swift
protocol ApiServiceInterface: ServiceInterface {

    func todos() -> AnyPublisher<[TodoObject], HTTP.Error>
}
```

Nowadays I'm using a HTTP namespace for all my network related stuff, like request methods, responses, errors, etc. Feel free to extend it based on your needs.

```swift
enum HTTP {

    enum Method: String {
        case get
        //...
    }
    enum Error: LocalizedError {
        case invalidResponse
        case statusCode(Int)
        case unknown(Swift.Error)
    }
}
```

As you can see it's quite lightweight, but it's extremely handy. We haven't talked about the TodoObject yet. That's going to be our very first DTO. 😱

## Data Transfer Objects

> A data transfer object (DTO) is an object that carries data between processes. - [Wikipedia](https://en.wikipedia.org/wiki/Data_transfer_object)

In this case we're not talking about processes, but services & VIPER modules. They exists so we can decouple our service layer from our modules. The interactor can transform the DTO into a module entity, so all other parts of the VIPER module will be completely independent from the service. Worth to mention that a DTO is usually really simple, in a RESTful API service, a DTO can implement the `Codable` interface and nothing more or for `CoreData` it can be just a `NSManagedObject` subclass.

```swift
struct TodoObject: Codable {
    let id: Int
    let title: String
    let completed: Bool
}
```

You can also use a simple DTO to wrap your request parameters. For example you can use a TodoRequestObject which can contain some filter or sorting parameters. You might noticed that I always use the Object suffix for my DTO's, that's a personal preference, but it helps me differentiate them from entities.

Going a little bit further this way: you can publish your entire service layer as an encapsulated Swift package using [SPM](https://theswiftdev.com/2019/01/14/all-about-the-swift-package-manager-and-the-swift-toolchain/), from Xcode 11 these packages are natively supported so if you're still using CocoaPods, you should consider [migrating to the Swift Package Manager](https://theswiftdev.com/2019/09/02/migrating-from-cocoapods-to-swift-package-manager/) as soon as possible.

## Service implementations

Before we start building our real service implementation, it's good to have a fake one for demos or testing purposes. I call this fake, because we're going to return a fixed amount of fake data, but it's close to our real-world implementation. If our request would include filtering or sorting, then this fake implementation service should filter or sort our response like the final one would do it.

```swift
final class FakeApiService: ApiServiceInterface {

    var delay: TimeInterval

    init(delay: TimeInterval = 1) {
        self.delay = delay
    }

    private func fakeRequest<T>(response: T) -> AnyPublisher<T, HTTP.Error> {
        return Future<T, HTTP.Error> { promise in
            promise(.success(response))
        }
        .delay(for: .init(self.delay), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func todos() -> AnyPublisher<[TodoObject], HTTP.Error> {
        let todos = [
            TodoObject(id: 1, title: "first", completed: false),
            TodoObject(id: 2, title: "second", completed: false),
            TodoObject(id: 3, title: "third", completed: false),
        ]
        return self.fakeRequest(response: todos)
    }
}
```

I like to add some delay to my fake objects, because it helps me testing the UI stack. I'm a big fan of Scott's [how to fix a bad user interface](https://www.scotthurff.com/posts/why-your-user-interface-is-awkward-youre-ignoring-the-ui-stack/) article. You should definitely read it, because it's amazing and it will help you to design better products. 👍

Moving forward, here is the actual "real-world" implementation of the service:

```swift
final class MyApiService: ApiServiceInterface {

    let baseUrl: String

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    func todos() -> AnyPublisher<[TodoObject], HTTP.Error> {
        let url = URL(string: self.baseUrl + "todos")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTP.Method.get.rawValue.uppercased()

        return URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTP.Error.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw HTTP.Error.statusCode(httpResponse.statusCode)
            }
            return data
        }
        .decode(type: [TodoObject].self, decoder: JSONDecoder())
        .mapError { error -> HTTP.Error in
            if let httpError = error as? HTTP.Error {
                return httpError
            }
            return HTTP.Error.unknown(error)
        }
        .eraseToAnyPublisher()
    }
}
```

The thing is that we could make this even better, but for the sake of simplicity I'm going to "hack-together" the implementation. I don't like the implicitly unwrapped url, and many more little details, but for learning purposes it's totally fine. 😛

So the big question is now, how to put things togehter? I mean we have a working service implementation, a fake service implementation, but how the hell should we put everything into a real Xcode project, without shipping fake code into production?

## Target environments

Usually you will have a live production environment, a development environment, maybe a staging environment and some more for QA, UAT, or demo purposes. Things can vary for these environments such as the final API url or the app icon, etc.

This time I'm going to set up a project with 3 separate environments:

- Production
- Development
- Fake

If you start with a new project you'll have one primary (non-test) target by default. You can duplicate a target by right-clicking on it. Let's do this two times.

I usually go with a suffix for the target and scheme names, except for the production environment, where I use the "base name" without the -Production postfix.

As you can see on the screenshot I have a basic folder structure for the environments. There has to be a separate `Info.plist` file for every target, so I put them into the proper Assets folder. The FakeApiService.swift is only part of the fake target, and every other file is shared. Wait, what the heck is a ServiceBuilder?

## Dependency injection

Multiple environment means that we have to use the right service (or configuration) for every build target. I'm using [the dependency injection design pattern](https://theswiftdev.com/2018/07/17/swift-dependency-injection-design-pattern/) for this purpose. A service builder is just a protocol that helps to achieve this goal. It defines how to setup services based on the environment. Let me show you how it works.

```swift
protocol ServiceBuilderInterface {

    var api: ApiServiceInterface { get }

    func setup()
}

extension ServiceBuilderInterface {

    func setup() {
        self.api.setup()
    }
}
```

Now for each target (environment) I implement the ServiceBuilderInterface in an actual ServiceBuilder.swift file, so I can setup my services just as I need them.

```swift
final class ServiceBuilder: ServiceBuilderInterface {

    lazy var api: ApiServiceInterface = {
        // this can be the url of the development server
        MyApiService(baseUrl: "https://jsonplaceholder.typicode.com")
    }()
}
```

I usually have a base service-interactor class that will receive all the services during the initialization process. So I can swap out anything without a hassle.

```swift
class ServiceInteractor {

    let services: ServiceBuilderInterface

    init(services: ServiceBuilderInterface = App.shared.services) {
        self.services = services
    }
}
```

DI is great, but I don't like to repeat myself too much, that's why I'm providing a default value for this property, which is located in my only [singleton class](https://theswiftdev.com/2018/05/22/swift-singleton-design-pattern/) called App. I know, singletons are evil, but I already have an anti-pattern here so it really doesn't matter if I introduce one more, right? #bastard #singleton 🤔

```swift
final class App {

    let services = ServiceBuilder()

    // MARK: - singleton

    static let shared = App()

    private init() {
        // do nothing...
    }

    // MARK: - api

    func setup() {
        self.services.setup()
    }
}
```

This setup is extremely useful if it comes to testing. You can simply mock out all the services if you want to test an interactor. It's also nice and clean, because you can reach your methods in the interactors like this: `self.services.api.todos()`

> You can apply the same pattern for your modules, I mean you can have for example a ModuleBuilder that implements a ModuleBuilderInterface and all the routers can have them through DI, so you don't have to initialize everything from scratch all the tim using the build function of the module. 😉

Still I want to clarify one more thing...

## Object, model, entity, what the...?

A little bit about naming conventions (I also use these as suffixes all the time):

- Object
- Entity
- Model

In my dictionary an Object is always a DTO, it only lives in the service layer. It's a freakin dumb one, without any more purpose than providing a nice Swiftish API. This means you don't have to deal with JSON objects or anything crazy like that, but you can work directly with these objects, which is usually a nice to have feature.

An Entity is related to a VIPER module. Its purpose is to act as a communication object that can be passed around between the view, interactor, presenter, router or as a parameter to another module. It can encapsulate the local stuff that's required for the module. This means if something changes in the service layer (a DTO maybe) your module will be able to work, you only have to align your interactor. 😬

> Still, sometimes I'm completely skipping entities, but I know I shouldn't. :(

A Model refers to a view-model, which is part of my [component based UI building approach](https://theswiftdev.com/2019/05/23/building-input-forms-for-ios-apps/) on top of the [UICollectionView](https://theswiftdev.com/2018/04/17/ultimate-uicollectionview-guide-with-ios-examples-written-in-swift/) class. You should check out the links if you want to learn more about it, the syntax is very similar to [SwiftUI](https://theswiftdev.com/2019/09/18/how-to-build-swiftui-apps-using-viper/), but it's obviously not as high-level. In summary a model always has the data that's required to render a view, nothing more and nothing less.

I hope this little article will help you to structure your apps better. VIPER can be quite problematic sometimes, because of the way you have to architect the apps. Using these kind of services is a nice approach to separate all the different API connections, sensors, and many more, and finally please remember:

> Not everything is a VIPER module.

You can download the source files for this article using The.Swift.Dev tutorials repository on [GitHub](https://github.com/theswiftdev/tutorials). Thanks for reading, if you haven't done it yet please subscribe to my newsletter below, or send me ideas, feedbacks through Twitter. 👏
