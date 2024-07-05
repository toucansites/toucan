---
slug: how-to-parse-json-in-swift-using-codable-protocol/
title: How to parse JSON in Swift using Codable protocol?
description: In this Swift tutorial, I'd like to give you an example about getting and parsing JSON data using URLSession and Codable protocol.
publication: 2018-01-29 16:20:00
tags: Swift, JSON
---

## Dependencies

First of all just a few words about dependencies. From Swift 4 you don't need any dependency to [parse JSON data](https://benscheirman.com/2017/06/swift-json/), because there are [built-in protocols](https://developer.apple.com/documentation/swift/codable) to take care of everything. If you are still using some kind of 3rd-party you should definitely ditch it for the sake of simplicity. By the way before you add any external dependency into your project, please think twice. 🤔

## Networking

If your task is simply to load some kind of JSON document through HTTP from around the web, - surprise - you won't need [Alamofire](https://github.com/Alamofire/Alamofire) at all. You can use the built-in [URLSession](https://developer.apple.com/documentation/foundation/urlsession) class to make the request, and get back everything that you'll need. The Foundation networking stack is already a complex and very useful stack, don't make things even more complicated with extra layers.

## JSON parsing

Now, after the short intro, let's dive in and get some real fake JSON data from the [JSONPlaceholder](https://jsonplaceholder.typicode.com/) web service. I'm going to place the whole thing right here, you can select it, copy and paste into a Swift playground file.

```swift
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Post: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case userIdentifier = "userId"
    }

    let id: Int
    let title: String
    let body: String
    let userIdentifier: Int
}

let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("Error: \(error.localizedDescription)")
        PlaygroundPage.current.finishExecution()
    }
    guard 
        let httpResponse = response as? HTTPURLResponse, 
        httpResponse.statusCode == 200 
    else {
        print("Error: invalid HTTP response code")
        PlaygroundPage.current.finishExecution()
    }
    guard let data = data else {
        print("Error: missing data")
        PlaygroundPage.current.finishExecution()
    }

    // feel free to uncomment this for debugging data
    // print(String(data: data, encoding: .utf8))

    do {
        let decoder = JSONDecoder()
        let posts = try decoder.decode([Post].self, from: data)

        print(posts.map { $0.title })
        PlaygroundPage.current.finishExecution()
    }
    catch {
        print("Error: \(error.localizedDescription)")
        PlaygroundPage.current.finishExecution()
    }
}.resume()
```

As you can see downloading and [parsing JSON](https://developer.apple.com/swift/blog/?id=37) from the web is a really easy task. This whole code snippet is around 50 lines of code. Of course it's just a proof of concept, but it works and you don't need any dependency. It's pure Swift and [Foundation](https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift).

> NOTE: To [save](http://roadfiresoftware.com/2015/08/save-your-future-self-from-broken-apps/) some typing, you can also generate the final objects directly from the JSON structure with these [amazing Xcode extensions](https://gitlab.com/theswiftdev/awesome-xcode-extensions).

The `Codable` protocol - which is actually a compound `typealias` from `Encodable & Decodable` protocols - makes the process of parsing JSON data in Swift magical. 💫

