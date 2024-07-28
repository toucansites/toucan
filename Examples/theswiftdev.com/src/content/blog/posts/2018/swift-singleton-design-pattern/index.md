---
type: post
slug: swift-singleton-design-pattern
title: Swift singleton design pattern
description: Singleton is the most criticized design pattern of all time. Learn the proper way of using Swift singleton classes inside iOS projects.
publication: 2018-05-22 16:20:00
tags: 
    - design-pattern
authors:
    - tibor-bodecs
---

Everyone is [bullying](https://www.swiftbysundell.com/posts/avoiding-singletons-in-swift) on the poor singleton pattern, most of the people call it anti-pattern. But what exactly is a singleton class and why is it so bad?


## What is a singleton?

It's a very popular and commonly adopted pattern because of simplicity. A singleton class can only have exactly one instance through the entire application lifecycle. That single instance is only accessible through a static property and the initialized object is usally shared globally. It's like a global variable. 🌏

### Global variables and states

Singletons have bad reputation because they share global mutable states. The global keyword is always feared even in the circle of experienced developers. Global states & variables are the hotbed of side effects. Global variables can be accessed from anywhere of your program so your classes that use them will become stateful, unsecure, tight coupled and hard to debug. It's not a good practice to share states alongside objects through this way for obvious reasons. 🤮

### Side effects

You should scope and isolate your variables as much as you can and minimize the statefullness of your code. This will eliminate side effects, make your code more secure to use. Consider the following example:

```swift
var global = 0

// method is written by someone else
func square(_ x: Int) -> Int {
    global = x
    return x * x
}

global = 1;
var result = square(5)
result += global //we assume that global is 1
print(result) //wtf 30 it should be 26
```

The square method is written by someone else, who wanted to store the input in the same global variable for some reason. Now when you call that function you won't be avare of this, until you look at his code. Imagine this kind of issues inside of a project with lots of oop classes written by multiple code authors... good luck with the army of BUGS! 🐛🐛🐛

### The secret life of a singleton object

Singletons are created once and live forever, they work almost exactly like global variables and that's why you have to be extremely careful with them. You should only manage those states with singletons that lasts for the complete lifecycle of the app. For example user-specific sessions are usually bad practices and you should rethink your design. Also Swift is not thread safe by default, so if you are working with singletons you have to be prepared for multi-threading issues as well. But if they are so problematic, shouldn't we simply [avoid](https://www.objc.io/issues/13-architecture/singletons/) them entirely? The answer is no. 🚫


## When to use a singleton class?

For example UIApplication is most likely a singleton because there should be only one application instance, and it should live until you shut it down. That makes just the perfect example for a singleton. Another use case can be a Logger class. It's safe to use a singleton because your application won't behave any different if a logger is turned on or not. Noone else will own or manage the logger and you'll only pass information into the logger, so states can't be messed up. Conclusion: a console or a logger class is quite an acceptable scenario for the usage of the singleton pattern. 👏


```swift
Console.default.notice("Hello I'm a singleton!")
```

There are a lots of "singletonish" (not everything is a true singleton object) use cases in Apple frameworks, here is a short list, so you can have a little inspiration:

    + HTTPCookieStorage.shared
    + URLCredentialStorage.shared
    + URLSessionConfiguration.default
    + URLSession.shared
    + FileManager.default
    + Bundle.main
    + UserDefaults.standard
    + NotificationCenter.default
    + UIScreen.main
    + UIDevice.current
    + UIApplication.shared
    + MPMusicPlayerController.systemMusicPlayer
    + GKLocalPlayer.localPlayer()
    + SKPaymentQueue.default()
    + WCSession.default
    + CKContainer.default()
    + etc.

I've seen lots of manager classes implemented as singletons, such as network, location or core data managers, but those objects usually shouldn't be singletons, simply because it can be more than one of them. 💩

Singleton pattern can be very useful, but it should be used with caution

If you want to turn something into a singleton, ask yourself these questions:

Will anything else own, manage or be responsible for it?
Is there going to be exactly one instance?

- Will it be a global state variable?
- Should I really use a globally shared object?
- Should live through the whole app lifecycle?
- Is there any alternatives for it?

If the answers is clearly a yes for everything above, then you can "safely" use a singleton or a global variable to store your data. 🎉🎉🎉


## How to create a singleton in Swift?

It's really easy to make a singleton object in Swift, but please always think twice and consider alternatives before you apply this design pattern.

```swift
class Singleton {

    static let shared = Singleton()

    private init() {
        // don't forget to make this private
    }
}
let singleton = Singleton.shared
```

Nowadays I'm always creating one specific singleton object, that's called App. This way I can hook up every application related global state properties into that one singleton. The naming convention also helps me to reevaluate what goes into it. 💡

## How to eliminate singletons?

If there is other way you should go with that in ~90% of the cases. The most common alternative solution for singletons is dependency injection. First you should abstract the singleton methods into a protocol, then you can use the singleton as the default implementation if it's still needed. Now you can inject the singleton or a [refactored object](https://www.jessesquires.com/blog/refactoring-singletons-in-swift/) into the right place. This way your code can be [tested](https://www.swiftbysundell.com/posts/testing-swift-code-that-uses-system-singletons-in-3-easy-steps) with mocked objects of the protocol, even ignoring the singleton itself. 😎

```swift
typealias DataCompletionBlock = (Data?) -> Void

// 1. abstract away the required functions
protocol Session {
    func make(request: URLRequest, completionHandler: @escaping DataCompletionBlock)
}

// 2. make your "singleton" conform to the protocol
extension URLSession: Session {

    func make(request: URLRequest, completionHandler: @escaping DataCompletionBlock) {
        let task = self.dataTask(with: request) { data, _, _ in
            completionHandler(data)
        }
        task.resume()
    }
}

class ApiService {

    var session: Session

    // 3. using dependency injection with the "singleton" object
    init(session: Session = URLSession.shared) {
        self.session = session
    }

    func load(_ request: URLRequest, completionHandler: @escaping DataCompletionBlock) {
        self.session.make(request: request, completionHandler: completionHandler)
    }
}

// 4. create mock object

class MockedSession: Session {

    func make(request: URLRequest, completionHandler: @escaping DataCompletionBlock) {
        completionHandler("Mocked data response".data(using: .utf8))
    }
}

// 5. write your tests
func test() {
    let api = ApiService(session: MockedSession())
    let request = URLRequest(url: URL(string: "https://localhost/")!)
    api.load(request) { data in
        print(String(data: data!, encoding: .utf8)!)
    }
}
test()
```

As you can see the singleton pattern is very easy to implement, but it's really hard to make a decision about it's application forms. I'm not saying that it's an anti-pattern, because it's clearly not, but take care if you are planning to deal with singletons. 😉



