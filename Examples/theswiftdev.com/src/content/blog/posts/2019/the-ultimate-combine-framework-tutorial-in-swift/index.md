---
type: post
title: The ultimate Combine framework tutorial in Swift
description: Get started with the brand new declarative Combine framework in practice using Swift. I'll teach you all the goodies from zero to hero.
publication: 2017-10-10 16:20:00
tags: 
    - uikit
    - ios
authors:
    - tibor-bodecs
---

## What is Combine?

> Customize handling of asynchronous events by combining event-processing operators. - [Apple's Combine Framework](https://developer.apple.com/documentation/combine/)

In other words, it allows you to write functional reactive code in a declarative way using Swift. Functional reactive programming ([FRP](https://en.wikipedia.org/wiki/Functional_reactive_programming)) is a special paradigm used to deal with asynchronous code. It's a special kind of [functional programming](https://theswiftdev.com/2019/02/05/beginners-guide-to-functional-swift/), where you are working with async streams of values. So basically you can process and transform values over time using functional methods like `map`, `flatMap`, etc. [Combine](https://www.vadimbulavin.com/swift-combine-framework-tutorial-getting-started/) is the "native" Swift implementation of this programming paradigm, made by Apple.

## Publishers, Operators, Subscribers

I already made [a brief networking example of using Combine](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/), which is good if you're just looking for a simple code snippet to simplify your URLSession requests. Allow me to grab one example and paste it here again, I'll show you why... 🤔

```swift
private var cancellable: AnyCancellable?
//...
self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
.map { $0.data }
.decode(type: [Post].self, decoder: JSONDecoder())
.replaceError(with: [])
.eraseToAnyPublisher()
.sink(receiveValue: { posts in
    print(posts.count)
})
//...
self.cancellable?.cancel()
```

The most important thing here is the new dataTaskPublisher method. It creates Publisher that can send (aka. publish) sequences of values over time.

Moving forward to the next few lines we can see examples of various Operator functions (`map`, `decode`, `replaceError`, `ereaseToAnyPublisher`). They are special functional methods and they always return a Publisher. By using operators you can chain a bunch of publishers together, this gives us that nice declarative syntax that I mentioned before. Functional programming is awesome! 😎

The final member of the Combine family is the Subscriber. Since we can publish all sort of things, we can assume that on the other end of the publisher chain, there will be some sort of object that's going to use our final result. Staying with our current example, the sink method is a built-in function that can connect a publisher to a subscriber. You'll learn the other one later on... hint: assign.

## Benefits of using the Combine framework

I believe that [Combine](https://engineering.q42.nl/swift-combine-framework/) is a huge leap forward and everyone should learn it. My only concern is that you can only use it if you are targeting iOS 13 or above, but this will fade away (in a blink) with time, just like it was with collection and stack views.

> Do you remember iOS 6? Yeah, next up: iOS 14!!!

Anyway, there are a bunch of goodies that Combine will bring you:

- Simplified asynchronous code - no more callback hells
- Declarative syntax - easier to read and maintain code
- Composable components - composition over inheritance & reusability
- Multi-platform - except on Linux, we're good with [SwiftNIO](https://github.com/apple/swift-nio)'s approach
- Cancellation support - it was always an issue with [Promises](https://theswiftdev.com/2019/05/28/promises-in-swift-for-beginners/)
- Multithreading - you don't have to worry about it (that much)
- Built-in memory management - no more bags to carry on

This is the future of aysnc programming on Apple plaftorms, and it's brighter than it was ever before. This is one of the biggest updates since the completely revamped [GCD framework API in Swift](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/). Oh, by the way you might ask the question...

## GCD vs Combine vs Rx vs Promises

My advice is to stay with your current favorite solution for about one year (but only if you are happy with it). Learn Combine and be prepared to flip the switch, if the time comes, but if you are just starting a new project and you can go with iOS13+ then I suggest to go with Combine only. You will see how amazing it is to work with this framework, so I if you are still not convinced, it's time to...

## Learn Combine by example

Since there are some great articles & books about [using Combine](https://heckj.github.io/swiftui-notes/), I decided to gather only those practical examples and patterns here that I use on a regular basis.

### Built-in publishers

There are just a few built-in publishers in the Foundation framework, but I think the number will grow rapidly. These are the ones that I used mostly to simplify my code:

### Timer

You can use Combine to get periodic time updates through a publisher:

```swift
var cancellable: AnyCancellable?

// start automatically
cancellable = Timer.publish(every: 1, on: .main, in: .default)
.autoconnect()
.sink {
    print($0)
}

// start manually
let timerPublisher = Timer.publish(every: 1.0, on: RunLoop.main, in: .default)
cancellable = timerPublisher
.sink {
    print($0)
}

// start publishing time
let cancellableTimerPublisher = timerPublisher.connect()
// stop publishing time
//cancellableTimerPublisher.cancel()

// cancel subscription
//cancellable?.cancel()
```

You can start & stop the publisher any time you need by using the connect method.

> NOTE: Combine has built-in support for cancellation. Both the sink and the assign methods are returning an object that you can store for later and you can call the cancel method on that AnyCancellable object to stop execution.

### NotificationCenter

You can also subscribe to notifications by using publishers.

```swift
extension Notification.Name {
    static let example = Notification.Name("example")
}

class ViewController: UIViewController {

    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cancellable = NotificationCenter.Publisher(center: .default, name: .example, object: nil)
        .sink { notification in
            print(notification)
        }

        //post notification
        NotificationCenter.default.post(name: .example, object: nil)
    }
}
```

If you save the cancellable object as a stored property you can retain the subscription until you call the cancel method. Make sure you don't make extra retain cycles, so if you need self inside the sink block, always use aweak or unowned reference.

### URLSession

I'm not going to repeat myself here again, because I already made a complete tutorial about [how to use URLSession with the Combine framework](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/), so please click the link if you want to learn more about it.

That's it about built-in publishers, let's take a look at...

### Published variables

[Property Wrappers](https://nshipster.com/propertywrapper/) are a brand new feature available from Swift 5.1. Combine comes with one new wrapper called `@Published`, which can be used to attach a Publisher to a single property. If you mark the property as `@Published`, you can subscribe to value changes and you can also use these variables as bindings.

```swift
import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    @Published var labelValue: String? = "Click the button!"

    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cancellable = self.$labelValue.receive(on: DispatchQueue.main)
                                           .assign(to: \.text, on: self.textLabel)

    }

    @IBAction func actionButtonTouched(_ sender: UIButton) {
        self.labelValue = "Hello World!"
    }
}
```

By using the `$` sign and the assign function we can create a binding and subscribe to value changes, so if the labelValue property changes, it'll be assigned to the text property of the textLabel variable. In other words, the actual text of the label will be updated on the user interface. Also you only want to get updates on the main queue, since we're doing UI related stuff. You can use the receive operator for this.

### Custom publishers

Creating a custom publisher is not so hard that you might think, but honestly I never had to make one for myself yet. Still there are some really nice use-cases where building a custom publisher is the right way to go. [Antoine v.d. SwiftLee](https://x.com/twannl) has a great tutorial about [how to create a custom combine publisher](https://www.avanderlee.com/swift/custom-combine-publisher/) to extend UIKit, you should definitely check that out if you want to learn more about custom publishers.

### Subjects

A subject can be used to transfer values between publishers and subscribers.

```swift
let subject = PassthroughSubject<String, Never>()

let anyCancellable = subject
.sink { value in
    print(value)
}

// sending values to the subject
subject.send("Hello")

// subscribe a subject to a publisher
let publisher = Just("world!")
publisher.subscribe(subject)

anyCancellable.cancel()


// sending errors
enum SubjectError: LocalizedError {
    case unknown
}
let errorSubject = PassthroughSubject<String, Error>()
errorSubject.send(completion: .failure(SubjectError.unknown))
```

You can send values or errors to the subject manually or you can subscribe a publisher to a subject. They are extremely useful if you'd like to make a Combine-like interface for a traditional delegate pattern based API. Consider the following example as a very basic starting point, but I hope you'll get the idea. 💡

```swift
class LocationPublisher: NSObject {

    let subject = PassthroughSubject<[CLLocation], Error>()

    //...
}

extension LocationPublisher: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.subject.send(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.subject.send(completion: .failure(error))
    }
}
```

### Futures and promises

I already have [a tutorial for beginners about promises in Swift](https://theswiftdev.com/2019/05/28/promises-in-swift-for-beginners/), if you need to understand the reasoning behind these types, please read that article first.

Combine has it's own future / promise implementation, which is surprisingly well-made. I use them very often if I have an async callback block, I usually transform that function into a promisified version (returning a publisher), by using a future.

```swift
func asyncMethod(completion: ((String) -> Void)) {
    //...
}

func promisifiedAsyncMethod() -> AnyPublisher<String, Never> {
    Future<String, Never> { promise in
        asyncMethod { value in
            promise(.success(value))
        }
    }
    .eraseToAnyPublisher()
}
```

### Just

`Just` is made from a generic [result type](https://theswiftdev.com/2019/01/28/how-to-use-the-result-type-to-handle-errors-in-swift/) and a `Never` failure type. It just provides you a single value, then it will terminate. It's quite useful if you want to fallback to a default value, or you just want to return a value.

```swift
let just = Just<String>("just a value")

just.sink(receiveCompletion: { _ in

}) { value in
    print(value)
}
```

### Schedulers

You can add a delay to a publisher by using a scheduler, for example if you'd like to add a 1 second delay, you can use the following snippet:

```swift
return Future<String, Error> { promise in
    promise(.success("example"))
}
.delay(for: .init(1), scheduler: RunLoop.main)
.eraseToAnyPublisher()
```

### Error handling

As I mentioned before the `Never` type is indicates no errors, but what happens if a publisher returns an actual error? Well, you can catch that error, or you can transform the error type into something else by using the `mapError` operator.

```swift
// error handling in sink
errorPublisher
.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        break
    case .failure(let error):
        fatalError(error.localizedDescription)
    }
}, receiveValue: { value in
    print(value)
})


// mapError, catch
_ = Future<String, Error> { promise in
    promise(.failure(NSError(domain: "", code: 0, userInfo: nil)))
}
.mapError { error in
    //transform the error if needed
    return error
}
.catch { error in
    Just("fallback")
}
.sink(receiveCompletion: { _ in

}, receiveValue: { value in
    print(value)
})
```

Of course this is just the tip of the iceberg, you can assert errors and many more, but I hardly use them on a daily basis. Usually I handle my errors in the sink block.

### Debugging

You can use the `handleEvents` operator to observe emitted events, the other option is to put breakpoints into your chain. There are a few helper methods in order to do this, you should read this [article about debugging Combine](https://www.avanderlee.com/swift/combine-swift/) if you want to know more. 👍

```swift
// handle events
.handleEvents(receiveSubscription: { subscription in

}, receiveOutput: { output in

}, receiveCompletion: { completion in

}, receiveCancel: {

}, receiveRequest: { request in

})

// breakpoints
.breakpoint()

.breakpoint(receiveSubscription: { subscription in
    true
}, receiveOutput: { output in
    true
}, receiveCompletion: { completion in
    true
})

.breakpointOnError()
```

### Groups and dependencies

I have examples for both cases in my other [article about Combine & URLSession](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/), so please go and read that if you'd like to learn how to zip together two publishers.

## Conclusion

Combine is a really nice framework, you should definitively learn it eventually. It's also a good opportunity to refactor your legacy / callback-based code into a nice modern declarative one. You can simply transform all your old-school delegates into publishers by using subjects. Futures and promises can help you to move away from callback blocks and prefer publishers instead. There are plenty of [good resources about Combine](https://heckj.github.io/swiftui-notes/) around the web, also the official documentation is real good. 📖
