---
type: post
slug: how-to-download-files-with-urlsession-using-combine-publishers-and-subscribers
title: How to download files with URLSession using Combine Publishers and Subscribers?
description: Learn how to load a remote image into an UIImageView asynchronously using URLSessionDownloadTask and the Combine framework in Swift.
publication: 2020-01-28 16:20:00
tags: URLSession, Combine
authors:
  - tibor-bodecs
---

## A simple image downloader

Downloading a resource from an URL seems like a trivial task, but is it really that easy? Well, it depends. If you have to [download and parse a JSON file](https://theswiftdev.com/2018/01/29/how-to-parse-json-in-swift-using-codable-protocol/) which is just a few KB, then you can go with the classical way or you can use the new `dataTaskPublisher` method on the [URLSession object from the Combine framework](https://theswiftdev.com/2019/08/15/urlsession-and-the-combine-framework/).

### Bad practices ⚠️

There are some quick & dirty approaches that you can use to get some smaller data from the internet. The problem with these methods is that you have to deal a lot with threads and queues. Fortunately [using the Dispatch framework](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/) helps a lot, so you can turn your blocking functions into non-blocking ones. 🚧

```swift
let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

// Synchronous download using Data & String
do {
    // get the content as String synchronously
    let content = try String(contentsOf: url)
    print(content)

    // get the content of the url as Data synchronously
    let data = try Data(contentsOf: url)
}
catch {
    print(error.localizedDescription)
}


// Turning sync to async
DispatchQueue.global().async { [weak self] in
    //this is happening on a background thread
    do {
        let content = try String(contentsOf: url)
        DispatchQueue.main.async {
            //this is happening on the main thread
            print(content)
        }
    }
    catch {
        print(error.localizedDescription)
    }
}
```

Apple made an important note on their [official Data documentation](https://developer.apple.com/documentation/foundation/nsdata/1547245-datawithcontentsofurl), that you should NOT use these methods for downloading non-file URLs, but still people are teaching / using these bad practices, but why? 😥

> Don't use this synchronous method to request network-based URLs.

My advice here: always use the [URLSession](https://developer.apple.com/documentation/foundation/urlsession) to perform network related data-transfers. Creating a data task is simple, it's an asynchronous operation by default, the callback runs on a background thread, so nothing will be blocked by default. Modern networking APIs are real good on iOS, in 99% of the cases you won't need [Alamofire](https://github.com/alamofire/alamofire) anymore for these kind of tasks. Say no to dependencies! 🚫

```swift
// The best approach without using Combine
URLSession.shared.dataTask(with: url) { data, response, error in
    // do your stuff here...
    DispatchQueue.main.async {
        // do something on the main queue
    }
}.resume()
```

It's also worth to mention if you need to use a different HTTP method (other than GET), send special headers (credentials, accept policies, etc.) or provide extra data in the body, you need to construct an `URLRequest` object first. You can only send these custom requests using the `URLSession` APIs.

> NOTE: On Apple platforms you are not allowed to use the insecure HTTP protocol anymore. If you want to reach a URL without the secure layer (HTTPS) you have to disable [App Transport Security](https://developer.apple.com/security/).

## The problem with data tasks


What about big files, such as images? Let me show you a few tutorials before we dive in:

- [UIImageView, Load UIImage from remote URL](https://stackoverflow.com/questions/47030822/uiimageview-load-uiimage-from-remote-url)
- [Loading an image into UIImage asynchronously](https://stackoverflow.com/questions/9786018/loading-an-image-into-uiimage-asynchronously)
- [How to load a remote image URL into UIImageView](https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview)
- [How To Downloading Image from server URL on Swift 4?](https://iosdevcenters.blogspot.com/2018/06/how-to-downloading-image-from-server.html)
- [Downloading UIImage via AlamofireImage?](https://stackoverflow.com/questions/46199203/downloading-uiimage-via-alamofireimage)
- [Loading images from URL in Swift](https://medium.com/swlh/loading-images-from-url-in-swift-2bf8b9db266)
- [How do I load an image by URL on iOS device using Swift?](https://www.tutorialspoint.com/how-do-i-load-an-image-by-url-on-ios-device-using-swift)
- [UIImageView and UIImage. Load Image From Remote URL.](http://swiftdeveloperblog.com/code-examples/uiimageview-and-uiimage-load-image-from-remote-url/)
- [Asynchronously Loading Images in SwiftUI](https://www.youtube.com/watch?v=DnZvlanmpNE)
- [How to load remote image in SwiftUI](https://onmyway133.github.io/blog/How-to-load-remote-image-in-SwiftUI/)
- [Loading/Downloading image from URL on Swift](https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift)

With all due respect, I think all of these links above are really bad examples of loading remote images. Sure they do the job, they're also very easy to implement, but maybe we should cover the whole story... 🤐

> For small interactions with remote servers, you can use the URLSessionDataTask class to receive response data into memory (as opposed to using the URLSessionDownloadTask class, which stores the data directly to the file system). A data task is ideal for uses like calling a web service endpoint.

What is difference between `URLSessionDataTask` vs `URLSessionDownloadTask`?

If we [read the docs carefully](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory#overview), it becomes clear that data task is NOT the right candidate for downloading big assets. That class is designed to request only smaller objects, since the underlying data is going to be loaded into memory. On the other hand the download task saves the content of the response on the disk (instead of memory) and you will receive a local file URL instead of a Data object. Turns out that moving from data tasks to download tasks will have a HUGE impact on your memory consumption. I have some numbers. 📈

I downloaded the [following image file](https://images.unsplash.com/photo-1554773228-1f38662139db) (6000x4000px 💾 13,1MB) using both methods. I made a brand new storyboard based Swift 5.1 project. The basic RAM usage was ~52MB, when I fetched the image using the `URLSessionDataTask` class, the memory usage jumped to ~82MB. Turning the data task into a download task only increased the base memory size by ~4MB (to a total ~56MB), which is a significant improvement.

```swift
let url = URL(string: "https://images.unsplash.com/photo-1554773228-1f38662139db")!

// data task
URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
    guard let data = data else {
        return
    }
    DispatchQueue.main.async {
        self?.imageView.image = UIImage(data: data)
    }
}.resume()


// download task
URLSession.shared.downloadTask(with: url) { [weak self] url, response, error in
    guard
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
        let url = url
    else {
        return
    }

    do {
        let file = cache.appendingPathComponent("\(UUID().uuidString).jpg")
        try FileManager.default.moveItem(atPath: url.path,
                                         toPath: file.path)
        DispatchQueue.main.async {
            self?.imageView.image = UIImage(contentsOfFile: file.path)
        }
    }
    catch {
        print(error.localizedDescription)
    }
}.resume()
```

When I rendered the image using an `UIImageView` the memory footprint was ~118MB (total: ~170MB) for the data task, and ~93MB (total: ~145MB) for the download task. Here's a quick summary:

- Data task: ~30MB
- Data task with rendering: ~118MB
- Download task: ~4MB
- Download task with rendering: ~93MB

I hope you get my point. Please don't forget that the Foundation networking layer comes with four types of session tasks. You should always use the right one that fits the job. We can say that the [difference between URLSessionDataTask vs URLSessionDownloadTask](https://stackoverflow.com/questions/20604910/what-is-difference-between-nsurlsessiondatatask-vs-nsurlsessiondownloadtask) is: a lot of memory (in this case about 25MB of RAM).

> You can use [Kingfisher](https://github.com/onevcat/Kingfisher) or [SDWebImage](https://github.com/SDWebImage/SDWebImage) to download & manipulate remote images..

You might say that this is an edge case since most of the images (even HD ones) are maximum a few hundred kilobytes. Still, my takeaway here is that we can do better, and we should always do so if possible. 🤓

## Downloading images using Combine

WWDC19, Apple announced the Combine framework, which brings us a few new extensions for some Foundation objects. Modern times require modern APIs, right? If you are already familiar with the new SDK that's good, but if you don't know what the heck is this declarative functional reactive madness, you should read my [comprehensive tutorial about the Combine framework](https://theswiftdev.com/2019/10/31/the-ultimate-combine-framework-tutorial-in-swift/).

The first version of Combine shipped with a nice `dataTaskPublisher` extension method for the `URLSession` class. Wait, where are the others? No download task publisher? What should we do now? 🤔

### How to write a custom Publisher?

[SwiftLee](https://x.com/twannl) has a nice [tutorial](https://www.avanderlee.com/swift/custom-combine-publisher/) about Combine that can help you a lot with UIControl events. Another great read (even better than the first one) by [Donny Wals](https://x.com/donnywals) is about [understanding Publishers and Subscribers](https://www.donnywals.com/understanding-combines-publishers-and-subscribers/). It's a really well-written article, you should definitely check this one, I highly recommend it. 🤘🏻

Now let's start creating our own `DownloadTaskPublisher`. If you command + click on the `dataTaskPublisher` method in Xcode, you can see the corresponding interface. There is also a `DataTaskPublisher` struct, right below. Based on that template we can create our own extension. There are two variants of the same data task method, we'll replicate this behavior. The other thing we need is a `DownloadTaskPublisher` struct, I'll show you the Swift code first, then we'll discuss the implementation details.

```swift
extension URLSession {

    public func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
        self.downloadTaskPublisher(for: .init(url: url))
    }

    public func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
        .init(request: request, session: self)
    }

    public struct DownloadTaskPublisher: Publisher {

        public typealias Output = (url: URL, response: URLResponse)
        public typealias Failure = URLError

        public let request: URLRequest
        public let session: URLSession

        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }

        public func receive<S>(subscriber: S) where S: Subscriber,
            DownloadTaskPublisher.Failure == S.Failure,
            DownloadTaskPublisher.Output == S.Input
        {
            let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
            subscriber.receive(subscription: subscription)
        }
    }
}
```

A Publisher can send an Output or a Failure message to an attached subscriber. You have to create a new typealias for each type, since they both are generic constraints defined on the protocol level. Next, we'll store the session and the request objects for later use. The last part of the protocol conformance is that you have to implement the `receive<S>(subscriber: S)` generic method. This method is responsible for attaching a new subscriber through a subscription object. Ummm... what? 🤨

> A publisher/subscriber relationship in Combine is solidified in a third object, the subscription. When a subscriber is created and subscribes to a publisher, the publisher will create a subscription object and it passes a reference to the subscription to the subscriber. The subscriber will then request a number of values from the subscription in order to begin receiving those values.

A `Publisher` and a `Subscriber` is connected through a `Subscription`. The Publisher only creates the Subscription and passes it to the subscriber. The Subscription contains the logic that'll fetch new data for the Subscriber. The Subscriber receives the Subscription, the values and the completion (success or failure).

- The Subscriber subscribes to a Publisher
- The Publisher creates a Subscription
- The Publisher gives this Subscription to the Subscriber
- The Subscriber demands some values from the Subscription
- The Subscription tries to collect the values (success or failure)
- The Subscription sends the values to the Subscriber based on the demand policy
- The Subscription sends a Failure completion to the Subscriber if an error happens
- The Subscription sends completion if no more values are available

### How to make a custom Subscription?

Ok, time to create our subscription for our little Combine based downloader, I think that you will understand the relationship between these three objects if we put together the final pieces of the code. 🧩

```swift
extension URLSession {

    final class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
        SubscriberType.Input == (url: URL, response: URLResponse),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionDownloadTask!

        init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.task = self.session.downloadTask(with: request) { [weak self] url, response, error in
                if let error = error as? URLError {
                    self?.subscriber?.receive(completion: .failure(error))
                    return
                }
                guard let response = response else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
                    return
                }
                guard let url = url else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
                    return
                }
                do {
                    let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                    let fileUrl = cacheDir.appendingPathComponent((UUID().uuidString))
                    try FileManager.default.moveItem(atPath: url.path, toPath: fileUrl.path)
                    _ = self?.subscriber?.receive((url: fileUrl, response: response))
                    self?.subscriber?.receive(completion: .finished)
                }
                catch {
                    self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                }
            }
            self.task.resume()
        }

        func cancel() {
            self.task.cancel()
        }
    }
}
```

A Subscriber has an Input and a Failure type. A subscriber can only subscribe to a publisher with the same types. The Publisher's Output & Failure types have to be identical with the Subscription Input and Failure types. This time we can't go with an associatedType, but we have to create a generic value that has a constraint on these requirements by using a where clause. The reason behind this is that we don't know what kind of Subscriber will subscribe to this subscription. It can be either a class `A` or `B`, who knows... 🤷‍♂️

We have to pass a few properties in the init method, store them as instance variables (be careful with classes, you should use weak if applicable). Lastly we implement the value request method, by respecting the demand policy. The [demand](https://developer.apple.com/documentation/combine/subscribers/demand) is just a number. It tells us how many values can we send back to the subscriber at maximum. In our case we'll have max 1 value, so if the demand is greater than zero, we're good to go. You can send messages to the subscriber by calling various receive methods on it.

You have to manually send the completion event with the `.finished` or the `.failure(T)` value. Also we have to move the downloaded temporary file before the completion block returns otherwise we'll completely lose it. This time I'm going to simply move the file to the application cache directory. As a gratis cancellation is a great way to end battery draining operations. You just need to implement a custom `cancel()` method. In our case, we can call the same method on the underlying `URLSessionDownloadTask`.

That's it. We're ready with the custom publisher & subscription. Wanna try them out?

### How to create a custom Subscriber?

Let's say that there are 4 kinds of subscriptions. You can use the `.sink` or the `.assign` method to make a new subscription, there is also a thing called Subject, which can be subscribed for publisher events or you can build your very own `Subscriber` object. If you choose this path you can use the `.subscribe` method to associate the publisher and the subscriber. You can also subscribe a subject.

```swift
final class DownloadTaskSubscriber: Subscriber {
    typealias Input = (url: URL, response: URLResponse)
    typealias Failure = URLError

    var subscription: Subscription?

    func receive(subscription: Subscription) {
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        print("Subscriber value \(input.url)")
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        print("Subscriber completion \(completion)")
        self.subscription?.cancel()
        self.subscription = nil
    }
}
```

The subscriber above will simply print out the incoming values. We have to be extremely careful with memory management. The received subscription will be stored as a strong property, but when the publisher sends a completion event we should cancel the subscription and remove the reference.

When a value arrives we have to return a demand. In our case it really doesn't matter since we'll only have 1 incoming value, but if you'd like to limit your publisher, you can use e.g. `.max(1)` as a demand.

Here is a quick sample code for all the Combine subscriber types written in Swift 5.1:

```swift
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    static let url = URL(string: "https://images.unsplash.com/photo-1554773228-1f38662139db")!

    static var defaultValue: (url: URL, response: URLResponse) = {
        let fallbackUrl = URL(fileURLWithPath: "fallback-image-path")
        let fallbackResponse = URLResponse(url: fallbackUrl, mimeType: "foo", expectedContentLength: 1, textEncodingName: "bar")
        return (url: fallbackUrl, response: fallbackResponse)
    }()

    @Published var value: (url: URL, response: URLResponse) = ViewController.defaultValue
    let subject = PassthroughSubject<(url: URL, response: URLResponse), URLError>()
    let subscriber = DownloadTaskSubscriber()

    var sinkOperation: AnyCancellable?

    var assignOperation: AnyCancellable?
    var assignSinkOperation: AnyCancellable?

    var subjectOperation: AnyCancellable?
    var subjectSinkOperation: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sinkExample()
        self.assignExample()
        self.subjectExample()
        self.subscriberExample()
    }

    func sinkExample() {
        self.sinkOperation = URLSession.shared
            .downloadTaskPublisher(for: ViewController.url)
            .sink(receiveCompletion: { completion in
                print("Sink completion: \(completion)")
            }) { value in
                print("Sink value: \(value.url)")
            }
    }

    func assignExample() {
        self.assignSinkOperation = self.$value.sink { value in
            print("Assign value: \(value.url)")
        }

        self.assignOperation = URLSession.shared
            .downloadTaskPublisher(for: ViewController.url)
            .replaceError(with: ViewController.defaultValue)
            .assign(to: \.value, on: self)
    }

    func subjectExample() {
        self.subjectSinkOperation = self.subject.sink(receiveCompletion: { completion in
            print("Subject completion: \(completion)")
        }) { value in
            print("Subject value: \(value.url)")
        }

        self.subjectOperation = URLSession.shared
            .downloadTaskPublisher(for: ViewController.url)
            .subscribe(self.subject)
    }

    func subscriberExample() {
        URLSession.shared
            .downloadTaskPublisher(for: ViewController.url)
            .subscribe(DownloadTaskSubscriber())
    }
}
```

This is really nice. We can download a file using our custom Combine based URLSession extension.

> NOTE: Don't forget to store the AnyCancellable pointer otherwise the entire Combine operation will be deallocated way before you could receive anything from the chain / stream.

## Putting everything together

I promised a working image downloader, so let me explain the whole flow. We have a custom download task publisher that'll save our remove image file locally and returns a tuple with the file URL and the response. ✅

Next I'm going to simply assume that there was a valid image behind the URL, and the server returned a valid response, so I'm going to map the publisher's output to an `UIImage` object. I'm also going to replace any kind of error with a fallback image value. In a real-world application, you should always do some extra checkings on the `URLResponse` object, but for the sake of simplicity I'll skip that for now.

The last thing is to update our image view with the returned image. Since this is a UI task it should happen on the main thread, so we have to use the `receive(on:)` operation to switch context. If you want to learn more about [schedulers in the Combine framework](https://www.vadimbulavin.com/understanding-schedulers-in-swift-combine-framework/) you should read [Vadim Bulavin's article](https://x.com/v8tr). It's a gem. 💎

> WARN: If you are not receiving values on certain appleOS versions, that's might because there was a change in Combine around December, 2019. You should check these links: [link1](https://forums.swift.org/t/combine-receive-on-runloop-main-loses-sent-value-how-can-i-make-it-work/28631/47), [link2](https://heckj.github.io/swiftui-notes/#coreconcepts-lifecycle)

Anyway, here's the final Swift code for a possible image download operation, simple & declarative. 👍

```swift
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var operation: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://images.unsplash.com/photo-1554773228-1f38662139db")!

        self.operation = URLSession.shared
            .downloadTaskPublisher(for: url)
            .map { UIImage(contentsOfFile: $0.url.path)! }
            .replaceError(with: UIImage(named: "fallback"))
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self.imageView)
    }
}
```

Finally, we can display our image. Ouch, but wait... there is still room for improvements. What about [caching](https://www.appsdissected.com/caching-custom-combine-operator-2-cache-method-generics/)? Plus a 6000x4000px picture is quite huge for a small display, shouldn't we [resize / scale the image](https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift) first? What happens if I want to use the image in a list, shouldn't I cancel the download tasks when the user scrolls? 😳

Maybe I'll write about these issues in an upcoming tutorial, but I think this is the point where I should end this article. Feel free to play around with my solution and please share your ideas & thoughts with me on Twitter.
