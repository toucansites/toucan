---
slug: async-http-client-by-example
title: AsyncHTTPClient by example
description: This article offers practical examples to introduce the Swift AsyncHTTPClient library.
publication: 2024-04-03 18:30:00
tags:
 - swift
 - http
authors:
 - tibor-bodecs
---

Swift [AsyncHTTPClient](https://github.com/swift-server/async-http-client) is an HTTP client library built on top of SwiftNIO. It provides a solid solution for efficiently managing HTTP requests by leveraging the Swift Concurrency model, thus simplifying networking tasks for developers.

The library's asynchronous and non-blocking request methods ensure that network operations do not hinder the responsiveness of the application. Additionally, the library offers TLS support, automatic HTTP/2 over HTTPS and several other convenient features.
 
The AsyncHTTPClient library is a comprehensive tool for seamless HTTP communication for server-side Swift applications. Throughout this article, we'll delve into practical [examples](https://github.com/swift-on-server/async-http-client-by-example-sample) to showcase the capabilities of this library.


## Setting up & configuring AsyncHTTPClient

Starting with this article, you can utilize a foundational code example as a starting point for integrating the Swift AsyncHTTPClient library into your Swift projects.

Now, open the `Package.swift` file in your project directory and add AsyncHTTPClient as a dependency:

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "async-http-client-by-example-sample",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
    ],
    targets: [
        .executableTarget(
            name: "async-http-client-by-example-sample",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
    ]
)
```

In the `main.swift` file, import the AsyncHTTPClient library and initialize an HTTPClient instance for future use:

```swift
import AsyncHTTPClient

struct Entrypoint {
    
    static func main() async throws {

        let httpClient = HTTPClient(
            // 1.
            eventLoopGroupProvider: .singleton,
            // 2.
            configuration: .init(
                // 3.
                redirectConfiguration: .follow(
                    max: 3,
                    allowCycles: false
                ),
                // 4.
                timeout: .init(
                    connect: .init(.seconds(1)),
                    read: .seconds(1),
                    write: .seconds(1)
                )
            )
        )
        
        do {
            // perform HTTP operations
        }
        catch {
            print("\(error)")
        }

        // 5.
        try await httpClient.shutdown()
    }
}
```

1. Specify the event loop group provider as `.singleton`, which manages the underlying event loops for asynchronous operations.
2. The configuration parameter is set, defining various aspects of the HTTP client's behavior.
3. `redirectConfiguration` is specified to follow redirects up to a maximum of 3 times and disallow redirect cycles.
4. Set timeouts for different phases of the HTTP request process, such as connection establishment, reading, and writing.
5. Cleanup by calling the `shutdown()` method on the HTTPClient instance.

Please be aware that it is essential to properly terminate the HTTP client after executing requests. Forgetting to invoke the `shutdown()` method may cause the library to issue a warning about a potential memory leak when compiling the application in debug mode.


## Performing HTTP requests

An HTTP request includes the method, a URL, headers providing supplementary details, and optionally, a body containing data transmitted to the server. Conversely, HTTP responses contain a status code, headers providing further details, and a body containing the actual content of the response. Together, these components facilitate the exchange of data between clients and servers over the HTTP protocol.

Below is an illustration of how to employ the HTTP request and response objects using the AsyncHTTPClient library in Swift:

```swift
let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

do {
    // 1.
    var request = HTTPClientRequest(url: "https://httpbin.org/post")
    // 2.
    request.method = .POST
    // 3.
    request.headers.add(name: "User-Agent", value: "Swift AsyncHTTPClient")
    // 4.
    request.body = .bytes(ByteBuffer(string: "Some data"))
    
    // 5.
    let response = try await httpClient.execute(request, timeout: .seconds(5))
    
    // 6.
    if response.status == .ok {
        // 7.
        let contentType = response.headers.first(name: "content-type")

        // 8.
        let contentLength = response.headers.first(
            name: "content-length"
        ).flatMap(Int.init)

        // 9.
        let buffer = try await response.body.collect(upTo: 1024 * 1024)

        // 10.
        let rawResponseBody = buffer.getString(
            at: 0,
            length: buffer.readableBytes
        )
    }
}
catch {
    print("\(error)")
}

try await httpClient.shutdown()
```

1. A new HTTP request object is created targeting the specified URL.
2. The HTTP request method is set to POST.
3. A `user-agent` header with the value `Swift AsyncHTTPClient` is added to the request.
4. The request body is set to contain the string "Some data".
5. The request is executed with a custom timeout of 5 seconds.
6. If the response status is `.ok` (`200`), further processing is performed.
7. The `content-type` of the response is retrieved from the headers.
8. The `content-length` of the response is obtained from the headers, as an `Int` value.
9. The response body is collected asynchronously, up to a maximum of 1 MiB in size.
10. The raw response body is retrieved as a string for further processing.

Any errors encountered during the execution of the request are caught and printed. If the response body exceeds the 1 MiB limit, a `NIOTooManyBytesError` error will occur.

Finally, the HTTP client is shut down to release associated resources.


## JSON requests

JSON requests involve sending and receiving data formatted in JSON to a server. REST API is a style for building networked apps where resources are managed using regular HTTP methods, and the data is encoded and decoded using the JSON format.

The following code snippet demonstrates how to encode request bodies and decode response bodies using JSON objects:

```swift
// 1.
struct Input: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

struct Output: Codable {
    let json: Input
}


let httpClient = HTTPClient(
    eventLoopGroupProvider: .singleton
)
do {
    // 2.
    var request = HTTPClientRequest(
        url: "https://httpbin.org/post"
    )
    request.method = .POST
    request.headers.add(name: "content-type", value: "application/json")
    
    // 4.
    let input = Input(
        id: 1,
        title: "foo",
        completed: false
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(input)
    let buffer = ByteBuffer(bytes: data)
    request.body = .bytes(buffer)
    
    let response = try await httpClient.execute(
        request,
        timeout: .seconds(5)
    )
    
    if response.status == .ok {
        // 5.
        if let contentType = response.headers.first(
            name: "content-type"
        ), contentType.contains("application/json") {
            // 6.
            var buffer: ByteBuffer = .init()
            for try await var chunk in response.body {
                buffer.writeBuffer(&chunk)
            }
            
            // 7.
            let decoder = JSONDecoder()
            if let data = buffer.getData(at: 0, length: buffer.readableBytes) {
                let output = try decoder.decode(Output.self, from: data)
                print(output.json.title)
            }
        }

    }
    else {
        print("Invalid status code: \(response.status)")
    }
}
catch {
    print("\(error)")
}

try await httpClient.shutdown()
```

1. Two `Codable` structures are defined: `Input` for the data to be sent and `Output` for receiving the JSON response.
2. An HTTP request is created using a POST method and a `content-type: application/json` header.
4. The `Input` data is encoded into JSON data using a `ByteBuffer` and set as the request body.
5. If the response status is ok and the content type is JSON, the response body is processed.
6. The response body chunks are collected asynchronously and concatenated into a single buffer.
7. The buffer containing the JSON data response is decoded as an `Output` structure using.

The code snippet above demonstrates how to use Swift's Codable protocol to handle JSON data in HTTP communication. It defines structures for input and output data, sends a POST request with JSON payload, and processes the response by decoding JSON into a designated output structure.

## File downloads

The AsyncHTTPClient library provides support for file downloads using the `FileDownloadDelegate`. This feature enables asynchronous streaming of downloaded data while simultaneously reporting the download progress, as demonstrated in the following example:

```swift
let httpClient = HTTPClient(
    eventLoopGroupProvider: .singleton
)

do {
    // 1.
    let delegate = try FileDownloadDelegate(
        // 2.
        path: NSTemporaryDirectory() + "600x400.png",
        // 3.
        reportProgress: {
            if let totalBytes = $0.totalBytes {
                print("Total: \(totalBytes).")
            }
            print("Downloaded: \($0.receivedBytes).")
        }
    )
    
    // 4.
    let fileDownloadResponse = try await httpClient.execute(
        request: .init(
            url: "https://placehold.co/600x400.png"
        ),
        delegate: delegate
    ).futureResult.get()
    
    print(fileDownloadResponse)
}
catch {
    print("\(error)")
}

try await httpClient.shutdown()
```

1. A `FileDownloadDelegate` is created to manage file downloads. 
2. Specify the download destination path.
3. A progress reporting function is provided to monitor the download progress.
4. The file download request is executed using the request URL and the delegate.

Running this example will display the download progress, indicating the received bytes and the total bytes, with the same information also available within the `fileDownloadResponse` object. 

There are many more configuration options available for the Swift AsyncHTTPClient library. It is also possible to create custom delegate objects; additional useful examples and code snippets are provided in the project's [README on GitHub](https://github.com/swift-server/async-http-client).

