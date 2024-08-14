---
type: post
title: Easy multipart file upload for Swift
description: Let me show you how to create HTTP requests using multipart (form data) body without a third party library. Simple solution.
publication: 2023-01-17 16:20:00
tags: 
    - swift
authors:
    - tibor-bodecs
---

I believe that you've already heard about the famous multipart-data upload technique that everyone loves to upload files and submit form data, but if not, hopefully this article will help you a little bit to understand these things better.

Let's start with some theory. Don't worry, it's just one link, [about the multipart/form-data content type specification](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST). To quickly summarize it first I'd like to tell you a few words about how the HTTP layer works. In a nutshell, you send some data with some headers (think about it as a key-value user info object) to a given URL using a method and as a response you'll get back a status code, some headers and maybe some sort of response data too. 🥜

- HTTP request = Method + URL + Headers + Body (request data)
- HTTP response = Status code + Headers + Body (response data)

The request method & URL is pretty straightforward, the interesting part is when you specify the `Content-Type` HTTP header, in our case the `multipart/form-data;boundary="xxx"` value means, that we're going to send a request body using multiple parts and we're going to use the "xxx" boundary string as a separator between the parts. Oh, by the way each part can have it's own type and name, we'll use the `Content-Disposition: form-data; name="field1"` line to let the server know about these fields, before we actually send the actual content value.

That's more than enough theory for now, let me snow you how we can implement all of this using Swift 5. First of all, we would like to be able to append string values to a Data object, so we're going to extend [Data type](https://developer.apple.com/documentation/foundation/data) with an 'append string using encoding' method:

```swift
import Foundation

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
```

Next, we need something that can construct the HTTP multipart body data, for this purpose we're going to build a `MultipartRequest` object. We can set the boundary when we init this object and we're going to append the parts needed to construct the HTTP body data.

The private methods will help to assemble everything, we simply append string values to the private data object that holds our data structure. The public API only consists of two add functions that you can use to append a key-value based form field or an entire file using its data. 👍

```swift
public struct MultipartRequest {
    
    public let boundary: String
    
    private let separator: String = "\r\n"
    private var data: Data

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }
    
    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
}
```

The last remaining two public variables are helpers to easily get back the HTTP related content type header value using the proper boundary and the complete data object that you should to send to the server. Here's how you can construct the HTTP [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) using the multipart struct.

```swift
var multipart = MultipartRequest()
for field in [
    "firstName": "John",
    "lastName": "Doe"
] {
    multipart.add(key: field.key, value: field.value)
}

multipart.add(
    key: "file",
    fileName: "pic.jpg",
    fileMimeType: "image/png",
    fileData: "fake-image-data".data(using: .utf8)!
)

/// Create a regular HTTP URL request & use multipart components
let url = URL(string: "https://httpbin.org/post")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
request.httpBody = multipart.httpBody

/// Fire the request using URL sesson or anything else...
let (data, response) = try await URLSession.shared.data(for: request)

print((response as! HTTPURLResponse).statusCode)
print(String(data: data, encoding: .utf8)!)
```

As you can see it's relatively straightforward, you just add the form fields and the files that you want to upload, and get back the HTTP related values using the helper API. I hope this article will help you to simulate form submissions using multipart requests without hassle. 😊
